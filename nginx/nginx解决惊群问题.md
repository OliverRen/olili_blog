---
title: nginx解决惊群问题
---

[toc]

### 惊群(thundering herd)问题的产生
在建立连接的时候，Nginx处于充分发挥多核CPU架构性能的考虑，使用了多个worker子进程监听相同端口的设计，这样多个子进程在accept建立新连接时会有争抢，这会带来著名的“惊群”问题，子进程数量越多越明显，这会造成系统性能的下降。

一般情况下，有多少CPU核心就有配置多少个worker子进程。假设现在没有用户连入服务器，某一时刻恰好所有的子进程都休眠且等待新连接的系统调用（如epoll_wait），这时有一个用户向服务器发起了连接，内核在收到TCP的SYN包时，会激活所有的休眠worker子进程。最终只有最先开始执行accept的子进程可以成功建立新连接，而其他worker子进程都将accept失败。这些accept失败的子进程被内核唤醒是不必要的，他们被唤醒会的执行很可能是多余的，那么这一时刻他们占用了本不需要占用的资源，引发了不必要的进程切换，增加了系统开销。

### 如何解决惊群问题 post事件处理机制
很多操作系统的最新版本的内核已经在事件驱动机制中解决了惊群问题，但Nginx作为可移植性极高的web服务器，还是在自身的应用层面上较好的解决了这一问题。
Nginx规定了同一时刻只有唯一一个worker子进程监听web端口，这一就不会发生惊群了，此时新连接事件只能唤醒唯一的正在监听端口的worker子进程。

如何限制在某一时刻是有一个子进程监听web端口呢？在打开accept_mutex锁的情况下，只有调用ngx_trylock_accept_mutex方法后，当前的worker进程才会去试着监听web端口。

那么，什么时候释放ngx_accept_mutex锁呢？
显然不能等到这批事件全部执行完。因为这个worker进程上可能有许多活跃的连接，处理这些连接上的事件会占用很长时间，其他worker进程很难得到处理新连接的机会。

如何解决长时间占用ngx_accept_mutex的问题呢？这就要依靠post事件处理机制，Nginx设计了两个队列：ngx_posted_accept_events队列（存放新连接事件的队列）和ngx_posted_events队列（存放普通事件的队列）。这两个队列都是ngx_event_t类型的双链表。定义如下：
``` cpp?linenums=false
ngx_thread_volatile ngx_event_t  *ngx_posted_accept_events;
ngx_thread_volatile ngx_event_t  *ngx_posted_events;
```

下面结合具体代码进行分析惊群问题的解决。
首先看worker进程中ngx_process_events_and_timers事件处理函数（src/event/ngx.event.c），它处于worker进程的ngx_worker_process_cycle方法中，循环处理时间，是事件驱动机制的核心，既会处理普通的网络事件，也会处理定时器事件。ngx_process_events_and_timers是Nginx实际处理web业务的方法，所有业务的执行都是由它开始的，它涉及Nginx完整的事件驱动机制！！特别重要~
``` cpp?linenums=false
void
ngx_process_events_and_timers(ngx_cycle_t *cycle)
{
    ngx_uint_t  flags;
    ngx_msec_t  timer, delta;
 
    if (ngx_timer_resolution) {
        timer = NGX_TIMER_INFINITE;
        flags = 0;
 
    } else {
        timer = ngx_event_find_timer();
        flags = NGX_UPDATE_TIME;
 
#if (NGX_THREADS)
 
        if (timer == NGX_TIMER_INFINITE || timer > 500) {
            timer = 500;
        }
 
#endif
    }
 
    /*ngx_use_accept_mutex表示是否需要通过对accept加锁来解决惊群问题。当使用了master模式，nginx worker进程数>1时且配置文件中打开accept_mutex时，这个标志置为1 
    它在函数ngx_event_process_int中被设置，源代码为：
    if (ccf->master && ccf->worker_processes > 1 && ecf->accept_mutex) {
        ngx_use_accept_mutex = 1;
        ngx_accept_mutex_held = 0;
        ngx_accept_mutex_delay = ecf->accept_mutex_delay;
    } else {
        ngx_use_accept_mutex = 0;
    }*/
    if (ngx_use_accept_mutex) {
        //负载均衡处理
        if (ngx_accept_disabled > 0) {
            ngx_accept_disabled--;
 
        } else {
            //调用ngx_trylock_accept_mutex方法，尝试获取accept锁
            if (ngx_trylock_accept_mutex(cycle) == NGX_ERROR) {
                return;
            }
 
            //拿到锁
            if (ngx_accept_mutex_held) {
                /*给flags增加标记NGX_POST_EVENTS，这个标记作为处理时间核心函数ngx_process_events的一个参数，这个函数中所有事件将延后处理。会把accept事件都放到ngx_posted_accept_events链表中，epollin|epollout普通事件都放到ngx_posted_events链表中 */
                flags |= NGX_POST_EVENTS;
            } else {
                /*获取锁失败，意味着既不能让当前worker进程频繁的试图抢锁，也不能让它经过太长事件再去抢锁
                下面的代码：即使开启了timer_resolution时间精度，牙需要让ngx_process_change方法在没有新事件的时候至少等待ngx_accept_mutex_delay毫秒之后再去试图抢锁
                而没有开启时间精度时，如果最近一个定时器事件的超时时间距离现在超过了ngx_accept_mutex_delay毫秒，也要把timer设置为ngx_accept_mutex_delay毫秒，这是因为当前进程虽然没有抢到accept_mutex锁，但也不能让ngx_process_change方法在没有新事件的时候等待的时间超过ngx_accept_mutex_delay，这会影响整个负载均衡机制*/
                if (timer == NGX_TIMER_INFINITE
                    || timer > ngx_accept_mutex_delay)
                {
                    timer = ngx_accept_mutex_delay;
                }
            }
        }
    }
 
    //计算ngx_process_events消耗的时间
    delta = ngx_current_msec;
 
    //事件处理核心函数
    (void) ngx_process_events(cycle, timer, flags);
 
    delta = ngx_current_msec - delta;
 
    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                   "timer delta: %M", delta);
 
    //ngx_posted_accept_events链表有数据，开始accept新连接
    if (ngx_posted_accept_events) {
        ngx_event_process_posted(cycle, &ngx_posted_accept_events);
    }
 
    //释放锁后再处理ngx_posted_events链表中的普通事件
    if (ngx_accept_mutex_held) {
        ngx_shmtx_unlock(&ngx_accept_mutex);
    }
 
    //如果ngx_process_events消耗的时间大于0，那么这是可能有新的定时器事件触发
    if (delta) {
        //处理定时器事件
        ngx_event_expire_timers();
    }
 
    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                   "posted events %p", ngx_posted_events);
 
    //ngx_posted_events链表中有数据，进行处理
    if (ngx_posted_events) {
        if (ngx_threaded) {
            ngx_wakeup_worker_thread(cycle);
 
        } else {
            ngx_event_process_posted(cycle, &ngx_posted_events);
        }
    }
}
```

