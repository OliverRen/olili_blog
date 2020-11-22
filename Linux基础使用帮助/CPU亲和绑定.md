---
title: CPU亲和绑定
tags: 
---

[toc]

本文主要内容来自 [LubinLew的cnblogs](https://www.cnblogs.com/LubinLew/p/cpu_affinity.html) 和其他网络内容的整理

#### 基础知识

将进程/线程与cpu绑定，最直观的好处就是提高了cpu cache的命中率，从而减少内存访问损耗，提高程序的速度。

我觉得在NUMA架构下，这个操作对系统运行速度的提升有较大的意义，而在SMP架构下，这个提升可能就比较小。

这主要是因为两者对于cache、总线这些资源的分配使用方式不同造成的，NUMA每个cpu有自己的一套资源体系， SMP中每个核心还是需要共享这些资源的

从这个角度来看，NUMA使用cpu绑定时，每个核心可以更专注地处理一件事情，资源体系被充分使用，减少了同步的损耗。

SMP由于一部分资源的共享，在进行了绑定操作后，受到的影响还是很大的。

建议使用更加简单的 `lscpu` , `lsmem` 来查看系统的资源.

使用 `ps -eo pid,args,psr | grep <xxx>` 来查看程序运行在的逻辑CPU上

使用 `ps -To 'pid,lwp,psr,cmd' -p <pid>` 来查看进程实际的线程工作在哪些逻辑CPU上

#### CPU亲和基本概念

CPU affinity 是一种调度属性(scheduler property), 它可以将一个进程"绑定" 到一个或一组CPU上.

在SMP(Symmetric Multi-Processing对称多处理)架构下，Linux调度器(scheduler)会根据CPU affinity的设置让指定的进程运行在"绑定"的CPU上,而不会在别的CPU上运行. 

Linux调度器同样支持自然CPU亲和性(natural CPU affinity): 调度器会试图保持进程在相同的CPU上运行, 这意味着进程通常不会在处理器之间频繁迁移,进程迁移的频率小就意味着产生的负载小。

因为程序的作者比调度器更了解程序,所以我们可以手动地为其分配CPU核，而不会过多地占用CPU0，或是让我们关键进程和一堆别的进程挤在一起,所有设置CPU亲和性可以使某些程序提高性能。

#### CPU亲和表示方法

CPU affinity 使用位掩码(bitmask)表示, 每一位都表示一个CPU, 置1表示"绑定".

最低位表示第一个逻辑CPU, 最高位表示最后一个逻辑CPU.

CPU affinity典型的表示方法是使用16进制,具体如下.

```
0x00000001
    is processor #0

0x00000003
    is processors #0 and #1

0xFFFFFFFF
    is all processors (#0 through #31)
```

#### Systemd中的配置

在 \[Manager] 部分中以下选项和 CPU亲和有关,详细可见 [systemd文档](https://www.freedesktop.org/software/systemd/man/systemd-system.conf.html)

`CPUAffinity`

为服务管理器配置CPU亲和力，并为所有分支的进程配置默认的CPU亲和力。获取由空白或逗号分隔的CPU索引或范围的列表。CPU范围由下限和上限CPU索引指定，并用短划线分隔。可以多次指定此选项，在这种情况下，将合并指定的CPU亲和力掩码。如果分配了空字符串，则掩码将被重置，在此之前的所有分配都将无效。各个服务可以使用CPUAffinity=单位文件中的设置覆盖其进程的CPU亲和力

`NUMAPolicy`

为服务管理器配置NUMA内存策略，并为所有分支的进程配置默认的NUMA内存策略。各个服务可以使用NUMAPolicy=单位文件中的设置覆盖默认策略

`NUMAMask`

配置将与所选NUMA策略关联的NUMA节点掩码。请注意， default并且localNUMA策略不需要显式的NUMA节点掩码，该选项的值可以为空。与相似NUMAPolicy=，值可以由单位文件中的各个服务覆盖

#### taskset 命令

```
# 命令行形式
taskset [options] mask command [arg]...
taskset [options] -p [mask] pid

PARAMETER
　　　　mask : cpu亲和性,当没有-c选项时, 其值前无论有没有0x标记都是16进制的,
　　　　　　　　当有-c选项时,其值是十进制的.
　　　　command : 命令或者可执行程序
　　　　arg : command的参数
　　　　pid : 进程ID,可以通过ps/top/pidof等命令获取
	
OPTIONS
　	-a, --all-tasks (旧版本中没有这个选项)
　　　　　　　　这个选项涉及到了linux中TID的概念,他会将一个进程中所有的TID都执行一次CPU亲和性设置.
　　　　　　　　TID就是Thread ID,他和POSIX中pthread_t表示的线程ID完全不是同一个东西.
　　　　　　　　Linux中的POSIX线程库实现的线程其实也是一个进程(LWP),这个TID就是这个线程的真实PID.
       -p, --pid
              操作已存在的PID,而不是加载一个新的程序
       -c, --cpu-list
              声明CPU的亲和力使用数字表示而不是用位掩码表示. 例如 0,5,7,9-11.
       -h, --help
              display usage information and exit
       -V, --version
              output version information and exit
```

1. 指定一个程序的 CPU亲和

`taskset [-c] mask command [arg]...`

`taskset -c 0 ls -al /etc/init.d/`

2. 显示已经运行的进程的CPU亲和

`taskset -p pid`

3. 改变已经运行进程的CPU亲和

```
 taskset -p[c] mask pid

举例:打开2个终端,在第一个终端运行top命令,第二个终端中
首先运行:[~]# ps -eo pid,args,psr | grep top #获取top命令的pid和其所运行的CPU号
其次运行:[~]# taskset -cp 新的CPU号 pid       #更改top命令运行的CPU号
最后运行:[~]# ps -eo pid,args,psr | grep top #查看是否更改成功
```


#### numactl 命令