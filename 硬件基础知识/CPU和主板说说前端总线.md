---
title: CPU和主板说说前端总线
tags: 小书匠语法
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

TIPS:
1. 首先把这个问题仅限于x86平台.
2. 文章开头的部分内容其实是过时的,特别是对于北桥的一些阐述

#### 谈总线之前，首先应该明白总线是什么

度娘的完整定义是：总线是计算机各种功能部件之间传送信息的公共通信干线，它是由导线组成的传输线束，按照计算机所传输的信息种类。其实总线就是是一种内部结构，它是 cpu、内存、输入、输出设备传递信息的公用通道。工程师为了简化硬件电路设计、简化系统结构，常用一组线路，配置以适当的接口电路，与各部件和外围设备连接，这组共用的连接线路被称为总线。另外就是采用总线结构便于部件和设备的扩充，尤其制定了统一的总线标准则容易使不同设备间实现互连。

微机中总线一般有内部总线、系统总线和外部总线。内部总线是微机内部各外围芯片与处理器之间的总线，用于芯片一级的互连；而系统总线是微机中各插件板与系统板之间的总线，用于插件板一级的互连；外部总线则是微机和外部设备之间的总线，微机作为一种设备，通过该总线和其他设备进行信息与数据交换，它用于设备一级的互连。

众所周知，主板上最重要、成本最高的两颗芯片，被称为北桥和南桥，其中北桥负责与处理器对接，主要功能包括：内存控制器、PCI-E控制器、集成显卡、前/后端总线等，都是速度较快的模块；而南桥则负责外围周边功能，速度较慢，主要包括：磁盘控制器、网络端口、扩展卡槽、音频模块、I/O接口等等。

![传统南北桥设计](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/CPU和主板说说前端总线/20201015/1602740435874.png)

#### 什么是前端总线

“前端总线”这个名称是由AMD在推出K7CPU时提出的概念，但是一直以来都被大家误认为这个名词不过是外频的另一个名称。我们所说的外频指的是CPU与主板连接的速度，这个概念是建立在数字脉冲信号震荡速度基础之上的，而前端总线的速度指的是数据传输的速度，由于数据传输最大带宽取决于所有同时传输的数据的宽度和传输频率，即数据带宽＝（总线频率×数据位宽）÷8。目前PC机上所能达到的前端总线频率有266MHz、333MHz、400MHz、533MHz、800MHz、1066MHz、1333MHz几种，前端总线频率越大，代表着CPU与内存之间的数据传输量越大，更能充分发挥出CPU的功能。现在的CPU技术发展很快，运算速度提高很快，而足够大的前端总线可以保障有足够的数据供给给CPU。较低的前端总线将无法供给足够的数据给CPU，这样就限制了CPU性能得发挥，成为系统瓶颈。

前端总线的英文名字是FrontSideBus，通常用FSB表示，是将CPU连接到北桥芯片的总线。选购主板和CPU时，要注意两者搭配问题，一般来说，如果CPU不超频，那么前端总线是由CPU决定的，如果主板不支持CPU所需要的前端总线，系统就无法工作。也就是说，需要主板和CPU都支持某个前端总线，系统才能工作，只不过一个CPU默认的前端总线是唯一的，因此看一个系统的前端总线主要看CPU就可以。

北桥芯片负责联系内存、显卡等数据吞吐量最大的部件，并和南桥芯片连接。CPU就是通过前端总线（FSB）连接到北桥芯片，进而通过北桥芯片和内存、显卡交换数据。前端总线是CPU和外界交换数据的最主要通道，因此前端总线的数据传输能力对计算机整体性能作用很大，如果没足够快的前端总线，再强的CPU也不能明显提高计算机整体速度。数据传输最大带宽取决于所有同时传输的数据的宽度和传输频率，即数据带宽＝（总线频率×数据位宽）÷8。目前PC机上所能达到的前端总线频率有266MHz、333MHz、400MHz、533MHz、800MHz几种，前端总线频率越大，代表着CPU与北桥芯片之间的数据传输能力越大，更能充分发挥出CPU的功能。现在的CPU技术发展很快，运算速度提高很快，而足够大的前端总线可以保障有足够的数据供给给CPU，较低的前端总线将无法供给足够的数据给CPU，这样就限制了CPU性能得发挥，成为系统瓶颈。显然同等条件下，前端总线越快，系统性能越好。

