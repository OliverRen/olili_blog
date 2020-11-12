---
title: 零拷贝(zero copy)技术
---

[toc]

### Linux操作系统中的物理内存和虚拟内存 , 内核空间和用户空间 以及 Linux 内部的层级结构

> 本文转载自网络并经过删改,原文出处作者 陈林

- 本文将从 Linux操作系统中的物理内存和虚拟内存 , 内核空间和用户空间 以及 Linux 内部的层级结构讲起.
- 在此基础上，进一步分析和对比传统 I/O 方式和零拷贝方式的区别，然后介绍了 Linux 内核提供的几种零拷贝实现。包括内存映射 mmap、Sendfile、Sendfile+DMA gather copy 以及 Splice 几种机制，并从系统调用和拷贝次数层面对它们进行了对比。
- 然后会介绍一下 Java与.Net对零拷贝的实现
- 最后对比一下 RocketMQ 和 Kafka 两种消息队列在零拷贝实现方式上的区别。

> 零拷贝描述的是CPU不执行拷贝数据从一个存储区域到另一个存储区域的任务,让CPU解脱出来专注于别的任务。
> 这样就可以让系统资源的利用更加有效，这通常用于通过网络传输一个文件时以减少CPU周期和内存带宽。

避免数据拷贝可以从这几方面区考虑
- 避免操作系统内核缓冲区之间进行数据拷贝操作。
- 避免操作系统内核和用户应用程序地址空间这两者之间进行数据拷贝操作。
- 用户应用程序可以避开操作系统直接访问硬件存储。

实现零拷贝用到的最主要的技术就是 ==DMA 数据传输技术== 和 ==内存区域映射技术==
- 零拷贝机制可以减少数据在内核缓冲区和用户进程缓冲区之间反复的 I/O 拷贝操作。
- 零拷贝机制可以减少用户进程地址空间和内核地址空间之间因为上下文切换而带来的 CPU 开销。

> DMA(Direct Memory Access，直接存储器访问) 是所有现代电脑的重要特色，它允许不同速度的硬件装置来沟通，而不需要依赖于 CPU 的大量中断负载。否则，CPU 需要从来源把每一片段的资料复制到暂存器，然后把它们再次写回到新的地方。在这个时间中，CPU 对于其他的工作来说就无法使用。
> I/O内存映射 : 在现代操作系统中。引用了I/O内存映射。即把寄存器的值映射到主存。对设备寄存器的操作，转换为对主存的操作，这样极大的提高了效率。
> 网卡缓冲区: NIC (network interface card) 在系统启动过程中会向系统注册自己的各种信息，系统会分配 Ring Buffer 队列也会分配一块专门的内核内存区域给 NIC 用于存放传输上来的数据包。

#### 物理内存和虚拟内存

由于操作系统的进程与进程之间是共享 CPU 和内存资源的，因此需要一套完善的内存管理机制防止进程之间内存泄漏的问题。

为了更加有效地管理内存并减少出错，现代操作系统提供了一种对主存的抽象概念，即虚拟内存（Virtual Memory）。

虚拟内存为每个进程提供了一个一致的、私有的地址空间，它让每个进程产生了一种自己在独享主存的错觉（每个进程拥有一片连续完整的内存空间）。

1. 物理内存
物理内存指通过物理内存条而获得的内存空间，而虚拟内存则是指将硬盘的一块区域划分来作为内存。内存主要作用是在计算机运行时为操作系统和各种程序提供临时储存。
在应用中，自然是顾名思义，物理上，真实存在的插在主板内存槽上的内存条的容量的大小。

2. 虚拟内存
虚拟内存是计算机系统内存管理的一种技术。它使得应用程序认为它拥有连续的可用的内存（一个连续完整的地址空间）。

而实际上，虚拟内存通常是被分隔成多个物理内存碎片，还有部分暂时存储在外部磁盘存储器上，在需要时进行数据交换，加载到物理内存中来。

目前，大多数操作系统都使用了虚拟内存，如 Windows 系统的虚拟内存、Linux 系统的交换空间等等。

虚拟内存地址和用户进程紧密相关，一般来说不同进程里的同一个虚拟地址指向的物理地址是不一样的，所以离开进程谈虚拟内存没有任何意义。每个进程所能使用的虚拟地址大小和 CPU 位数有关。

在 32 位的系统上，虚拟地址空间大小是 2^32=4G，在 64 位系统上，虚拟地址空间大小是 2^64=16G，而实际的物理内存可能远远小于虚拟内存的大小。

**页表**
每个用户进程维护了一个单独的页表（Page Table），虚拟内存和物理内存就是通过这个页表实现地址空间的映射的。

下面给出两个进程 A、B 各自的虚拟内存空间以及对应的物理内存之间的地址映射示意图：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238338.png)

当进程执行一个程序时，需要先从内存中读取该进程的指令，然后执行，获取指令时用到的就是虚拟地址。

这个虚拟地址是程序链接时确定的（内核加载并初始化进程时会调整动态库的地址范围）。

