---
title: windows网络编程
---

[toc]

#### 前言

本文大量内容来自 PiggyXP 的 完成端口详解 和 aluluka 的 windows网络编程专栏,并经过删减.

文章通过服务端程序的并发处理客户端请求出发,使用不同的api,不断尝试减少系统开销,增加并发性能.下面就从winsocket2 API上按照技术发展或者说性能优化的顺序逐一说明.

#### 阻塞

网络编程的基本模型其实是 C/S 模型,即两个进程间的通信.例如通过tcp连接后,套接字进行通信.传统的方式是同步阻塞的,双方都是输入和输出流同步阻塞通信.通常由一个独立的Acceptor线程负责监听客户端的连接，接收客户端请求之后为每个客户端建立新线程进行链路处理，通过输出流返回给客户端，然后再进行线程销毁；

但是在服务端程序的设计中,一个服务器不可能只响应一个客户端的请求,为了响应多个客户端的链接，需要使用多线程的方式，每当有一个客户端连接进来，我们就开辟一个线程，用来处理双方的交互（主要是利用recv或者recvfrom用于收发信息），由于但是在网络中可能出现这样一种情况：由于处理比较复杂，下一条信息到来之后，上一条信息的处理还没有完成，这样信息太多了之后系统的缓冲占满之后可能会发生丢包的现象，所以为了解决这个问题，需要另外再开一个线程，专门用来处理接收到的数据，这样总共至少有3个线程，主线程，收发信息的线程，处理线程；这样可能也不完整，处理的操作种类多了的话可能需要根据不同的请求来开辟不同的线程用来处理这一类请求.

不过虽说这个解决了多个客户端与服务器通信的问题，但是这样写确定也很明显：所有的与客户端通信的socket都有程序员自己管理，无疑加重了程序员的负担；每有一个连接都需要创建一个线程，当有大量的客户端连接进来开辟的线程数是非常多的，线程是非常耗资源的，所以为了解决这些问题就提出了异步的I/O模型，它们解决了这些问题，由系统管理套接字，不要要人为的一个个管理，同时不需要开辟多个线程来处理与客户端的连接，我们可以将线程主要用于处理客户端的请求上；

#### select() 模型

上面说了传统模型中是同步阻塞的,也就是网络中有特定的事件发生时才会返回，在没有发生事件时会一直等待,就算设置成非阻塞状态也是到了超时时间返回,这样就需要一个死循环不断的轮询监听.特别是对于有多个客户端需要管理的时候，每一个与客户端通信的socket都需要一个侦听，这样管理起来非常麻烦，我们希望系统帮助我们管理，告诉我们有哪些socket现在可以操作。为了实现这个，我们可以使用select模型.

select模型使用 FD_SETSIZE  宏定义可以管理64个socket连接

下面说一下服务端一个简单的select模型的编写
1. 创建套接字，绑定、侦听；
2. 等待客户端链接
3. 将连接返回的套接字压入一个数组中保存
4. 将数组的套接字填入集合中
5. 调用select函数
6. 检测特定集合中的套接字
7. 进行读写操作
8. 返回到第四步，等待客户端下一步请求

在编写时需要注意以下几点：
- 为了与多个客户端保持连接，需要一个数组保存与客户端连接的所有的socket，由于select函数只会执行一次，每次返回后需要再次将徐监控的套接字压入集合，调用select，以便进行下一次检测；所以一般将这一步写在一个死循环中
- 注意select是一个阻塞函数，所以为了可以支持多个客户端可以采用一些方法：第一种就是采用多线程的方式，每有一个客户端连接都需要将新开一个线程处理并调用select监控；另一种就是调用select对侦听套接字以及与客户端通信的套接字；为什么可以这样呢，这就要说到TCP/IP中的三次握手，首先一般由客户端发起链接，发送一条数据包到服务器，服务器接收到数据，发送一条确认信息给客户端，然后客户端再发送一条数据，这样就正式建立连接，所以在客户端与服务器建立连接时必然会发送数据，而服务器一定会收到数据，所以将侦听套接字放入到read集合中，当有客户端需要连接时自然会收到一条数据，这个时候select会返回，我们需要校验集合中的套接字是否是侦听套接字，如果是则表明有客户端需要连接；这样当客户端有请求select会返回，可以进行下一次的侦听，没有请求，会死锁在select函数上，但是对于所有客户端并没有太大的影响；
- 我们用数组存储所有的套接字时，每当有客户端链接，我们需要添加，而有客户端断开链接我们需要在数组中删除，并将下一个套接字添加进该位置，为了管理套接字数组，我们另外需要一个队列用来记录退出客户端的socket在数组中的位置，下一次有新的链接进来就将相应的套接字放到这个位置。

