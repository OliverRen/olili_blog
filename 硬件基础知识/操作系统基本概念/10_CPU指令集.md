---
title: CPU指令集
---

[toc]

我们都知道之所以计算机能够进行计算，主要靠的是大规模集成电路中由晶体管组成的逻辑电路。这些逻辑电路使得计算机能够进行运算及判断。但对于一个简单逻辑电路来讲，它只能进行一个完整运算中的部分操作，所以人们通过组合这些简单逻辑电路，这样就可以让计算机进行复杂的运算了。

当CPU设计人员将这些组合逻辑电路制作成通用运算单元后，我们将一定格式的指令及数据输入，即可得到运算结果。而当需要的运算种类越来越多、运算越来越复杂后，CPU设计人员就将这些指令进行划分重构，组成一整套进行运算的集合，这就是指令集。

不过以上面向CPU指令集设计师及CPU微架构设计师的，CPU指令设计者将不同一些计算机操作设计成指令，然后微架构设计师通过这些指令的格式等进行微架构设计。而对于软件开发者，更多接触到的是软件层面的汇编语言，通过汇编语言指令就可以让程序员控制计算机了。计算机软硬件架构是有层次的，随着高级语言的开发，GUI的出现，更多的人可以方便的使用计算机。虽然编程语言越来越“高级”，软件越来越华丽，但是其依然需要通过CPU中的海量晶体管进行运算，调用指令集。

从英特尔开发出8086处理器开始，x86指令集就开始形成了，此后英特尔推出了80286、80386等处理器，虽然1985年时英特尔的处理器发展到32位的80386，但它依旧采用的是x86架构，而且在此后很长时间内，80386采用的指令集、编程模型及二进制格式仍然是所有32位x86处理器需要遵守的，而这也被称为x86或IA-32，统一的指令集、编程模型及二进制也让采用x86指令集架构的处理器成为PC市场的霸主。

随后如英特尔等厂商在此后的产品上添加了一些指令，如浮点指令等，这也让处理器满足了人们对计算机更高性能的需求。在新世纪到来后，又发展出了最新的x86-64指令集，也提供了对传统的32位x86指令集的兼容，同时如Windows 10、大部分基于Linux内核操作系统都还提供32位兼容。

不过如x86指令集不能满足我们在计算机中的所有工作，所以在基础的x86指令集上，CPU指令集设计人员又向x86指令集中添加了一些有用的指令集，以方便软件开发人员进行开发。不过随着计算机多媒体时代的来临，导致用户对计算机性能的要求越来越高，所以为了应对并行计算等需求，处理器设计设计生产厂商开始在x86指令集之外开发扩展指令集（Extended Instruction Sets）,这些指令集通常能有强大的并行计算能力，可以大幅加速部分运算的速度，这样就可以进行多媒体处理等需要大量运算的任务。

从1998年AMD的K6-2架构发布后，3D!Now、MMX等扩展指令集依次被添加进入CPU中，使得CPU的通用并行计算能力越来越强。到现在英特尔及AMD已经开发出了非常多的扩展指令集，如SSE（Streaming SIMD Extensions，流式单指令多数据流扩展）、VT-x（Intel Vertualization）、AES-IN（高级加密标准指令集）、AVX（Advanced Vector Extensions，高级矢量扩展），而这些指令集不仅影响了程序员，通过使用这些扩展指令集编写程序，可以加速运算，为我们带来更可靠、强大、实用的软件，而且对普通用户，我们也能通过这些软件应用体验到扩展指令集带来的优势，那么到具体应用中，我们在日常中使用了那些指令集呢?

**第一大类：基础运算类x86、x86-64及EM64T等**

在Intel推出8086处理器之后，x86指令集（x86 Instruction Sets）就形成了。在8086/8088处理器中采用最初的x86指令集中主要为数据操作，如ADD（数据加）、DIV（数据除）等数据运算操作，AND（逻辑加）、OR（逻辑或）等逻辑操作，MOV（CPU内或CPU与内部存储器之间传送数据）、JMP（跳转）等指令，这些基础指令组成了最初的x86指令集。

而从此后，Intel等厂商也在扩展X86指令集，添加了很多有关堆栈、状态的指令。随着这些指令的增加，让能够让处理器快速执行一些了基础运算、逻辑判断。

在2001年后，AMD推出了x86-64指令集，自此x86架构处理器进入了64位时代。而后来Intel跟进推出了EM64T指令集。将所有通用寄存器从32位扩充至64位，而且虚拟内存地址空间和物理地址空间都大幅扩大，这些都有助于处理器运行效率的提高。