上面代码中要进行说明的是，flags被设置后作为函数ngx_process_events方法的一个参数，在epoll模块中这个接口的实现方法是ngx_epoll_process_events 。当falgs标志位含有nGX_POST_EVENTS时是不会立即调用事件的handler回调方法的，代码如下所示：
``` cpp?linenums=false
 //事件需要延后处理
if (flags & NGX_POST_EVENTS) {
    /*如果要在post队列中延后处理该事件，首先要判断它是新连接时间还是普通事件
    以确定是把它加入到ngx_posted_accept_events队列或者ngx_posted_events队列中。*/
    queue = (ngx_event_t **) (rev->accept ?
       &ngx_posted_accept_events : &ngx_posted_events);
    //将该事件添加到相应的延后队列中
    ngx_locked_post_event(rev, queue); 
} else {
    //立即调用事件回调方法来处理这个事件
    rev->handler(rev);
}
```
通过上面的代码可以看出，先处理ngx_posted_accept_events队列中的事件，处理完毕后立即释放ngx_accept_mutex锁，接着再处理ngx_posted_events队列中事件。这样大大减少了ngx_accept_mutex锁占用的时间

下面看看ngx_trylock_accept-mutex的具体实现 (src/event/ngx_event_accept.c)
``` cpp?linenums=false
ngx_int_t
ngx_trylock_accept_mutex(ngx_cycle_t *cycle)
{
    //尝试获取accept_mutex锁。注意是非阻塞的。返回1表示成功，返回0表示失败。
    //ngx_accept_mutex 定义：ngx_shmtx_t    ngx_accept_mutex;（ngx_shmtx_t是Nginx封装的互斥锁，用于经常间同步）
    if (ngx_shmtx_trylock(&ngx_accept_mutex)) {
 
        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                       "accept mutex locked");
 
        //获取到锁，但是标志位ngx_accept_mutex_held为1，表示当前进程已经获取到锁了，立即返回。
        if (ngx_accept_mutex_held
            && ngx_accept_events == 0
            && !(ngx_event_flags & NGX_USE_RTSIG_EVENT))
        {
            return NGX_OK;
        }
 
        //将所有监听事件添加到当前的epoll等事件驱动模块中
        if (ngx_enable_accept_events(cycle) == NGX_ERROR) {
            //添加失败，必须释放互斥锁
            ngx_shmtx_unlock(&ngx_accept_mutex);
            return NGX_ERROR;
        }
        //标志位设置
        ngx_accept_events = 0;
        //当前进程已经获取到锁
        ngx_accept_mutex_held = 1;
 
        return NGX_OK;
    }
 
    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                   "accept mutex lock failed: %ui", ngx_accept_mutex_held);
 
    //获取锁失败，但是标志位ngx_accept_mutex_held仍然为1，即当前进程还处在获取到锁的状态，这是不正确的
    if (ngx_accept_mutex_held) {
        //将所有监听事件从事件驱动模块中移除
        if (ngx_disable_accept_events(cycle) == NGX_ERROR) {
            return NGX_ERROR;
        }
        //没有获取到锁，设置标志位
        ngx_accept_mutex_held = 0;
    }
 
    return NGX_OK;
}
```

调用这个方法的结果是，要么唯一获取到锁且其epoll等事件驱动模块开始监控web端口上的新连接事件。这种情况下调用process_events方法时就会既处理已有连接上的事件，也处理新连接的事件。要么没有获取到锁，当前进程不会收到新连接事件。这种情况下process_events只处理已有连接上的事件。