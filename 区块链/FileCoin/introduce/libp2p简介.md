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

[toc]

#### 介绍

1. libp2p 简介

	libp2p 是一个模块化的网络栈,通过将各种传输和 P2P 协议结合在一起,使得开发人员很容易构建大型,健壮的 P2P 网络. [libp2p.io官网](https://libp2p.io/)

	libp2p 被用作IPFS的网络层,主要负责发现节点,连接节点,发现数据,传输数据.

	libp2p 集成了各种传输协议和点对点协议,其主要作用是发现节点和内容,并且让不同的网络协议能够互相之间顺利的传送数据.开发人员可以使用 libp2p 轻松构建大型,稳定的 p2p 网络. libp2p 主要包含了如下技术实现

	- Transports : 传输
	- Discovery : 发现
	- Peer Routing : 节点路由
	- NAT Traversal : NAT穿透
	- Content Routing : 内容路由

2. libp2p 架构

	*   ==Discovery 发现== </br>
		发现和识别网络中的其他节点.	

	*   ==Distributed Record Store 分布式记录存储== </br>
		存储和分发记录的系统,负责记录节点相关的各种信息,便于连接管理和内容寻址.	

	*   ==Peer Routing 节点路由== </br>
		用来决定使用哪些节点来路由指定的消息.这种路由机制可以递归甚至在广播/组播模式下完成.	

	*   ==Swarm 连接处理== </br>
		负责管理节点之间连接的创建,维护,销毁.包括协议多路复用,流多路复用,NAT穿透和连接中继,同时进行多路传输.ps:更新的版本叫switch的,取决于何种实现		
		
3. libp2p 流程
	
	-  运行 libp2p 协议的节点在初始化之后需要通过各种方式发现更多的节点,比如Bootstrap list,mDNS,DHT 等,这主要由 **Discovery模块** 负责与实现

	-  libp2p 会把这些获取到的节点信息存储在 **Distributed Record Store模块** 中,供以后方便使用

	-  当上层应用需要连接某个节点时, **Peer Routing模块** 会找到多条不同的路径, **Swarm模块** 会对这些路径进行尝试连接.(由于P2P网络本身的特性,节点之间的连接状况始终在动态变化,故不是所有路径都是可以成功连接的～)

	-  连接成功之后,上层应用将通过 libp2p 与连接节点进行交互,互相传递数据

---------------

#### 术语

[doc](https://docs.libp2p.io/reference/glossary/)

**Peer** : p2p网络中的单个参与者,虽然每个具体的机器有可能支持很多协议,但只用一个peerId来标识自己.

**PeerId** : 全局唯一的标识参与者的id,常用的peerId是该peer公钥的multihash

**DHT** : 即 `distributed hash table`,DHT会以一种确定性的规范给node分配可寻址的key,从而可以高效的路由到指定key的node.

**mDNS** :  即`Multicast DNS`，mDNS主要实现了在没有传统DNS服务器的情况下使局域网内的主机实现相互发现和通信，使用的端口为5353，遵从dns协议，使用现有的DNS信息结构、名语法和资源记录类型。并且没有指定新的操作代码或响应代码。在局域网中，设备和设备之前相互通信需要知道对方的ip地址的，大多数情况，设备的ip不是静态ip地址，而是通过dhcp协议动态分配的ip 地址，如何设备发现呢，就是要mdns大显身手，例如：现在物联网设备和app之间的通信，要么app通过广播，要么通过组播，发一些特定信息，感兴趣设备应答，实现局域网设备的发现，当然mdns 比这强大。

**Circuit Relay** : 由于网络,或应用协议的不同等原因,peer与peer之间无法直接建立连接进行通信,此时就可以由这些愿意充当中介的第三方 peer来充当"继电器",分别建立与双方的连接并转发信息以实现通信.

**Multiplexing** : 多路复用是指在单个逻辑“介质”上组合多个通信流的过程,例如,我们可以在单个TCP网络连接上维护多个独立的数据流,当然,它本身可以在单个物理连接（以太网，wifi等）上多路复用.

**Multistream** : 这是一种轻量级约定，用于使用简短的标头“标记”二进制数据流，该标头标识流的内容。

-----------------

#### Libp2p 协议

[doc](https://docs.libp2p.io/concepts/protocols/)

libp2协议可以使用唯一的字符串标识符,来标识可以进行连接的地址.

协议协商,当连接拨出启用一个新的传输流时,需要确定使用的传输协议的协议id,如果监听的peer不支持所请求的协议,他们将关闭传输流.如果支持,则会回显协议id.

核心的libp2p协议:全部使用 protobuf 来定义消息模式

- Ping : 最简单的检测对方peer是否在线
- Identify : 识别允许peer交换彼此的信息,特别时他们的公钥和已经知道的网络地址
- identify/push : 与 Identify稍有不同,push时主动发出的,而不是相应请求.
- secio : secure input/output 的缩写,这是一种用于加密通信的协议,类似与 `TLS 1.2`,但是这不需要证书颁发机构.因为每个peer都有一个从其公钥派生出来的 peerId.所以可以使用 peer的公钥验证已经签名的消息来确认peer的身份.
- kad-dht : `DHT`是基于 `Kademlia` 路由算法修改而来的分布式哈希表,作为 libp2p中peer路由和内容路由的基础.
- Circuit Relay : 线路中继协议.

-----------------

#### 概念

[doc](https://docs.libp2p.io/concepts/)

1. Multiaddr 地址解析
		
	为了适应复杂的网络环境,libp2p 支持多种不同的底层协议,甚至 IPFS 社区专门立了一个项目来标准化节点的地址[multiaddr](https://github.com/multiformats/multiaddr).目前 libp2p 主要支持以下几种地址格式,通过地址解析, libp2p 能获知如何才能连接到目的节点,下一步就是尝试建立连接.
		
	* `/ip4/127.0.0.1/tcp/4001/ipfs/QmNodeID` : 这种格式跟传统的 TCP 网络里是一样的,直接可以解析出对应的 IPv4 地址和端口号
	* `/ipfs/QmNodeID` : 这种格式的地址适用于 IPFS 网络,只有节点ID的地址,需要节点路由模块找到节点对应的IP地址,然后再进行连接
	* `/dns4/http://ipfs.ipfsbit.com/tcp/443/wss/p2p-webrtc-star` : 这种地址需要调用`multiaddr-dns`组件,把域名解析成IP地址,然后再进行连接
	* `/p2p-circuit/p2p/QmNodeID` : 这种地址是 relay 地址,用于中继网络,需要首先连接一个中继节点,才能连接到目的节点

2. TRANSPORT 传输

	主要涉及两方面,一是传输需要监听和建立连接,二是传输有不同的协议.

	libp2p定义可以让应用以统一的,可寻址包含了多种不同的传输协议.

	libp2p通过调用传输协议的连接函数来尝试连接目的地node.

3. NAT 遍历

	NAT（Network Address Translation，网络地址转换）,当在专用网内部的一些主机本来已经分配到了本地IP地址（即仅在本专用网内使用的专用地址），但现在又想和因特网上的主机通信（并不需要加密）时，可使用NAT方法。
	
	互联网是由无数网络组成的，通过基础传输协议将这些网络连接成共享的地址空间。当流量在网络边界之间移动时，通常会出现一个称为网络地址转换的过程。网络地址转换（NAT）将一个地址从一个地址空间映射到另一个地址空间。NAT允许许多机器共享一个公共地址，它对IPv4协议的持续运行至关重要，否则IPv4协议的32位地址空间将无法满足现代网络人口的需求。

	虽然NAT对出站连接通常是透明的，但对入站连接的监听则需要进行一些配置。路由器监听的是一个单一的公共IP地址，但内部网络上的任何数量的机器都可以处理请求。为了服务请求，你的路由器必须被配置成将某些流量发送到特定的机器，通常是通过将一个或多个TCP或UDP端口从公共IP映射到内部IP。

	libp2p应用程序可以在任何地点运行,而不仅仅是在IDC或需要有稳定的公网IP的机器上运行.所以目前libp2p中有这些可用的NAT方法.
	
	- automatic route configuration 

		许多路由器支持端口转发的自动配置协议,最常见的是 `upnp` 和 `nat-pmp`.如果路由器支持这些协议之一,则 libp2p 将尝试自动配置端口映射,以使其能够侦听传入的流量.如果网络和 libp2p 实现支持,这通常是最简单的选项.
		
	- stun 
		
		在内部机器拨号建立了到公网地址的连接时,海可以接收到在公网地址端口上的传入连接,并会路由到内部计算机的内部IP.但遗憾的是,内部计算机并不会自行发现公网地址上分配给他们连接的端口

		但是,外部的对等节点可以告诉他们观察到的地址,并进行广播,让对等网络知道在哪里可以找到这些内部节点.

		当使用IP支持的传输的时候, libp2p 会尝试使用套接字选项通过相同的端口来继续宁传输.

		这种外部发现机制的作用和 STUN 相同,但并不需要一组 STUN 服务器.
		
	- AutoNAT 
		
		上面描述的方式可以使 peer 之间相互通知自己观察到的网络地址,但并非所有网络都允许在拨出的公网地址上的同一端口接受传入连接.

		那么其他 peer可以帮助我们察觉到这个处境,他们可以通过我们自己连接到的对等地址来连接我们
		
	- Circuit Relay(TURN)
		
		当然也有可能 peer完全无法以nat的方式获得可公开访问的途径, libp2p 提供了 TURN 使得 peer 之间通过一个中间对等节点来相互通信.

		这就是 `Circuit relay`,它可以让两个 peer 通过一个第三方的继电器 peer 相互通信.

		中继协议是非透明的,即通信双方可以看到这个中继地址

		中继协议仅在peers双方都可以发现并愿意对两端访问进行中继中继对等 peer 才有效.
		
5. Circuit Relay 中继
		
	中继是一种传输协议,作为 nat遍历 中的一种方式,可以让两个peer通过一个第三方的中继peer来传输流量.因为很多情况下,节点无法被可以公开访问的方式进行连接,或者他们不具有相同的传输协议可以直接通信.
	
	为了在peer之间有nat障碍的时候也实现p2p连接,libp2p定义了一个`p2p-circuit`的协议,当一个peer无法在共有的ip地址上进行监听的时候,它可以向一个中继peer进行拨号,这将保持一个开放的长连接,其他的peer可以通过这个中继拨号来将流量转发给内网中的peer.
	
	至关重要的,中继连接时端到端加密的,这意味着中继peer是无法读取,篡改经自己转接的流量的,同时中继这个行为是不透明的,即源端peer和目的地peer都知道自己的流量正在被中继,因为自己是先拨号到这个中继peer上的.
	
6. 中继地址

	当前流量正在被中继的peer他的id会被用来作为一个中继线路的id.举例如下:
	
	如果我是在nat后的内网节点,我的peerId是QmAlice,我想要和我的朋友QmBob通信.我可以构建一个最基本的p2p线路是 `/p2p-circuit/p2p/QmAlice`但是这有有个问题,这个地址不包括中继,所以bob要跟我通信的唯一机会就是发现一个中继peer并且可以连接到我.更好的地址是 `/p2p/QmRelay/p2p-circuit/p2p/QmAlice`,这样bob就可以明确知道通过 QmRelay的中继连接就可以和我通信了,不过这还是有问题,bob无法发现哪个QmRelay可以与我通信.
	
	更好的办法是在地址中包含中继peer的传输地址,比如说我已经和一个特定的中继拨号建立了连接,该中继通过标识协议告诉我,他们正在通过 ip:port 监听tpc连接,那么我可以构建这样的地址 `ip4/7.7.7.7/tcp/55555/p2p/QmRelay/p2p-circuit/p2p/QmAlice`, 这样bob就知道通过特定的QmRelay监听的tcp连接转发流量后与我通信了.
	
	所以最好的中继地址就是包含了特定中继peer监听信息的地址,如果有多个中继peer那么发布多个中继地址就可以了.
  
7. 自动中继

	从中继地址上我们可以看出,只有当需要通信的peer双发都可以访问该中继peer的时候,中继线路协议才会生效,但是无论是通过硬编码类似引导node一样写入一些著名的中继节点,还是给整个网络提供一些中心化的专用中继,如果这些节点变得不可用,那么就会比较麻烦.
	
	自动中继是在 go-libp2p 中实现的一个功能,peer可以启用该功能,以尝试通过 libp2p 的 [content routing](https://docs.libp2p.io/concepts/content-routing/) 内容路由来发现中继节点,这样peer就可以使用一个或多个公共中继建立连接,并通过这些地址接受通讯.
	
	==PS:自动中继应该谨慎使用,目前没有对恶意的中继节点有有效的措施.==
	
	自动中继工作原理(自动中继服务):当 `AutoNAT服务` 检测到我们处于 NAT 环境中时, `Autorelay` 就会跳出来.
	
	- 发现所有的中继节点
	- 与他们建立长连接
	- 宣传我们支持中继的地址

8. 双方协议协商

	连接建立之后, libp2p 会首先进行双方协商,确定对方支持哪些功能.负责协商功能的是 identify 协议,它是内置在 libp2p 的基础协议,能够交换节点的公钥,本地监听地址等.

	协商完成后,连接两端的节点会找到共同支持的协议,并且初始化它们.初始化时会注册每种协议的 handler 回调函数,当有协议数据到达时,相应的 handler 就会被调用.由于多种传输协议会复用同一个底层连接,所以连接会被拆分成多个“流(Stream)”.

	libp2p 可以通俗理解成适用于多种传输协议的P2P网络层.由于目前网络模式多种多样,比如4G 网络/宽带网络,拨号/固定公网IP,以及还有着各式各样的传输协议(TCP,UDP等等)和网络防火墙的通信阻碍,所以导致这个协议的实现是非常复杂的.
		
9. 多路复用
	
	libp2p 中的多路复用和 tcp/ip 使用端口号来多路复用不同.他是在应用层实现的,这意味着它不是操作系统的网络堆栈来提供的功能.

	libp2p 中一般是在初始配置中对这一模块进行启用的配置,然后在 swarm (或者称为 switch 取决于实现) 的组件中维护有关已知对等项和连接的状态的. swarm 提供了 dial 和 listen 的接口可以用来处理流的多路复用.
	
---------------------

- [完整的libp2p文档doc](https://docs.libp2p.io/)
- [libp2p说明书github spec](https://github.com/libp2p/specs)