前端总线的速度指的是数据传输的速度，外频是CPU与主板之间同步运行的速度。也就是说，100MHz外频特指数字脉冲信号在每秒钟震荡一千万次；而100MHz前端总线指的是每秒钟CPU可接受的数据传输量是100MHz×64bit=6400Mbit/s=800MByte/s（1Byte=8bit）。

北桥是PCI/PCIe 总线 的发源地。但是由于技术的进步，FSB已经被取代（或逐步取代），AMD很早就开始采用自己的HyperTransport（后续版本更改为HyperTransport Link简称HT link）代替了FSB来提高cpu与内存等芯片的数据传输速度，而intel亦采用QuickPathInterconnect（QPI）技术。但是总体上讲，这两种技术都是FSB的进化。外频看名字就知道，这是频率。频率是看不见的，前端总线是看得见的。其实外频，不就是给cpu的输入时钟嘛。比如给cpu一个66Mhz的时钟输入，cpu通过把这个输入通过PLL翻倍，成为我们熟悉的几个GHz的频率。早期外频和前端总线的频率一致，相当于外频x1，但是后来前端总线的频率也会在外频上翻倍，但应该低于cpu频率。

`TIPS:看到这里,我觉得大多数人应该有必要在这停顿一下,其实现在Intel CPU早已经将北桥的功能合并掉,甚至一些超低压CPU已经内置了南桥,我们也知道一些CPU都内置了GPU了.与这些CPU配套的主板不会再有芯片组，只是一块堆满接口和插槽的扩展输出板子而已。`

#### 特别说明 这里面过时转变的那段时间

Intel方面主要是 Clarkdale 与 Sandybridge 两代.

Clarkdale核心虽然将CPU和GPU首次封装在了CPU基板上面，但本质上它并没有做到CPU和GPU的融合，竞争对手AMD认为Intel这种方式其实是“胶水”整合，他们自己的APU才是真正意义上的“融合”。

Lynnfield虽然确实整合了北桥，但它在整合时并没有包括显卡。

而到了Sandybridge处理器，则集众多先进技术与一身，在Lynnfield核心的基础上，加入了新一代核心显卡，架构方面也有所微调。这是第一款真正意义上整合了北桥+显卡的处理器。毫无疑问，SandyBridge相对于上代的Clarkdale来说，最大的改进就是将GPU部分真正融入了CPU核心内部，这样GPU部分也使用了先进的32nm工艺，并且可以充分利用CPU部分的大容量三级缓存以及低延迟的内存控制器，共享内存带宽，从而让集显部分获得可观的性能提升。

除了CPU和GPU真正无缝整合在一起之外，Intel还对CPU与GPU两大处理器核心分别做了优化与改进，获得更高的指令执行效率，此外整合内存控制器相比上代产品带宽将更高、延迟会更低，而且CPU的三级缓存也可以被GPU共享，因此整合显卡的性能获得了非常客观的提升。

#### Intel和AMD的CPU前端总线上的区别

TIPS:Intel core 2的双通道就可以满足  但是Intel的CPU的缓存大而且架构优势明显，可以同时处理大量数据  而AMD是得益于共享内存得到较快的数据传输  所以两者其实差不多。**所以AMD的CPU在带宽上更多的依靠内存的提升来增加吞吐带宽**

AMD 7nm EPYC 7002系列处理器采用7nm CPU die + 14nm I/O die，每8个CPU die连接一个I/O die，8通道内存，128条PCIe通道。

总的来说，AMD 第二代EPYC处理器拥有最高64核心的配置，比英特尔的至强多128%，比至强的性能高97%，最高支持8TB 3200MHz内存，128条 PCIe 4.0通道。
微机中总线一般有内部总线、系统总线和外部总线。内部总线是微机内部各外围芯片与处理器之间的总线，用于芯片一级的互连；而系统总线是微机中各插件板与系统板之间的总线，用于插件板一级的互连；外部总线则是微机和外部设备之间的总线，微机作为一种设备，通过该总线和其他设备进行信息与数据交换，它用于设备一级的互连。

![AMD EPYC 7002系列](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/CPU和主板说说前端总线/20201015/1602740869393.png)



主要参考:</br>
1. [知乎匿名用户的答案](https://www.zhihu.com/question/20584517/answer/15567015)
2. [电子发烧友论坛文章](http://www.elecfans.com/d/878818.html)