为了获取到实际的数据，CPU 需要将虚拟地址转换成物理地址，CPU 转换地址时需要用到进程的页表（Page Table），而页表（Page Table）里面的数据由操作系统维护。

其中页表（Page Table）可以简单的理解为单个内存映射（Memory Mapping）的链表（当然实际结构很复杂）。
里面的每个内存映射（Memory Mapping）都将一块虚拟地址映射到一个特定的地址空间（物理内存或者磁盘存储空间）。

每个进程拥有自己的页表（Page Table），和其他进程的页表（Page Table）没有关系。

**用户进程访问物理内存总结**
通过上面的介绍，我们可以简单的将用户进程申请并访问物理内存（或磁盘存储空间）的过程总结如下：

*   用户进程向操作系统发出内存申请请求。
*   系统会检查进程的虚拟地址空间是否被用完，如果有剩余，给进程分配虚拟地址。
*   系统为这块虚拟地址创建内存映射（Memory Mapping），并将它放进该进程的页表（Page Table）。
*   系统返回虚拟地址给用户进程，用户进程开始访问该虚拟地址。
*   CPU 根据虚拟地址在此进程的页表（Page Table）中找到了相应的内存映射（Memory Mapping），但是这个内存映射（Memory Mapping）没有和物理内存关联，于是产生缺页中断。
*   操作系统收到缺页中断后，分配真正的物理内存并将它关联到页表相应的内存映射（Memory Mapping）。中断处理完成后，CPU 就可以访问内存了
*   当然缺页中断不是每次都会发生，只有系统觉得有必要延迟分配内存的时候才用的着，也即很多时候在上面的第 3 步系统会分配真正的物理内存并和内存映射（Memory Mapping）进行关联。

**引入虚拟内存的优点**
在用户进程和物理内存（磁盘存储器）之间引入虚拟内存主要有以下的优点：

*   **地址空间：** 提供更大的地址空间，并且地址空间是连续的，使得程序编写、链接更加简单。
*   **进程隔离：** 不同进程的虚拟地址之间没有关系，所以一个进程的操作不会对其他进程造成影响。
*   **数据保护：** 每块虚拟内存都有相应的读写属性，这样就能保护程序的代码段不被修改，数据块不能被执行等，增加了系统的安全性。
*   **内存映射：** 有了虚拟内存之后，可以直接映射磁盘上的文件（可执行文件或动态库）到虚拟地址空间。
    这样可以做到物理内存延时分配，只有在需要读相应的文件的时候，才将它真正的从磁盘上加载到内存中来，而在内存吃紧的时候又可以将这部分内存清空掉，提高物理内存利用效率，并且所有这些对应用程序都是透明的。
*   **共享内存：** 比如动态库只需要在内存中存储一份，然后将它映射到不同进程的虚拟地址空间中，让进程觉得自己独占了这个文件。
    进程间的内存共享也可以通过映射同一块物理内存到进程的不同虚拟地址空间来实现共享。
*   **物理内存管理：** 物理地址空间全部由操作系统管理，进程无法直接分配和回收，从而系统可以更好的利用内存，平衡进程间对内存的需求。

#### 内核空间和用户空间

操作系统的核心是内核，独立于普通的应用程序，可以访问受保护的内存空间，也有访问底层硬件设备的权限。

为了避免用户进程直接操作内核，保证内核安全，操作系统将虚拟内存划分为两部分，一部分是内核空间（Kernel-space），一部分是用户空间（User-space）。 

在 Linux 系统中，内核模块运行在内核空间，对应的进程处于内核态；而用户程序运行在用户空间，对应的进程处于用户态。

内核进程和用户进程所占的虚拟内存比例是 1:3，而 Linux x86_32 系统的寻址空间（虚拟存储空间）为 4G（2 的 32 次方），将最高的 1G 的字节（从虚拟地址 0xC0000000 到 0xFFFFFFFF）供内核进程使用，称为内核空间。

而较低的 3G 的字节（从虚拟地址 0x00000000 到 0xBFFFFFFF），供各个用户进程使用，称为用户空间。

1. 内存布局

下图是一个进程的用户空间和内核空间的内存布局：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238414.png)

2. 内核空间

内核空间总是驻留在内存中，它是为操作系统的内核保留的。应用程序是不允许直接在该区域进行读写或直接调用内核代码定义的函数的。

上图左侧区域为内核进程对应的虚拟内存，按访问权限可以分为进程私有和进程共享两块区域：

*   **进程私有的虚拟内存：** 每个进程都有单独的内核栈、页表、task 结构以及 mem_map 结构等。
*   **进程共享的虚拟内存：** 属于所有进程共享的内存区域，包括物理存储器、内核数据和内核代码区域。

3. 用户空间

每个普通的用户进程都有一个单独的用户空间，处于用户态的进程不能访问内核空间中的数据，也不能直接调用内核函数的 ，因此要进行系统调用的时候，就要将进程切换到内核态才行。