> select 模型是程序线程主动的不断去轮询socket是否有数据要进行处理

#### WSAAsyncSelect消息模型

select模型虽然可以管理多个socket,但是他涉及到一个时机的问题,select模型会针对所管理的数组中的每一个socket循环检测它管理是否在对应的数组中，从时间复杂度上来说它是O(n^2)的,而且还有可能发生数组中没有socket处于待决状态而导致本轮循环做无用功的情况，针对这些问题，winsock中有了新的模型——WSAAsyncSelect 消息模型

消息模型的核心是基于Windows窗口消息获得网络事件的通知，Windows窗口是用来与用户交互的，而它并不知道用户什么时候会操作窗口，所以Windows窗口本身就是基于消息的通知，网络事件本身也是一个通知消息，将二者结合起来可以很好的使socket通知像消息那样当触发通知时调用窗口过程。这样就解决了select中的时机问题和里面两层循环的问题

如果对一个句柄调用了WSAAsyncSelect 并成功后，对应的socket会自动变成非阻塞模式

该模型相对于select来说省去了查看socket是否在对应数组中的操作，减少了循环。而且可以很好的把握什么调用时机问题。
主要的缺点是它需要一个窗口，这样在服务程序中基本就排除掉了这个模型，它基本上只会出现在客户端程序中。
另外如果在一个窗口中需要管理成千上万个句柄时，它的性能会急剧下降，因此它的伸缩性较差。但是在客户端中基本不存在这个问题，所以如果要在客户端中想要减少编程难度，它是一个不二的选择

> WSAAsyncSelect 是通过窗口消息来通知服务线程相应的socket上有数据需要进行处理.

#### WSAEventSelect模型

该模型主要特色在于它使用事件句柄来完成SOCKET事件的通知。与WSAAsyncSelect 模型类似，它也允许使用事件对象来完成多个socket的完成通知。该模型首先在每个socket句柄上调用WSACreateEvent来创建一个WSAEvent对象句柄,接着调用WSAEventSelect将SOCKET句柄和WSAEvent对象绑定，最终通过WSAWaitForMultiEvents来等待WSAEvent变为有信号，然后再来处理对应的socket.

WSAEvent工作状态有有信号和无信号两种
工作模式有手工重置和人工重置，手工重置指的是每当WSAWaitForMultiEvents或者WSAWaitForSingleEvents 返回之后，WSAEvent不会自动变为无信号，需要手工调用WSAResetEvent来将WSAEvent对象设置为无信号，而自动重置表示每次等待函数返回后会自动重置为无信号；调用WSACreateEvent创建的WSAEvent对象是需要手工重置的，如果想创建自动重置的WSAEvent对象可以调用CreateEvent函数来创建

> WSAEventSelect 是通过在socket句柄上创建WSAEvent并进行绑定,然后等待WSAEvent有信号回调来处理相应的socket,关于 WSAEvent的工作模式,可以参考 C# 的ManualResetEvent喝AutoResetEvent

我们总结一下使用WSAEventSelect模型的步骤
1. 调用WSACreateEvent为每一个SOCKET创建一个等待对象，并与对应的SOCKET形成映射关系
2. 调用WSAEventSelect函数将SOCKET于WSAEvent对象进行绑定
3. 调用WSAWaitForMultipleEvents 函数对所有SOCKET句柄进行等待
4. 当WSAWaitForMultipleEvents 函数返回时利用返回的索引找到对应的WSAEvent对象和SOCKET对象
5. 调用WSAEnumNetworkEvents来获取对应的网络事件，根据网络事件来进行对应的收发操作
6. 重复3~5的步骤

