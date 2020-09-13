---
title: nginx使用keepalived搭建双机热备HA负载均衡环境
tags: 新建
renderNumberedHeading: true
---

[toc]

入门说明
nginx mater主机在独占式模式下，流量会先走master，在master宕机后走backup。每个nginx服务器都安装了keepalived进行状态检测。在nginx服务器之前会配置一个虚拟的VIP。用户访问虚拟VIP，然后反向代理给后端的web服务器。

 1. 安装库
 ``` bash?linenums=false
 yum -y install libnl libnl-devel
yum install -y libnfnetlink-devel
 ```
 2.编译安装
 ``` bash?linenums=false
 tar -zxvf  keepalived-1.2.24.tar.gz
 cd  keepalived-1.2.24.tar.gz
 ./configure --prefix=/usr/local/keepalived
 make && make install
 ```
  3.初始化Keepalived
 ``` bash?linenums=false
 mkdir /etc/keepalived
cp /usr/local/keepalived/etc/keepalived.conf /etc/keepalived/keepalived.conf
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/rc.d/init.d/keepalived
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived
#添加到开机自启
chkconfig keepalived on

#如果提示keepalived: command not found 解决方法如下
ln -s /usr/local/keepalived/sbin/keepalived /sbin/ 
#如果遇权限不足 执行以下命令
chmod 755 /etc/init.d/keepalived

#相关操作
service keepalived start   #启动服务
service keepalived stop    #停止服务
service keepalived restart #重启服务
 ```
 4.配置keepalived
 ``` bash?linenus=false
 keepalived服务安装完成之后，后面的主要工作就是在keepalived.conf文件中配置HA和负载均衡。
一个功能比较完整的常用的keepalived配置文件，主要包含三块：
全局定义块、VRRP实例定义块和虚拟服务器定义块。
全局定义块是必须的，如果keepalived只用来做ha，
虚拟服务器是可选的。下面是一个功能比较完整的配置文件模板：
#全局定义块
global_defs {
    # 邮件通知配置
    notification_email {
        email1
        email2
    }
    notification_email_from email
    smtp_server host
    smtp_connect_timeout num

    lvs_id string
    router_id string    ## 标识本节点的字条串,通常为hostname
}

#VRRP 实例定义块
vrrp_sync_group string { 
    group {
        string
        string
    }
}

vrrp_instance string {
    state MASTER|BACKUP
    virtual_router_id num
    interface string
    mcast_src_ip @IP 
    priority num
    advert_int num
    nopreempt
    smtp_alert
    lvs_sync_daemon_interface string 
    authentication {
        auth_type PASS|AH
        auth_pass string
    }

    virtual_ipaddress {  # Block limited to 20 IP addresses @IP
        @IP
        @IP
    }
}

#虚拟服务器定义块
virtual_server (@IP PORT)|(fwmark num) { 
    delay_loop num
    lb_algo rr|wrr|lc|wlc|sh|dh|lblc 
    lb_kind NAT|DR|TUN
    persistence_timeout num 
    protocol TCP|UDP
    real_server @IP PORT { 
        weight num
        notify_down /path/script.sh
        TCP_CHECK { 
            connect_port num 
            connect_timeout num
        }
    }

    real_server @IP PORT {
        weight num
        MISC_CHECK {
            misc_path /path_to_script/script.sh(or misc_path “/path_to_script/script.sh <arg_list>”)
        }
    }

    real_server @IP PORT {
        weight num
        HTTP_GET|SSL_GET {
            url { 
                # You can add multiple url block path alphanum
                digest alphanum
            }
            connect_port num
            connect_timeout num 
            nb_get_retry num 
            delay_before_retry num
        }
    }
}

## 全局定义块
1、email通知（notification_email、smtp_server、smtp_connect_timeout）：
用于服务有故障时发送邮件报警，可选项，不建议用。需要系统开启sendmail服务，
建议用第三独立监控服务，如用nagios全面监控代替。
2、lvs_id：lvs负载均衡器标识，在一个网络内，它的值应该是唯一的。
3、router_id：用户标识本节点的名称，通常为hostname
4、花括号｛｝：用来分隔定义块，必须成对出现。如果写漏了，
keepalived运行时不会得到预期的结果。由于定义块存在嵌套关系，
因此很容易遗漏结尾处的花括号，这点需要特别注意。

## VRRP实例定义块
 vrrp_sync_group：同步vrrp级，用于确定失败切换（FailOver）包含的路由实例个数。
即在有2个负载均衡器的场景，一旦某个负载均衡器失效，需要自动切换到另外一个负载均衡器的实例是哪
    group：至少要包含一个vrrp实例，vrrp实例名称必须和vrrp_instance定义的一致
    vrrp_instance：vrrp实例名
    1> state：实例状态，只有MASTER 和 BACKUP两种状态，并且需要全部大写。
抢占模式下，其中MASTER为工作状态，BACKUP为备用状态。当MASTER所在的服务器失效时，
BACKUP所在的服务会自动把它的状态由BACKUP切换到MASTER状态。
当失效的MASTER所在的服务恢复时，BACKUP从MASTER恢复到BACKUP状态。
    2> interface：对外提供服务的网卡接口，即VIP绑定的网卡接口。
如：eth0，eth1。当前主流的服务器都有2个或2个以上的接口（分别对应外网和内网），在选择网卡接口时，一定要核实清楚。
    3> mcast_src_ip：本机IP地址
    4> virtual_router_id：虚拟路由的ID号，每个节点设置必须一样，
可选择IP最后一段使用，相同的 VRID 为一个组，他将决定多播的 MAC 地址。
    5> priority：节点优先级，取值范围0～254，MASTER要比BACKUP高
    6> advert_int：MASTER与BACKUP节点间同步检查的时间间隔，单位为秒
    7> lvs_sync_daemon_inteface：负载均衡器之间的监控接口,
类似于 HA HeartBeat 的心跳线。但它的机制优于 Heartbeat，因为它没有“裂脑”这个问题,
它是以优先级这个机制来规避这个麻烦的。在 DR 模式中，
lvs_sync_daemon_inteface与服务接口interface使用同一个网络接口
    8> authentication：验证类型和验证密码。类型主要有 PASS、AH 两种，通常使用PASS类型，
据说AH使用时有问题。验证密码为明文，同一vrrp 实例MASTER与BACKUP使用相同的密码才能正常通信。
    9> smtp_alert：有故障时是否激活邮件通知
    10> nopreempt：禁止抢占服务。默认情况，当MASTER服务挂掉之后，
BACKUP自动升级为MASTER并接替它的任务，当MASTER服务恢复后，
升级为MASTER的BACKUP服务又自动降为BACKUP，
把工作权交给原MASTER。当配置了nopreempt，
MASTER从挂掉到恢复，不再将服务抢占过来。
    11> virtual_ipaddress：虚拟IP地址池，可以有多个IP，每个IP占一行，不需要指定子网掩码。注意：这个IP必须与我们的设定的vip保持一致。

## 虚拟服务器virtual_server定义块
    virtual_server：定义一个虚拟服务器，这个ip是virtual_ipaddress中定义的其中一个，后面一个空格，然后加上虚拟服务的端口号。
    1> delay_loop：健康检查时间间隔，单位：秒
    2> lb_algo：负载均衡调度算法，互联网应用常用方式为wlc或rr
    3> lb_kind：负载均衡转发规则。包括DR、NAT、TUN 3种，一般使用路由（DR）转发规则。
    4> persistence_timeout：http服务会话保持时间，单位：秒
    5> protocol：转发协议，分为TCP和UDP两种
    real_server：真实服务器IP和端口，可以定义多个
    1> weight：负载权重，值越大，转发的优先级越高
    2> notify_down：服务停止后执行的脚本
    3> TCP_CHECK：服务有效性检测
    * connect_port：服务连接端口
    * connect_timeout：服务连接超时时长，单位：秒
    * nb_get_retry：服务连接失败重试次数
    * delay_before_retry：重试连接间隔，单位：秒
 ```
 5.keepalived配置抢占模式增加VIP
 ``` bash?linenums=false
 ## master配置
 global_defs {
   router_id nginx_master #hostname 
}
vrrp_script chk_nginx {
    script "/etc/keepalived/nginx_check.sh" #检测nginx的脚本
    interval 2                              #每2秒检测一次
    weight -20								#如果某一个nginx宕机 则权重减20
}
vrrp_instance VI_1 {
    state MASTER							#状态 MASTER BACKUP
    interface eth0							#绑定的网卡
    virtual_router_id 51                    #虚拟路由的ID号,两个节点设置必须一样
    mcast_src_ip 192.168.110.128            #本机的IP
    priority 90
    advert_int 1
# 设置验证信息，两个节点必须一致
    authentication {
        auth_type PASS
        auth_pass 1111
    }
 # 虚拟IP，两个节点设置必须一样。
    virtual_ipaddress {
        192.168.110.138
    }
# nginx存活状态检测脚本
    track_script {
       chk_nginx
    }
}

## backup配置
global_defs {
   router_id nginx_backup  #hostname 
}
vrrp_script chk_nginx {
    script "/etc/keepalived/nginx_check.sh" #检测nginx的脚本
    interval 2                              #每2秒检测一次
    weight -20								#如果某一个nginx宕机 则权重减20
}
vrrp_instance VI_1 {
    state BACKUP							#状态 MASTER BACKUP
    interface eth0							#绑定的网卡
    virtual_router_id 51
    mcast_src_ip 192.168.110.130
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.110.138
    }

    track_script {
       chk_nginx
    }
}

## nginx检测脚本
#!/bin/bash
A=`ps -C nginx --no-header | wc -l`
if [ $A -eq 0 ];then
    /opt/nginx/sbin/nginx #尝试重新启动nginx
    sleep 2  #睡眠2秒
    if [ `ps -C nginx --no-header | wc -l` -eq 0 ];then
        killall keepalived #启动失败，将keepalived服务杀死。将vip漂移到其它备份节点
    fi
fi
 ```