*   **运行时栈：** 由编译器自动释放，存放函数的参数值，局部变量和方法返回值等。每当一个函数被调用时，该函数的返回类型和一些调用的信息被存储到栈顶，调用结束后调用信息会被弹出并释放掉内存。
    栈区是从高地址位向低地址位增长的，是一块连续的内在区域，最大容量是由系统预先定义好的，申请的栈空间超过这个界限时会提示溢出，用户能从栈中获取的空间较小。
*   **运行时堆：** 用于存放进程运行中被动态分配的内存段，位于 BSS 和栈中间的地址位。由卡发人员申请分配（malloc）和释放（free）。堆是从低地址位向高地址位增长，采用链式存储结构。
    频繁地 malloc/free 造成内存空间的不连续，产生大量碎片。当申请堆空间时，库函数按照一定的算法搜索可用的足够大的空间。因此堆的效率比栈要低的多。
*   **代码段：** 存放 CPU 可以执行的机器指令，该部分内存只能读不能写。通常代码区是共享的，即其他执行程序可调用它。假如机器中有数个进程运行相同的一个程序，那么它们就可以使用同一个代码段。
*   **未初始化的数据段：** 存放未初始化的全局变量，BSS 的数据在程序开始执行之前被初始化为 0 或 NULL。
*   **已初始化的数据段：** 存放已初始化的全局变量，包括静态全局变量、静态局部变量以及常量。
*   **内存映射区域：** 例如将动态库，共享内存等虚拟空间的内存映射到物理空间的内存，一般是 mmap 函数所分配的虚拟内存空间。

#### Linux的内部层级结构

内核态可以执行任意命令，调用系统的一切资源，而用户态只能执行简单的运算，不能直接调用系统资源。用户态必须通过系统接口（System Call），才能向内核发出指令。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238289.png)

> 比如，当用户进程启动一个 bash 时，它会通过 getpid() 对内核的 pid 服务发起系统调用，获取当前用户进程的 ID。
当用户进程通过 cat 命令查看主机配置时，它会对内核的文件子系统发起系统调用：
> 
> *   内核空间可以访问所有的 CPU 指令和所有的内存空间、I/O 空间和硬件设备。
> *   用户空间只能访问受限的资源，如果需要特殊权限，可以通过系统调用获取相应的资源。
> *   用户空间允许页面中断，而内核空间则不允许。
> *   内核空间和用户空间是针对线性地址空间的。
> *   x86 CPU 中用户空间是 0-3G 的地址范围，内核空间是 3G-4G 的地址范围。
>     x86_64 CPU 用户空间地址范围为0x0000000000000000–0x00007fffffffffff，内核地址空间为 0xffff880000000000-最大地址。
> *   所有内核进程（线程）共用一个地址空间，而用户进程都有各自的地址空间。

有了用户空间和内核空间的划分后，Linux 内部层级结构可以分为三部分，从最底层到最上层依次是硬件、内核空间和用户空间，如下图所示：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238413.png)

------------------

### Linux I/O 的读写方式

Linux 提供了轮询、I/O 中断以及 DMA 传输这 3 种磁盘与主存之间的数据传输机制。
1. 轮询方式是基于死循环对 I/O 端口进行不断检测。
2. I/O 中断方式是指当数据到达时，磁盘主动向 CPU 发起中断请求，由 CPU 自身负责数据的传输过程。
3. DMA 传输则在 I/O 中断的基础上引入了 DMA 磁盘控制器，由 DMA 磁盘控制器负责数据的传输，降低了 I/O 中断操作对 CPU 资源的大量消耗。

#### I/O 中断原理

在 DMA 技术出现之前，应用程序与磁盘之间的 I/O 操作都是通过 CPU 的中断完成的。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238351.png)

每次用户进程读取磁盘数据时，都需要 CPU 中断，然后发起 I/O 请求等待数据读取和拷贝完成，每次的 I/O 中断都导致 CPU 的上下文切换：
*   用户进程向 CPU 发起 read 系统调用读取数据，由用户态切换为内核态，然后一直阻塞等待数据的返回。
*   CPU 在接收到指令以后对磁盘发起 I/O 请求，将磁盘数据先放入磁盘控制器缓冲区。
*   数据准备完成以后，磁盘向 CPU 发起 I/O 中断。
*   CPU 收到 I/O 中断以后将磁盘缓冲区中的数据拷贝到内核缓冲区，然后再从内核缓冲区拷贝到用户缓冲区。
*   用户进程由内核态切换回用户态，解除阻塞状态，然后等待 CPU 的下一个执行时间钟。

#### DMA 传输原理

DMA 的全称叫直接内存存取（Direct Memory Access），是一种允许外围设备（硬件子系统）直接访问系统主内存的机制。

也就是说，基于 DMA 访问方式，系统主内存于硬盘或网卡之间的数据传输可以绕开 CPU 的全程调度。
目前大多数的硬件设备，包括==磁盘控制器==、==网卡==、==显卡==以及==声卡==等都支持 DMA 技术。

整个数据传输操作在一个 DMA 控制器的控制下进行的。CPU 除了在数据传输开始和结束时做一点处理外（开始和结束时候要做中断处理），在传输过程中 CPU 可以继续进行其他的工作。这样在大部分时间里，CPU 计算和 I/O 操作都处于并行操作，使整个计算机系统的效率大大提高。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238370.png)

