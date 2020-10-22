---
title: libp2p简介
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

#### 术语

[doc](https://docs.libp2p.io/reference/glossary/)

**Circuit Relay** : 由于网络,或应用协议的不同等原因,peer与peer之间无法直接建立连接进行通信,此时就可以由这些愿意充当中介的第三方 peer来充当"继电器",分别建立与双方的连接并转发信息以实现通信.

**DHT** : 即 `distributed hash table`








#### libp2p

1. libp2p 简介 </br>
	libp2p 是一个模块化的网络栈,通过将各种传输和 P2P 协议结合在一起,使得开发人员很容易构建大型,健壮的 P2P 网络. [libp2p.io官网](https://libp2p.io/)

	libp2p 被用作IPFS的网络层,主要负责发现节点,连接节点,发现数据,传输数据.

	libp2p 集成了各种传输协议和点对点协议,其主要作用是发现节点和内容,并且让不同的网络协议能够互相之间顺利的传送数据.开发人员可以使用 libp2p 轻松构建大型,稳定的 p2p 网络. libp2p 主要包含了如下技术实现

	- Transports : 传输
	- Discovery : 发现
	- Peer Routing : 节点路由
	- NAT Traversal : NAT穿透
	- Content Routing : 内容路由

2. libp2p 架构 </br>
	*   ==Discovery 发现== </br>
		发现和识别网络中的其他节点.	
	*   ==Distributed Record Store 分布式记录存储== </br>
		存储和分发记录的系统,负责记录节点相关的各种信息,便于连接管理和内容寻址.	
	*   ==Peer Routing 节点路由== </br>
		用来决定使用哪些节点来路由指定的消息.这种路由机制可以递归甚至在广播/组播模式下完成.	
	*   ==Swarm 连接处理== </br>
		负责管理节点之间连接的创建,维护,销毁.包括协议多路复用,流多路复用,NAT穿透和连接中继,同时进行多路传输.ps:更新的版本也有叫switch的,取决于何种实现		
		
3. libp2p 流程 </br>
	-  运行 libp2p 协议的节点在初始化之后需要通过各种方式发现更多的节点,比如Bootstrap list,mDNS,DHT 等,这主要由 **Discovery模块** 负责与实现
	-  libp2p 会把这些获取到的节点信息存储在 **Distributed Record Store模块** 中,供以后方便使用
	-  当上层应用需要连接某个节点时, **Peer Routing模块** 会找到多条不同的路径, **Swarm模块** 会对这些路径进行尝试连接.(由于P2P网络本身的特性,节点之间的连接状况始终在动态变化,故不是所有路径都是可以成功连接的～)
	-  连接成功之后,上层应用将通过 libp2p 与连接节点进行交互,互相传递数据

	1. 地址解析(multiaddr) </br>
		为了适应复杂的网络环境,libp2p 支持多种不同的底层协议,甚至 IPFS 社区专门立了一个项目来标准化节点的地址[multiaddr](https://github.com/multiformats/multiaddr).目前 libp2p 主要支持以下几种地址格式,通过地址解析, libp2p 能获知如何才能连接到目的节点,下一步就是尝试建立连接.
		*   `/ip4/127.0.0.1/tcp/4001/ipfs/QmNodeID` : 这种格式跟传统的 TCP 网络里是一样的,直接可以解析出对应的 IPv4 地址和端口号
		*   `/ipfs/QmNodeID` : 这种格式的地址适用于 IPFS 网络,只有节点ID的地址,需要节点路由模块找到节点对应的IP地址,然后再进行连接
		*   `/dns4/http://ipfs.ipfsbit.com/tcp/443/wss/p2p-webrtc-star` : 这种地址需要调用`multiaddr-dns`组件,把域名解析成IP地址,然后再进行连接
		*   `/p2p-circuit/p2p/QmNodeID` : 这种地址是 relay 地址,用于中继网络,需要首先连接一个中继节点,才能连接到目的节点
	2. 传输协议分配 </br>
		地址里面的`/tcp`,`/quic`,`/ws`,`/p2p`分别对应不同的传输协议实现. libp2p 定义了统一的,选择地址对应的传输协议,调用传输协议的连接函数尝试连接目的节点.
	3. 双方协商 </br>
		连接建立之后, libp2p 会首先进行双方协商,确定对方支持哪些功能.负责协商功能的是 identify 协议,它是内置在 libp2p 的基础协议,能够交换节点的公钥,本地监听地址等.

		协商完成后,连接两端的节点会找到共同支持的协议,并且初始化它们.初始化时会注册每种协议的 handler 回调函数,当有协议数据到达时,相应的 handler 就会被调用.由于多种传输协议会复用同一个底层连接,所以连接会被拆分成多个“流(Stream)”.

		libp2p 可以通俗理解成适用于多种传输协议的P2P网络层.由于目前网络模式多种多样,比如4G 网络/宽带网络,拨号/固定公网IP,以及还有着各式各样的传输协议(TCP,UDP等等)和网络防火墙的通信阻碍,所以导致这个协议的实现是非常复杂的.
		
4. NAT 遍历 </br>
	- automatic route configuration </br>
		许多路由器支持端口转发的自动配置协议,最常见的是 `upnp` 和 `nat-pmp`.如果路由器支持这些协议之一,则 libp2p 将尝试自动配置端口映射,以使其能够侦听传入的流量.如果网络和 libp2p 实现支持,这通常是最简单的选项.
	- stun </br>
		在内部机器拨号建立了到公网地址的连接时,海可以接收到在公网地址端口上的传入连接,并会路由到内部计算机的内部IP.但遗憾的是,内部计算机并不会自行发现公网地址上分配给他们连接的端口

		但是,外部的对等节点可以告诉他们观察到的地址,并进行广播,让对等网络知道在哪里可以找到这些内部节点.

		当使用IP支持的传输的时候, libp2p 会尝试使用套接字选项通过相同的端口来继续宁传输.

		这种外部发现机制的作用和 STUN 相同,但并不需要一组 STUN 服务器.
	- AutoNAT </br>
		上面描述的方式可以使 peer 之间相互通知自己观察到的网络地址,但并非所有网络都允许在拨出的公网地址上的同一端口接受传入连接.

		那么其他 peer可以帮助我们察觉到这个处境,他们可以通过我们自己连接到的对等地址来连接我们
	- TURN </br>
		当然也有可能 peer完全无法以nat的方式获得可公开访问的途径, libp2p 提供了 TURN 使得 peer 之间通过一个中间对等节点来相互通信.

		这就是 `Circuit relay`,它可以让两个 peer 通过一个第三方的继电器 peer 相互通信.

		中继协议是非透明的,即通信双方可以看到这个中继地址

		中继协议仅在peers双方都可以发现并愿意对两端访问进行中继中继对等 peer 才有效.
		
5. 多路复用 </br>
	libp2p 中的多路复用和 tcp/ip 使用端口号来多路复用不同.他是在应用层实现的,这意味着它不是操作系统的网络堆栈来提供的功能.

	libp2p 中一般是在初始配置中对这一模块进行启用的配置,然后在 swarm (或者称为 switch 取决于实现) 的组件中维护有关已知对等项和连接的状态的. swarm 提供了 dial 和 listen 的接口可以用来处理流的多路复用.
	
	
	
	
---------------------

- [完整的libp2p文档doc](https://docs.libp2p.io/)
- [libp2p说明书github spec](https://github.com/libp2p/specs)