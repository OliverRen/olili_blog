---
title: 06_ZeroCopy零拷贝技术
tags: 
---

零拷贝描述的是CPU不执行拷贝数据从一个存储区域到另一个存储区域的任务,让CPU解脱出来专注于别的任务。

这样就可以让系统资源的利用更加有效，这通常用于通过网络传输一个文件时以减少CPU周期和内存带宽。

避免数据拷贝可以从这几方面区考虑
- 避免操作系统内核缓冲区之间进行数据拷贝操作。
- 避免操作系统内核和用户应用程序地址空间这两者之间进行数据拷贝操作。
- 用户应用程序可以避开操作系统直接访问硬件存储。

实现零拷贝用到的最主要的技术就是 `DMA 数据传输技术` 和 `内存区域映射技术`
- 零拷贝机制可以减少数据在内核缓冲区和用户进程缓冲区之间反复的 I/O 拷贝操作。
- 零拷贝机制可以减少用户进程地址空间和内核地址空间之间因为上下文切换而带来的 CPU 开销。

DMA(Direct Memory Access，直接存储器访问) 是所有现代电脑的重要特色，它允许不同速度的硬件装置来沟通，而不需要依赖于 CPU 的大量中断负载。否则，CPU 需要从来源把每一片段的资料复制到暂存器，然后把它们再次写回到新的地方。在这个时间中，CPU 对于其他的工作来说就无法使用。

I/O内存映射 : 在现代操作系统中。引用了I/O内存映射。即把寄存器的值映射到主存。对设备寄存器的操作，转换为对主存的操作，这样极大的提高了效率。

网卡缓冲区: NIC (network interface card) 在系统启动过程中会向系统注册自己的各种信息，系统会分配 Ring Buffer 队列也会分配一块专门的内核内存区域给 NIC 用于存放传输上来的数据包。

PS:现在还有适用于网络传输的 `RDMA` 技术,这与硬件结合的较为紧密,这里不再展开

---------------------------------

#### 传输机制

Linux 提供了轮询、I/O 中断以及 DMA 传输这 3 种磁盘与主存之间的数据传输机制。
1. 轮询方式是基于死循环对 I/O 端口进行不断检测,不再多讲
2. I/O 中断方式是指当数据到达时，磁盘主动向 CPU 发起中断请求，由 CPU 自身负责数据的传输过程。
3. DMA 传输则在 I/O 中断的基础上引入了 DMA 磁盘控制器，由 DMA 磁盘控制器负责数据的传输，降低了 I/O 中断操作对 CPU 资源的大量消耗。

在 DMA 技术出现之前，应用程序与磁盘之间的 I/O 操作都是通过 CPU 的中断完成的。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238351.png)

每次用户进程读取磁盘数据时，都需要 CPU 中断，然后发起 I/O 请求等待数据读取和拷贝完成，每次的 I/O 中断都导致 CPU 的上下文切换：
*   用户进程向 CPU 发起 read 系统调用读取数据，由用户态切换为内核态，然后一直阻塞等待数据的返回。
*   CPU 在接收到指令以后对磁盘发起 I/O 请求，将磁盘数据先放入磁盘控制器缓冲区。
*   数据准备完成以后，磁盘向 CPU 发起 I/O 中断。
*   CPU 收到 I/O 中断以后将磁盘缓冲区中的数据拷贝到内核缓冲区，然后再从内核缓冲区拷贝到用户缓冲区。
*   用户进程由内核态切换回用户态，解除阻塞状态，然后等待 CPU 的下一个执行时间钟。

DMA 的全称叫直接内存存取（Direct Memory Access），是一种允许外围设备（硬件子系统）直接访问系统主内存的机制。

也就是说，基于 DMA 访问方式，系统主内存于硬盘或网卡之间的数据传输可以绕开 CPU 的全程调度。
目前大多数的硬件设备，包括`磁盘控制器`、`网卡`、`显卡`以及`声卡`等都支持 DMA 技术。

整个数据传输操作在一个 DMA 控制器的控制下进行的。CPU 除了在数据传输开始和结束时做一点处理外（开始和结束时候要做中断处理），在传输过程中 CPU 可以继续进行其他的工作。这样在大部分时间里，CPU 计算和 I/O 操作都处于并行操作，使整个计算机系统的效率大大提高。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238370.png)

有了 DMA 磁盘控制器接管数据读写请求以后，CPU 从繁重的 I/O 操作中解脱，数据读取操作的流程如下：
*   用户进程向 CPU 发起 read 系统调用读取数据，由用户态切换为内核态，然后一直阻塞等待数据的返回。
*   CPU 在接收到指令以后对 DMA 磁盘控制器发起调度指令。
*   DMA 磁盘控制器对磁盘发起 I/O 请求，将磁盘数据先放入磁盘控制器缓冲区，CPU 全程不参与此过程。
*   数据读取完成后，DMA 磁盘控制器会接受到磁盘的通知，将数据从磁盘控制器缓冲区拷贝到内核缓冲区。
*   DMA 磁盘控制器向 CPU 发出数据读完的信号，由 CPU 负责将数据从内核缓冲区拷贝到用户缓冲区。
*   用户进程由内核态切换回用户态，解除阻塞状态，然后等待 CPU 的下一个执行时间钟。