有了 DMA 磁盘控制器接管数据读写请求以后，CPU 从繁重的 I/O 操作中解脱，数据读取操作的流程如下：
*   用户进程向 CPU 发起 read 系统调用读取数据，由用户态切换为内核态，然后一直阻塞等待数据的返回。
*   CPU 在接收到指令以后对 DMA 磁盘控制器发起调度指令。
*   DMA 磁盘控制器对磁盘发起 I/O 请求，将磁盘数据先放入磁盘控制器缓冲区，CPU 全程不参与此过程。
*   数据读取完成后，DMA 磁盘控制器会接受到磁盘的通知，将数据从磁盘控制器缓冲区拷贝到内核缓冲区。
*   DMA 磁盘控制器向 CPU 发出数据读完的信号，由 CPU 负责将数据从内核缓冲区拷贝到用户缓冲区。
*   用户进程由内核态切换回用户态，解除阻塞状态，然后等待 CPU 的下一个执行时间钟。

#### 传统的I/O流传输方式

先简单的阐述一下相关的概念:
*   **上下文切换：** 当用户程序向内核发起系统调用时，CPU 将用户进程从用户态切换到内核态；当系统调用返回时，CPU 将用户进程从内核态切换回用户态。
*   **CPU 拷贝：** 由 CPU 直接处理数据的传送，数据拷贝时会一直占用 CPU 的资源。
*   **DMA 拷贝：** 由 CPU 向DMA磁盘控制器下达指令，让 DMA 控制器来处理数据的传送，数据传送完毕再把信息反馈给 CPU，从而减轻了 CPU 资源的占有率。

为了更好的理解零拷贝解决的问题，我们首先了解一下传统 I/O 方式存在的问题。
在 Linux 系统中，传统的访问方式是通过 write() 和 read() 两个系统调用实现的，通过 read() 函数读取文件到到缓存区中，然后通过 write() 方法把缓存中的数据输出到网络端口。

```
while((n = read(file_fd, buf, BUF_SIZE)) > 0)
    write(sock_fd, buf , n);
```

上述伪代码就两行,即读文件到buff,然后去socket发送buffer,但是由于Linux的I/O操作默认是缓冲I/O。这里面主要使用的也就是read和write两个系统调用，我们并不知道操作系统在其中做了什么。实际上在以上I/O操作中，发生了多次的数据拷贝。

下图分别对应传统 I/O 操作的数据读写流程，整个过程涉及 2 次 CPU 拷贝、2 次 DMA 拷贝，总共 4 次拷贝，以及 4 次上下文切换。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238412.png)

1. 传统读操作

当应用程序执行 read 系统调用读取一块数据的时候，如果这块数据已经存在于用户进程的页内存中，就直接从内存中读取数据。

如果数据不存在，则先将数据从磁盘加载数据到内核空间的读缓存（read buffer）中，再从读缓存拷贝到用户进程的页内存中。

`read(file_fd, tmp_buf, len);`

基于传统的 I/O 读取方式，read 系统调用会触发 2 次上下文切换，1 次 DMA 拷贝和 1 次 CPU 拷贝。

发起数据读取的流程如下：
*   用户进程通过 read() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   CPU 利用 DMA 控制器将数据从主存或硬盘拷贝到内核空间（kernel space）的读缓冲区（read buffer）。
*   CPU 将读缓冲区（read buffer）中的数据拷贝到用户空间（user space）的用户缓冲区（user buffer）。
*   上下文从内核态（kernel space）切换回用户态（user space），read 调用执行返回。

2. 传统写操作

当应用程序准备好数据，执行 write 系统调用发送网络数据时，先将数据从用户空间的页缓存拷贝到内核空间的网络缓冲区（socket buffer）中，然后再将写缓存中的数据拷贝到网卡设备完成数据发送。

`write(socket_fd, tmp_buf, len);`

基于传统的 I/O 写入方式，write() 系统调用会触发 2 次上下文切换，1 次 CPU 拷贝和 1 次 DMA 拷贝。

用户程序发送网络数据的流程如下：
*   用户进程通过 write() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   CPU 将用户缓冲区（user buffer）中的数据拷贝到内核空间（kernel space）的网络缓冲区（socket buffer）。
*   CPU 利用 DMA 控制器将数据从网络缓冲区（socket buffer）拷贝到网卡进行数据传输。
*   上下文从内核态（kernel space）切换回用户态（user space），write 系统调用执行返回。

#### Linux环境中的零拷贝方式

在 Linux 中零拷贝技术主要有 3 个实现思路：
*   **用户态直接 I/O：** 应用程序可以直接访问硬件存储，操作系统内核只是辅助数据传输。
    这种方式依旧存在用户空间和内核空间的上下文切换，硬件上的数据直接拷贝至了用户空间，不经过内核空间。因此，直接 I/O 不存在内核空间缓冲区和用户空间缓冲区之间的数据拷贝。
