---
title: 01_Filecoin逻辑梳理及源代码导读
tags: 
---

文章转自 Star Li 星想法 的公众号

[toc]

Filecoin的源代码可以从Github下载：https://github.com/filecoin-project/go-filecoin。

在阅读源代码之前，强烈建议看两份对阅读代码有益的文档：

Filecoin的设计文档 

https://github.com/filecoin-project/specs

设计文档，从设计的角度，分别介绍数据结构，挖矿机制，共识机制，支付方式，虚拟机执行，状态机，存储角色等等。

CODEWALK.md

https://github.com/filecoin-project/go-filecoin/blob/master/CODEWALK.md

CODEWALK也是高屋建瓴的讲述了Filecoin的代码历史，框架，以及各个模块的功能。

总的来说，这两份文档篇幅都不长，对理解Filecoin的项目以及代码很有帮助。建议大家有空看看。注意的是，这些文档也不是实时更新，和代码有些出入的。闲话不多说，我整理了一下Filecoin源代码的一些理解，方便对Filecoin代码感兴趣的小伙伴，可以更快的理解Filecoin的设计以及现状。文章比较长，请耐心阅读 :)

在该导读中使用的Filecoin代码的最后一个commit信息如下：

commit c293e9032505fce2f89575846dcf5491b7b0fe92 (HEAD -> master, origin/master, origin/HEAD)

Author: Richard Littauer richard.littauer@gmail.com

Date:   Mon Feb 18 19:22:47 2019 +0200

docs: Add dual license

Missing it in the manifest. Not sure if this is how GX reads it (cc @whyrusleeping), but I'm going off of this example from @kemitchell.

#### Filecoin的几个基本概念

**Filecoin State Machine (Filecoin状态机)**:

Filecoin的状态机，主要是维护如下一些状态信息：支付情况，存储市场情况，各个节点的Power（算力）等等。

**Actor：**

Filecoin网络中的Actor可以类比以太坊网络中的账户（一般账户或者智能合约账户）。每个Actor有自己的地址，余额，也可以维护自己的状态，同时Actor提供一些函数调用（也正是这些函数调用触发Actor的状态变化）。Filecoin的状态机，包括所有Actor的状态。

Actor的状态，包括：账户信息（Balance），类型（Code），以及序号（Nonce）。Actor的定义在actor/actor.go中。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452971.jpg)

**Message：**

Filecoin网络中的区块是由一个个的Message组成。你可以把Message想象成以太坊的交易。一个Message由发起地址，目标地址，金额，调用的函数以及参数组成。所有Message的执行的结果就是状态机的全局状态。Filecoin网络的全局状态就是映射表：Actor的地址和Actor的状态/信息。以太坊的全局信息是通过leveldb数据库存储。Filecoin的全局状态是使用IPLD HAMT(Hash-Array Mapped Trie) 存储。

Message的定义在types/message.go中。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452976.jpg)

**FIL & AttoFIL**:

FIL是Filecoin项目的代币。AttoFIL是FIL代币的最小单位，1 AttoFIL = 10^(-18) FIL。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452977.jpg)

**Gas费用：**

和以太坊网络类似，执行Actor的函数需要消耗Gas。Actor的函数调用有两种方式：1/ 用户发起签名后的Message（指定调用某个Actor的某个函数），并支付矿工Gas费用（类似以太坊的Gas费用）。2/ Actor之间调用。Actor之间调用也必须是用户发起。

**区块（Block & TipSet）:**

Block是一个区块，定义在types/block.go文件中：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452970.jpg)

一个区块的信息主要包括：

*   打包者的地址信息

*   区块的高度/权重信息

*   区块中包括的交易信息/更新后新的Root信息

*   Ticket信息以及Ticket的PoSt的证明信息

一个Tip，就是一个区块。一个TipSet，就是多个区块信息的集合，这些区块拥有同一个父亲区块。所谓的TipSet，就是一个区块的多个子区块，定义在types/tipset.go文件中：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452980.jpg)

目前Filecoin的代码中，每个区块的生成时间设置为30秒。

#### Filecoin地址生成逻辑

在深入其他逻辑之前，先介绍一下Filecoin网络中的地址生成逻辑。Filecoin的地址总共为41个字节，比如**fc**qphnea72vq5yynshuur33pfnnksjsn5sle75rxc。**fc**代表是主网，**tf**代表是测试网络。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452983.jpg)

详细的代码在address/address.go，核心逻辑在encode函数。 在address/constants.go文件中定义了一些参数，并预制了一些固定地址：Filecoin的铸币地址，存储市场地址，支付通道地址等等。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452978.jpg)

#### Filecoin的整体框架

Filecoin区块链相关的整体框架如下图所示：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452984.jpg)

所有的交易在节点间同步到每个节点的“Message Pool”中。经过“Expected Consensus”共识机制，当选为Leader的一个或者多个节点从“Message Pool”中挑选Message，并打包。被打包的区块，会同步给其他节点。打包的区块中的交易（Message）会被Filecoin虚拟机执行，更新各个Actor的状态。所有的区块数据，Actor的状态是通过IPFS/IPLD进行存储。