--------------------

#### 重叠IO模型

上述介绍的 WSAAsyncSelect和WSAEventSelect模型解决了线程需要去处理socket的收发数据的实际问题.但是网卡这种设备相比于 CPU和内存 来说依然是慢速设备,而调用send和recv进行数据依然是同步的操作,及时我们能够异步的,在恰当的时间调用对应的函数进行收发操作,但是依然需要CPU去同步等待网络执行.

重叠IO最早是在读写磁盘时提出的一种异步操作模型，它主要思想是CPU只管发送读写的命令，而不用等待读写完成，CPU发送命令后接着去执行自己后面的命令，至于具体的读写操作由硬件的DMA来控制，当读写完成时会向CPU发送一个终端信号，此时CPU中断当前的工作转而去进行IO完成的处理。

> **重叠结构(OVERLAPPED)**
> 至于为什么叫Overlapped？Jeffrey Richter的解释是因为“执行I/O请求的时间与线程执行其他任务的时间是重叠(overlapped)的”，从这个名字我们也可能看得出来重叠结构发明的初衷了.
>
> 这里我想要解释的是，这个重叠结构是异步通信机制实现的一个核心数据结构，几乎所有的网络操作例如发送/接收之类的，都会用WSASend()和WSARecv()代替，参数里面都会附带一个重叠结构，这是为什么呢？
>
> 因为重叠结构我们就可以理解成为是一个网络操作的ID号，也就是说我们要利用重叠I/O提供的异步机制的话，每一个网络操作都要有一个唯一的ID号，因为进了系统内核，里面黑灯瞎火的，也不了解上面出了什么状况，一看到有重叠I/O的调用进来了，就会使用其异步机制，并且操作系统就只能靠这个重叠结构带有的ID号来区分是哪一个网络操作了，然后内核里面处理完毕之后，根据这个ID号，把对应的数据传上去。

创建重叠IO的socket需要使用winsock2的WSASocket并将dwFl为 WSA_FLAG_OVERLAPPED
使用重叠IO除了要将SOCKET设置为支持重叠IO外，还需要使用对应的支持重叠IO的函数，之前了解的巴克利套接字函数最多只能算是支持非阻塞而不支持异步。在WinSock1.0 中可以使用ReadFile和WriteFile来支持重叠IO，但是WinSock2.0 中重新设计的一套函数来支持重叠IO
- WSASend (send的等价函数)
- WSASendTo (sendto的等价函数)
- WSARecv (recv的等价函数)
- WSARecvFrom (recvfrom的等价函数)
- WSAIoctl (ioctlsocket的等价函数)
- WSARecvMsg (recv OOB版的等价函数)
- AcceptEx (accept 等价函数)
- ConnectEx (connect 等价函数)
- TransmitFile (专门用于高效发送文件的扩展API)
- TransmitPackets (专门用于高效发送大规模数据包的扩展API)
- DisconnectEx (扩展的断开连接的Winsock API)
- WSANSPIoctl (用于操作名字空间的重叠I/O版扩展控制API)

> 比起比起阻塞、select、WSAAsyncSelect以及WSAEventSelect，使用重叠模型的应用程序通知缓冲区收发系统直接使用数据，也就是说，如果应用程序投递了一个10KB大小的缓冲区来接收数据，且数据已经到达套接字，则该数据将直接被拷贝到投递的缓冲区。
>
> 而这4种模型种，数据到达并拷贝到单套接字接收缓冲区中，此时应用程序会被告知可以读入的容量。当应用程序调用接收函数之后，数据才从单套接字缓冲区拷贝到应用程序的缓冲区，差别就体现出来了。

**重叠IO的通知**

需要注意的是，有两个方法可以用来管理重叠IO请求的完成情况（就是说接到重叠操作完成的通知）：