那么x86以及之后推出的x86-64以及EM64T主要是针对计算机运行的基础操作，如数据运算、数据操作以及逻辑判断。我们在运行基础的数据运算、数据操作及逻辑判断时都用的是处理器的x86指令集、它为计算机的提供基础的基础运算能力，逻辑判断能力。但随着处理器并行化计算的趋势，接下来这些指令集是负责目前目前处理器中更多的计算任务。

**第二大类：SIMD指令集，有SSE系列，AVX系列**

随着对处理器数据处理能力需求的增强，面对更大数据量、更复杂的计算，单纯使用x86指令集已不足以满足需求，所以AMD K6-2处理器推出后，SIMD多媒体指令集的出现让处理器的浮点矢量运算、并行处理能力大幅增强。

最初的3D!Now、MMX指令集推出的时候，计算机的3D图形能力不强，所以那时MMX等指令集会对3D、2D计算进行加速。而后来推出的SSE系列指令集以及AVX指令集的出现将CPU处理数据的宽度从最初的64位到最新的AVX512系列指令集的512位，都是为了增强处理器的并行计算能力的。而以2010年为节点，之前的就是SSE系列，之后就是AVX系列。

虽然如3D运算是由GPU计算，不过由于对细碎数据并行计算能力较强，编程模型更加易用，所以到现在用处依旧非常广泛。而随着数据宽度提升，如目前火热的人工智能应用都可以进行加速。

之所以将这类SSE、AVX放在一起，是因为虽然它们之间有很多区别，但它们都是SIMD（单指令多数据流）指令集，所以AVX可以看做是SSE指令集的延续。

- 多媒体应用
	虽然现在更多的如2D、3D计算是在GPU中处理的，但是依旧有多媒体应用使用处理器中的SSE等指令集进行计算。虽然如视频编解码都已经有专门的处理单元了，但是还是有视频编解码应用采用SSE、AVX指令集。如著名的音视频处理软件FFmpeg就有使用SSE指令集进行音视频处理的编解码器。而x264、x265视频编码器也可以使用AVX2甚至是AVX-512来加速编码。

- 视频压缩软件使用了SSE2指令集
	而随着技术的发展，我们浏览的网页也越来越华丽，图片，视频等为我们展现了丰富的内容，而这些内容也需要通过更多的计算性能，通过SSE等指令集渲染网页中的图像等内容。如我们常用的Chrome浏览器，在2014年后，就只支持含有SSE2指令集的处理器（国内很多浏览器也是使用的Chromium内核）。而FireFox（火狐）浏览器也在49版本后只支持有SSE2指令集的处理器。

- 加解密运算
	虽然SSE等SIMD指令集最初是为了加速3D等多媒体任务的，但是再后来其对很多大量并行数据超强的处理能力及更宽的数据宽度让其可以执行更多的任务。随着数据信息安全越来越重要，越来越多的加解密应用使用了SSE、AVX指令集进行编解码操作。如我们常见的OpenSSL等就采用了AVX及AVX2指令集优化加密功能。而Ubuntu等操作系统采用的Linux内核中采用了AVX或AVX2指令集，作为AES-GCM等多种加密算法的优化实现。通过更高指令集的实现，可以让加解密运算更加迅速，而且相对于独立出来的AES-IN指令集，其更具有通用性，软件开发者不需要要对指令集做专门的适配。

- 数据序列化
	随着移动互联网的发展，移动设备也在产生着非常多的数据。而这些数据是有一定格式的，如常见的XML（可扩展标记语言）、JSON（一种轻量级数据交换语言）。而无论是移动设备，还是接收数据的服务器，都是需要解析这些数据。而由于格式固定，所以可以海量的数据可以通过并行化的方式进行解析，让程序获得需要的数据。

- JSON格式的数据
	现在已经有一些采用SSE指令集的数据解析程序，这些程序代码被一些应用使用，非常快速高效的解析获取的数据，并将数据呈现给使用者。

- 游戏
	在游戏中现在也大量的使用SSE、AVX指令集。由于游戏画面需要大量的坐标等数据，而坐标等向量数据使用SSE指令集正是处理这类数据最好的方式。通常程序并行化编程可以加速矩阵乘法等游戏中常用的运算，所以一些游戏开发者会开发专门的数学库，以加速这类运算。
	而除了对游戏进行优化外，部分开发商还会使用Denuvo、VMPortect等进行加密，Denuvo、VMPortec需要处理器支持如AVX指令集等进行加密。此前育碧推出的《刺客信条：奥德赛》最初的版本需要支持AVX指令集的处理器才可以运行，而随后由于玩家向育碧反映，育碧修复了这个“问题”。此后也有很多游戏采用了VMProtect，所以如果玩家需要运行未来的游戏，需要注意一下处理器支持的指令集了。Intel的初代酷睿处理器（如Core i7-920）支持SSE4.2指令集，而到了第二代酷睿处理器（如Core i7-2600K）开始正式支持AVX指令集，所以玩家们不仅因为性能，还应该考虑未来游戏需要支持的指令集（支持正版）。