#### Filecoin 虚拟机以及Gas计算

Filecoin虚拟机比较简单，在Filecoin虚拟机执行具体某个Message的时候（Actor的某个Method），会准备VMContext，提供Actor的执行环境：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452989.jpg)

Filecoin虚拟机相关的代码在vm的目录下。所有的区块数据以及Actor状态数据存储是通过IPFS/IPLD实现。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452990.jpg)

*   Message（）函数提供了当前交易Message的信息

*   BlockHeight（）函数提供了当前区块高度信息

*   Stoage/ReadStorage/WriteStorage提供对当前目标地址的存储访问信息

*   Charge()函数提供油费耗费的调用

*   CreateNewActor/AddressForNewActor/IsFromAcccountActor函数提供了对Actor地址的创建以及基本查询功能

*   Rand函数提供了随机数能力

*   Send函数提供了调用其他Actor函数的能力

#### Expected Consensus - EC共识机制

Filecoin的共识算法叫Expected Consensus，简称EC共识机制。Expected Consensus实现的相关代码在consensus目录。除了区块链数据外，Expected Consensus每一轮会生成一个Ticket，每个节点通过一定的计算，确定是否是该轮的Leader。如果选为Leader，节点可以打包区块。也就是说，每一轮可能没有Leader（所有节点都不符合Leader的条件），或者多个Leader（有多个节点符合Leader）。Filecoin使用TipSet的概念，表明一轮中多个Leader产生的指向同一个父亲区块的区块集合。

**Ticket的生成：**

下一轮的Ticket是通过前一轮的区块的Proof以及节点的地址的Hash计算的结果，具体看consensus/expected.go中的CreateTicket函数。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452979.jpg)

**Leader的选择：**

在每个Ticket生成的基础上，进行Leader的选择，具体查看consensus/expected.go中的IsWinningTicket函数。也就是说，如果Ticket的数值小于当前节点的有效存储的比例的话，该节点在该轮就是Leader。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452981.jpg)

**Weight的计算：**

当多个Leader打包，形成多个TipSet时，通过计算TipSet的Weight的计算确定“主链”。具体查看consensus/expected.go中的Weight函数。如下图，在高度n+1，存在两个合法的TipSet，如何选择TipSet作为主链：计算Weight。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452982.jpg)

每个区块的Weight的计算公式如下：

   **Weight = ParentWeight + ECV + ECPrM * ratio**

目前，ECV设置为10， ECPrM设置为100，Ratio是当前节点的存储有效率（节点存储的容量/所有节点的存储容量）。在目前的算法下，也就是说，节点的ratio高，Weight就高。

一个TipSet的Weight等于TipSet中所有区块的Weight的总和。Weight大的TipSet认为是主链。当两个TipSet的Weight一样大的时候，取Ticket较小者。

#### Filecoin协议层

在区块链的基础上，Filecoin设计了几个协议：hello协议，storage协议以及retrieval协议。协议层在区块链数据之上，通过Message驱动区块链状态转移。Hello协议负责TipSet的区块同步，storage协议负责存储需求双方的撮合，retrieval协议负责文件的检索以及读取服务。协议层的代码在protocol目录中。

以storage协议为例，讲解一些协议层的主要逻辑：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/01_Filecoin逻辑梳理及源代码导读/2020123/1606985452985.jpg)

Miner（紫红色）就是平时所说的存储矿工，通过createMiner创建Miner Actor。使用Miner Actor的addAsk提供存储服务。存储需求方，也就是Client，通过getAsks获取所有Miner Actor的存储服务，并在这些服务中确定相应的存储矿工。在确定存储矿工的基础上，使用createChannel创建支付通道，并和存储矿工进行数据的传输。存储矿工在存储数据后，定期向Miner Actor报告存储证明（submitPoSt）。存储矿工通过FPS（Filecon Proving Subsystem）实现数据的存储以及存储证明：SectorBase提供存储接口，Storage Proof提供PoRep以及PoSt的存储证明。PoRep以及PoSt的存储证明逻辑可以查看：[IPFS & FileCoin - PoRep和PoSt算法](http://mp.weixin.qq.com/s?__biz=MzU5MzMxNTk2Nw==&mid=2247483765&idx=1&sn=e646e5e37da91f572b60cc904e7e1b8d&chksm=fe131065c9649973139abc75f9a99d246932c669462e037c0b4cbe508e2cfc0069d557e9d6e6&scene=21#wechat_redirect)。其他协议逻辑类似，感兴趣的小伙伴可以自行查看源代码。

**总结：** Filecoin是由区块链以及上层协议构成的存储系统。Filecoin有自己的一套术语：Message，Block，TipSet，Actor，Ticket，GAS。Filecoin的状态由多个Actor的状态组成。Filecoin区块链的区块数据以及Actor的状态数据通过IPFS/IPLD进行存储。Filecoin采用EC共识机制，通过TipSet的Weight确定主链。Filecoin目前实现三个上层协议：Hello，Storage（存储协议）以及Retrieval（检索协议）。目前的代码还在迭代中，代码中有很多TODO，也有一些和设计文档不一致的地方。