与文件的重叠IO类似，重叠IO的第一种模型就是事件通知模型(event object notification)
1. 利用该模型首先需要把一个event对象绑定到OVERLAPPED(WinSokc中一般是WSAOVERLAPPED)上，然后利用这个OVERLAPPED结构来进行IO操作.如:WSASend/WSARecv等
2. 判断对应IO操作的返回值，如果使用重叠IO模式，IO操作函数不会返回成功，而是会返回失败，使用WSAGetLastError得到的错误码为WSA_IO_PENDING,此时认为函数进行一种待决状态，也就是CPU将命令发送出去了，而任务没有最终完成
3. 然后CPU可以去做接下来的工作，而在需要操作结果的地方调用对应的等待函数 WSAWaitForMultipleEvents 来等待对应的事件对象。如果事件对象为有信号表示操作完成
4. 接着可以设置事件对象为无信号 WSAResetEvent，使用 WSAGetOverlappedResult 获取重叠IO的返回状态,然后继续投递IO操作.

> 但这种事件通知模型在资源的消耗上有时是惊人的。这主要是因为对于每个重叠I/O操作(WSASend/WSARecv等)来说,都必须额外创建一个Event对象。对于一个I/O密集型SOCKET应用来说,这种消耗会造成资源的严重浪费。由于Event对象是一个内核对象，它在应用层表现为一个4字节的句柄值，但是在内核中它对应的是一个具体的结构，而且所有的进程共享同一块内核的内存，因此某几个进程创建大量的内核对象的话，会影响整个系统的性能。

为此重叠I/O又提供了一种称之为完成过程方式的模型。该模型不需要像前面那样提供对应的事件句柄。它需要为每个I/O操作提供一个完成之后回调处理的函数。即 完成历程 (Completion Routine).
完成历程的本质是一个历程它仍然是使用当前线程的环境。它主要向系统注册一些完成函数，当对应的IO操作完成时，系统会将函数放入到线程的APC队列，当线程陷入可警告状态时，它利用线程的环境来依次执行队列中的APC函数、
要使用重叠I/O完成历程模型,那么也需要为每个I/O操作提供WSAOVERLAPPED结构体,只是此时不需要Event对象了。取而代之的是提供一个完成历程的函数

通俗的打个比方,完成例程的处理过程，也就像我们告诉系统，说“我想要在网络上接收网络数据，你去帮我办一下”（投递WSARecv操作），“不过我并不知道网络数据合适到达，总之在接收到网络数据之后，你直接就调用我给你的这个函数(比如_CompletionProess)，把他们保存到内存中或是显示到界面中等等，全权交给你处理了”，于是乎，系统在接收到网络数据之后，一方面系统会给我们一个通知，另外同时系统也会自动调用我们事先准备好的回调函数，就不需要我们自己操心了。

1. 使用该模型在有新的套接字连入后,新建立一个 WSAOVERLAPPED 重叠结构,当然可以提前建立好的,然后将其绑定到我们的重叠操作上,这里就不需要为 WSAOVERLAPPED 结构绑定 event了.
2. 在套接字上执行IO操作函数,同时传入我们准备的完成历程作为参数
3. 调用WSAWaitForMultipleEvents函数或者SleepEx函数等待重叠操作返回的结果,然后CPU就可以做其他工作了,当系统完成了网络通信,会自动调用我们的完成历程函数,只要调用完成,就意味着重叠IO已经完成了.

> 重叠IO模型是非阻塞,并且是异步,但是也依然有缺点,即使我们使用历程来处理完成通知，但是我们知道历程它本身是在对应线程暂停，它借用当前线程的线程环境来执行完成通知，也就是说要执行完成通知就必须暂停当前线程的工作。这对工作线程来说也是一个不必要的性能浪费，这样我们自然就会想到，另外开辟一个线程来执行完成通知，而本来的线程就不需要暂停，而是一直执行它自身的任务。处于这个思想，WinSock提供了一个新的模型——完成端口模型。

#### 完成端口(CompletionPort)

完成端口是第三种管理重叠I/O的方式,虽然都是基于重叠I/O，但是因为基于时间通知的重叠I/O和基于完成历程的重叠I/O都是需要自己来管理任务的分派，所以性能上没有区别，而完成端口是创建完成端口对象使操作系统亲自来管理任务的分派，所以完成端口肯定是能获得最好的性能。