- 科学计算&人工智能
	虽然科学计算对于大部分用户来说比较久远，但是这也是计算机最重要的应用之一。科学计算通常需要强大的并行计算能力，而且这类应用也是浮点密集型应用，所以SSE、AVX指令集可以起到加速这类应用的目的。
	而目前大热的人工智能，当采用CPU进行机器学习运算时，如AVX这类并行化的指令集也可以加速学习速度。著名的机器学习框架TensorFlow从1.6版开始要求处理器至少支持AVX指令集。而Intel在最新的Ice Lake-U处理器中内置的AVX-512指令集甚至对机器学习进行了优化。
	以上的应用都是我们都会用到的，而很多编程语言的代码库中都会有一些支持SSE、AVX指令集的接口，而这些指令集的通用性很强，所以未来会有更多的应用采用这些指令集进行编程，同时我们也会体会到这些指令集的优势。
	
- 检测处理性能，跑分 : 
	由于这些指令集构成的具体处理器架构实现，同时采用这些指令集的软件在运行时会让CPU高负荷运行，所以用专门编写运行这些指令集的软件，然后将运行时间等进行量化，可以测试处理器性能。我们常用的测试有很多，如AIDA64、CINEBench等都会使用到这些指令集，而最终测试得到的分数就可以作为评判处理器性能的标准。

**第三大类：虚拟化指令集Intel，虚拟机应用**

虚拟化技术不是一项新技术，在20世纪60年代末，IBM公司就通过在硬件之上添加一套软件抽象层，将计算机硬件虚拟分割成一个或多个虚拟机（Virtual Machine）。而这种划分计算机资源的技术就是虚拟化技术。

目前大多数x86指令集架构的处理器才用的是硬件抽象级别虚拟化技术，通过这种有限的硬件虚拟化技术，虚拟机软件隐藏不同厂商的处理器、存储器等特征，为虚拟机提供抽象且统一的虚拟平台。

英特尔及AMD都在2006年后在处理器中提供了虚拟化指令集，Intel为VT-x，AMD为AMD-V，而随后两家又推出了可以支持直接存储器访问（Direct Memory Access，DMA）以及PCIe设备直接访问的VT-d及AMD-Vi技术。现在这些虚拟化指令集能为目前的x86指令集架构的处理器提供运行高效的虚拟机。

虽然我们都听说过虚拟机，但实际上我们也会使用到虚拟化技术。我们移动设备中的一些应用使用的服务器很多都是通过处理器虚拟化技术划分出的虚拟机，软件开发商通过购买云服务，然后再这些虚拟机中运行自己的程序，为用户提供服务。

有时候我们自己会通过开源的Virtualbox、需要购买的VMware Workstation等软件去安装自己的虚拟机，然后在虚拟机里安装应用，与本机进行隔离。如信息安全研究人员会通过虚拟机来进行安全研究。

**第四大类：安全类指令集，如加解密AES-IN指令集**

现在信息安全问题越发突出，而对数据进行加密也是很多用户进行的操作。但是通过基础指令进行加解密速度不甚理想，而虽然现在已经可以通过AES等指令集进行并行化加密，但是人类在追求速度上是无止境的。所以Intel及AMD都在处理器中添加了针对加解密的指令集，Intel处理器内有AES（先进加密标准）指令集，而AMD这边出了AES指令集外，还有SHA（安全散列算法）指令集。

这些指令集都是为数据进行加解密操作的，其中AES指令集是为了加速目前非常流行的AES（如NAS产品会称支持AES加密）加解密算法的。而AMD支持的SHA指令集支持SHA加解密算法。这些指令集的加入甚至可以让加解密操作实时执行，在保证用户数据安全的同时，不会影响实际使用。

**第五大类：多线程应用，TSX事务同步扩展指令集**

TSX（事务同步扩展）作为近几年新增的指令集，是一个小透明一样的存在。从Intel的Haswell架构开始在第四代酷睿处理器开始提供。TSX指令集可以实现事务代码的预测执行，硬件监测多个线程以进行冲突的内存访问，加速多线程软件的执行。

然而看似美好的事情可能存在风险，在2016年，信息安全研究人员发现了利用侧信道攻击发现的TSX漏洞。而在随后的处理器中Intel修复了这个漏洞。

Finally :

当处理器指令集设计者不再将扩展基本的x86指令集后，添加扩展指令集成为了x86处理器设计厂商的主流。而这些设计者也极具远见，从现在来看，目前我们常见CPU中的指令集都有具体使用，而随着编译器等软件开发工具的添加这些指令集的支持，相信会有越来越多的程序开始支持，我们使用的软件也会以越来越高的效率运行。