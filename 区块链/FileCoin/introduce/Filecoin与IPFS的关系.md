---
title: Filecoin与IPFS的关系
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

IPFS和Filecoin都是由协议实验室打造的明星项目，IPFS是一种点对点、版本化、内容寻址的超媒体传输协议，对标的是传统互联网协议HTTP,其所要构建的是一个分布式的web 3.0.

但IPFS只是一个开源的互联网底层通信协议，大家都可以免费的使用他。目前所有IPFS节点都提供存储空间同时也需要其他节点帮助自己存储资源，即「人人为我，我为人人」，你需要别人的存储帮助同时也要求自己有共享。

从本质上来说IPFS将原来P2P软件的按需下载转变为资源的长期存储，那么长期存储就需要有服务质量保证，否则没有用户愿意将自己有价值数据或者需要服务质量保证的资源内容存储到IPFS中。那么对于一个松散的IPFS网络，用户的随意退出、网络质量的不确定性、存储地理位置的不确定性、硬件资源性能参差不齐，硬件资源的性能抖动，这些问题都使得IPFS没有办法去存储对服务质量有强需求的资源存储，换句话说没有办法在商业领域中使用。

所以，IPFS需要Filecoin的激励机制来吸引一批专业的存储服务商来提供更专业、安全和稳定的存储服务。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin与IPFS的关系/2020112/1604309931694.png)

Filecoin是一个基于IPFS的去中心化存储网络，是IPFS上唯一的激励层，是一个基于区块链技术发行的通证。在FIlecoin网络中的矿工可以通过为客户提供存储和检索服务来获取FIL。相反的，客户可以通过花费FIL雇佣矿工来存储或分发数据。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin与IPFS的关系/2020112/1604309945276.png)

IPFS与Filecoin之间的关系有点类似于区块链与比特币的关系。Filecoin的诞生是为了通过经济激励的机制来促进IPFS的发展，Filecoin网络也需要IPFS为其市场的发展提供强大的生态支持。

IPFS网络使用的越多，对Filecoin的需求就越大；Filecoin的矿工越多，对IPFS网络的也就支持越大。所以IPFS和Filecoin形成了共生关系。他们的关系有点类似于区块链与比特币之间的关系。Filecoin的诞生是为了支持IPFS的发展，IPFS也需要Filecoin为其丰富生态。IPFS使用的越多，Filecoin的需求更大；Filecoin的矿工越多，对IPFS的支持越大。

------------------

Filecoin是一个去中心化分布式存储网络，是IPFS的唯一激励层。Filecoin采用了区块链通证体系发行了Token，Token简称FIL。Filecoin是一个去中心化存储网络，是的IPFS激励层。所以，Filecoin也是IPFS上的一个重要应用。

Filecoin基于IPFS协议将云存储构建了一个去中心化的存储交易市场，包括「存储」和「检索」两个市场。这个市场运行在有着本地协议令牌（FIL）的区块链，矿工可以通过为客户提供存储来获取FIL；相反的，客户可以通过花费FIL来雇佣矿工来存储或分发数据。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin与IPFS的关系/2020112/1604309985155.png)

--------------------

FileCoin创新开发采用了一种混合共识机制——复制证明 （PoRep）+时空证明（PoSt）+预期共识机制（Expected Consensus)。

复制证明（PoRep）：复制证明是一个新型的存储证明，存储矿工需要向验证人证明自己把相应的数据存储在一个特定的设备上面，而不是把多份数据存储在一个设备上面。Filecoin采用复制证明有效阻止了女巫攻击、外包攻击、代攻击。

时空证明（PoSt)：时空证明则是在复制证明的基础上，加上时间戳等技术，得到一个一段时间内旷工存储数据的证明。即使用户不在线，也可以在未来的某个时候，利用时空证明去验证在该段时间内矿工存储的数据。

PoSt是Filecoin在验证矿工存储用户数据的时候产生的，Filecoin把矿工在网络中的当前存储数据相对于整个网络的存储比例转化为矿工投票权（voting power of the miner），重用PoSt来产生共识。

预期共识(EC)：Filecoin的共识协议是基于权益共识（Proof-of-Stake）构建的，并将权益共识里面的权益（stake）换成了存储，在每一个周期里面，预期选举出来的领导矿工是1个，但是在某些情况下也会选举出来多个领导矿工。被选举出来的矿工创建新的区块，并把新的区块对网络进行广播，从而获得区块奖励。目标是使得矿工出块的权益，与自己对存储的贡献成正比。