---
title : IPFS和FileCoin的FIL币
tags : 小书匠语法
renderNumberedHeading : true
grammar_abbr : true
grammar_table : true
grammar_defList : true
grammar_emoji : true
grammar_footnote : true
grammar_ins : true
grammar_mark : true
grammar_sub : true
grammar_sup : true
grammar_checkbox : true
grammar_mathjax : true
grammar_flow : true
grammar_sequence : true
grammar_plot : true
grammar_code : true
grammar_highlight : true
grammar_html : true
grammar_linkify : true
grammar_typographer : true
grammar_video : true
grammar_audio : true
grammar_attachment : true
grammar_mermaid : true
grammar_classy : true
grammar_cjkEmphasis : true
grammar_cjkRuby : true
grammar_center : true
grammar_align : true
grammar_tableExtra : true
---

[toc]

### Protocol Labs 的明星项目

Protocol Labs 旗下的明星项目,每一个都有其独特的定位和功能.我们就来看一看围绕在 IPFS 和 FileCoin 周围的几个项目,他们分别是 libp2p,IPLD,IPFS,Filecoin.

#### libp2p 协议

libp2p 是一个模块化的网络栈,通过将各种传输和 P2P 协议结合在一起,使得开发人员很容易构建大型,健壮的 P2P 网络. [libp2p.io官网](https://libp2p.io/)

libp2p 被用作IPFS的网络层,主要负责发现节点,连接节点,发现数据,传输数据.

libp2p 集成了各种传输协议和点对点协议,其主要作用是发现节点和内容,并且让不同的网络协议能够互相之间顺利的传送数据.开发人员可以使用 libp2p 轻松构建大型,稳定的 p2p 网络. libp2p 主要包含了如下技术实现

- Transports : 传输
- Discovery : 发现
- Peer Routing : 节点路由
- NAT Traversal : NAT穿透
- Content Routing : 内容路由

##### libp2p 架构

*   ==Discovery 发现== </br>
    发现和识别网络中的其他节点.	
*   ==Distributed Record Store 分布式记录存储== </br>
    存储和分发记录的系统,负责记录节点相关的各种信息,便于连接管理和内容寻址.	
*   ==Peer Routing 节点路由== </br>
	用来决定使用哪些节点来路由指定的消息.这种路由机制可以递归甚至在广播/组播模式下完成.	
*   ==Swarm 连接处理== </br>
    负责管理节点之间连接的创建,维护,销毁.包括协议多路复用,流多路复用,NAT穿透和连接中继,同时进行多路传输.ps:更新的版本也有叫switch的,取决于何种实现

##### libp2p 流程

-  运行 libp2p 协议的节点在初始化之后需要通过各种方式发现更多的节点,比如Bootstrap list,mDNS,DHT 等,这主要由 **Discovery模块** 负责与实现
-  libp2p 会把这些获取到的节点信息存储在 **Distributed Record Store模块** 中,供以后方便使用
-  当上层应用需要连接某个节点时, **Peer Routing模块** 会找到多条不同的路径, **Swarm模块** 会对这些路径进行尝试连接.(由于P2P网络本身的特性,节点之间的连接状况始终在动态变化,故不是所有路径都是可以成功连接的～)
-  连接成功之后,上层应用将通过 libp2p 与连接节点进行交互,互相传递数据

1. 地址解析(multiaddr)
	
	为了适应复杂的网络环境,libp2p 支持多种不同的底层协议,甚至 IPFS 社区专门立了一个项目来标准化节点的地址[multiaddr](https://github.com/multiformats/multiaddr).目前 libp2p 主要支持以下几种地址格式,通过地址解析, libp2p 能获知如何才能连接到目的节点,下一步就是尝试建立连接.
	*   `/ip4/127.0.0.1/tcp/4001/ipfs/QmNodeID` : 这种格式跟传统的 TCP 网络里是一样的,直接可以解析出对应的 IPv4 地址和端口号
	*   `/ipfs/QmNodeID` : 这种格式的地址适用于 IPFS 网络,只有节点ID的地址,需要节点路由模块找到节点对应的IP地址,然后再进行连接
	*   `/dns4/http://ipfs.ipfsbit.com/tcp/443/wss/p2p-webrtc-star` : 这种地址需要调用`multiaddr-dns`组件,把域名解析成IP地址,然后再进行连接
	*   `/p2p-circuit/p2p/QmNodeID` : 这种地址是 relay 地址,用于中继网络,需要首先连接一个中继节点,才能连接到目的节点
2. 传输协议分配
	
	地址里面的`/tcp`,`/quic`,`/ws`,`/p2p`分别对应不同的传输协议实现. libp2p 定义了统一的,选择地址对应的传输协议,调用传输协议的连接函数尝试连接目的节点.
3. 双方协商
	
	连接建立之后, libp2p 会首先进行双方协商,确定对方支持哪些功能.负责协商功能的是 identify 协议,它是内置在 libp2p 的基础协议,能够交换节点的公钥,本地监听地址等.
	
	协商完成后,连接两端的节点会找到共同支持的协议,并且初始化它们.初始化时会注册每种协议的 handler 回调函数,当有协议数据到达时,相应的 handler 就会被调用.由于多种传输协议会复用同一个底层连接,所以连接会被拆分成多个“流(Stream)”.

	libp2p 可以通俗理解成适用于多种传输协议的P2P网络层.由于目前网络模式多种多样,比如4G 网络/宽带网络,拨号/固定公网IP,以及还有着各式各样的传输协议(TCP,UDP等等)和网络防火墙的通信阻碍,所以导致这个协议的实现是非常复杂的.

##### NAT 遍历

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

- TURN

	当然也有可能 peer完全无法以nat的方式获得可公开访问的途径, libp2p 提供了 TURN 使得 peer 之间通过一个中间对等节点来相互通信.

	这就是 `Circuit relay`,它可以让两个 peer 通过一个第三方的继电器 peer 相互通信.

	中继协议是非透明的,即通信双方可以看到这个中继地址

	中继协议仅在peers双方都可以发现并愿意对两端访问进行中继中继对等 peer 才有效.

##### 多路复用

libp2p 中的多路复用和 tcp/ip 使用端口号来多路复用不同.他是在应用层实现的,这意味着它不是操作系统的网络堆栈来提供的功能.

libp2p 中一般是在初始配置中对这一模块进行启用的配置,然后在 swarm (或者称为 switch 取决于实现) 的组件中维护有关已知对等项和连接的状态的. swarm 提供了 dial 和 listen 的接口可以用来处理流的多路复用.

----------------

#### IPLD

IPLD是内容寻址的数据模型,即 merkle dag 的组装数据结构.
- block layer (layer 0)

	仅此一层就可以描述很多格式的的基本数据,但是并没有定义数据结构或者数据类型,可以使用不同的编码器编码到不同的类型.

- data model layer (layer 1)

	这一层是由IPLD编码器来实现的基本必须要的数据类型.
	* 基本类型 : Null, Boolean, Integer, Float, String, Bytes, List, Map, Link
	* 循环类型 : List, Map
	* 可以用在循环类型T中的类型 : Null, Boolean, Integer, Float, String, Bytes, Link

- schema layer

	架构曾定义了从数据模型层到包含了复杂数据结构的映射 : Set, List, Queue, Stack, SortedSet, Map, ListMap, SortedMap

----------------

#### IPFS

- IPLD : 将数据 import 到 ipfs 中组织的协议族
- Bitswap : 拉取和传输数据区块的协议
- CID v0 : 使用Qm开头的cid
- CID v1 : 包含了一只前缀来标识可以向后兼容的cid version.
- DHT : A Distributed Hash Table (DHT) 分布式的key-value存储.
- Gateway : ipfs网络在http上的代理接入点
- multihash中被hash的数据是通过multicodec组织的数据
- multihash是一个自描述hash算法后的数据

**CID字符串的组成**
```
cid-version有两种

cid v0是 Qm开头的 只有multihash
看起来是这样的
<0><dag-pb><multihash>
当使用cid v0的时候都是固定使用base58的

cid v1是 一串00000001的version数据看起来像这样
Binary : 
<cid-version><ipld-format><multihash>
String : 
<base>base(<cid-version><ipld-format><multihash>)
ipld-format是定义好的不是 magic-number 的常量
```

当使用cid v1的时候如果第一个字符是 b表示base32,z表示base58btc,f表示base16

这个base字符叫做 multibase table [multibase](https://github.com/multiformats/multibase)

可以使用这个工具进行分析 [cid.ipfs.io](https://cid.ipfs.io)

**将文件加入到ipfs**

首先会对要加入的文件内容进行 chunk 分块,并组成dag的形式

然后从叶子节点开始一层一层往上计算cid直到最终的根节点

可以使用这个工具进行分析 [dag.ipfs.io](https://dag.ipfs.io/)

平均分割法和smart变长分割法(rabin方式);
rabin方式会使用16byte的滑动窗口来计算,使得块大小分布在一个平均值形成正太分布,
这样可以使得内容的修改仅仅知会影响修改的块

==UnixFS==

Node+ \[UnixFS File] + C1

**客户端**

使用 go-ipfs 的cli或者是 ipfs-desktop 的 windows客户端都可以;
使用 ipfs-update进行更新,或者在更新了程序后使用 `ipfs daemon`进行数据升级迁移.

**IPNS和DNSLink**
IPNS是使用 `ipfs name pushlish CID`来创建一个对特定内容 ipfs-path 的指向;
DNSLink是直接使用dns的txt记录来实现的.即将对一个域名的访问,改为 dnslink=/ipfs/Cid 的访问;

`my-dns-tool set --type=TXT --ttl=60 --domain=libp2p.io --name=_dnslink --value="dnslink=/ipfs/Qmc2o4ZNtbinEmRF9UGouBYTuiHbtCSShMFRbBY5ZiZDmU"`

----------------
----------------

### FileCoin的前期调研和初步了解

Filecoin作为去中心化存储网络的激励和验证机制,矿工是整个网络的主要参与者,也是网络运营和维护者.所有去中心化网络的前提假设都是节点是自私的,理性的,因为只有基于这样的假设设计的机制才能保证网络的稳定性.在这样的假设下Filecoin利用期望共识(Expectation Consensus)保证区块链网络的共识,利用复制证明(Proof of Replication)和时空证明(Proof of Spacetime)保证了自私矿工的理性决策是做诚实的节点,即只有诚实的行为才能保证收益的最大化.

#### FileCoin Quick View

IPFS是一个协议,现在的挖矿是指FileCoin上的挖FIL币

>矿机选择  灵动,先河,原力,1457,蚂蚁,星际 只是看看的
矿机的硬件要素需求 磁盘 显卡 CPU RAM
矿机厂商更多的是对硬件资源的整合
IPFS的Filecoin挖矿技术成本很低,主要是官方提高了硬件成本
公网IP 对等带宽 8core+ 32g扇区参数下的内存128gRam最少 企业级ssdCache 热插拔设计 GPU加速

从硬件要求上看,各个矿机供应商大同小异,
但是硬件配置其实只占了挖矿收益影响因素约30%的比重,主要影响因素还是各厂家的软件与运维上.

主网上线后算力大涨,每T内存的产币量会同步缩减,自建矿机的成本问题,
当前FIL币价非常高,比年初要涨了将近7-8倍,
卖矿机相当于卖矿机使用权,同时还有FIL的托管费用(25%).

针对不同的角色所需求的硬件能力是不一样的,
对于旨在存储数据作为仓储节点的话主要是需要硬盘和打包速度.

如果还需要作为一个检索服务的节点的话,那么高性能的带宽传输能力也是必须的.

**挖矿的主要操作**

1. 密封预交付阶段1 PoRep(复制证明)几个小时
	PoRep SDR编码,此阶段受CPU限制,并且是单线程的,故需要强性能的CPU,SHA扩展的==AMD处理器==在很大程度上加快了此过程

2. 密封预交付阶段2 波塞冬(Poseidon)哈希算法执行Merkle树生成 几十分钟
	GPU

3. 密封提交阶段1 几十秒
	执行生成证明所必需的准备工作的中间阶段 CPU运算

4. 该密封阶段涉及创建SNARK 将证明在广播之前进行压缩, 30分钟
	GPU密集型

质押包括质押扇区的规模和存储矿工存放的抵押币
1Sector 1Filecoin=32GB -> 1pb=10^6G/32G=31250Fil
也就是说,1PB要3万个Fil质押进去,如果10PB就要质押进去30万个,主网上线第一天全球挖出来的币是41.8万个

综上所述,目前filecoin的机制设定和硬件要求,就是完完全全的阻碍个人挖矿者的,必须采取大容量矿池的方式进入

-------------------

#### Fileoin的基础术语

- **Block和Epoch**
	FileCoin区块链中的epoch是离散为25秒的一个时期,每个epoch中,都会选择存储矿工的一个子集,这个子集会通过 Winning-of-Spacetime来向filecoin添加一个block区块.这个选择被称为选举,一个矿工当选的可能性大致与他们贡献的网络总存储容量占整个filecoin网络的份额成正比.

- **客户**
	客户付费存储和检索数据.他们可以从可用的存储服务商中进行选择.如果他们想存储私有数据,则需要在将其提交给存储服务商之前对其进行加密.

- **存储矿工**
	存储矿工存储客户的数据以获得奖励.他们决定愿意保留多少空间来存储.在客户和存储矿工达成协议后,矿工有义务继续提供其存储数据的证据.每个人都可以查看证据,并确保存储矿工可信.
	
- **检索矿工**
	检索矿工根据他们的要求提供客户的数据.他们可以从客户或存储矿工那里获取数据.检索矿工和客户支付很少的费用来交换数据,数据被分成几部分,客户每片段支付很少费用.检索矿工也可以充当存储矿工.
	
- **片段**
	片段是客户端存储在分散存储网络中的数据的一部分.例如,可以将数据(可能是一个目录)有意地分为许多部分,并且每个部分可以由一组不同的存储矿工存储.用户添加的文件首先是会被chucking成为一个个小块hash后组织起来的.
	
- **扇区(Sector)**
	扇区是存储矿工提供给网络的一些磁盘空间(可以认为是与特定存储提供者的磁盘空间的特定部分相关联的唯一ID).矿工将客户的物品存放在其所在的区域,并为其服务赚取代币.为了存储片段,存储矿工必须向网络保证其扇区可用.目前sector的大小有32GB和64GB两种.
	
- **订单和订单簿**
	订单是请求或提供服务的意图声明.客户向市场提交标的订单以请求服务(分别是用于存储数据的存储市场和用于获取数据的检索市场),而矿工则接受订单以提供服务.订单簿是订单的集合.Filecoin为存储市场和检索市场维护独立的订单簿.
	
- **承诺aka质押**
	承诺是向网络提供存储(特别是扇区)的承诺.存储矿工必须向账本(文件币区块链)提交质押才能开始在存储市场中接受订单.质押包括质押扇区的规模和存储矿工存放的抵押币.
	
- **消减(Slash)**	
	当某个扇区出现故障的时候,filecoin网络会大幅减少本应该存储这个sector的存储矿工.并且会减去该矿工的总算力.
	
- **密封(Seal)**	
	密封是Filecoin协议的基本构建块之一.这是在一个扇区上执行的计算密集型过程,导致该扇区的唯一表示.这种新表示的性质是基本验证的复制的和验证的时空过程.

- **存储挖矿**
	存储矿工的作用是代表Filecoin网络保存文件.存储矿工必须以加密方式证明他们兑现了存储这些文件的承诺–这是通过复制证明(PoRep)和时空证明(PoSt)机制实现的.将存储抵押到Filecoin网络本身需要Filecoin.这些被用作担保,以确保存储矿工履行其合同义务.

- **储存资料**
	在Filecoin网络中,数据存储在固定大小的扇区中.通常,存储矿工用代表客户存储的数据填充这些部门,客户通过交易在特定时间段内与存储矿工服务签约.但是,存储矿工并没有被迫进行交易.如果存储矿工没有找到任何有吸引力的交易建议,他们可以选择做出容量承诺,用任意数据填充部门.这使他们可以证明他们正在代表网络保留空间.如果需要,以后可以“升级”为充当容量承诺而创建的部门,以便为将来的交易提供合同存储空间.
	
- **非交互性零知识证明(zk-SNARK)**

	验证者和证明者之间不需要进行交互,而仅仅只需要持有相对应随机数不同的hash值即可判定证明者的确证明了对应的事物.这里就需要证明者自证即为 WindowsPost

- **存储证明Proof-of-Storage(PoSt)**

	许多区块链网络都以参与者为区块链提供某种价值这一观念为基础-这种贡献很难伪造,但如果确实做出了,则可以进行微不足道的验证.通常认为基于这种方法的区块链需要“ X证明”,其中X是有价值的贡献.Filecoin区块链重视存储容量的贡献；它以新颖的存储证明(PoSt)构造为基础,将其与其他区块链区分开来,而其他区块链在大多数情况下需要贡献计算能力.

	术语,存储证明是指Filecoin协议的设计元素,它使一个人可以保证(达到很高的容忍度)声称声称贡献了给定存储量的参与者确实履行了这一承诺.实际上,Filecoin的存储证明结构提供了更为强大的主张,使人们可以有效地验证参与者是否正在存储特定的数据,而无需一个人自己拥有文件的副本.

	注意 : 这里的“证明”是非正式的用法-通常,这些证明采取概率论证的形式,而不是具体的证明；也就是说,从技术上讲,可以说服其他参与者,一个人没有做出贡献,但是这种可能性微乎其微,几乎不可能
	
	PS : 存储证明是一个泛化的概念,挖矿软件的实际工作是下面的复制证明和时空证明.

- **复制证明Proof-of-Replication(PoRep)**
	一旦该扇区已被填充,PoRep看到存储矿工密封 扇区-密封是计算密集的过程的结果在所述数据的唯一表示(原始表示随后可以通过重构开封).一旦数据被密封,存储矿工 : 生成证明；对证明运行SNARK进行压缩；最后,将压缩结果提交给区块链,作为存储承诺的证明.通过此过程为网络保留的存储称为抵押存储.

- **时空证明Proof-of-Spacetime(PoSt)**
	PoRep完成后,存储矿工必须不断证明他们仍在存储他们承诺存储的数据.这是通过PoSt完成的,PoSt是向存储矿工发出加密挑战的过程,只有直接咨询密封部门才能正确回答.存储矿工必须在严格的时间限制内应对这一挑战；密封的计算难度确保了存储矿工必须保持对密封部门的随时访问和完整性.

- **窗口时空证明(WindowPost)**
	WindowPoSt是一种机制,可用来审核存储矿工的承诺.它看到每个24小时周期分解为一系列窗口.相应地,每个存储矿工的保证扇区集都被划分为子集,每个窗口一个子集.在给定的窗口内,每个存储矿工必须为其各自子集中的每个扇区提交PoSt.这要求可以立即访问每个面临挑战的部门,并将导致将SNARK压缩的证据作为消息以块形式发布到区块链.这样,在每个24小时内至少对一次保证存储的每个sector进行一次审核,并保留一个永久,可验证的公共记录,以证明每个存储矿工的持续承诺.Filecoin网络期望存储文件的持续可用性.未按规定提交WindowPoSt的Sector将导致故障,存储矿工提供的Sector将被削减 -也就是说,他们的抵押品的一部分将被没收,他们的总算力将看到一个减少.在被认为完全放弃存储承诺之前,存储矿工将有有限的时间从故障中恢复.如果需要,存储矿工也将具有先提交有过错的能力,这将减少处罚,但仍必须在合理的时间内解决.

- **赢得时空证明(WinningPost)**
	WinningPoSt是一种机制,通过这种机制可以奖励存储矿工的贡献.在Filecoin网络中,时间离散化为一系列时期-区块链的高度对应于经过的时期数.在每个时间点开始处,存储的矿工的少数当选到矿井新块(Filecoin利用 tipsets,其允许多个块而在相同的高度被开采).每个成功创建区块的当选矿工都将获得Filecoin,并有机会向其他节点收取费用以在区块中包含消息.存储矿工的当选概率与其存储能力相对应.在与基础WindowPoSt相似的过程中,存储矿工的任务是在epoch结束之前提交指定扇区的压缩存储证明.未能在必要的窗口中完成WinningPoSt的存储矿工将丧失开采区块的机会,但不会因未能这样做而受到处罚.

- **存储能力**
	Filecoin存储矿工的能力与选择存储矿工开采区块的可能性相对应,与他们代表网络密封的存储量大致成比例.为了通过简单的容量承诺进一步激励“有用”数据的存储,存储矿工有额外的机会竞争经过验证的客户提供的特殊交易.此类客户在提供涉及存储有意义数据的交易意图方面获得了认证,并且存储矿工为这些交易赚取的权力将通过乘数得到增强.考虑到该乘数后,给定存储矿工拥有的总电量称为质量调整后的 电量.

- **存储市场**

	客户向存储订单簿提交一个投标订单(使用PUT协议,在下一节中说明).客户必须存放订单中指定的费用并指定他们要存储的副本数量.客户可以提交多个订单,也可以在订单中指定复制因子.更高的冗余度(更高的复制因子)导致对存储故障的更高容错率(如下所述).

	==Manage.PledgeSector==
	存储矿工通过通过==Manage.PledgeSector==在区块链中通过质押交易存入抵押品来保证其对网络的存储.抵押品(Fil)在提供服务的时间内存放,如果矿工为其承诺存储的数据生成存储凭证,则将其退还.如果某些存储证明丢失,则会损失一定比例的抵押品.一旦质押交易出现在区块链中,矿工就可以在存储市场中提供其存储服务 : 他们设置价格并将要价单添加到市场的订单簿中.

	==Put.AddOrders==
	一旦质押交易出现在区块链中(在AllocTable中),矿工便可以在存储市场中提供其存储服务 : 他们设置价格并通过==Put.AddOrders==将要价订单添加到市场的订单簿中.

	==Put.MatchOrders==
	当找到匹配的要价和买价单时(通过==Put.MatchOrders==),客户将片段(数据)发送给矿工.

	==Put.ReceivePiece==
	当接收到片段,矿工运行==Put.ReceivePiece==.接收到数据后,矿工和客户都签署了交易订单并将其提交到区块链(在存储市场订单中)

	==Manage.AssignOrders==
	存储矿工的存储分为多个扇区,每个扇区包含分配给矿工的部分.网络通过分配表跟踪每个存储矿工的扇区.此时(签署交易订单时),网络会将数据分配给矿工,并在分配表中记录下来.

	==Manage.SealSector==
	当存储矿工扇区被填充时,该扇区被密封.密封是一种缓慢的顺序操作,它将扇区中的数据转换为副本,该副本是与存储矿工公钥关联的数据唯一物理副本.在复制证明期间,密封是必要的操作.

	==Manage.ProveSector==
	当为存储矿工分配数据时,他们必须反复生成复制证明以确保他们正在存储数据,证明会发布在区块链上,网络会对其进行验证.

	==Δfault==
	如果缺少任何证据或证据无效,则网络会通过存储矿工的抵押币对他们进行惩罚.
	如果大量证据缺失或无效(由系统参数Δfault定义),则网络会认为存储矿工有故障,将订单结算为失败,然后相同新订单重新引入市场.
	如果每个存储该矿工的都无法存储该片段,则该片段将丢失,并且客户将获得退款.

- **检索市场**

	这是一个脱链交换,客户和检索矿工以对等方式彼此发现.一旦客户和矿工就价格达成协议,他们便开始使用小额付款逐笔交换数据和币.

	Get.AddOrders
	检索矿工通过在网络上散播他们的要价单 : 他们设置价格并将要价单添加到市场的订单簿中.

	Get.MatchOrders
	客户向投标市场订单簿提交投标订单.检索矿工检查其订单是否与客户的相应投标订单相匹配.

	Put.SendPiece
	订单匹配后,检索矿工将件发送给客户(矿工发送部分数据,客户发送小额付款).收到件后,矿工和客户都签署了交易订单并将其提交给区块链.

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020831/1598855520528.png)

-----------

#### 一般硬件问题

虽然我们无法提供具体建议,但可以提供一些一般性指导.

**CPU** 
根据经验,具有高时钟频率的多核CPU将加速密封过程,使存储矿工可以更快地将存储到网络上.Protocol Labs自己的测试表明,具有SHA扩展功能的现代AMD处理器具有 比其他处理器更大的优势.

**GPU**
必须有强大的GPU,才能在所需的时间限制内完成SNARK计算.Lotus当前被设计为支持NVIDIA制造的芯片.我们预计将来还会有其他制造商的支持卡.我们的 基准测试 可帮助您深入了解成功的芯片.

**RAM** 
当前的Filecoin网络仅支持密封32GiB和64GiB扇区.在这些较大的扇区上执行必要的计算需要相应的更多RAM.建议采矿系统至少配备128GiB.

**存储** 
选择合适的存储解决方案涉及很多考虑因素,也许最重要的是采矿作业所采用的特定收益模型.存储矿工目前需要保证原始存储量为1TiB(或质量调整后的等同量；对于主网,它将增加到100TiB),以便开采区块,但是超出此要求的因素还有很多,他们可能会觉得有用考虑.

*   首先,存储矿工应该牢记数据丢失的严厉处罚；即使翻转一位也可能导致严厉的处罚.结果,存储矿工可能希望考虑开销以实现数据冗余.
*   对于试图加入检索市场的存储矿工来说,考虑合并其他存储以准备提供密封数据的“热”副本也可能是明智的.尽管当然可以打开一个扇区以恢复原始数据,但是支持此用例的Filecoin实现将消除这种计算负担(这是Lotus当前正在开发的功能).
*   要考虑的另一个考虑因素是Filecoin网络对高可用性的期望.虽然理论上存储矿工应该能够与大多数商品的硬盘,固态硬盘,或其他合适的,非冷存储解决方案,不是所有的存储解决方案可依靠操作时执行最佳参加24 / 7.
*   当前,存储矿工还需要足够的空间来存储区块链本身.减少磁盘上区块链的占用空间是Lotus积极开发的一项功能.Filecoin的实现可能还需要额外的磁盘存储,以用于簿记,相当于已抵押存储的一小部分.
*   最后,协议实验室在测试中发现,将NVMe存储用作交换空间 可以在具有较少RAM(128GiB)数量的系统中用作补充.否则,存储矿工在某些操作期间可能会遇到内存不足的问题(尤其是密封需要大量工作内存).

**网络** 
如果使用分布式Lotus Seal工作人员(请参阅 下面的“ 高级挖掘注意事项”),则建议使用高性能网络(建议使用10GbE +网卡和交换机).使用网络附加存储时,还建议使用高性能网络.

-------------------

#### 先进的采矿注意事项

如前所述,Filecoin存储挖掘主要由与PoRep和PoSt机制相关的担忧所主导.PoRep本身是由几个阶段和Lotus实施Filecoin的便于这些阶段不同的机器代表团使用效率最大化密封工人.Protocol Labs开发了一个示例架构,旨在利用这些功能进行大规模挖掘.在这里,我们分解了设计类似系统时要考虑的不同瓶颈.

- 密封预交付阶段1

在此阶段,进行PoRep SDR编码.此阶段受CPU限制,并且是单线程的(根据设计,它不适合并行化).该阶段预计需要几个小时的时间,确切的时间取决于要密封的扇形的大小,当然还取决于进行密封的机器的规格.如前所述,Protocol Labs(及其他)发现,具有SHA扩展的AMD处理器在很大程度上加快了此过程.使用时钟频率更高的CPU也会提高性能.

- 密封预交付阶段2

在此阶段,使用波塞冬(Poseidon)哈希算法执行Merkle树生成.此过程主要是受GPU限制的-可以将CPU用作替代方案,但应该会慢得多.使用GPU时,此阶段预计需要45分钟到一个小时.

- 密封提交阶段1

这是执行生成证明所必需的准备工作的中间阶段.它受CPU限制,通常在数十秒内完成.

- 密封提交阶段2

最后,该密封阶段涉及创建SNARK,该SNARK用于在将必需的证明广播到区块链之前对其进行压缩.这是一个GPU密集型过程,预计需要20到30分钟才能完成.

协议实验室发现将preCommit阶段2,提交阶段1和提交阶段2并置在同一台计算机上是有效的,利用高密度计算机进行preCommit阶段1.但是,preCommit阶段1之间存在大量文件传输以及交付前阶段2；在网络访问速度较慢或使用硬盘而不是固态驱动器的计算机上,这可能会超过其他方面的性能提升.在这种情况下,让所有阶段都出现在同一台机器上可能会更有效率.

PoSt主要受GPU约束,但可以利用具有许多内核的CPU来加速过程.例如,WindowPoSt当前必须在30分钟的窗口内进行；24核CPU和8核CPU之间的差异可能是在以适当的余量清除该窗口与在狭窄的时间范围内进行清除之间的差异.WinningPoSt是一种强度较低的计算,必须在Filecoin时期的较小窗口(当前为25秒)内完成.

-------------------

#### 服务器安装注意事项

20200927 update

- 服务器主板FPanel没有USB针,所以只有尾部的2个USB口,需要接hub
- 引导U盘不能量产,所以是USB-ZIP模式,有可能主板比较新已经不支持了.只可以使用USB-HDD或者直接USB光驱引导
- 设置SATA控制器为AHCI模式,再CSM兼容中关闭secure boot,设置所有板载设备为UEFI启动
- 服务器的板载VGA如果选择safe graphic模式启动只能使用英文安装,否则后续步骤有按钮被遮挡无法控制选项
- 创建了EFI分区后,需要手动在下方选择EFI分区来安装boot loader,他不会自动选择
- Nvidia显卡在ubuntu中不能使用默认的开源驱动 nouveau ,需要手动禁用,否则会有looping登录界面的问题

**显卡驱动和cuda加速**

虽然在安装ubuntu的时候我已经勾选了专用软件和显卡驱动的选项,但是由于用到的是 NVIDIA RTX3080,不知道是不是因为太新了,所以并没有检测出来专用驱动,没办法只能自行安装了.

PS : 可以尝试添加PPA源使用apt的安装方式,当然要这个源有方案之后
``` shell
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
```

CUDA工具包其中其实也已经包含了显卡的驱动程序,但是cuda只是一个工具包,他是可以多个版本进行安装的.所以并不一定要安装cuda中的显卡驱动,具体可以看后面的安装过程,需要注意的是 cuda文件名上标记的版本号是支持的最低的显卡驱动的版本,所以如果自己安装显卡驱动的话,是一定需要在这个版本之上的.


- 准备工作

建议都使用离线安装的方式,主要还是网络太蛋疼了,显卡驱动几百M,cuda工具包下载的时候有好几G
	
显卡驱动 : 从官方网站下载 [download search](https://www.nvidia.cn/geforce/drivers/) , 我下载的版本是 NVIDIA-Linux-x86_64-455.23.04.run

CUDA工具阿波 : [下载界面地址](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=runfilelocal)

- 禁用开源驱动 nouveau编辑文件 blacklist.conf

``` shell
sudo gedit /etc/modprobe.d/blacklist.conf
blacklist nouveau
blacklist intel
# 实际测试没有这句也没问题
options nouveau modeset=0
# 更新
sudo update-initramfs -u
# 重启
sudo reboot
# 验证
lsmod | grep nouveau
```

- 删除干净历史安装

``` shell
# 驱动如果是 runfile安装的
sudo NVIDIA-*.run -uninstall
# 驱动如果是使用apt安装的
sudo apt remove nvidia*

# 卸载CUDA
CUDA默认是安装在 /usr/local/cuda-*下的
sudo uninstall_cuda_*.pl
```

- 禁用 x window服务

网上教程都安装,重启,并停止了 lightdm,其实ubuntu 20.04是使用了gdm的.直接停止后尝试安装

``` shell
# 更新 apt
sudo apt update

# 有可能的 lightdm 然后完成需要重启
sudo apt install lightdm 
# 如果安装了lightdm需要关闭
sudo service lightdm stop
sudo systemctl stop lightdm

# 直接关闭gdm
sudo systemctl stop gdm
```

- 安装驱动文件

进入runfile文件所在的目录,赋予权限,然后开始安装

``` shell
sudo chmod a+x NVIDIA*.run

# NVIDIA*.run -h 可以输出帮助
# NVIDIA*.run -A 可以输出扩展选项

# 执行安装
sudo ./NVIDIA-Linux-x86_64-396.18.run --no-x-check --no-nouveau-check --no-opengl-files 
# 我们已经自己禁用了x-window
# 我们已经手动禁用了nouveau
# 由于ubuntu自己有opengl,所以我们不用安装opengl,否则会出现循环登录的情况
```

- 安装过程

```
大概说是NVIDIA驱动已经被Ubuntu集成安装,可以在软件更新器的附加驱动中找到,我就是因为3080显卡找不到才需要自己安装的,所以直接继续

The distribution-provided pre-install script failed! Are you sure you want to continue?
选择 yes 继续.

Would you like to register the kernel module souces with DKMS? This will allow DKMS to automatically build a new module, if you install a different kernel later?
选择 No 继续.

是否安装 NVIDIA 32位兼容库
选择NO继续

Would you like to run the nvidia-xconfig utility to automatically update your x configuration so that the NVIDIA x driver will be used when you restart x? Any pre-existing x confile will be backed up.
选择 Yes 继续
```

- 安装完成

```
# 挂载专用驱动 正常来说会自动挂载
modprobe nvidia
检查驱动是否成功
nvidia-smi
nvidia-settings 是ui界面的配置

# 开启图形界面,之前如果安装了lightdm则启动之
sudo systemctl start lightdm
sudo systemctl start gdm

sudo reboot

# ps : 如重启后出现分辨率为800*600,且不可调的情况执行下面命令
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
sudo touch /etc/X11/xorg.conf
sudo reboot
```

- 安装CUDA

进入runfile文件目录,添加执行权限后执行安装

``` shell
sudo sh ./cuda_*.run --no-opengl-libs

# 同驱动安装一样,这里也不需要安装opengl库
```

- 安装过程

```
Do you accept the previously read EULA?
accept
然后选择安装项
```

- 安装完成

``` shell
# 安装CUDA工具需要自行设置path,编辑 .bashrc 或者 /etc/profile全局文件

gedit ~/.bashrc 
export PATH=/usr/local/cuda-8.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH
```

```
===========
= Summary =
===========

Driver : Not Selected
Toolkit : Installed in /usr/local/cuda-11.1/
Samples : Installed in /home/rxc/, but missing recommended libraries

Please make sure that
 -   PATH includes /usr/local/cuda-11.1/bin
 -   LD_LIBRARY_PATH includes /usr/local/cuda-11.1/lib64, or, add /usr/local/cuda-11.1/lib64 to /etc/ld.so.conf and run ldconfig as root

To uninstall the CUDA Toolkit, run cuda-uninstaller in /usr/local/cuda-11.1/bin
***WARNING : Incomplete installation! This installation did not install the CUDA Driver. A driver of version at least .00 is required for CUDA 11.1 functionality to work.
To install the driver using this installer, run the following command, replacing <CudaInstaller> with the name of this run file : 
    sudo <CudaInstaller>.run --silent --driver

Logfile is /var/log/cuda-installer.log

```

- 测试

``` shell
cd /usr/local/cuda-8.0/samples/1_Utilities/deviceQuery
sudo make -j4
# 这里-j4是因为是4核cpu,可以4个jobs一起跑.运行结果如下图

./deviceQuery
```

----------------

20200924 update

#### FileCoin的经济模型

**代币释放模型**

Filecoin 代币总量为 20 亿枚

- 5％分配给 Filecoin 基金会,
- 10% 用于融资,
- 15% 分配给协议实验室,
- 70% 分配给矿工.其中代币总量的 15%, 3亿枚,将被用作为挖矿储备金,以在未来激励检索矿工和其他类型的矿工,具体使用方式以后由社区通过 Filecoin 改进提案(FIP)共同决定.
- 59.5% 存储矿工能挖到的币,一天释放的币认为是在40万左右. 

[资料来源](https://ipfs.io/ipfs/Qmdsip9Kcoyj3J3Fyvjw3wjPCuewkZiGVWpN8rYF3dJKqg/vesting.html)

种种这些措施都能看出,项目方对项目的代币释放计划是经过精心设计的.

这样的设计首先从制度上约束了项目方不能不劳而获在项目没完成之前就得到大量奖励.由于代币是分批释放的,因此项目方必须把项目做好,刺激代币价格上涨,这样自己后续拿到代币时收益才能尽量高.

另外这样的释放计划也尽量防止代币在上线初期像其它很多项目那样被投资者套现抛售而导致价格承受巨大的抛压.

在这个项目中,上线初期没有任何一方手中握有大量筹码,因此市场上的代币货源稀少.

总的说来,这个项目从代币释放的机制来看项目方可谓是用心良苦,尽量约束和平衡各方的利益,促使各方一起为项目的长远发展和生态建设努力.


**质押**

为了减轻矿工的负担至最低来满足对质押的多种需求,Filecoin有三种不同的质押机制

- 存储质押 : 7天的扇区故障费和1个扇区故障检测费(和区块奖励大小挂钩)
- 共识质押 : 为了实现30%的网络流通量都要被锁定在初始共识质押中. 所以需根据扇区加权字节算力(QAP), 在网络中所占的比例分配给该扇区一小部分质押份额, 初始质押应随时间的减少而减少
- 区块奖励质押 : 挖到币后先锁仓20天,后180天线性释放.意思就是20天后就能每天平均地拿到挖到的币,180天拿完.因为矿工是一致在挖币的, 所以只需要等待第一个20天, 后面每天都会受到奖励.(update有调整 取消20天锁定)

其中1+2目前是一个扇区1个FIL.只是极限值,未来只少不多.当然这只是 space race 时的测试值,主网正式上线的时候肯定时会调整的.否则中小矿工或新增矿工很难加入进来.

**产币**

- 简单产币 : 6年减半的那种.这部分占每天释放币的30%.
- 基准产币 : 总网络达到某一个算力基准时, 才释放币.这个基准一开始为1EB(相当于1000PB),然后每年增加200%,之后5年分别是 : 3EB,9EB, 27EB, 81EB,243EB...全网算力一旦到了这个基准线,就继续释放剩余的奖励币, 这部分占70%.

- 第一阶段 : 收入以“简单产币”为主,因为全网还没到1EB, 所以30%的币是一挖就有,另外70%得到了基准线后才有.

- 第二阶段 : 到了网络基准线了, 这时候整个网络容量很大,可以存很多有用的数据, 我们也能挖到那额外的70%的“基准产币”了,除此之外还会有一部分的存储订单交易收入.

- 第三阶段 : 挖币的人越来越多, 区块奖励越来越少,“简单产币”基本上没了, 这就和比特币一样,那么主要收入来源于提供高质量存储和检索服务和交易手续费了

**消减**

- 只要未能提交PoSt证明就会有故障费用的消减 br(2.14)
- 扇区故障费用的消减每天都会扣除直到钱包账户归零或矿工将sector从网络中移除,同时会受到一个扇区惩罚的消减
- 当矿工在WindowPoSt检查发生之前自我声明之后就不会收到后续的一次性的故障检出惩罚
- 如果矿工自我声明,但是声明的太晚了,则依然会被做对于这个sector的消减惩罚 br(3.5) (update 数值有可能会变更)
- 如果矿工没有自我声明,然后被区块网络检查错误,则会对整个 partition 都执行消减惩罚 br(3.5) (update数值有可能会变更)
- 如果矿工的sector被删除的话会收到一个中止费用的消减.

**矿工应在以下3方面努力来挖到更多币**

- 性能更高的复制证明算法 : 链上数据更少,验证时间更快,硬件成本更低,不同的安全性假设,从而使扇区生命周期更长,并且无需重新封装即可进行扇区升级.

- 更具可扩展性的共识算法,可以提供更大的吞吐量并以更短的时间内处理更多的消 息.

- 更多可以使扇区持续更长的时间的交易订单功能.

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020831/1598861682918.png)

----------------

#### FileCoin的区块结构 tipsets

GHOSTy协议让矿工记录过去所有被观察到的区块,以增加其区块链的权重.Filecoin的共识机制建立在这些综合之上,叫做tipsets. 如果比特币是靠最长和最有效的链的竞赛来运作,那么Filecoin的期望共识就是基于选举,在指定回合中可以选举多个矿工作为领导者.这就意味着可以在每个区块中创建多个有效的同级区块,**在每个新的纪元(epoch),新一代的家谱发展出来,称之为tipset,这也是我们网络中独特的系统.**

Filecoin中的区块按纪元(epoch)排序,每个新的区块都引用上一个纪元(epoch)中产生的至少一个块(父块).一个tipset集是具有相同父块且在同一个纪元(epoch)中挖到的有效区块组成.

下图,为了简化没有将存储算力考虑在内,用不同颜色表示的3个来自相同祖父块的tipsets.让我们来计算一下这些tipsets的权重.

![在同一个Epoch中3个Tipsets的示例](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918330213.png)

下面第一个图表中, “**祖块+父块+子块**” 给纪元2中的第一个tipset赋予总权重为5.

![纪元2中的第一个tipset总权重为5](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918422870.png)

下面第二个tipset拥有总权重为4(一个祖块,两个父块,一个子块).

![纪元2中第二个tipset权重为4](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918442371.png)

最后一个tipset(第三张表)拥有总权重为3(一个祖块,一个父块,一个子块)

![纪元2中第三个tipset权重为3](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918457685.png)

最后的表提供了该链的全面视角,在纪元2里第一个tipset赢了, 尽管到下一个纪元才会被确认.

![来自同一纪元的所有tipsets.尽管还没有到下一个纪元被确认,目前权重最大的链是第一个权重为5的tipset](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918479137.png)

与以太坊一样,该系统通过确保不浪费任何工作量来激励协作并从总体来提高链上的吞吐量.此外,由于tipset要求严格,所有的块都必须来自相同的父块,并且在相同的高度被开采,因此在分叉的情况下,该链可以实现“*快速收敛*”.

**最终,Filecoin会赋予提供更多存储算力的区块以权重,因为它的核心是存储网络.随着时间的流逝,矿工会聚集在权重最大的链上来创造价值**,而权重小的链将成为孤块.

-----------------

20200924 add

#### FileCoin矿工的经济效应

统一以官方的  AMD Ryzen线程撕裂者3970x,128GB ram,使用 nvidia 2080TI显卡为基准当量, 
这个配置每天大概可以封装setor的个数在 4-5 个左右 (32GB) , 差不多是140-150GB的总量, 
如果使用以 AMD Epyc 7402 ,1TB  ram,8T\*2 ssd,使用 nvidia 2080TI或 nvidia 3080显卡, 
这个配置可以提供基准当量的 12倍左右的并行运行. 可以视作每天可以有1.5-1.8TB的总密封量,

由币的释放模型可知,存储矿工每天挖出的币总数大概是在 40万枚,基准产币未达到的情况下,只有30%的简单产币即12万枚, 
虽然每个 tipsets 设置所有矿工预期赢得选票数的平均值设为 5,(泊松分布)(同时每个矿工的win count也由不同,这是可以有多份的),但目前实际都是偏小,大概在 3.5 左右(块由于网络原因丢了,或者是说孤块没有被网络接受) ,所以我们可以看到每个矿工出块的时候一个 win count的收益大概是12Fil,PS由于丢快和孤块的原因,所以你的绝对爆块率也肯定是小于你全网算力比例的.

`(3.5 win counts) \* 2tipsets \* 60 minutes * 24hours * 12FIL ==> 120000 FIL`

**需要特别注意的几个数据**

- 算力增长率 : 单位时间算力增长比率；
- 爆块率 : 矿工获得出块权的比率；
- 出块率 : 矿工获得出块权并成功出块的比率；
- 挖矿效率 : 单位算力对应的FIL收益；

对于一个矿工来说==算力增长率==与密封机器数量,单个扇区密封平均时间相关

其中单个扇区密封时间与机器配置,代码效率和稳定性相关,这是由于目前官方支持单台机器多个数据密封任务的并行计算,经过证明的扇区空间需要不断的挑战验证,所以算力增长率是一个综合的衡量指标.

爆块率 : 矿工通过有效算力获得出块权的==理论值==,只与矿工的有效算力成正比；

出块率 : 矿工通过有效算力获得==出块权==,并成功提交算力证明(WinningPost),然后对消息进行打包才算是完成了一次出块,这个过程需要在一个区块时间(25秒)内完成.

由于完成一次算力证明,需要数据读取与零知识证明过程(大量计算)需要保证程序的高效性和稳定性,并且要完成对链上消息的打包.这个过程需要完整准确的做完才能获得对应的收益.

![每tipset执行出块的流程](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600923338207.png)

![挖矿效率的本质](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600923418890.png)

我们一直谈论的混杂了法币经济效益的数据 Fil/天\*万元 则是更加复杂的一个数据结合.它是综合了非常庞大的参数计算而成的.这不是简简单单的随口就能报出来的.需要不断的上线运行后才能总结得出.

**期望共识的误区**

矿工通过密封数据形成有效算力,可以通过算力争夺出块权,这个过程类似于POW机制,具体的方式为 :  

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600922951377.png)

其中,h(vrfout)是不可预测随机数,totalPower是全网算力,myPower是当前矿工密封数据的算力,e=5是每个tipset预期出块数量.每个Epoch时,每个矿工可以计算上面公式看是否成立,若满足则矿工获得出块权,成功出块以后可以得到对应的收益.

 可以看出,当矿工的算力达到全网算力的20%时,矿工一定可以获得出块权；当矿工算力小于20%时,矿工获得出块权的比率与矿工算力占全网算力比率成正比.

**平均区块奖励 这是错误的思路,只是销售用来量化阐述的概念**

每区块奖励 只是和释放与win count数量有大的相关性.跟你挖了多少没啥大关联

每TB的平均挖矿收益,这一定是会下降的,但是要反过来看,自己的存力一定是要从整网算力比例去看,而不是单纯看自己的算力总额,诚然只要自己增加了算力总额总是好事,但如果增长率的斜率还追不上整网存力增长速率,也就是自己的算力份额不能保持,有非常大的滑坡,那么自己的总收益就会下降,看平均收益率仅仅是用来计算自己当前期望挖取的Fil币数目,不能展示出来你的趋势,而趋势才是更重要的.

**质押费 和 收益额 之间微妙的关系**

由于目前的FIL流通量严重不足,绝大部分的FIL都要倍用来增加算力进行前置质押,所以前置质押的速率也抑制了总存量的增长,反过来也延缓了单位存力收益额下降的趋势.

可想而知,随着比例增长维持在整个网络中一个微妙的平衡时,这个数值也相对的会进行动态平衡.

**FileCoin大矿工的历史包袱问题**

从目前看,只要是有能力拿到达标奖励的159个矿工中头部的一些,他们获得的奖励FIL是非常丰厚的.结合 SR2 AMA上官方确定的 封装的算力和质押的Fil币会进行轨道转移映射到主网.他们只要不出太大的问题,在主网后6个月代币释放完成,就算根据目前期权价格做贴现远期也是早就收回了成本.故目前对大矿工来说,他们的急只是主网上线的急,一种托底的急,并不需要长远的去寻求额外的增长点了.

小矿工方面,由于有100,500,1000的small miner reward存在,他们只要舍得开6个月的机器,也绝对是不会大亏的,特别需要指出的是小矿工一般都是在官方确定了机器配置之后采购的,一般不会有什么太大的前期试错成本.

较为困难的是中型,什么都是一般般的矿工,技术一般般,机器一般般,封装量一般般.所以收益也是一般般,如果还有试错历史的话,有可能就需要更长的周期来平摊成本,他们一般就没法将成本大量的转移了.

----------------
----------------

### FileCoin的技术学习记录

#### 推荐的学习路径文档列表

当然从头开始看是最完整的,不过我们可以分主次,有一些是越早了解完全越好的

1. FileCoin官方文档 [docs.filecoin.io](https://docs.filecoin.io/) ps官方的文档有可能一天都改动好多,看的时候多多刷新

2. [术语表](https://docs.filecoin.io/reference/glossary)

3. FileCoin官方说明书 [spec.filecoin.io](https://spec.filecoin.io/)

4. Go-filecoin的code review [github go-filecoin code review](https://github.com/filecoin-project/go-filecoin/blob/master/CODEWALK.md)

5. 推荐的客户端工具Lotus [lotus.sh](https://lotu.sh/) , [lotus.github源码](https://github.com/filecoin-project/lotus)

6. 石榴矿池 6block提供的开源挖矿软件 [6block.lotus-miner](https://github.com/shannon-6block/lotus-miner)

7. FileCoin api驱动的接入工具powergate [powergate](https://docs.textile.io/powergate/)

8. IPFS的集群化管理软件 [Fleek的space-daemon](https://docs.fleek.co/), [源码](https://github.com/FleekHQ/space-daemon)

9. 关于filecoin的存储证明教学 [proto_school](https://proto.school/tutorials) ,[proto school-verifying storage on filecoin](https://proto.school/verifying-storage-on-filecoin/)

10. 仅作为参考的 开始挖矿系列 [Github awesome-filecoin-mining](https://github.com/bobjiang/awesome-filecoin-mining)

----------------------

20200921 begin update

#### 使用Lotus接入测试网络

- 测试机器地址 172.16.0.27 有vino
- 测试网络信息 [Network Info](https://network.filecoin.io/#testnet)
- 测试网络的水龙地址 [testnet filecoin faucet](https://spacerace.faucet.glif.io/)
- apt源选网易或者阿里
- 安装好git后需要设置本地代理
	
	```
	git config --gloabl http.proxy=http://xxx:1080
	git config --global https.proxy=http://xxx:1080
	
	git config --global --unset http.proxy
	git config --global --unset https.proxy
	```
- lotus的中国ipfs代理 `IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"`
- GO的代理
	
	```	shell
	go env -w GO111MODULE=on
	go env -w GOPROXY=https://goproxy.io,direct
	
	# 设置不走 proxy 的私有仓库,多个用逗号相隔(可选)
	go env -w GOPRIVATE=*.corp.example.com

	# 设置不走 proxy 的私有组织(可选)
	go env -w GOPRIVATE=example.com/org_name
	```	
- ubuntu 的系统要求
	
	`sudo apt update && sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl -y && sudo apt upgrade -y`
- 对rustup的依赖,需要 ==cargo== 和 ==rustc== 两个工具,哪个命令好用用哪个,其实都一样.而且现在lotus在make clean的时候也会下载指定版本的rust和cargo,这里是否需要自己安装也未可知
	`snap install rustup`
	`rustup install stable`
	`rustup default stable`
		
	cargo在编译时需要下载,在 `/home/.cargo`创建config文件,其实使用了sudo会在 /root下,cargo在编译的时候也需要下载,config文件中可以指定代理项
	```
	[http]
	proxy = "172.16.0.25:1081"

	[https]
	proxy = "172.16.0.25:1081"
	```	
	
	或者也可以直接使用国内镜像的方式
	
	``` shell
	# 安环境变量 设置环境变量 RUSTUP_DIST_SERVER(用于更新 toolchain)
	export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
	以及 RUSTUP_UPDATE_ROOT(用于更新 rustup)
	export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
	
	cargo镜像配置,在/home/.cargo下的config文件中配置如下内容
	[source.crates-io]
	registry = "https://github.com/rust-lang/crates.io-index"
	# 指定镜像
	replace-with = 'sjtu'

	# 清华大学
	[source.tuna]
	registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

	# 中国科学技术大学
	[source.ustc]
	registry = "git://mirrors.ustc.edu.cn/crates.io-index"

	# 上海交通大学
	[source.sjtu]
	registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

	# rustcc社区
	[source.rustcc]
	registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
	```
	
- 服务器需要安装clang,llvm	,否则在编译lotus的时候会出现 llvm-config 找不到文件的问题
	`sudo apt isntall clang`
	`sudo apt install llvm`
- 对go的依赖,我们使用golang官网的下载解压方式,需要安装 go 1.14及以上的版本
- 使用git克隆lotus库
	`git clone https://github.com/filecoin-project/lotus.git`
- 支持 SHA 扩展指令的cpu使用 rust标记 [Native Filecoin FFI section](https://docs.filecoin.io/get-started/lotus/installation/#native-filecoin-ffi)
	`export RUSTFLAGS="-C target-cpu=native -g"`
	`export FFI_BUILD_FROM_SOURCE=1`
- 编译 lotus
	`sudo make clean all`
	`sudo make install`
- 查看可执行文件 ==lotus==	,==lotus-miner==	,==lotus-worker==	应该在 ==/usr/local/bin== 下
- lotus的工作目录默认是在 $HOME/.lotus,用户不同是不一样的.
- 启动 lotus的守护进程  `lotus daemon`
- 或者通过命令创建 systemd service
	`sudo make install-daemon-service`
	`sudo make install-chainwatch-service`
	`sudo make install-miner-service` 
	对应 ==systemctl status lotus-daemon==
	默认的log重定向到 ==/var/log/lotus/daemon.log==,不能使用journalctl查看日志
	当同步的时候在日志中产生的error和warning并不需要太过担心,他们一般都是守护进程执行一些分布式的方法出现的
	**需要注意如果有设置了环境变量在启动服务文件中也需要设置**,systemd加载环境变量的文件在/etc/systemd/system.conf和/etc/systemd/user.conf中, 需要注意,如果使用sudo来运行命令,由于安全原因会清除掉用户环境变量,如果确实有需要,可以用 `-E` 参数,即 `sudo -E`.
- 开始同步区块 `lotus sync status` ,  `lotus sync wait`
	需要注意的是目前的区块同步依然是一个比较大的工程,大概实际运行的数据需要1/4的下载同步时间,所以强烈建议通过下载快照来进行同步,[快照地址](https://very-temporary-spacerace-chain-snapshot.s3-us-west-2.amazonaws.com/Spacerace_stateroots_snapshot_latest.car),请直接使用浏览器下载速度会快的多,这个快照每6小时都会进行更新.你可以使用 `lotus daemon --import-snapshot <snapshot>.car` 文件来进行同步数据的导入.
- filecoin相关目录	, 整个本地数据由这些相关目录 和 wallet 及 chain文件组成,切记同步的时候把全局代理取消了
	`~/.lotus ($LOTUS_PATH)`
	`~./lotusminer ($LOTUS_MINER_PATH)`
	`~./lotusworker ($LOTUS_WORKER_PATH)`
- 区块数据的快照 snapshot
	`lotus chain export <file>` 导出区块链
	`lotus daemon --import-snapshot <file>` 导入区块链

---------------------

#### Lotus的配置文件和环境变量

Lotus的配置文件在 ==$LOTUS_PATH/config.toml== ,主要是关于api和libp2p的网络配置,其中api设置的是lotus daemon本身监听的端口,而libp2p则是用在与网络中的其他节点进行交互的设置,其中ListenAddress和AnnounceAddresses可以显示的配置为自己的固定ip和port,当然需要使用multiaddress的格式.

**环境变量的设置**

*   `LOTUS_FD_MAX` : Sets the file descriptor limit for the process
*   `LOTUS_JAEGER` : Sets the Jaeger URL to send traces. See TODO.
*   `LOTUS_DEV` : Any non-empty value will enable more verbose logging, useful only for developers.

Variables specific to the _Lotus daemon_ 

*   `LOTUS_PATH` : Location to store Lotus data (defaults to `~/.lotus`).
*   `LOTUS_SKIP_GENESIS_CHECK=_yes_` : Set only if you wish to run a lotus network with a different genesis block.
*   `LOTUS_CHAIN_TIPSET_CACHE` : Sets the size for the chainstore tipset cache. Defaults to `8192`. Increase if you perform frequent arbitrary tipset lookups.
*   `LOTUS_CHAIN_INDEX_CACHE` : Sets the size for the epoch index cache. Defaults to `32768`. Increase if you perform frequent deep chain lookups for block heights far from the latest height.
*   `LOTUS_BSYNC_MSG_WINDOW` : Sets the initial maximum window size for message fetching blocksync request. Set to 10-20 if you have an internet connection with low bandwidth.
*   `FULLNODE_API_INFO="TOKEN : /ip4/<IP>/tcp/<PORT>/http"` 可以设置本地的lotus读取远程的 lotus daemon

---------------------

#### 钱包管理

- 查看钱包
	`lotus wallet list` 查看所有的钱包账户
	`lotus wallet default` 查看默认钱包
	`lotus wallet set-default <address>` 设置一个默认钱包
	`lotus wallt balance` 
- 新建钱包
	`lotus wallet new [bls|secp256k1 (default secp256k1)]` 其中bls会生成 t3长地址(对multisig友好),secp256k1即btc的曲线参数会生成t1的短地址,新创建的钱包会在 ==$LOTUS_PATH/keystore==
- 执行转账
	`lotus wallet send --from=<sender_address> <target_address> <amount>`
	`lotus wallet send <target_address> <amount>`
- 导入导出钱包 (你也可以直接copy ~/.lotus/keystore)
	`lotus wallet export <address> > wallet.private`
	`lotus wallet import wallet.private` 

---------------------

#### 如何使用 Lotus daemon 或 Lotus-miner提供的 json-rpc 接口

目前json-rpc接口没有文档,只能看源码

1. EndPoint

*   `http://[api:port]/rpc/v0` http json-rpc接口
*   `ws://[api:port]/rpc/v0` websocket json-rpc接口
*   `http://[api:port]/rest/v0/import` 只允许put请求,需要一个写权限来添加文件

2. 创建有权限控制的 JWT
	```sh
	# Lotus Node
	lotus auth create-token --perm admin

	# Lotus Miner
	lotus-miner auth create-token --perm admin
	```
	其中有4种权限
	- `read` - 只能读取
	- `write` - 可以写入,包含 read
	- `sign` - 可以使用私钥签名,包含 read,write
	- `admin` - 管理节点的权限,包含 read,write,sign

3. 请求方式,和标准 json-rpc 2.0 一致.
	``` sh
	# 不需要权限
	curl -X POST \
     -H "Content-Type:application/json" \
     --data '{ "jsonrpc":"2.0", "method":"Filecoin.ChainHead", "params":[], "id":3 }' \
     'http://127.0.0.1:1234/rpc/v0'
	 
	 # 需要权限时,需要传入 JWT
	 curl -X POST \
     -H "Content-Type:application/json" \
     -H "Authorization:Bearer $(cat ~/.lotusminer/token)" \
     --data '{ "jsonrpc":"2.0", "method":"Filecoin.ChainHead", "params":[], "id":3 }' \
     'http://127.0.0.1:1234/rpc/v0'
	```
	
---------------------

#### 使用Lotus存储数据

术语解释 CAR文件 : [Specification : Content Addressable aRchives](https://github.com/ipld/specs/blob/master/block-layer/content-addressable-archives.md)

- 数据必须打包到一个CAR文件中,这里可以使用以下命令
	`lotus client generate-car <input path> <output path>`
	`lotus client import <file path>`
- 列出本地已经导入或者创建car的文件
	`lotus client local`
- 数据必须切割到指定的扇区大小,如果你自己创建了car文件,确保使用--czr标志来进行导入	
- 查询矿工,询问价格,开始存储交易(在线交易)
	`lotus state list-miners`
	`lotus client query-ask <miner>`
	`lotus client deal` 
- 扇区文件可以存储的容量,首先计算使用的是1024而不是1000,同时对于每256位 bits,需要保留2位作为证明之需.即32GB的sector可以存储的容量是 2^30\*254\/256 字节
- 离线交易,生成car,然后生成对应所选矿工的piece块的CID,然后提出离线交易
	`lotus client generate-car <input path>	<output path>`
	`client commP <inputCAR filepath> <miner>`
	`lotus client deal --manual-piece-cid=CID --manual-piece-size=datasize <Data CID> <miner> <piece> <duration>`
	`lotus-miner deals import-data <dealCID> <filepath>`
- 从IPFS中导入数据,首先需要在lotus配置中打开 UseIpfs,然后可以直接将ipfs中的文件进行在线交易
	`lotus client deal QmSomeData t0100 0 100`

	
#### 使用Lotus检索交易

- 查询自己的数据被哪些矿工存储
	`lotus client find <Data CID>`
- 进行检索交易
	`lotus client retrieve <Data CID> <out file>`
	
---------------------	

#### 使用官方Lotus-miner执行挖矿的常见问题

1. 在lotus中使用filter只与指定的bot进行deal

``` lotusminer/config.toml
~/.lotusminer/config.toml

[Dealmaking]
Filter = <shell command>

## Reject all deals
Filter = "false"

## Accept all deals
Filter = "true"

## Only accept deals from the 4 competition dealbots (requires jq installed)
Filter = "jq -e '.Proposal.Client == \"t1nslxql4pck5pq7hddlzym3orxlx35wkepzjkm3i\" or .Proposal.Client == \"t1stghxhdp2w53dym2nz2jtbpk6ccd4l2lxgmezlq\" or .Proposal.Client == \"t1mcr5xkgv4jdl3rnz77outn6xbmygb55vdejgbfi\" or .Proposal.Client == \"t1qiqdbbmrdalbntnuapriirduvxu5ltsc5mhy7si\" '"
```

2. 修改miner的gas费率

``` lotusminer/config.toml
[Fees]
MaxPreCommitGasFee = "0.05 FIL"
MaxCommitGasFee = "0.05 FIL"
MaxWindowPoStGasFee = "50 FIL"
```

3. [使用单独的地址来进行 windowPoSt](https://github.com/filecoin-project/lotus/blob/master/documentation/en/mining.md#separate-address-for-windowpost-messages)

4. 如果sector损坏无法生成PoSt,而且就算只有一个 sector失败,也会把整个runPost标记为失败,如果是一个小矿工,所有的sector在一个window中,如果错失了提交则会在之后的24小时内失去所有算力,必须在24后重新提交一次有效WindowPoSt才能自动恢复.

5. sector升级,再SR中,必须升级一个sector才判定会成功挖矿

``` sh
lotus-miner sectors list
[sector number]: Proving sSet: YES active: YES tktH: XXXX seedH: YYYY deals: [0]

lotus-miner sectors mark-for-upgrade [sector number]

24小时内他将从 active: YES 变为 active: NO

for s in $( seq $( lotus-miner sectors list | wc -l ) ) ; do lotus-miner sectors status --log $s | grep -Eo 'ReplaceCapacity":true' && echo $s; done`

lotus-miner sectors status --on-chain-info $SECTOR_NUMBER | grep OnTime

```

6. 查看 lotus-miner显示支持的GPU和benchmark

[权威列表](https://github.com/filecoin-project/bellman#supported--tested-cards)

[使用自定义的GPU](https://docs.filecoin.io/mine/lotus/gpus/#enabling-a-custom-gpu)

[bellperson](https://github.com/filecoin-project/bellman#supported--tested-cards)

添加环境变量
`export BELLMAN_CUSTOM_GPU="GeForce RTX 3080:8704"`

测试
`./lotus-bench sealing --sector-size=2KiB`

---------------------

#### 使用官方Lotus-miner开始挖矿

1. 查看上述的 ==使用Lotus接入测试网络== 章节安装 Lotus套件,并开启 Native Filecoin FFI, 并且确保设置了中国地区参与的必要参数
2. 设置性能参数环境变量 
``` shell
# See https://github.com/filecoin-project/bellman
export BELLMAN_CPU_UTILIZATION=0.875

# See https://github.com/filecoin-project/rust-fil-proofs/
export FIL_PROOFS_MAXIMIZE_CACHING=1 # More speed at RAM cost (1x sector-size of RAM - 32 GB).使用更多的内存来加快预提交的速度
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 # precommit 2 GPU acceleration,加快GPU
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
```
3. 设置 lotus node 节点 (当node和miner运行在不同的机器上的时候,详细参看上文的 如何使用 Lotus daemon 或 Lotus-miner监听提供的 json-rpc 接口 章节)
`export FULLNODE_API_INFO=<api_token>:/ip4/<lotus_daemon_ip>/tcp/<lotus_daemon_port>/http`
4. 如果内存过少,则需要添加swap分区,详细可以参看 linux使用文档中的添加swap
``` shell
sudo fallocate -l 256G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# show current swap spaces and take note of the current highest priority
swapon --show
# append the following line to /etc/fstab (ensure highest priority) and then reboot
# /swapfile swap swap pri=50 0 0
sudo reboot
# check a 256GB swap file is automatically mounted and has the highest priority
swapon --show
```
5. 下载 Filecoin矿工证明参数,32GB和64GB时不一样的,(默认路径`/var/tmp/filecoin-proof-parameters`),通过环境变量设置,你可以通过提前下载,或是在init的时候自动下载
`export FIL_PROOFS_PARAMETER_CACHE=/path/to/fast/mount`
``` shell
# Use sectors supported by the Filecoin network that the miner will join and use.
# lotus-miner fetch-params <sector-size>
lotus-miner fetch-params 32GiB
lotus-miner fetch-params 64GiB
```
6. 矿工初始化,使用 --no-local-storage 创建配置文件,配置文件一般是在 ~/.lotusminer/ 或 $LOTUS_MINER_PATH
`lotus-miner init --owner=<bls address>  --no-local-storage`
7. 需要一个公网ip来进行矿工设置.编辑 ~/.lotusminer/config.toml
``` lotusminer/config.toml
[libp2p]
  ListenAddresses = ["/ip4/0.0.0.0/tcp/24001"] # choose a fixed port
  AnnounceAddresses = ["/ip4/<YOUR_PUBLIC_IP_ADDRESS>/tcp/24001"] # important!
```
8. 当的确可以访问该公网ip时,启动 lotus-miner
`lotus-miner run` 或 `systemctl start lotus-miner`
9. 公布矿工地址 `lotus-miner actor set-addrs /ip4/<YOUR_PUBLIC_IP_ADDRESS>/tcp/24001`
10. 其他步骤
	- 配置自定义存储的布局,这要求一开始使用 --no-local-storage
	- 编辑 lotus-miner 的配置
	- 合适关闭或重启矿机
	- 发现或者说通过运行基准测试来得到密封一个sector的时间 ExpectedSealDuration
	- 配置额外的worker来提高miner的密封sector的能力
	- 为 windowPost设置单独的账户地址.