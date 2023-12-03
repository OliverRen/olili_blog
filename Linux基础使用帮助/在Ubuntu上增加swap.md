---
title: 在Ubuntu上增加swap
---

[toc]

swap即内存交换分区,当内存不够的时候也可以救急

主要命令为 ==mkswap==,==swapon==,==swapoff==,==swaplabel==

查看交换信息 
`swapon --show` 
`free -h` 
`df -h` 

创建交换分区 
原来的写法是 `dd if=/dev/zero of=swapfile bs=1024 count=1024` 
但现在更推荐  `fallocate -l 1G swapfile` 他直接操作文件对应的磁盘空间而不需要使用0来填充

更改权限  
`chmod 600 /swapfile` 

标记文件为交换空间 
`mkswap /swapfile` 

启用交换空间 
`swapon /swapfile` 

永久保留交换文件 
需要在fstab中加入挂载 
`echo '/swapfile swap swap defaults 0 0' | tee -a /etc/fstab` 

调整交换分区相关的参数swappiness,设置ram到交换空间的频率 0-100.服务器越低越好
`cat /proc/sys/vm/swappiness`
`sysctl vm.swappiness=10` 或将 `vm.swappiness=10` 写入 `/etc/sysctl.conf`

-------------------------

- 服务器swap优化

    基本原则：
    1. 尽量使用内存，减少swap
    2. 尽早flush到外存，早点释放内存给写cache使用。
    3. 做到尽量使用分区而非文件
    4. 分布到不同设备上可以实现轮循

    ```
    临时修改
    sysctl vm.swappiness=0
    vm.swappiness = 0
    cat /proc/sys/vm/swappiness
    0
    始终生效
    cat /etc/sysctl.conf
    vm.swappiness=0
    ```

    ==sysctl中关于swap的参数详解==

    1.vm.swappiness 60->0

    swappiness的值的大小对如何使用swap分区是有着很大的联系的。swappiness=0的时候表示最大限度使用物理内存，然后才是 swap空间，swappiness＝100的时候表示积极的使用swap分区，并且把内存上的数据及时的搬运到swap空间里面。linux的基本默认设置为60

    2.vm.dirty_ratio 默认20

    同步刷脏页，会阻塞应用程序
    这个参数控制文件系统的同步写写缓冲区的大小，单位是百分比，表示当写缓冲使用到系统内存多少的时候（即指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如10%），），开始向磁盘写出数据，即系统不得不开始处理缓存脏页（因为此时脏页数量已经比较多，为了避免数据丢失需要将一定脏页刷入外存），在此过程中很多应用进程可能会因为系统转而处理文件IO而阻塞。    
    增大之会使用更多系统内存用于磁盘写缓冲，也可以极大提高系统的写性能。但是，当你需要持续、恒定的写入场合时，应该降低其数值，一般启动上缺省是 10。

    3.vm.dirty_background_ratio 默认10

    异步刷脏页，不会阻塞应用程序
    这个参数控制文件系统的后台进程，在何时刷新磁盘。单位是百分比，表示系统内存的百分比，意思是当写缓冲使用到系统内存多少的时候，就会触发pdflush/flush/kdmflush等后台回写进程运行，将一定缓存的脏页异步地刷入外存。增大之会使用更多系统内存用于磁盘写缓冲，也可以极大提高系统的写性能。但是，当你需要持续、恒定的写入场合时，应该降低其数值，一般启动上缺省是 5。
　　注意：如果dirty_ratio设置比dirty_background_ratio大，可能认为dirty_ratio的触发条件不可能达到，因为每次肯定会先达到vm.dirty_background_ratio的条件，然而，确实是先达到vm.dirty_background_ratio的条件然后触发flush进程进行异步的回写操作，但是这一过程中应用进程仍然可以进行写操作，如果多个应用进程写入的量大于flush进程刷出的量那自然会达到vm.dirty_ratio这个参数所设定的坎，此时操作系统会转入同步地处理脏页的过程，阻塞应用进程。

    4.vm.dirty_expire_centisecs 默认3000

    这个参数声明Linux内核写缓冲区里面的数据多“旧”了之后，pdflush进程就开始考虑写到磁盘中去。单位是 1/100秒。缺省是 3000，也就是 30 秒的数据就算旧了，将会刷新磁盘。对于特别重载的写操作来说，这个值适当缩小也是好的，但也不能缩小太多，因为缩小太多也会导致IO提高太快。建议设置为 1500，也就是15秒算旧。当然，如果你的系统内存比较大，并且写入模式是间歇式的，并且每次写入的数据不大（比如几十M），那么这个值还是大些的好。

    5.vm.dirty_writeback_centisecs 500

    这个参数控制内核的脏数据刷新进程pdflush的运行间隔。单位是 1/100 秒。缺省数值是500，也就是 5 秒。如果你的系统是持续地写入动作，那么实际上还是降低这个数值比较好，这样可以把尖峰的写操作削平成多次写操作。设置方法如下：

    6.vm.vfs_cache_pressure 默认100
    
    增大这个参数设置了虚拟内存回收directory和inode缓冲的倾向，这个值越大。越易回收。
　　该文件表示内核回收用于directory和inode cache内存的倾向；缺省值100表示内核将根据pagecache和swapcache，把directory和inode cache保持在一个合理的百分比；降低该值低于100，将导致内核倾向于保留directory和inode cache；增加该值超过100，将导致内核倾向于回收directory和inode cache。