*   **减少数据拷贝次数：** 在数据传输过程中，避免数据在用户空间缓冲区和系统内核空间缓冲区之间的 CPU 拷贝，以及数据在系统内核空间内的 CPU 拷贝，这也是当前主流零拷贝技术的实现思路。
*   **写时复制技术：** 写时复制指的是当多个进程共享同一块数据时，如果其中一个进程需要对这份数据进行修改，那么将其拷贝到自己的进程地址空间中，如果只是数据读取操作则不需要进行拷贝操作。

1. **用户态直接 I/O**

用户态直接 I/O 使得应用进程或运行在用户态（user space）下的库函数直接访问硬件设备。

数据直接跨过内核进行传输，内核在数据传输过程除了进行必要的虚拟存储配置工作之外，不参与任何其他工作，这种方式能够直接绕过内核，极大提高了性能。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238371.png)

用户态直接 I/O 只能适用于不需要内核缓冲区处理的应用程序，这些应用程序通常在进程地址空间有自己的数据缓存机制，称为自缓存应用程序，如数据库管理系统就是一个代表。

其次，这种零拷贝机制会直接操作磁盘 I/O，由于 CPU 和磁盘 I/O 之间的执行时间差距，会造成大量资源的浪费，解决方案是配合异步 I/O 使用。

2. **mmap+write**

这时一种减少CPU拷贝次数的一种方法,使用mmap()来代替read()调用：
mmap 是 Linux 提供的一种内存映射文件方法，即将一个进程的地址空间中的一段虚拟地址映射到磁盘文件地址.
```
buf = mmap(diskfd, len);
write(sockfd, buf, len);
```
使用 mmap 的目的是将内核中读缓冲区（read buffer）的地址与用户空间的缓冲区（user buffer）进行映射。
从而实现内核缓冲区与应用程序内存的共享，省去了将数据从内核读缓冲区（read buffer）拷贝到用户缓冲区（user buffer）的过程。

然而内核读缓冲区（read buffer）仍需将数据拷贝到内核写缓冲区（socket buffer），大致的流程如下图所示：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238415.png)

基于 mmap+write 系统调用的零拷贝方式，整个拷贝过程会发生 4 次上下文切换，1 次 CPU 拷贝和 2 次 DMA 拷贝。

用户程序读写数据的流程如下：
*   用户进程通过 mmap() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   将用户进程的内核空间的读缓冲区（read buffer）与用户空间的缓存区（user buffer）进行内存地址映射。
*   CPU 利用 DMA 控制器将数据从主存或硬盘拷贝到内核空间（kernel space）的读缓冲区（read buffer）。
*   上下文从内核态（kernel space）切换回用户态（user space），mmap 系统调用执行返回。
*   用户进程通过 write() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   CPU 将读缓冲区（read buffer）中的数据拷贝到网络缓冲区（socket buffer）。
*   CPU 利用 DMA 控制器将数据从网络缓冲区（socket buffer）拷贝到网卡进行数据传输。
*   上下文从内核态（kernel space）切换回用户态（user space），write 系统调用执行返回。

mmap 主要的用处是提高 I/O 性能，特别是针对大文件。对于小文件，内存映射文件反而会导致碎片空间的浪费。因为内存映射总是要对齐页边界，最小单位是 4 KB，一个 5 KB 的文件将会映射占用 8 KB 内存，也就会浪费 3 KB 内存。

mmap 的拷贝虽然减少了 1 次拷贝，提升了效率，但也存在一些隐藏的问题。
当 mmap 一个文件时，如果这个文件被另一个进程所截获，那么 write 系统调用会因为访问非法地址被 SIGBUS 信号终止，SIGBUS 默认会杀死进程并产生一个 coredump，服务器可能因此被终止。

通常我们使用以下解决方案避免这种问题：
- 为SIGBUS信号建立信号处理程序
当遇到SIGBUS信号时，信号处理程序简单地返回，write系统调用在被中断之前会返回已经写入的字节数，并且errno会被设置成success,但是这是一种糟糕的处理办法，因为你并没有解决问题的实质核心。
- 使用文件租借锁
通常我们使用这种方法，在文件描述符上使用租借锁，我们为文件向内核申请一个租借锁，当其它进程想要截断这个文件时，内核会向我们发送一个实时的RT_SIGNAL_LEASE信号，告诉我们内核正在破坏你加持在文件上的读写锁。这样在程序访问非法内存并且被SIGBUS杀死之前，你的write系统调用会被中断。write会返回已经写入的字节数，并且置errno为success。

我们应该在mmap文件之前加锁，并且在操作完文件后解锁：
```
if(fcntl(diskfd, F_SETSIG, RT_SIGNAL_LEASE) == -1) {
    perror("kernel lease set signal");
    return -1;
}
/* l_type can be F_RDLCK F_WRLCK  加锁*/
/* l_type can be  F_UNLCK 解锁*/
if(fcntl(diskfd, F_SETLEASE, l_type)){
    perror("kernel lease set type");
    return -1;
}
```

3. **sendfile**