---------------------------

#### 传统读写

先简单的阐述一下相关的概念:
*   上下文切换： 当用户程序向内核发起系统调用时，CPU 将用户进程从用户态切换到内核态；当系统调用返回时，CPU 将用户进程从内核态切换回用户态。
*   CPU 拷贝： 由 CPU 直接处理数据的传送，数据拷贝时会一直占用 CPU 的资源。
*   DMA 拷贝： 由 CPU 向DMA磁盘控制器下达指令，让 DMA 控制器来处理数据的传送，数据传送完毕再把信息反馈给 CPU，从而减轻了 CPU 资源的占有率。

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

----------------------------

#### Linux中实现

在 Linux 中零拷贝技术主要有 3 个实现思路：
*   用户态直接 I/O： 应用程序可以直接访问硬件存储，操作系统内核只是辅助数据传输。
    这种方式依旧存在用户空间和内核空间的上下文切换，硬件上的数据直接拷贝至了用户空间，不经过内核空间。因此，直接 I/O 不存在内核空间缓冲区和用户空间缓冲区之间的数据拷贝。
*   减少数据拷贝次数： 在数据传输过程中，避免数据在用户空间缓冲区和系统内核空间缓冲区之间的 CPU 拷贝，以及数据在系统内核空间内的 CPU 拷贝，这也是当前主流零拷贝技术的实现思路。
*   写时复制技术： 写时复制指的是当多个进程共享同一块数据时，如果其中一个进程需要对这份数据进行修改，那么将其拷贝到自己的进程地址空间中，如果只是数据读取操作则不需要进行拷贝操作。


##### 用户态直接 I/O

用户态直接 I/O 使得应用进程或运行在用户态（user space）下的库函数直接访问硬件设备。

数据直接跨过内核进行传输，内核在数据传输过程除了进行必要的虚拟存储配置工作之外，不参与任何其他工作，这种方式能够直接绕过内核，极大提高了性能。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238371.png)

用户态直接 I/O 只能适用于不需要内核缓冲区处理的应用程序，这些应用程序通常在进程地址空间有自己的数据缓存机制，称为自缓存应用程序，如数据库管理系统就是一个代表。

其次，这种零拷贝机制会直接操作磁盘 I/O，由于 CPU 和磁盘 I/O 之间的执行时间差距，会造成大量资源的浪费，解决方案是配合异步 I/O 使用。

##### mmap+write

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
if(fcntl(diskfd, F_SETSIG, RT_SIGNAL_LEASE) ` -1) {
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

##### sendfile

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

##### Sendfile+DMA gather copy

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

##### 通过 splice 实现的零拷贝

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

##### 通过 写时复制

以上几种零拷贝技术都是减少数据在用户空间和内核空间拷贝技术实现的，但是有些时候，数据必须在用户空间和内核空间之间拷贝。这时候，我们只能针对数据在用户空间和内核空间拷贝的时机上下功夫了。Linux通常利用写时复制(copy on write)来减少系统开销，这个技术又时常称作COW。

大概描述下就是：如果多个程序同时访问同用户态直接 I/O一块数据，那么每个程序都拥有指向这块数据的指针，在每个程序看来，自己都是独立拥有这块数据的，只有当程序需要对数据内容进行修改时，才会把数据内容拷贝到程序自己的应用空间里去，这时候，数据才成为该程序的私有数据。如果程序不需要对数据进行修改，那么永远都不需要拷贝数据到自己的应用空间里。这样就减少了数据的拷贝。

##### 缓冲区共享

缓冲区共享方式完全改写了传统的 I/O 操作，因为传统 I/O 接口都是基于数据拷贝进行的，要避免拷贝就得去掉原先的那套接口并重新改写。

所以这种方法是比较全面的零拷贝技术，目前比较成熟的一个方案是在 Solaris 上实现的 fbuf（Fast Buffer，快速缓冲区）。

fbuf 的思想是每个进程都维护着一个缓冲区池，这个缓冲区池能被同时映射到用户空间（user space）和内核态（kernel space），内核和用户共享这个缓冲区池，这样就避免了一系列的拷贝操作。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238419.png)

> 缓冲区共享的难度在于管理共享缓冲区池需要应用程序、网络软件以及设备驱动程序之间的紧密合作，而且如何改写 API 目前还处于试验阶段并不成熟。

----------------------------------

Linux 零拷贝对比
无论是传统 I/O 拷贝方式还是引入零拷贝的方式，2 次 DMA Copy 是都少不了的，因为两次 DMA 都是依赖硬件完成的。

下面从 CPU 拷贝次数、DMA 拷贝次数以及系统调用几个方面总结一下上述几种 I/O 拷贝方式的差别：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/零拷贝(zero_copy)技术/2020811/1597124238417.png)