对于完成端口这个概念，我一直不知道为什么它的名字是叫“完成端口”，我个人的感觉应该叫它“完成队列”似乎更合适一些，总之这个“端口”和我们平常所说的用于网络通信的“端口”完全不是一个东西，其本质是一个线程池一样的模型.

- 首先，它之所以叫“完成”端口，就是说系统会在网络I/O操作“完成”之后才会通知我们.
- 因为我们在之前给系统分派工作的时候，都嘱咐好了，我们会通过代码告诉系统“你给我做这个做那个，等待做完了再通知我”
- 然后在接到系统的通知的时候，其实网络操作已经完成了，就是比如说在系统通知我们的时候，并非是有数据从网络上到来，而是来自于网络上的数据已经接收完毕了；或者是客户端的连入请求已经被系统接入完毕了等等，我们只需要处理后面的事情就好了。
- 其次，我们需要知道，所谓的完成端口，其实和HANDLE一样，也是一个内核对象,我们暂时只用把它大体理解为一个容纳网络通信操作的队列就好了，它会把网络操作完成的通知，都放在这个队列里面，咱们只用从这个队列里面取就行了，取走一个就少一个

#### 历个模型的比较

最后针对5种模型和两种socket工作模式来做一个归纳说明。
1. 最先学习的是SOCKET的阻塞模式，它的效率最低，它会一直等待有客户端连接或者有数据发送过来才会返回。这就好像我们在等某个人的信，但是不知道这封信什么时候能送到，于是我们在自家门口的收信箱前一直等待，直到有信到来。
2. 为了解决这个问题，提出了SOCKET的非阻塞模式，它不会等待连接或者收发数据的操作完成，当我们调用对应的accept或者send、recv时会立即返回，但是我们不知道它什么时候有数据要处理，如果针对每个socket都等待直到有数据到来，那么跟之前的阻塞模式相比没有任何改进，于是就有了socket模式，它会等待多个socket，只要其中有一个有数据就返回，并处理。用收信的模型类比的话，现在我们不用在邮箱前等待了。但是我们会每隔一段时间就去邮箱那看看，有没有信，有信就将它收回否则空手而归。
3. 我们说select模型的最大问题在于不知道什么时候有待决的SOCKET，因此我们需要在循环中不停的等待。为了解决这个时机问题，又提出了WSAAsyncSelect模型和WSAEvent模型，它们主要用来解决调用对应函数的时机。用收信的例子类比就是现在我在邮箱上装了一个报警的按钮，只有有信，警报就会响，这个时候我们就去收信。而不用向之前那样每隔一段时间就去邮箱看看
4. 我们说解决了时机的问题，但是调用send和recv对网卡进行读写操作仍然是同步的操作，CPU需要傻傻的等着数据从网卡读到内存或者从内存写到网卡上。因此又有了重叠IO的模型和一些列的新的API，向WSARecv和WSASend等等函数。这样就相当于当有信来的警报响起时，我们不需要自己去取信了，另外派了一个人帮我们拿信，这样我们的工作效率又提高了一些。节约了我们的时间
5. 重叠IO也有它的问题，如果使用重叠IO的事件模型时，也需要在合适的时候等待，就好像我们虽然派了一个人来帮忙拿信，但是我们自己却需要停下手头上的工作，询问拿信的人回来了。而使用完成历程也存在自己的问题，因为它需要使用主线程的资源来执行历程，它需要主线程暂停下来，这样就可能出现两种情况：1）有通知事件到来，但是并没有进入可警告状态；2）进入可警告状态却没有客户端发送请求。这就相当于可能我们不停的等待但是拿信的那个人却没有回来，或者拿信的人回来了，我们却没有时间处理信件。
6. 针对重叠IO的上述问题，提出了完成端口的解决方案，完成事件由对应的线程处理，而主线程只需要专注于它自己的工作就好了，这就相当于警报响了，我们知道信来了，直接派一个人去拿信，后面的我就不管了，而拿信的人把信拿回来的时候将信放好。当我们忙完之后去处理这封信。没忙完的话信就一直放在那，甚至让拿信的人处理这封信，这样就能更高效的集中注意力来处理眼前的工作。