Sendfile 系统调用在 Linux 内核版本 2.1 中被引入，目的是简化通过网络在两个通道之间进行的数据传输过程。Sendfile 系统调用的引入，不仅减少了 CPU 拷贝的次数，还减少了上下文切换的次数，它的伪代码如下：

`sendfile(socket, file, len);`

file可以是文件句柄，也可以是socket句柄,把文件数据通过网络发送出去，减少了上下文的切换,内核的缓存数据到直接网卡数据也不用CPU去复制，由DMA完成.系统调用sendfile()在代表输入文件的描述符in_fd和代表输出文件的描述符out_fd之间传送文件内容（字节）。描述符out_fd必须指向一个套接字，而in_fd指向的文件必须是可以mmap的。这些局限限制了sendfile的使用，使sendfile只能将数据从文件传递到套接字上，反之则不行。

与 mmap 内存映射方式不同的是， Sendfile 调用中 I/O 数据对用户空间是完全不可见的。也就是说，这是一次完全意义上的数据传输过程。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238418.png)

基于 Sendfile 系统调用的零拷贝方式，整个拷贝过程会发生 2 次上下文切换，1 次 CPU 拷贝和 2 次 DMA 拷贝。用户程序读写数据的流程如下：
*   用户进程通过 sendfile() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   CPU 利用 DMA 控制器将数据从主存或硬盘拷贝到内核空间（kernel space）的读缓冲区（read buffer）。
*   CPU 将读缓冲区（read buffer）中的数据拷贝到的网络缓冲区（socket buffer）。
*   CPU 利用 DMA 控制器将数据从网络缓冲区（socket buffer）拷贝到网卡进行数据传输。
*   上下文从内核态（kernel space）切换回用户态（user space），Sendfile 系统调用执行返回。

相比较于 mmap 内存映射的方式，Sendfile 少了 2 次上下文切换，但是仍然有 1 次 CPU 拷贝操作。
Sendfile 存在的问题是用户程序不能对数据进行修改，而只是单纯地完成了一次数据传输过程。
在我们调用sendfile时，如果有其它进程截断了文件会发生什么呢？假设我们没有设置任何信号处理程序，sendfile调用仅仅返回它在被中断之前已经传输的字节数，errno会被置为success。如果我们在调用sendfile之前给文件加了锁，sendfile的行为仍然和之前相同，我们还会收到RT_SIGNAL_LEASE的信号。

> 同时,借助于硬件的帮助,我们还可以将页缓存到socket缓冲区的拷贝省去.只需要将缓冲区描述符传到socket缓冲区,然后再将数据长度传过去就可以了.这样 DMA 控制器就可以直接将页缓存中的数据打包发送到网络了. 这就是下面的 DMA gather copy,不过这一种收集拷贝功能是需要硬件以及驱动程序支持的。

4. **Sendfile+DMA gather copy**

Linux 2.4 版本的内核对 Sendfile 系统调用进行修改，为 DMA 拷贝引入了 gather 操作。

它将内核空间（kernel space）的读缓冲区（read buffer）中对应的数据描述信息（内存地址、地址偏移量）记录到相应的网络缓冲区（ socket buffer）中，由 DMA 根据内存地址、地址偏移量将数据批量地从读缓冲区（read buffer）拷贝到网卡设备中。

这样就省去了内核空间中仅剩的 1 次 CPU 拷贝操作，Sendfile 的伪代码如下：
`sendfile(socket_fd, file_fd, len);`

在硬件的支持下，Sendfile 拷贝方式不再从内核缓冲区的数据拷贝到 socket 缓冲区，取而代之的仅仅是缓冲区文件描述符和数据长度的拷贝。
这样 DMA 引擎直接利用 gather 操作将页缓存中数据打包发送到网络中即可，本质就是和虚拟内存映射的思路类似。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238416.png)

基于 Sendfile+DMA gather copy 系统调用的零拷贝方式，整个拷贝过程会发生 2 次上下文切换、0 次 CPU 拷贝以及 2 次 DMA 拷贝。用户程序读写数据的流程如下：
*   用户进程通过 sendfile() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   CPU 利用 DMA 控制器将数据从主存或硬盘拷贝到内核空间（kernel space）的读缓冲区（read buffer）。
*   CPU 把读缓冲区（read buffer）的文件描述符（file descriptor）和数据长度拷贝到网络缓冲区（socket buffer）。
*   基于已拷贝的文件描述符（file descriptor）和数据长度，CPU 利用 DMA 控制器的 gather/scatter 操作直接批量地将数据从内核的读缓冲区（read buffer）拷贝到网卡进行数据传输。
*   上下文从内核态（kernel space）切换回用户态（user space），Sendfile 系统调用执行返回。

Sendfile+DMA gather copy 拷贝方式同样存在用户程序不能对数据进行修改的问题，而且本身需要硬件的支持，它只适用于将数据从文件拷贝到 socket 套接字上的传输过程。

5. **通过 splice 实现的零拷贝**

splice只适合将数据从文件拷贝到套接字,同时需要硬件的支持，这限定了它的使用范围。Linux在2.6.17版本引入splice系统调用，不仅不需要硬件支持，还实现了两个文件描述符之间的数据零拷贝。

