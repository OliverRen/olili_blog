---
title: AMD_EPYC_Rome2的使用
tags: 
---

[toc]

#### 提要

说到 AMD EPYC 即霄龙第二代的CPU,甚至现在还有第三代的处理器 (前者为7002系列,后者为7003系列) ,单路64C128T,率先拥有PCIE4,以及每路超高的内存贷款这些都是优势

但是单核性能,numa亲和 就有可能会对应用造成一些限制和影响.

当然对于指令集来说,缺少一系列 AVX-512 的指令集会使浮点计算差强人意,不过其支持的 sha_ni 扩展指令集在某些特殊领域非常受欢迎,所以具体要看运行的业务.

最早在服务器市场推出AMD服务器的应该大概是Dell把.现在依然觉得bios对于amd处理器设置上,Dell是最直观简单的

#### AMD EPYC Rome CCX/CCD配置汇总

直接摘自大佬和 Hardwareluxx

[AMD EPYC Rome CCX/CCD配置汇总](https://www.chiphell.com/thread-2210032-1-1.html)

[AMD EPYC on hardware LUXX](https://www.hardwareluxx.de/index.php/news/hardware/prozessoren/52861-amd-epyc-7fx2-mit-hohen-taktraten-gegen-den-cascade-lake-refresh.html)

![AMD rome cpu CCD+CCX](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/AMD_EPYC_Rome2的使用/2021414/AMD_rome_cpu_CCD+CCX.jpg)

第1行分别对应64C 7H12/7V12/7742/7702/7662, 48C 7642, 32C 7542/7502/7452, 24C 7F72, 16C 7F52, 8C 7F32/7262

第2行分别对应48C 7R32/7552, 24C 7402/7352, 16C 7302, 8C 7252

第3行分别对应16C 7282, 8C 7232P

#### 内存控制器

![Xeon Scalable内存控制器及均衡配置](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/AMD_EPYC_Rome2的使用/2021414/xeon.png)

首先拿服务器CPU市场的对手志强处理器来看下,6通道内存控制器分为2组各三通道,所以简而言之每颗 Xeon Scalable 安装内存为6或6倍数是,最均衡的配置

如果只有1-3根内存,则应该优先把一侧控制通道用满;

如果有4或8则应该对称安装,其他数量应该尽量避免

回过头来看AMD的CPU

![AMD EPYC](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/AMD_EPYC_Rome2的使用/2021414/无标题.png)

AMD EPYC2凭借将8个小的CCD（Core Die）和I/O Die分开的设计，再加上CCD使用7nm先进工艺，在核心数量上做到了64，超出Intel Xeon。

同时代价也是有的，那就是和第一代EPYC服务器CPU类似的片上NUMA（非一致性内存访问），尽管内存控制器都在中间那颗大的I/O Die上。

![ccd](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/AMD_EPYC_Rome2的使用/2021414/ccd.png)

![ccx](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/AMD_EPYC_Rome2的使用/2021414/ccx.png)

ROME（EPYC2）的8个内存通道分别属于4个内存控制器，每2个CCD Die能够就近优化访问其中的一组，而跨越一组进行内存访问就不是最佳性能（延时/带宽）了。

#### AMD EPYC 服务器上 NUMA设置建议

在 AMD EPYC2 处理器上访问内存的控制主要是使用 NPS (NUMA) 来设定的

就是你所看到的Dell Bios中的 每路CPU,或者说 每socket 多少个node

其定义大致如下:

- NPS 0——双CPU系统设置为1个NUMA节点（相当于Intel Xeon系统关闭NUMA），所有内存通道使用interleave交错访问模式；
- NPS 1——每个CPU插槽1个NUMA节点（相当于Intel Xeon系统打开NUMA），连接到同一插槽的所有内存通道使用交错访问；
- NPS 2——每个CPU插槽2个NUMA节点，划分为2个4内存通道的interleave集；
- NPS 4——每插槽4个NUMA节点，在“四象限”各自的2通道内存间交错访问，相当于CPU to内存的亲和优化到每个内存控制器；

那么看起来使用 NPS 4 是最贴近 CCD/CCX 设计的,是否这样就是最优的呢,这个问题先留着我们继续搜索

这里引用Dell白皮书《Balanced Memory with 2nd Generation AMD EPYC Processors for PowerEdge Servers》中的一个表格

![dell](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/AMD_EPYC_Rome2的使用/2021414/dell.png)

第二个点是厂商推荐我们使用AMD的服务器时,一般都会建议使用4的倍数的内存条数

第三点则是 AMD CPU 的问题,一般来说能开到 8个CCD全部激活就可以支持 NPS 4,但也是有例外的,主要时看内存控制器的布局和结构

现在来回答上面的问题 , 如何使用 NPS (NUMA设定) 依然是要看最终运行的应用的

如果是一般普通的应用或者数据库之类的应用,设置为 NPS 1 就可以了.而且一般应用也会对 NPS 1 有一些优化

而如果是虚拟化相关的应用,本身就可以很好的对应CCD,那么就可以使用 NPS 4

或者运行的应用可以有多个进程并行,这样也可以使用更多的 NPS 来进行精确的内存控制

#### FileCoin的坑

Interleaving 其实性能没啥损失...真不如就 NPS 0 或者双路机器最多设置 NPS 1来跑

NPS 多了势必需要多个 worker 进程,对于内存其实是有更多的开销的,会减少并行数

NPS 控制后切记内存使用时不能超过控制器所能控制的数量的

P1时SDR依然是一个看核的游戏,主频率高依然是打不过核心多的.当然性价比不提,也不听 7F52这种超级大阉割