---
title: Filecoin入门基础概念
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

#### 推荐的学习路径文档列表

1. FileCoin官方文档 [docs.Filecoin.io](https://docs.Filecoin.io/) ps官方的文档有可能一天都改动好多,看的时候多多刷新
2. [术语表](https://docs.Filecoin.io/reference/glossary)
3. FileCoin官方说明书 [spec.Filecoin.io](https://spec.Filecoin.io/)
4. Go-Filecoin的code review [github go-Filecoin code review](https://github.com/Filecoin-project/go-Filecoin/blob/master/CODEWALK.md)
5. 推荐的客户端工具Lotus [lotus.sh](https://lotu.sh/) , [lotus.github源码](https://github.com/Filecoin-project/lotus)
6. 关于Filecoin的存储证明教学 [proto_school](https://proto.school/tutorials) ,[proto school-verifying storage on Filecoin](https://proto.school/verifying-storage-on-Filecoin/)	

--------------------------------------------------------------------------------	

#### 什么是Filecoin

IPFS是一个去中心化存储网络，Filecoin是IPFS存储的激励层，Filecoin作为生态激励来保证 IPFS 节点的运行。

FIL 是 Filecoin 项目基于 Filecoin 公链发行的 Token，全称是：Filecoin ,符号是：FIL。

Filecoin项目主要组成部分
- 去中心化存储网络DSN
- 复制证明PoRep
- 构建两个可验证市场，即存储市场和检索市场

在Filecoin中,用户付费将其文件存储在存储矿工上,存储矿工负责存储文件,并不断随时间推移证明文件被如实保存.

Filecoin 链包括区块链和本机加密货币 （FIL）。存储矿工赚取用于存储文件的 FIL 单位。Filecoin 的区块链记录了要发送和接收 FIL 的交易，以及存储矿工提供的证据，证明他们正确存储了文件。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin入门基础概念/20201116/1605533346328.png)


#### 官方FAQ

参考URL: https://filecoin.io/zh-cn/faqs/

##### IPFS和Filecoin之间有什么联系?

Filecoin和IPFS是互补协议，两者均由Protocol Labs创建。IPFS 允许网络中的参与者互相存储，索取和传输可验证的数据。 IPFS是开源的，可以被免费下载和使用，并且已经被大量的团队使用。运用IPFS，各个节点可存储它们认为重要的数据；没有简单的方法可以激励他人加入网络或存储特定数据。 为了解决这一关键问题，Filecoin的设计旨在提供一个持久的数据存储系统。在Filecoin的激励结构下，客户付费以在特定的冗余和可用性水平上存储数据，矿工通过不断地存储数据并以加密方式证明数据存储来获得付款和奖励。 简而言之：IPFS按内容寻址并使其移动； Filecoin就是缺失的激励机制。

Filecoin还使用了IPFS的许多性能。例如：

Filecoin将IPLD用于区块链数据结构
Filecoin节点使用libp2p保证安全连接
节点之间的消息传递和Filecoin块传播使用libp2p发布订阅

此外，Filecoin核心团队包括IPFS核心团队的成员。 IPFS和Filecoin之间的兼容将尽可能无缝对接。即使在Filecoin发布之后，我们仍然期望IPFS和Filecoin的开源社区们继续协作和提升两个项目的兼容性。

##### 我什么时候应该选择使用Filecoin？何时应该选择IPFS?

首先，值得重复的是，Filecoin和IPFS相互补充，并且具有显着的交叉兼容性。 我们正努力地使自发的IPFS存储和付费Filecoin存储之间的转换更加简单。

使用IPFS，您可以通过直接提供硬件或从第三方购买存储来负责您自己的存储节点。 在IPFS上，单独的节点可以存储他们认为重要的内容； 没有任何简单的方法来激励他人来保证储存你的数据在他们的系统里。Filecoin提供了缺少的激励机制。

如果您希望维护自己的存储节点，或者和外部协作来合作存储数据，IPFS将可能会是您的首选方案。如果您希望支付具有竞争力的价格并在特定的冗余和可用性下为您管理信息存储，Filecoin可能是您的首选方案。