`splice(fd_in, off_in, fd_out, off_out, len, flags);`

splice用于在两个文件描述符之间传输数据,而不需要数据在内核空间和用户空间来回拷贝.但输入和输出文件描述符必须有一个是pipe。也就是说如果你需要从一个socket 传输数据到另外一个socket，是需要使用 pipe来做为中介的

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238420.png)

基于 Splice 系统调用的零拷贝方式，整个拷贝过程会发生 2 次上下文切换，0 次 CPU 拷贝以及 2 次 DMA 拷贝。用户程序读写数据的流程如下：
*   用户进程通过 splice() 函数向内核（kernel）发起系统调用，上下文从用户态（user space）切换为内核态（kernel space）。
*   CPU 利用 DMA 控制器将数据从主存或硬盘拷贝到内核空间（kernel space）的读缓冲区（read buffer）。
*   CPU 在内核空间的读缓冲区（read buffer）和网络缓冲区（socket buffer）之间建立管道（pipeline）。
*   CPU 利用 DMA 控制器将数据从网络缓冲区（socket buffer）拷贝到网卡进行数据传输。
*   上下文从内核态（kernel space）切换回用户态（user space），Splice 系统调用执行返回。

Splice 拷贝方式也同样存在用户程序不能对数据进行修改的问题。除此之外，它使用了 Linux 的管道缓冲机制，可以用于任意两个文件描述符中传输数据，但是它的两个文件描述符参数中有一个必须是管道设备。

6. **通过 写时复制**

以上几种零拷贝技术都是减少数据在用户空间和内核空间拷贝技术实现的，但是有些时候，数据必须在用户空间和内核空间之间拷贝。这时候，我们只能针对数据在用户空间和内核空间拷贝的时机上下功夫了。Linux通常利用写时复制(copy on write)来减少系统开销，这个技术又时常称作COW。

大概描述下就是：如果多个程序同时访问同用户态直接 I/O一块数据，那么每个程序都拥有指向这块数据的指针，在每个程序看来，自己都是独立拥有这块数据的，只有当程序需要对数据内容进行修改时，才会把数据内容拷贝到程序自己的应用空间里去，这时候，数据才成为该程序的私有数据。如果程序不需要对数据进行修改，那么永远都不需要拷贝数据到自己的应用空间里。这样就减少了数据的拷贝。

7. **缓冲区共享**

缓冲区共享方式完全改写了传统的 I/O 操作，因为传统 I/O 接口都是基于数据拷贝进行的，要避免拷贝就得去掉原先的那套接口并重新改写。

所以这种方法是比较全面的零拷贝技术，目前比较成熟的一个方案是在 Solaris 上实现的 fbuf（Fast Buffer，快速缓冲区）。

fbuf 的思想是每个进程都维护着一个缓冲区池，这个缓冲区池能被同时映射到用户空间（user space）和内核态（kernel space），内核和用户共享这个缓冲区池，这样就避免了一系列的拷贝操作。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238419.png)

> 缓冲区共享的难度在于管理共享缓冲区池需要应用程序、网络软件以及设备驱动程序之间的紧密合作，而且如何改写 API 目前还处于试验阶段并不成熟。

**Linux 零拷贝对比**
无论是传统 I/O 拷贝方式还是引入零拷贝的方式，2 次 DMA Copy 是都少不了的，因为两次 DMA 都是依赖硬件完成的。

下面从 CPU 拷贝次数、DMA 拷贝次数以及系统调用几个方面总结一下上述几种 I/O 拷贝方式的差别：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238417.png)

---------------------------

### Java与.Net对零拷贝的实现

#### Java NIO零拷贝实现

在 Java NIO 中的通道（Channel）就相当于操作系统的内核空间（kernel space）的缓冲区。

而缓冲区（Buffer）对应的相当于操作系统的用户空间（user space）中的用户缓冲区（user buffer）：
*   通道（Channel）是全双工的（双向传输），它既可能是读缓冲区（read buffer），也可能是网络缓冲区（socket buffer）。
*   缓冲区（Buffer）分为堆内存（HeapBuffer）和堆外内存（DirectBuffer），这是通过 malloc() 分配出来的用户态内存。

堆外内存（DirectBuffer）在使用后需要应用程序手动回收，而堆内存（HeapBuffer）的数据在 GC 时可能会被自动回收。

因此，在使用 HeapBuffer 读写数据时，为了避免缓冲区数据因为 GC 而丢失，NIO 会先把 HeapBuffer 内部的数据拷贝到一个临时的 DirectBuffer 中的本地内存（native memory）。

这个拷贝涉及到 sun.misc.Unsafe.copyMemory() 的调用，背后的实现原理与 memcpy() 类似。 

最后，将临时生成的 DirectBuffer 内部的数据的内存地址传给 I/O 调用函数，这样就避免了再去访问 Java 对象处理 I/O 读写。

1. **MappedByteBuffer**

