---
title: 09_CPU三大架构_SMP_NUMA_MPP
tags: 
---

系统的性能很大程度上依赖于cpu 硬件架构的支持。从系统架构来看，目前的商用服务器大体可以分为三类，即对称多处理器结构 (SMP ： Symmetric Multi-Processor) ，非一致存储访问结构 (NUMA ： Non-Uniform Memory Access) ，以及海量并行处理结构 (MPP ： Massive Parallel Processing) 。它们的特征分别描述如下：

#### SMP

SMP （Symmetric Multiprocessing） , 所谓对称多处理器,，是指服务器中多个 CPU 对称工作，无主次或从属关系。

在SMP中所有的处理器都是对等的, 它们通过总线连接共享同一块物理内存，这也就导致了系统中所有资源(CPU、内存、I/O等)都是共享的

因此 SMP 也被称为一致存储器访问结构 (UMA ： Uniform Memory Access) 。

当我们打开服务器的背板盖，如果发现有多个cpu的槽位，但是却连接到同一个内存插槽的位置，那一般就是smp架构的服务器

日常中常见的pc啊，笔记本啊，手机还有一些老的服务器都是这个架构，其架构简单，但是拓展性能非常差

对 SMP 服务器进行扩展的方式包括增加内存、使用更快的 CPU 、增加 CPU 、扩充 I/O( 槽口数与总线数 ) 以及添加更多的外部设备 ( 通常是磁盘存储 ) 。

对于 SMP 服务器而言，每一个共享的环节都可能造成 SMP 服务器扩展时的瓶颈，而最受限制的则是内存。由于每个 CPU 必须通过相同的内存总线访问相同的内存资源，因此随着 CPU 数量的增加，内存访问冲突将迅速增加，最终会造成 CPU 资源的浪费，使 CPU 性能的有效性大大降低。实验证明， SMP 服务器 CPU 利用率最好的情况是 2 至 4 个 CPU 。

从linux 上也能看到,如果只看到一个node0 那就是smp架构

`ls /sys/devices/system/node/`

#### NUMA

由于 SMP 在扩展能力上的限制，人们开始探究如何进行有效地扩展从而构建大型系统的技术， NUMA 就是这种努力下的结果之一。

利用 NUMA 技术，可以把几十个 CPU( 甚至上百个 CPU) 组合在一个服务器内。

NUMA （ Non-Uniform Memory Access），非均匀访问存储模型

如果说smp 相当于多个cpu 连接一个内存池导致请求经常发生冲突的话，numa 就是将cpu的资源分开，以node 为单位进行切割

NUMA 服务器的基本特征是具有多个 CPU 模块，每个 CPU 模块由多个 CPU( 如 4 个 ) 组成，并且具有独立的本地内存、 I/O 槽口等。

每个node 里有着独有的core ，memory 等资源，这就可以使得cpu在性能使用上的提升

由于其节点之间可以通过互联模块 ( 如称为 Crossbar Switch) 进行连接和信息交互，因此每个 CPU 可以访问整个系统的内存 ( 这是 NUMA 系统与 MPP 系统的重要差别 ) 。显然，访问本地内存的速度将远远高于访问远程内存 ( 系统内其它节点的内存 ) 的速度，这也是非一致存储访问 NUMA 的由来。由于此设计特点，为了更好地发挥系统性能，开发应用程序时需要尽量减少不同 CPU 模块之间的信息交互。

利用 NUMA 技术，可以较好地解决原来 SMP 系统的扩展问题，在一个物理服务器内可以支持上百个 CPU 。比较典型的 NUMA 服务器的例子包括 HP 的 Superdome 、 SUN15K 、 IBMp690 等。

但 NUMA 技术同样有一定缺陷，由于访问远程内存的延时远远超过本地内存，因此当 CPU 数量增加时，系统性能无法线性增加。如 HP 公司发布 Superdome 服务器时，曾公布了它与 HP 其它 UNIX 服务器的相对性能值，结果发现，64 路CPU的 Superdome (NUMA 结构 ) 的相对性能值是 20 ，而 8 路 N4000( 共享的 SMP 结构 ) 的相对性能值是 6.3 。从这个结果可以看到， 8 倍数量的 CPU 换来的只是 3 倍性能的提升。

所以可以看到很多明明有很多core的服务器却只有2个node区。

#### MPP

与NUMA 不同，MPP 提供了另外一种进行系统扩展的方式，它由多个 SMP 服务器通过一定的节点互联网络进行连接，协同工作，完成相同的任务，从用户的角度来看是一个服务器系统。

其基本特征是由多个 SMP 服务器 ( 每个 SMP 服务器称节点 ) 通过节点互联网络连接而成

每个节点只访问自己的本地资源 ( 内存、存储等 ) ，是一种完全无共享 (Share Nothing) 结构

因而扩展能力最好，理论上其扩展无限制，目前的技术可实现 512 个节点互联，数千个 CPU 。

目前业界对节点互联网络暂无标准，如 NCR 的 Bynet ， IBM 的 SPSwitch ，它们都采用了不同的内部实现机制。

但节点互联网仅供 MPP 服务器内部使用，对用户而言是透明的。

在 MPP 系统中，每个 SMP 节点也可以运行自己的操作系统、数据库等。

但和 NUMA 不同的是，它不存在远程内存访问的问题。

换言之，每个节点内的 CPU 不能访问另一个节点的内存。节点之间的信息交互是通过节点互联网络实现的，这个过程一般称为数据重分配 (Data Redistribution) 。

但是 MPP 服务器需要一种复杂的机制来调度和平衡各个节点的负载和并行处理过程。

目前一些基于 MPP 技术的服务器往往通过系统级软件 ( 如数据库 ) 来屏蔽这种复杂性。

举例来说， NCR 的 Teradata 就是基于 MPP 技术的一个关系数据库软件，基于此数据库来开发应用时，不管后台服务器由多少个节点组成，开发人员所面对的都是同一个数据库系统，而不需要考虑如何调度其中某几个节点的负载。

----------------------

我们使用 `lscpu` 命令可以很简单的看出cpu的架构和配置

```
#lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                8
On-line CPU(s) list:   0-7
Thread(s) per core:    1 #每个core 有几个线程
Core(s) per socket:    4 #每个槽位有4个core 
Socket(s):             2 #服务器面板上有2个cpu 槽位
NUMA node(s):          2 #nodes的数量
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 44
Stepping:              2
CPU MHz:               2128.025
BogoMIPS:              4256.03
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              8192K
NUMA node0 CPU(s):     0,2,4,6 #对应的core
NUMA node1 CPU(s):     1,3,5,7
```


由于numa 架构经常会有内存分配不均匀的情况，常常需要手动干预，除了代码以外，还有linux命令进行cpu的绑定:

`taskset  -cp 1,2  25718 #将进程ID 25718 绑定到cpu的第1和第2个core 里`

这个会在 CPU亲和绑定 一篇中更加详细的介绍