---
title: CPU亲和绑定
tags: 
---

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