-----------------------

#### System.Net.Sockets 封装

Socket 类 的主要方法中

``` csharp
// Socket.Connect方法:建立到远程设备的连接
public void Connect(EndPoint remoteEP)（有重载方法）
// Socket.Send 方法:从数据中的指示位置开始将数据发送到连接的 Socket。
public int Send(byte\[], int, SocketFlags);(有重载方法)
// Socket.SendTo 方法 将数据发送到特定终结点。
public int SendTo(byte\[], EndPoint);（有重载方法）
// Socket.Receive方法:将数据从连接的 Socket 接收到接收缓冲区的特定位置。
public int Receive(byte\[],int,SocketFlags);
// Socket.ReceiveFrom方法：接收数据缓冲区中特定位置的数据并存储终结点。
public int ReceiveFrom(byte\[], int, SocketFlags, ref EndPoint);
// Socket.Bind 方法：使 Socket 与一个本地终结点相关联：
public void Bind( EndPoint localEP );
// Socket.Listen方法：将 Socket 置于侦听状态。
public void Listen( int backlog );
// Socket.Accept方法:创建新的 Socket 以处理传入的连接请求。
public Socket Accept();
// Socket.Shutdown方法:禁用某 Socket 上的发送和接收
public void Shutdown( SocketShutdown how );
// Socket.Close方法:强制 Socket 连接关闭
public void Close();
```
其中不支持异步得方法是
- Bind指定的EndPoint
- Listen指定长度的队列

支持异步操作的有
- Accept
- Connect
- Send,SendTo
- Recv,RecvFrom