MappedByteBuffer 是 NIO 基于内存映射（mmap）这种零拷贝方式提供的一种实现，它继承自 ByteBuffer。

FileChannel 定义了一个 map() 方法，它可以把一个文件从 position 位置开始的 size 大小的区域映射为内存映像文件。

抽象方法 map() 方法在 FileChannel 中的定义如下：

```
public abstract MappedByteBuffer map(MapMode mode, long position, long size)
        throws IOException;
```

2. **DirectByteBuffer**

DirectByteBuffer 的对象引用位于 Java 内存模型的堆里面，JVM 可以对 DirectByteBuffer 的对象进行内存分配和回收管理。

一般使用 DirectByteBuffer 的静态方法 allocateDirect() 创建 DirectByteBuffer 实例并分配内存。
```
public static ByteBuffer allocateDirect(int capacity) {
    return new DirectByteBuffer(capacity);
}
```

3. **FileChannel**

FileChannel 是一个用于文件读写、映射和操作的通道，同时它在并发环境下是线程安全的。

基于 FileInputStream、FileOutputStream 或者 RandomAccessFile 的 getChannel() 方法可以创建并打开一个文件通道。

FileChannel 定义了 transferFrom() 和 transferTo() 两个抽象方法，它通过在通道和通道之间建立连接实现数据传输的。

4. **Netty零拷贝**

Netty 中的零拷贝和上面提到的操作系统层面上的零拷贝不太一样, 我们所说的 Netty 零拷贝完全是基于（Java 层面）用户态的，它的更多的是偏向于数据操作优化这样的概念。具体表现在以下几个方面：
*   Netty 通过 DefaultFileRegion 类对 java.nio.channels.FileChannel 的 tranferTo() 方法进行包装，在文件传输时可以将文件缓冲区的数据直接发送到目的通道（Channel）。
*   ByteBuf 可以通过 wrap 操作把字节数组、ByteBuf、ByteBuffer 包装成一个 ByteBuf 对象, 进而避免了拷贝操作。
*   ByteBuf 支持 Slice 操作, 因此可以将 ByteBuf 分解为多个共享同一个存储区域的 ByteBuf，避免了内存的拷贝。
*   Netty 提供了 CompositeByteBuf 类，它可以将多个 ByteBuf 合并为一个逻辑上的 ByteBuf，避免了各个 ByteBuf 之间的拷贝。

> 其中第 1 条属于操作系统层面的零拷贝操作，后面 3 条只能算用户层面的数据操作优化。

#### .Net 环境下的零拷贝

.net下我搜索msdn的确找到了相关的winsock 2 API,后面关于使用winsock 2 API进行网络编程

1. **winsock 2 - Mswsock - TransmitFile**

TransmitFile是一个扩展的 API，它允许在套接字连接上发送一个打开的文件。这使得应用程序可以避免亲自打开文件，重复地在文件执行读入操作，再将读入的那块数据写入套接字。相反，已打开的文件的句柄和套接字连接一起给出的，在套接字上，文件数据的读入和发送都在模式下进行。这就避免了多次的用户/内核模式切换。与linux的sendfile函数类似。

[winsock 2 transmitFile](https://docs.microsoft.com/zh-cn/windows/win32/api/mswsock/nf-mswsock-transmitfile)

对应在 c# 中,可以使用 `Socket.SendFile`,`HttpResponse.Tran'smitFile`的封装来调用该API.

[Socket.SendFile](https://docs.microsoft.com/zh-cn/dotnet/api/system.net.sockets.socket.sendfile)

[HttpResponse.TransmitFile](https://docs.microsoft.com/zh-cn/dotnet/api/system.web.httpresponse.transmitfile)

2. **winsock 2 - Mswsock -TransmitPackets**

同样类似的API还有 TransmitPackets , 需要注意 TransmitFile的 wirte,send 大小是一个 DWORD 值,是一个32位值,即最多只有4GB.所以当需要传输的数据大小超过4GB是肯定需要使用 TransmitPackets的.

[winsock 2 transmitPackets](https://docs.microsoft.com/zh-cn/windows/win32/api/mswsock/nc-mswsock-lpfn_transmitpackets)

对应在 c# 中,可以使用 `Socket.SendPacketAsync`, 这个方法在windows客户端上时有特别优化的,可以使用 APC模式对内存和资源占有率进行优化.具体时通过 `TransmitFileOptions.UseKernelApc`来使用的.

[Socket.SendPacketsAsync](https://docs.microsoft.com/zh-cn/dotnet/api/system.net.sockets.socket.sendpacketsasync)

-----------------

### RocketMQ 和 Kafka 两种消息队列在零拷贝实现方式上的区别

RocketMQ 选择了 mmap+write 这种零拷贝方式，适用于业务级消息这种小块文件的数据持久化和传输。

而 Kafka 采用的是 Sendfile 这种零拷贝方式，适用于系统日志消息这种高吞吐量的大块文件的数据持久化和传输。但是值得注意的一点是，Kafka 的索引文件使用的是 mmap+write 方式，数据文件使用的是 Sendfile 方式。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238421.png)