支持异步的方法有两种风格,一种是老的 Begin,End异步回调风格,另外一种就是 XXXXAsync风格了
目前socket相关操作已经推荐使用 XXXXAsync代替 Begin,End的方式
可以参考 Stephen Cleary 的回答 [difference-between-async-and-begin-net-asynchronous-apis](https://stackoverflow.com/questions/3081079/difference-between-async-and-begin-net-asynchronous-apis)

PS:如果你一定要使用 Begin,End的方式,需要注意点,需要在execonfig中指明配置节点
``` xml
  <system.net>
    <settings>
      <socket
        alwaysUseCompletionPortsForAccept="true"
        alwaysUseCompletionPortsForConnect="true"
        ipProtectionLevel="Unrestricted"
      />
    </settings>
  </system.net>
```

因为BeginAccept方法会判断socket的CanUseAcceptEx属性,这个属性会读取配置文件
``` csharp
private bool CanUseAcceptEx
{
    get
    {
        if (!ComNetOS.IsWinNt)
        {
            return false;
        }
        if (!Thread.CurrentThread.IsThreadPoolThread && !SettingsSectionInternal.Section.AlwaysUseCompletionPortsForAccept)
        {
            return this.m_IsDisconnected;
        }
        return true;
    }
} 
```

**使用完成端口的基本流程**
在调用 XXXXAsync方法时会使用 `SocketAsyncEventArgs` 类 来包装最近一次操作的上下文,其中就包括了 Overlapped 重叠结构的对象

SocketAsyncEventArg 类中使用 `SockeAsyncOperation` 枚举 来记录最近一次操作的类型
可以看出这个枚举正好对应了上面支持Async方法的操作.

从framework源码中我们可以了解到:
SocketAsyncEventArg对象中使用实例方法
- `StartOperationCommon(socket)`
- `StartOperationXXXX`
来进行最近一次操作的上下文初始化

然后使用 `BindToCompletionPort()` 方法绑定完成端口,即将当前socket的 `SafeCloseSocket` 对象绑定到 `ThreadPool` 中.
虽然多个方法,或者外部会多次调用,但是一个socket只需要绑定一次即可.

SocketAsyncEventArg对象在完成端口 `CompletionPortCallback` 返回后,在方法 `FinishOperationSuccess` 中根据 最近一次执行操作 `SockeAsyncOperation` 枚举对象 `CompletedOperation` 来通过socket执行对应的操作把上下文更新,并通过 Completed事件通知调用方.

对于服务端来说,简单的流程如下
1. 拿一个socket bind到 endpoint 后开始listen.
2. 通过一个可以复用的 SocketAsyncEventArgs 调用 ==socket.AcceptAsync== 执行端口绑定.即该 SocketAsyncEventArgs 只执行 Accept 客户端过来的 connect. 这里其实 AcceptAsync 在执行 winsock 2的 AcceptEx时需要外部传入SOCKET作为传输数据用的SOCEKT,所以建议可以复数的 SocketAsyncEventArgs 初始化,在需要的时候选择一个作为AcceptEx连接用的SOCKET
2. 当客户端建立连接,并且有第一次数据接入的时候,AcceptEx 完成通知,就会通过 SocketAsyncEventArgs 将客户端接入的socket 通过 ==AcceptSocket== 属性表示, 服务端即可使用该socket与客户端通信了.需要注意的是,通过该socket进行 send和receive时也应该使用不同的 SocketAsyncEventArgs(可以复用),即基本思路就是该对象可以跨socket对象反复利用,但应当保证在一个时刻只有一个socket下一个用途.

**Socket 关闭的时候**

socket.Close 方法会关闭远程主机连接，并释放与 Socket关联的所有托管资源和非托管资源。 关闭时，Connected 属性设置为 false。
对于面向连接的协议，建议你在调用 Close 方法之前调用 Shutdown。 这可确保所有数据在连接的套接字关闭之前都已发送和接收。
这是因为在应用程序调用 Socket 或 TcpClient 方法后，传出网络缓冲区中可能仍有可用的数据。 

``` csharp
try
{
    aSocket.Shutdown(SocketShutdown.Both);
}
finally
{
    aSocket.Close();
}

```

如果需要在不首先调用 Shutdown的情况下调用 Close
可以指定Socket 在关闭后将尝试传输未发送数据的时间量
1.设置DontLinger=false,并指定一个超时时间来保证保将排队等待传出传输的数据发送,这时Close将被阻塞知道发送完数据或超过指定的时间
2.设置DontLinger=false,但是指定0为超时时间,或直接指定 DontLinger=true 时,Close会直接释放连接并丢弃未发出的数据

`client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.DontLinger, true);`

Linger 和 DontLinger 其实正好是相反意义的一对配置,意思是需要逗留,不过使用 Linger 选项则可以使用对象 LingerOption 来进行描述和配置
1. 设置 Linger=true,并指定一个seconds 参数非0的 LingerOption来保证socket尽可能将未发送的数据发出去,seconds 参数用于指示在超时前 Socket 保持连接的时间。
2. 设置 Linger=true,并指定 seconds参数为0,或直接指定 Linger参数为 false,在这种情况下，Socket 会立即关闭，任何未发送的数据都将丢失。

``` csharp
LingerOption myOpts = new LingerOption(true,1);
mySocket.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Linger, myOpts);
```
> IP 堆栈根据连接的往返时间来计算要使用的默认 IP 协议超时期限。 在大多数情况下，堆栈计算出的超时比应用程序定义的超时更密切。 

#### 本文参考资料:
1. [C# System.Net.Sockets.Socket MSDN API Explorer](https://docs.microsoft.com/zh-cn/dotnet/api/system.net.sockets.socket)
2. [C# System.Net.Sockets.Socket ReferenceSource](https://referencesource.microsoft.com/#System/net/System/Net/Sockets/Socket.cs)
3. [Winsock2 win32 API](https://docs.microsoft.com/zh-cn/windows/win32/api/winsock2/)
4. [.net framework中的网络编程](https://docs.microsoft.com/zh-cn/dotnet/framework/network-programming/)
5. PiggyXP的 [完成端口详解](https://blog.csdn.net/PiggyXP/article/details/6922277)
6. aluluka的 [windows网络编程专栏](https://blog.csdn.net/lanuage/category_5837519.html)
