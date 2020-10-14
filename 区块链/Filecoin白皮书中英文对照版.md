---
title: Filecoin白皮书中英文对照版
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

## Filecoin:一种去中心化的存储网络

Filecoin: A Decentralized Storage Network

作者：协议实验室（Protocol Labs）

摘要 Abstract

当前互联网正处于一场革命中：集中式专有服务正在被去中心化开放服务所代替；信任式参与被可验证式计算所代替；脆弱的位置寻址被弹性的内容寻址所代替；低效率的整体式服务被点对点算法市场所代替；比特币、以太坊和其他的区块链网络已经证明了去中心化交易账本的有效性。这些公共账本处理复杂的智能合约应用程序和交易价值数百亿美金的加密资产。这些系统的参与者们形成去中心化的、没有中心管理机构或者可信任党派的网络提供了有用的支付服务，这是广泛互联网开放服务的第一个实例。IPFS通过分散的网页自身已经证明了内容寻址的有效性，它提供了全球点对点网络数十亿文件使用。它解放了孤岛数据，网络分区存活，离线工作，审查制度路线，产生了持久的数字信息。

The internet is in the middle of a revolution: centralized proprietary services are being replaced with decentralized open ones; trusted parties replaced with verifiable computation; brittle location addresses replaced with resilient content addresses; inefficient monolithic services replaced with peer-to-peer algorithmic markets. Bitcoin, Ethereum, and other blockchain networks have proven the utility of decentralized transaction ledgers. These public ledgers process sophisticated smart contract applications and transact crypto-assets worth tens of billions of dollars. These systems are the first instances of internet-wide Open Services, where participants form a decentralized network providing useful services for pay, with no central management or trusted parties. IPFS has proven the utility of content-addressing by decentralizing the web itself, serving billions of files used across a global peer-to-peer network. It liberates data from silos, survives network partitions, works offline, routes around censorship, and gives permanence to digital information.

Filecoin是一个去中心化存储网络，它让云存储变成一个算法市场。这个市场运行在有着本地协议令牌（也叫做Filecoin）的区块链。区块链中的旷工可以通过为客户提供存储来获取Filecoin,相反的，客户可以通过花费Filecoin来雇佣旷工来存储或分发数据。和比特币一样，Filecoin的旷工们为了巨大的奖励而竞争式挖区块，但Filecoin的挖矿效率是与存储活跃度成比例的，这直接为客户提供了有用的服务（不像比特币的挖矿仅是为了维护区块链的共识）。这种方式给旷工们创造了强大的激励，激励他们尽可能多的聚集存储器并且把它们出租给客户们。Filecoin协议将这些聚集的资源编织成世界上任何人都能依赖的自我修复的存储网络。该网络通过复制和分散内容实现鲁棒性，同时自动检测和修复副本失败。客户可以选择复制参数来防范不同的威胁模型。该协议的云存储网络还提供了安全性，因为内容是在客户端端对端加密的，而存储提供者不能访问到解密秘钥。Filecoin的成果作为可以为任何数据提供存储基础架构的IPFS最上面的激励层。它对去中心化数据，构建和运行分布式应用程序，以及实现智能合同都非常有用。

Filecoin is a decentralized storage network that turns cloud storage into an algorithmic market. The market runs on a blockchain with a native protocol token (also called “Filecoin”), which miners earn by providing storage to clients. Conversely, clients spend Filecoin hiring miners to store or distribute data. As with Bitcoin, Filecoin miners compete to mine blocks with sizable rewards, but Filecoin mining power is proportional to active storage, which directly provides a useful service to clients (unlike Bitcoin mining, whose usefulness is limited to maintaining blockchain consensus). This creates a powerful incentive for miners to amass as much storage as they can, and rent it out to clients. The protocol weaves these amassed resources into a self-healing storage network that anybody in the world can rely on. The network achieves robustness by replicating and dispersing content, while automatically detecting and repairing replica failures. Clients can select replication parameters to protect against different threat models. The protocol’s cloud storage network also provides security, as content is encrypted end-to-end at the client, while storage providers do not have access to decryption keys. Filecoin works as an incentive layer on top of IPFS, which can provide storage infrastructure for any data. It is especially useful for decentralizing data, building and running distributed applications, and implementing smart contracts.

这些工作包括以下几部分内容：

1.  介绍Filecoin网络，概述这个协议以及详细介绍几个组件。
2.  形式化去中心化存储网络（DSN)的计划与内容，然后构建Filecoin作为一个DSN。
3.  介绍一种叫“复制证明”的新型存储证明方案，它允许验证任何数据副本都存储在物理上独立的存储器中。
4.  介绍一种新型的以基于顺序复制和存储作为激励度量的有用工作共识。
5.  形成可验证市场，并构建两个市场，存储市场和检索市场，它们分别管理如何从Filecoin写入和读取数据。
6.  讨论用例，如何连接其他系统以及如何使用这个协议。

注意：Filecoin是一项正在进行的工作。正在进行积极的研究，本文的新版本将会出现在filecoin.io

This work:

1.  Introduces the Filecoin Network, gives an overview of the protocol, and walks through several components in detail.
2.  Formalizes decentralized storage network (DSN) schemes and their properties, then constructs File-coin as a DSN.
3.  Introduces a novel class of proof-of-storage schemes called proof-of-replication, which allows proving that any replica of data is stored in physically independent storage.
4.  Introduces a novel useful-work consensus based on sequential proofs-of-replication and storage as a measure of power.
5.  Formalizes verifiable markets and constructs two markets, a Storage Market and a Retrieval Market, which govern how data is written to and read from Filecoin, respectively.
6.  Discusses use cases, connections to other systems, and how to use the protocol.

Note: Filecoin is a work in progress. Active research is under way, and new versions of this paper will appear at https://filecoin.io. For comments and suggestions, contact us at research@filecoin.io.

----------------

## 介绍 Introduction

Filecoin是一种协议令牌，其区块链运行在一种叫“时空证明”的新型证明机制上，其区块被存储数据的矿工所挖。Filecoin协议通过不依赖于单个协调员的独立存储提供商组成的网络提供数据存储服务和数据检索服务。其中：

1.  用户为数据存储和检索支付令牌
2.  存储矿工通过提供存储空间赚取令牌
3.  检索矿工通过提供数据服务赚取令牌

Filecoin is a protocol token whose blockchain runs on a novel proof, called Proof-of-Spacetime, where blocks are created by miners that are storing data. Filecoin protocol provides a data storage and retrieval service via a network of independent storage providers that does not rely on a single coordinator, where: (1) clients pay to store and retrieve data, (2) Storage Miners earn tokens by offering storage (3) Retrieval Miners earn tokens by serving data.

### 基本组件 Elementary Components

Filecoin协议由四个新型组件组成。

1.  去中心化存储网络(Decentralized Storage Network)(DSN)：我们提供一个由提供存储和检索服务的独立服务商网络的抽象（在第二节）。接着我们提出了Filecoin协议作为激励，可审计和可验证的DSN构建（在第4节）。
2.  新型的存储证明：我们提出了两种新型存储证明方案（在第三节）：（1）“复制证明”（Proof-of-Replication）允许存储提供商证明数据已经被复制到了他自己唯一专用的物理存储设备上了。执行唯一的物理副本使验证者能够检查证明者是否不存在将多个数据副本重复拷贝到同一存储空间。（2）“时空证明”（Proof-of-Spacetime）允许存储提供商证明在指定的时间内存储了某些数据。
3.  可验证市场：我们将存储请求和检索需求作为两个由Filecoin网络操作的去中心化可验证市场的订单进行建模（在第五节）。验证市场确保了当一个服务被正确提供的时候能执行付款。我们介绍了客户和矿工可以分别提交存储和检索订单的存储市场和检索市场。
4.  有效的工作量证明（Proof-of-Work）：我们展示了如何基于“时空证明”来构建有效的工作量证明来应用于共识协议。旷工们不需要花费不必要的计算来挖矿，但相反的必须存储数据于网络中。

The Filceoin protocol builds upon four novel components.

1.  Decentralized Storage Network (DSN): We provide an abstraction for network of independent storage providers to offer storage and retrieval services (in Section (2)). Later, we present the Fileeoin protocol as an incentivized, auditable and verifiable DSN construction (in Section |4j).
2.  Novel Proofs-of-Storage: We present two novel Proofs-of-Storage (in Section [3]): (1) Proof-of-Replication allows storage providers to prove that data has been replicated to its own uniquely dedicated physical storage. Enforcing unique physical copies enables a verifier to check that a prover is not deduplicating multiple copies of the data into the same storage space; (2) Proof-of-Spacetime allows storage providers to prove they have stored some data throughout a specified amount of time.
3.  Verifiable Markets: We model storage requests and retrieval requests as orders in two decentralized verifiable markets operated by the Fileeoin network (in Section |5j). Verifiable markets ensure that payments are performed when a service has been correctly provided. We present the Storage Market and the Retrieval Market where miners and clients can respectively submit storage and retrieval orders.
4.  Useful Proof-of-Work: We show how to construct a useful Proof-of-Work based on Proof-of-Spacetime that can be used in consensus protocols. Miners do not need to spend wasteful computation to mine blocks, but instead must store data in the network.

### 协议概述 Protocol Overview

*   Filecoin协议是构建于区块链和带有原生令牌的去中心化存储网络。客户花费令牌来存储数据和检索数据，而矿工们通过提供存储和检索数据来赚取令牌。
*   Filecoin DSN 分别通过两个可验证市场来处理存储请求和检索请求：存储市场和检索市场。客户和矿工设定所要求服务的价格和提供服务的价格，并将其订单提交到市场。
*   市场由Filecoin网络来操作，该网络采用了“时空证明”和“复制证明”来确保矿工们正确存储他们承诺存储的数据。
*   最后，矿工们能参与到区块链新区块的锻造。矿工对下一个区块链的影响与他们在网络中当前存储使用量成正比。
*   The Filecoin protocol is a Decentralized Storage Network construction built on a blockchain and with a native token. Clients spend tokens for storing and retrieving data and miners earn tokens by storing and serving data.
*   The Filecoin DSN handle storage and retrieval requests respectively via two verifiable markets: the Storage Market and the Retrieval Market. Clients and miners set the prices for the services requested and offered and submit their orders to the markets.
*   The markets are operated by the Filecoin network which employs Proof-of-Spacetime and Proof-of-Replication to guarantee that miners have correctly stored the data they committed to store.
*   Finally, miners can participate in the creations of new blocks for the underlining blockchain. The influence of a miner over the next block is proportional to the amount of their storage currently in use in the network.

_图一是使用了术语定义之后的Filecoin协议草图，伴随着一个例子如图2所示。_

A sketch of the Filecoin protocol, using nomenclature defined later within the paper, is shown in Figure [1] accompanied with an illustration in Figure [2].

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662061081.jpg)

图1：Filecoin 协议草图

Figure 1: Sketch of the Filecoin Protocol.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662098517.jpg)

图2：Filecoin 协议实例与用户矿机交互

Figure 2: Illustration of the Filecoin Protocol, showing an overview of the Client-Miner interactions. The Storage and Retrieval Markets shown above and below the blockchain, respectively, with time advancing from the Order Matching phase on the left to the Settlement phase on the right. Note that before micropayments can be made for retrieval, the client must lock the funds for the microtransaction.

### 论文组织 Paper organization

本文的其余部分安排如下：我们在第二节中介绍了对一个理论上的DNS方案的定义和需求。在第三节中我们定义和介绍我们的“复制证明”和“时空证明”协议，以及Filecoin将其用于加密地验证数据按照订单的要求被持续不断的存储。第四节描述了Filecoin DSN的具体实例，描述了数据结构，协议，以及参与者之间的交互。第5节定义和描述可验证市场的概念，还有存储市场和检索市场的实施。第6节描述了使用“时空证明”协议进行演示，并且评估矿工对网络的贡献，这对扩展区块链块和区块奖励是必要的。第7节简要介绍了Filecoin中的智能合约。在第8节中讨论了未来的工作作为结束。

The remainder of this paper is organized as follows. We present our definition of and requirements for a theoretical DSNscheme in Section 2\. In Section 3 we motivate, define, and present our Proof-of-Replication and Proof-of-Spacetime protocols, used within Filecoin to cryptographically verify that data is continuously stored in accordance with deals made. Section 4 describes the concrete instantiation of the Filecoin DSN, describing data structures, protocols, and the interactions between participants. Section 5 defines and describes the concept of Verifiable Markets, as well as their implementations, the Storage Market and Retrieval Market. Section 6 motivates and describes the use of the Proof-of-Spacetime protocol for demonstrating and evaluating a miner’s contribution to the network, which is necessary to extend the blockchain and assign the block reward. Section 7 provides a brief description of Smart Contracts within the Filecoin We conclude with a discussion of future work in Section 8.

----------------

## 去中心化存储网络的定义 Denition of a Decentralized Storage Network

我们介绍了去中心化存储网络（DSN）方案的概念。DSNs聚集了由多个独立存储提供商提供的存储，并且能自我协调的提供存储数据和检索数据服务给客户。这种协调是去中心化的、无需信任的：通过协议的协调与个体参与者能实施验证操作，系统可以获得安全性操作。DSNs可以使用不同的协调策略，包括拜占庭协议，gossip协议或者CRDTs，这取决于系统的需求。在后面，第四节，我们提供Filecoin DSN的的一个构建。

We introduce the notion of a Decentralized Storage Network (DSN) scheme. DSNs aggregate storage offered by multiple independent storage providers and self-coordinate to provide data storage and data retrieval to clients. Coordination is decentralized and does not require trusted parties: the secure operation of theses systems is achieved through protocols that coordinate and verify operations carried out by individual parties. DSNs can employ different strategies for coordination, including Byzantine Agreement, gossip protocols, or CRDTs, depending on the requirements of the system. Later, in Section [4} we provide a construction for the Filecoin DSN.

定义 2.1 _DSN方案(Π)是由存储提供商和客户运行的协议元组:_

_(Put, Get, Manage)_

*   Put(data) → key: 客户端执行Put协议以将数据存储在唯一的标识符秘钥下。
*   Get(key) → data: 客户端执行Get协议来检索当前使用秘钥存储的数据。
*   Manage(): 网络的参与者通过管理协议来协调：控制可用的存储，审核提供商提供的服务并修复可能的故障、管理协议由存储提供商来运行，并且经常与客户或者审计网络结合（在管理协议依赖区块链的情况下，我们认为矿工是审计人员，因为他们验证和协调存储提供商）。

DSN方案(Π)必须保证数据的完整性和可恢复性，并且能够容忍在后面章节中所定义的管理和存储故障。

Definition 2.1. A DSN scheme II is a tuple of protocols run by storage providers and clients:

(Put, Get, Manage)

*   Put(data) -> key: Clients execute the Put protocol to store data under a unique identifier key.
*   Get(key) -> data: Clients execute the Get protocol to retrieve data that is currently stored using key.
*   Manage(): The network of participants coordinates via the Manage protocol to: control the available storage, audit the service offered by providers and repair possible faults. The Manage protocol is run by storage providers often in conjunction with clients or a network of auditor.

A DSN scheme II must guarantee data integrity and retrievability as well as tolerate management and storage faults defined in the following sections.

### 故障容错 Fault tolerance

#### 管理故障 Management faults

我们将管理故障定义为管理协议的参与者引起的拜占庭故障。一个DSN方案依赖于它的基础管理协议的故障容错。违反故障容错的管理故障假设可能会影响系统的活跃度和安全性。

We define management faults to be byzantine faults caused by participants in the Manage protocol. A DSN scheme relies on the fault tolerance of its underlining Manage protocol. Violations on the faults tolerance assumptions for management faults can compromise liveness and safety of the system.

例如，考虑一个DSN方案，其中管理协议要求拜占庭容错来审核存储提供商。在这样的协议中，网络收集到来自存储提供商的存储证明，并运行拜占庭容错对这些证明的有效性达成共识。如果在总共n个节点中，拜占庭容错最多容忍f个故障节点。那么我们的DSN可以容忍 f<n/2 个故障节点。在违反了这些假设的情况下，审计上就要做出妥协。

For example, consider a DSN scheme II, where the Manage protocol requires Byzantine Agreement (BA) to audit storage providers. In such protocol, the network receives proofs of storage from storage providers and runs BA to agree on the validity of these proofs. If the BA tolerates up to f faults out of n total nodes, then our DSN can tolerate f < n/2 faulty nodes. On violations of these assumptions, audits can be compromised.

#### 存储故障 Storage faults

我们将存储故障定位为拜占庭故障，阻止了客户检索数据。例如存储矿工丢失了他们的数据，检索矿工停止了他们的服务。一个成功的Put操作的定义是(f,m),既是它的输入数据被存储在m个独立的存储提供商（总共有n个）中，并且它可以容忍最多f个拜占庭存储提供商。参数f和m取决于协议的实现。协议设计者可以固定f和m，或者留给用户自己选择。将Put(data) 扩展为Put(data,f,m)。如果有小于f个故障存储提供商，则对存储数据的Get操作是成功的。

We define storage faults to be Byzantine faults that prevent clients from retrieving the data: i.e. Storage Miners lose their pieces, Retrieval Miners stop serving pieces. A successful Put execution is (J, m)-tolerant if it results in its input data being stored in m independent storage providers (out of n total) and it can tolerate up to f Byzantine providers. The parameters f and m depend on protocol implementation; protocol designers can fix f and m or leave the choice to the user, extending Put(data) into Put(data, /, m). A Get execution on stored data is successful if there are fewer than f faulty storage providers.

例如，考虑一个简单的方案。它的Put协议设计为每个存储提供商存储所有的数据。在这个方案里，m=n,并且f=m-1。但总是f=m-1吗，不一定的，有些方案可能采用可擦除式设计，其中每个存储供应商存储数据的特定部分，这样使得m个存储供应商中的x个需要检索数据，在这种场景下f=m-x。

For example, consider a simple scheme, where the Put protocol is designed such that each storage provider stores all of the data. In this scheme m = n and f = m – 1\. Is it always f = m – 1? No, some schemes can be designed using erasure coding, where each storage providers store a special portion of the data, such that x out of m storage providers are required to retrieve the data; in this case f = m – x.

### 属性 Properties

我们描述DSN方案所必须的两个属性，然后提出Filecoin DSN所需要的其他属性。

We describe the two required properties for a DSN scheme and then present additional properties required by the Filecoin DSN.

#### 数据完整性 Data Integrity

该属性要求没有有限的对手A可以让客户在Get操作结束的时候接受被更改或者伪造的数据。

This property requires that no bounded adversary A can convince clients to accept altered or falsified data at the end of a Get execution.

定义 2.2 _一个DSN方案(Π)提供了数据完整性：如果有任意成功的Put操作将数据d设置在键k下，那不存在计算有限的对手A能使得客户在对键k执行Get操作结束的时候接受d‘，其中d’ 不等于d。_

Definition 2.2. A DSN scheme II provides data integrity if: for any successful Put execution for some data d under key k, there is no computationally-bounded adversary A that can convince a client to accept d’, for d’ / d at, the end of a Get execution for identifier k.

#### 可恢复性 Retrievability

该属性满足了以下要求：考虑到我们的Π的容错假设，如果有些数据已经成功存储在Π并且存储提供商继续遵循协议，那么客户最终能够检索到数据。

This property captures the requirement that, given our fault-tolerance assumptions of Π, if some data has been successfully stored in Π and storage providers continue to follow the protocol, then clients can eventually retrieve the data.

定义2.3 _一个DSN方案(Π)提供了可恢复性：如果有任意成功的Put操作将数据d设置在键k下，且存在一个成功的客户Get操作通过对键K执行检索得到数据（这个定义并不保证每次Get操作都能成功，如果每次Get操作最终都能返回数据，那这个方案是公平的）。_

Definition 2.3. A DSN scheme Π provides retrievability if: for any successful Put execution for data under key, there exists a successful Get execution for key for which a client retrieves data.

### 其他属性 Other Properties

DSNs可以提供特定于其应用程序的其他属性。我们定义了Filecoin DSN所需要的三个关键属性：公开可验证性、可审查性和激励兼容性。

DSNs can provide other properties specific to their application. We define three key properties required by the Filecoin DSN: public verifiability, auditability, and incentive-compatibility.

定义2.4 _一个DSN方案(Π)是公开可验证的：对于每个成功的Put操作，存储网络的供应商可以生成数据当前正在被存储的证明。这个存储证明必须说服任何只知道键但并不能访问键所对应的数据的有效验证者。_

Definition 2.4\. A DSN scheme II is publicly verifiable if: for each successful Put, the network of storage providers can generate a proof that the data is currently being stored. The Proof-of-Storage must convince any efficient verifier, which only knows key and does not have access to data.

定义2.5 _一个DSN方案(Π)是可审查的：如果它产生了可验证的操作轨迹，并且在未来能被检查在正确的时间上数据确实被存储了。_

Definition 2.5\. A DSN scheme II is auditable, if it generates a verifiable trace of operation that can be checked in the future to confirm storage was indeed stored for the right duration of time.

定义2.6 _一个DSN方案(Π)是激励可兼容的：如果存储提供商由于成功提供了存储数据和检索数据的服务而获得激励，或者因为作弊而得到惩罚。所有存储提供商的优势策略是存储数据。_

Definition 2.6\. A DSN scheme II is incentive-compatible, if: storage providers are rewarded for successfully offering storage and retrieval sendee, or penalized for misbehaving, such that the storage providers’ dominant strategy’ is to store data.

----------------

## 复制证明与时空证明 Proof-of-Replication and Proof-of-Spacetime

在 Filecoin 协议中，存储供应商必须让他们的客户确信，客户的付费存储数据已经被他们存储；在实践中，存储供应商们会生成“存储证明”（POS）来让区块链网络（或客户自己）验证。

In the Filecoin protocol, storage providers must convince their clients that they stored the data they were paid to store; in practice, storage providers will generate Proofs-of-Storage (PoS) that the blockchain network (or the clients themselves) verifies.

在本节中，我们将展示和概述在 Filecoin 中所使用的“复制证明”（PoRep）和“时空证明”（PoSt）的方案。

In this section we motivate, present and outline implementations for the Proof-of-Replication (PoRep) and Proof-of-Spacetime (PoSt) schemes used in Filecoin.

### 动机 Motivation

存储证明（POS）方案，例如“数据持有性验证”（PDP）和“可恢复性证明”（PoR）方案，允许一个将数据外包给服务器（即证明人P）的用户（即验证者V）可以反复检查服务器是否依然存储数据D。用户可以用比下载数据更高效的方式来验证他外包给服务器的数据的完整性。服务器通过对一组随机数据块进行采样和传送少量数据来生成拥有的概率证明作为给用户的挑战 / 响应协议。

Proofs-of-Storage (POS) schemes such as Provable Data Possession (PDP) and Proof-of-Retrievability (PoR), schemes allow a user (i.e. the verifier V) who outsources data D to a server (i.e. the prover V) to repeatedly check if the server is still storing D. The user can verify the integrity of the data outsourced to a server in a very efficient way, more efficiently than downloading the data. The server generates probabilistic proofs of possession by sampling a random set of blocks and transmits a small constant amount of data in a challenge/response protocol with the user.

PDP和PoR方案只能保证了证明人在响应的时候拥有某些数据。但在 Filecoin 中，我们需要更强大的保障，来阻止作恶矿工进行不提供存储却获得奖励的三种类型攻击：女巫攻击（Sybil attack）、外包攻击（outsourcing attacks）生成攻击（generation attacks）。

*   女巫攻击：作恶矿工通过创建多个女巫身份，假装物理存储了很多副本（从中获取奖励），但实际上只存储了一次。
*   外包攻击：通过快速从其他存储提供商获取数据，作恶矿工可能承诺能存储比他们实际物理存储容量更大的数据。
*   生成攻：作恶矿工可以宣称要存储大量的数据，相反的他们使用小程序有效地生成请求。如果这个小程序小于所宣称要存储的数据，则作恶矿工在Filecoin 获取区块奖励的可能性增加了，因为这是和矿工当前使用量成正比的。

PDP and PoR schemes only guarantee that a prover had possession of some data at the time of the challenge /response. In Filecoin, we need stronger guarantees to prevent three types of attacks that malicious miners could exploit to get rewarded for storage they are not providing: Sybil attack, outsourcing attacks, generation attacks.

*   Sybil Attacks: Malicious miners could pretend to store (and get paid for) more copies than the ones physically stored by creating multiple Sybil identities, but storing the data only once.
*   Outsourcing Attacks: Malicious miners could commit to store more data than the amount they can physically store, relying on quickly fetching data from other storage providers.
*   Generation Attacks: Malicious miners could claim to be storing a large amount of data which they are instead efficiently generating on-demand using a small program. If the program is smaller than the purportedly stored data, this inflates the malicious miner’s likelihood of winning a block reward in Filecoin, which is proportional to the miner’s storage currently in use.

### 复制证明 Proof-of-Replication

“复制证明”（PoRep）是一个新型的存储证明。它允许服务器（既证明人P）说服用户（既验证者V）一些数据D已被复制到它唯一的专用物理存储上了。我们的方案是一种交互式协议。当证明人P:（a）承诺存储某数据D的n个不同的副本（独立物理副本），然后（b）通过响应协议来说服验证者V，P确实已经存储了每个副本。据我们所知PoRep改善了PDP和PoR方案，阻止了女巫攻击、外包攻击、代攻击。

Proof-of-Explication (PoRep) is a novel Proof-of-Storage which allows a server (i.e. the prover V) to convince a user (i.e. the verifier V) that some data T> has been replicated to its own uniquely dedicated physical storage. Our scheme is an interactive protocol, where the prover V： (a) commits to store n distinct replicas (physically independent copies) of some data V, and then (b) convinces the verifier V, that V is indeed storing each of the replicas via a challenge/response protocol. To the best of our knowledge, PoRep improves on PoR and PDP schemes, preventing Sybil Attacks^ Outsourcing Attacks^ and Generation Attacks.

_请注意，正式的定义，它的属性描述，和PoRep的深入研究，我们参考了 Technical Report: Proof-of-Replication, 2007。_

Note. For a formal definition, a description of its properties, and an in-depth study of Proof-of-B.eplication, we refer the reader to _Technical Report: Proof-of-Replication, 2007_.

定义3.1 _PoRep方案使得有效的证明人P能说服验证者V，数据D的一个P专用的独立物理副本R已被存储。PoRep协议其特征是多项式时间算法的元组：_

_(Setup, Prove, Verify)_

*   PoRep.Setup(1λ, D) → R, SP , SV , 其中SP和SV是P和V的特点方案的设置变量，λ是一个安全参数。PoRep.Setup用来生成副本R，并且给予P和V必要的信息来运行PoRep.Prove 和 PoRep.Verify。一些方案可能要求证明人或者是有互动的第三方去运算PoRep.Setup。
*   PoRep.Prove(SP , R, c) → πc，其中c是验证人V发出的随机验证， πc是证明人产生的可以访问数据D的特定副本R的证明。PoRep.Prove由P（证明人）为V（验证者）运行生成πc。
*   PoRep.Verify(Sv , c, πc) → {0, 1}，用来检测证明是否是正确。PoRep.Verify由V运行和说服V相信P已经存储了R。

Definition 3.1. (Proof-ot-R.eplication) A PoRep scheme enables an efficient prover V to convince a verifier V that P is storing a replica R, a physical independent copy of some data D, unique to P. A PoRep protocol is characterized by a tuple of polynomial-time algorithms:

(Setup, Prove, Verify)

*   PoRep.Setup(1λ, D) → R, SP, SV, where SP and SV are scheme-specific setup variables for V and V, A is a security parameter. PoRep.Setup is used to generate a replica TZ, and give V and V the necessary information to run PoRep.Prove and PoRep.Verify. Some schemes may require the prover or interaction with a third party to compute PoRep.Setup.
*   PoRep.Prove(SP , R, c) → πc, where c is a random challenge issued by a verifier V, and πc is a proof that a prover has access to R a specific replica of D. PoRep.Prove is run by P to produce a πc for V.
*   PoRep.Verify(Sv , c, πc) → {0, 1}, which checks whether a proof is correct. PoRep.Verify is run by V and convinces V whether P has been storing D.

### 时空证明 Proof-of-Spacetime

存储证明方案允许用户请求检查存储提供商当时是否已经存储了外包数据。我们如何使用PoS方案来证明数据在一段时间内都已经被存储了？这个问题的一个自然的答案是要求用户重复（例如每分钟）对存储提供商发送请求。然而每次交互所需要的通信复杂度会成为类似Filecoin这样的系统的瓶颈，因为存储提供商被要求提交他们的证明到区块链网络。

Proof-of-Storage schemes allow a user to check if a storage provider is storing the outsourced data at the time of the challenge. How can we use PoS schemes to prove that some data was being stored throughout a period of time? A natural answer to this question is to require the user to repeatedly (e.g. every minute) send challenges to the storage provider. However, the communication complexity required in each interaction can be the bottleneck in systems such as Filecoin, where storage providers are required to submit their proofs to the blockchain network.

为了回答这个问题，我们介绍了新的证明，“时空证明”，它可以让验证者检查存储提供商是否在一段时间内存储了他/她的外包数据。这对提供商的直接要求是：（1）生成顺序的存储证明（在我们的例子里是“复制证明”）来作为确定时间的一种方法 （2）组成递归执行来生成简单的证明。

To address this question, we introduce a new proof, Proof-of-Spacetime^ where a verifier can check if a prover is storing her/his outsourced data for a range of time. The intuition is to require the prover to (1) generate sequential Proofs-of-Storage (in our case Proof-of-Beplication) y as a way to determine time (2) recursively compose the executions to generate a short proof.

定义3.2 （时空证明）Post方案使得有效的证明人P能够说服一个验证者V相信P在一段时间内已经存储了一些数据D。PoSt其特征是多项式时间算法的元组：

_(Setup, Prove, Verify)_

*   PoSt.Setup(1λ,D) → Sp，Sv，其中SP和SV是P和V的特点方案的设置变量，λ是一个安全参数。PoSt.Setup用来给予P和V必要的信息来运行PoSt.Prove 和 PoSt.Prove。一些方案可能要求证明人或者是有互动的第三方去运算PoSt.Setup。
*   PoSt.Prove(Sp , D, c, t) → πc，其中c是验证人V发出的随机验证， πc是证明人在一段时间内可以访问数据D的的证明。PoSt.Prove由P（证明人）为V（验证者）运行生成πc。
*   PoSt.Verify(Sv , c, t, πc) → {0, 1}，用来检测证明是否是正确。PoSt.Verify由V运行和说服V相信P在一段时间内已经存储了R。

Definition 3.2. (Proof-of-Spacetime) A PoSt scheme enables an efficient prover V to convince a verifier V that V is storing some data V for some time t. A PoSt is characterized by a tuple of polynomial-time algorithms:

(Setup, Prove, Verify)

*   PoSt.Setup(1λ,D) → Sp , SV, where SP and SV are scheme-specific setup variables for P and V, A is a security parameter. PoSt.Setup is used to give V and V the necessary information to run PoSt.Prove and PoSt.Verify. Some schemes may require the prover or interaction with a third party to compute PoSt.Setup.
*   PoSt.Prove(Sp , D, c, t) → πc, where c is a random challenge issued by a verifier V, and πc is a proof that a prover has access to D for some time t. PoSt.Prove is run by P to produce a πc for V.
*   PoSt.Verify(Sv , c, t, πc) → {0, 1}, which checks whether a proof is correct. PoSt.Verify is run by V and convinces V whether P has been storing D for some time t.

### PoRep和PoSt实际应用 Practical PoRep and PoSt

我们感兴趣的是 PoRep 和 PoSt 的应用构建，可以应用于现存系统并且不依赖于可信任的第三方或者硬件。我们给出了 PoRep 的一个构建（请参见基于密封的复制证明），它在 Setup 过程中需要一个非常慢的顺序计算密封的执行来生成副本。PoRep 和 PoSt 的协议草图在图4给出，Post 的底层机制的证明步骤在图3中。

We are interested in practical PoRep and PoSt constructions that can be deployed in existing systems and do not rely on trusted parties or hardware. We give a construction for PoRep (see Seal-based Proof-of-Replication) that requires a very slow sequential computation Seal to be performed during Setup to generate a replica. The protocol sketches for PoRep and PoSt are presented in Figure 4 and the underlying mechanism of the proving step in PoSt is illustrated in Figure 3.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662127790.jpg)

图3：PoSt.Prove 基础机制的插图，展示了随时间呈现存储的迭代证明。

Figure 3: Illustration of the underlying mechanism of PoSt.Prove showing the iterative proof to demonstrate storage over time.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662202907.jpg)

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662212694.jpg)

图4：复制证明和时空证明协议草图。

Figure 4: Proof-of-Replication and Proof-of-Spacetime protocol sketches. Here CRH denotes a collisionresistant hash, x~ is the NP-statement to be proven, and w~ is the witness.

#### 构建加密区块 Cryptographic building blocks

防碰撞散列 我们使用一个防碰撞的散列函数：CRH : {0, 1}* → {0, 1}O(λ)。我们还使用了一个防碰撞散列函数MerkleCRH，它将字符串分割成多个部分，构造出二叉树并递归应用CRH，然后输出树根。

Collision-resistant hashing. We use a collision resistant hash function CRH : {0, 1}* → {0, 1}O(λ). We also use a collision resistant hash function MerkleCRH, which divides a string in multiple parts, construct a binary tree and recursively apply CRH and outputs the root.

zk-SNARKs 我们的PoRep和PoSt的实际实现依赖于零知识证明的简洁的非交互式知识论（zk-SNARKs)。因为zk-SNARKs是简洁的，所以证明很短并且很容易验证。更正式地，让L为NP语言，C为L的决策电路。受信任的一方进行一次设置阶段，产生两个公共密钥：证明密钥pk和验证密钥vk。证明密钥pk使任何（不可信）的证明者都能产生证明证明π，对于她选择的实例x，x∈L。非交互式证明π是零知识和知识证明。任何人都可以使用验证密钥vk验证证明π。特别是zk-SNARK的证明可公开验证：任何人都可以验证π，而不与产生π的证明者进行交互。证明π具有恒定的大小，并且可以在| x |中线性的时间内验证。

zk-SNARKs. Our practical implementations of PoR.ep and PoSt rely on zero-knowledge Succinct Non-interactive ARguments of Knowledge (zk-SNARKs). Because zk-SNARKs are succinct, proofs are very short and easy to verify. More formally, let L be an NP language and C be a decision circuit for L. A trusted party conducts a one-time setup phase that results in two public keys: a proving key pk and a verification key vk. The proving key pk enables any (untrusted) prover to generate a proof π attesting that x ∈ L for an instance x of her choice. The non-interactive proof tt is both zero-knowledge and proof-of-knowledge. Anyone can use the verification key vk to verify the proof π; in particular zk-SNARK proofs are publicly verifiable: anyone can verify π, without interacting with the prover that generated π. The proof tt has constant size and can be verified in time that is linear in |x|.

可满足电路可靠性的zk-SNARKs是多项式时间算法的元组：

_(KeyGen, Prove, Verify)_

*   KeyGen(1λ,C)→ (pk, vk)，输入安全参数λ和电路C，KeyGen产生概率样本pk和vk。这两个键作为公共参数发布，可在Lc上用于证明/验证。
*   Prove(pk, x, w) → π 在输入pk、输入x和NP声明w的见证时，证明人为语句x∈LC输出非交互式证明π。
*   Verify(vk, x, π) → {0, 1} 当输入vk，输入x和证明 π，验证者验证输出1是否满足x ∈ LC。

我们建议感兴趣的读者参看文献对zk-SNARK系统的正式介绍和实现。

通常而言这些系统要求KeyGen是由可信任参与方来运行。创新的可扩展计算完整性和隐私（SCIP）系统展示了在假设信任的前提下，一个有希望的方向来避免这个初始化步骤。

A zk-SNARK for circuit satisfiability is a triple of polynomial-time algorithms

(KeyGen, Prove, Verify)

*   KeyGen(1λ,C)→ (pk, vk). On input security parameter λ and a circuit C, KeyGen probabilistically samples pk and vk. Both keys are published as public parameters and can be used to prove/verify membership in Lc.
*   Prove(pk, x, w) → π. On input pk and input x and witness for the NP-statement w, the prover Prove outputs a non-interactive proof π for the statement x ∈ LC.
*   Verify(vk, x, π) → {0, 1}. On input vk, an input x, and a proof π, the verifier Verify outputs 1 if x ∈ LC.

We refer the interested reader for formal presentation and implementation of zk-SNARK systems. Generally these systems require the KeyGen operation to be run by a trusted party; novel work on Scalable Computational Integrity and Privacy (SCIP) systems shows a promising direction to avoid this initial step，hence the above trust assumption.

#### 密封操作 Seal operation

密封操作的作用是（1）通过要求证明人存储对于他们公钥唯一的数据D的伪随机排列副本成为物理的独立复制，使得提交存储n个副本导致了n个独立的磁盘空间（因此是副本存储大小的n倍）和（2）在PoRep.Setup的时候强制生成副本实质上会花费比预计响应请求更多的时间。有关密封操作的更正式定义，请参见 Technical Report: Proof-of-Replication, 2007。上述的操作可以用SealτAES−256来实现，并且τ使得SealτAES−256需要花费比诚实的证明验证请求序列多10-100倍的时间。请注意，对τ的选择是重要的，这使得运行SealτBC比证明人随机访问R花费更多时间显得更加明显。

The role of the Seal operation is to (1) force replicas to be physically independent copies by requiring provers to store a pseudorandom permutation of D unique to their public key, such that committing to store n replicas results in dedicating disk space for n independent replicas (hence n times the storage size of a replica) and (2) to force the generation of the replica during PoRep.Setup to take substantially longer than the time expected for responding to a challenge. For a more formal definition of the Seal operation see Technical Report: Proof-of-Replication, 2007\. The above operation can be realized with SealτAES−256, and t such that SealτAES−256 takes 10-100x longer than the honest challenge-prove-verify sequence. Note that it is important to choose r such that running SealτBC is distinguishably more expensive than running Prove with random access to R.

#### PoRep构建实践 Practical PoRep construction

这节描述PoRep协议的构建并已在图4包括了一个简单协议草图。实现和优化的细节略过了。

This section describes the construction of the PoRep protocol and includes a simplified protocol sketch in Figure 4 implementation and optimization details are omitted.

创建副本 Setup算法通过密封算法生成一个副本并提供证明。证明人生成副本并将输出（不包括R)发送给验证者。

Setup

*   inputs:– prover key pair (pkP ,skP )– prover SEAL key pkSEAL– data D
*   outputs: replica R, Merkle root rt of R, proof πSEAL

Creating a Replica. The Setup algorithm generates a replica via the Seal operation and a proof that it was correctly generated. The prover generates the replica and sends the outputs (excluding R) to the verifier.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662223883.png)

证明存储 Prove算法生成副本的存储证明。证明人收到来自验证者的随机挑战，要求在树根为rt的Merkle树R中确认特定的叶子节点Rc。证明人生成关于从树根rt到叶子Rc的路径的知识证明。

Prove

*   inputs:– prover Proof-of-Storage key pkPOS– replica R– random challenge c
*   outputs: a proof πPOS

Proving Storage. The Prove algorithm generates a proof of storage for the replica. The prover receives a random challenge, c, from the verifier, which determines a specific leaf Rc in the Merkle tree of R with root rt; the prover generates a proof of knowledge about Rc and its Merkle path leading up to rt.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662240821.png)

验证证明 Verify算法检查所给的源数据的哈希和副本的Merkle树根的存储证明的有效性。证明是公开可验证的：分布式系统的节点维护账本和对特定数据感兴趣的可以验证这些证明。

Verify

*   inputs:– prover public key, pkP– verifier SEAL and POS keys vkSEAL, vkPOS– hash of data D, hD– Merkle root of replica R, rt– random challenge, c– tuple of proofs, (πSEAL, πPOS)
*   outputs: bit b, equals 1 if proofs are valid

Verifying the Proofs. The Verify algorithm checks the validity of the proofs of storage given the Merkle root of the replica and the hash of the original data. Proofs are publicly verifiable: nodes in the distributed system maintaining the ledger and clients interested in particular data can verify these proofs.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662255986.jpg)

#### PoSt构建实践 Practical PoSt construction

这节描述 Post 协议的构建并已在图4中包含了一个简单协议草图。实现和优化的细节略过了。Setup 和 Verify算法和上面的 PoRep 构建是一样的。所以我们这里值描述 Prove。

This section describes the construction of the PoSt protocol and includes a simplified protocol sketch in Figure 4; implementation and optimization details are omitted. The Setup and Verify algorithm are equivalent to the PoRep construction, hence we describe here only Prove.

空间和空间的证明 Prove 算法为副本生成“时空证明”。证明人接收到来自于验证者的随机挑战，并顺序生成”复制证明“，然后使用证明的输出作为另一个输入做指定t次迭代（见图3）。

Prove

*   inputs:– prover PoSt key pkPOST– replica R– random challenge c– time parameter t
*   outputs: a proof πPOST

Proving space and time. The Prove algorithm generates a Proof-of-Spacetime for the replica. The prover receives a random challenge from the verifier and generate Proofs-of-Replication in sequence, using the output of a proof as an input of the other for a specified amount of iterations t (see Figure 3).

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662273002.png)

### 在 Filecoin 的应用 Usage in Filecoin

Filecoin 协议采用”时空证明“来审核矿工提供的存储。为了在 Filecoin 中使用 PoSt，因为没有指定的验证者，并且我们想要任何网络成员都能够验证，所以我们把方案改成了非交互式。因为我们的验证者是在 public-coin 模型中运行，所以我们可以从区块链中提取随机性来发出挑战。

The Filecoin protocol employs Proof-of-Spacetime to audit the storage offered by miners. To use PoSt in Filecoin, we modify our scheme to be non-interactive since there is no designated verifier, and we want any member of the network to be able to verify. Since our verifier runs in the public-coin model, we can extract randomness from the blockchain to issue challenges.

----------------

## Filecoin：DSN 构建 Filecoin: a DSN Construction

Filecoin DSN 是一个去中心化的存储网络，可审计、可公开验证并根据激励模式进行设计。客户支付矿工网络进行存储数据和检索；矿工提供磁盘空间和带宽来换取报酬。矿工只有当网络能够审计他们的服务被正确提供时，才能收到他们的报酬。

The Filecoin DSN is a decentralized storage network that is auditable, publicly verifiable and designed on incentives. Clients pay a network of miners for data storage and retrieval; miners offer disk space and bandwidth in exchange of payments. Miners receive their payments only if the network can audit that their service was correctly provided.

在本节中，我们将介绍基于DSN的定义和”时空证明“的 Filecoin DSN 构造。

In this section, we present the Filecoin DSN construction, based on the DSN definition and Proof-of-Spacetime.

### 设定 Setting

#### 参与者 Participants

任何用户都可以作为客户端、存储矿工和/或检索矿工来参与 Filecoin 网络。

*   客户在DSN中通过Put和Get请求存储数据或者检索数据，并为此付费。
*   存储矿工为网络提供数据存储。存储矿工通过提供他们的磁盘空间和响应 Put 请求来参与 Filecoin。要想成为存储矿工，用户必须用与存储空间成比例的抵押品来抵押。存储矿工通过在特定时间存储数据来响应用户的Put请求。存储矿工生成”时空证明”，并提交到区块链网络来证明他们在特定时间内存储了数据。假如证明无效或丢失，那存储矿工将被罚没他们的部分抵押品。存储矿工也有资格挖取新区块，如果挖到了新块，矿工就能得到挖取新块的奖励和包含在块中的交易费。
*   检索矿工为网络提供数据检索服务。检索矿工通过提供用户Get请求所需要的数据来参与Filecoin。和存储矿工不同，他们不需要抵押，不需要提交存储数据，不需要提供存储证明。存储矿工可以同时也作为检索矿工参与网络。检索矿工可以直接从客户或者从检索市场赚取收益。

Any user can participate as a Client, a Storage Miner, and/or a Retrieval Miner.

*   Clients pay to store data and to retrieve data in the DSN, via Put and Get requests.
*   Storage Miners provide data storage to the network. Storage Miners participate in Filecoin by offering their disk space and serving Put requests. To become Storage Miners, users must pledge their storage by depositing collateral proportional to it. Storage Miners respond to Put requests by committing to store the client’s data for a specified time. Storage Miners generate Proofs-of-Spacetime and submit them to the blockchain to prove to the Network that they are storing the data through time. In case of invalid or missing proofs, Storage Miners are penalized and loose part of their collateral. Storage Miners are also eligible to mine new blocks, and in doing so they hence receive the mining reward for creating a block and transaction fees for the transactions included in the block.
*   Retrieval Miners provide data retrieval to the Network. Retrieval Miners participate in Filecoin by serving data that users request via Get. Unlike Storage Miners, they are not required to pledge, commit to store data, or provide proofs of storage. It is natural for Storage Miners to also participate as Retrieval Miners. Retrieval Miners can obtain pieces directly from clients, or from the Retrieval Market.

#### 网络 N The Network, N

我们将运行所有运行Filecoin全节点的所有用户细化为一个抽象实体：网络。该网络作为运行管理协议的中介。简单的说，Filecoin区块链的每个新块,全节点管理可用的存储，验证抵押品，审核存储证明已经修复可能的故障。

We personify all the users that run Filecoin full nodes as one single abstract entity: The Network. The Network acts as an intermediary that runs the Manage protocol; informally, at every new block in the Filecoin blockchain, full nodes manage the available storage, validate pledges, audit the storage proofs, and repair possible faults.

#### 账本 The Ledger

我们的协议适用于基于账本的货币。为了通用，我们称之为“账本” L。在任何给定的时间t(称为时期)，所有的用户都能访问Lt。当处于时期t的时候，账本是追加式的，它由顺序的一系列交易组成。Filecoin DSN协议可以在运行验证Filecoin的证明的任意账本上实现。在第六节中我们展示了我们如何基于有用的工作构建一个账本。

Our protocol is applied on top of a ledger-based currency; for generality we refer to this as the Ledger, C. At any given time t (referred to as epoch), all users have access to Lt, the ledger at epoch t, which is a sequence of transactions. The ledger is apperid-only. The Filecoin DSN protocol can be implemented on any ledger that allows for the verification of Filecoin’s proofs; we show how we can construct a ledger based on useful work in Section 6.

#### 市场 The Markets

存储需求和供给组成了两个Filecoin市场：存储市场和检索市场。这两个市场是两个去中心化交易所，这会在第5节中详细解释。简而言之，客户和矿工们通过向各自的市场提交订单来设定他们请求服务或者提供服务的订单的价格。交易所为客户和矿工们提供了一种方式来查看匹配出价并执行订单。如果服务请求被成功满足，通过运行管理协议，网络保证了矿工得到报酬，客户将被收取费用。

Demand and supply of storage meet at the two Filecoin Markets: Storage Market and Retrieval Market. The markets are two decentralized exchanges and are explained in detail in Section 5\. In brief, clients and miners set the prices for the services they request or provide by submitting orders to the respective markets. The exchanges provide a way for clients and miners to see matching offers and initiate deals. By running the Manage protocol, the Network guarantees that miners are rewarded and clients are charged if the service requested has been successfully provided.

### 数据结构 Data Structures

碎片 碎片是客户在DSN所存储数据的一部分。例如，数据是可以任意划分为许多片，并且每片都可以有不同集合的存储矿工来存储。

Pieces. A piece is some part of data that a client is storing in the DSN. For example, data can be deliberately divided into many pieces and each piece can be stored by a different set of Storage Miners.

扇区 扇区是存款矿工向网络提供的一些磁盘空间。矿工将客户数据的碎片存储到扇区，并通过他们的服务来赚取令牌。为了存储碎片，矿工们必须向网络抵押他们的扇区。

Sectors. A sector is some disk space that a Storage Miner provides to the network. Miners store pieces from clients in their sectors and earn tokens for their services. In order to store pieces, Storage Miners must pledge their sectors to the network.

分配表 分配表式衣柜数据结构，可以跟踪碎片和其分配的扇区。分配表在长辈的每个区块都会更新，Merkle根存储在最新的区块中。在实践中，该表用来保持DSN的状态，它使得在证明验证的过程中可以快速查找。更详细的信息，请参看图5。

AlIocationTable. The AllocTable is a data structure that keeps track of pieces and their assigned sectors. The AllocTable is updated at every block in the ledger and its Merkle root is stored in the latest block. In practice, the table is used to keep the state of the DSN, allowing for quick look-ups during proof verification. For more details, see Figure 5.

订单 订单式请求或提供服务的意向声明。客户向市场提交投标订单来请求服务（存储数据的存储市场和检索数据的检索市场），矿工们提交报价订单来提供服务。订单数据结构如图10所示。市场协议将在第5节详细介绍。

Orders. An order is a statement of intent to request or offer a service. Clients submit bid orders to the markets to request a service (resp. Storage Market for storing data and Retrieval Market for retrieving data) and Miners submit ask orders to offer a service. The order data structures are shown in Figure 10\. The Market Protocols are detailed in Section 5.

订单簿 订单簿是订单的集合。请查看第5.2.2节的存储市场订单簿和第5.3.3节的检索市场订单簿。

Orderbook. Orderbooks are sets of orders. See the Storage Market orderbook in Section 5.2.2 and Retrieval Market orderbook in Section 5.3.2 for details.

抵押 抵押是像网络提供存储（特别是扇区）的承诺。存储矿工必须将抵押提交给账本，以便能在存储市场接受订单。抵押包括了抵押扇区的大小和存储矿工的存放的抵押品。

Pledge. A pledge is a commitment to offer storage (specifically a sector) to the network. Storage Miners must submit their pledge to the ledger in order to start accepting orders in the Storage Market. A pledge consists of the size of the pledged sector and the collateral deposited by the Storage Miner (see Figure 5 for more details).

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662336837.jpg)

图5：DSN 方案中的数据结构

Figure 5: Data Structures in a DSN scheme

### 协议 Protocol

在本节中，我们将通过描述客户端、矿工和网络执行的操作来概述Filecoin DSN。我们在图7中介绍了Get和Put协议的方法，和在图8中的管理协议。一个协议执行的示例如图6所示。图1是 Filecoin 协议概览。

In this Section, we give an overview of the Filecoin DSN by describing the operations performed by the clients, the Network and the miners. We present the methods of the Get and the Put protocol in Figure 7 and the Manage protocol in Figure 8\. An example protocol execution is shown in Figure 6\. The overall Filecoin Protocol is presented in Figure 1.

#### 客户生命周期 Client Cycle

我们将给出客户生命周期的概览；其余部分的协议将会在第五节进行深度地解析。

We give a brief overview of the client cycle; an in-depth explanation of the following protocols is given in Section 5.

1.  Put：客户将数据存储于Filecoin客户可以通过向Filecoin中的矿工支付令牌来存储他们的数据。第5.2节详细介绍了Put协议。客户通过Put协议向存储市场的订单簿提交投标订单。当找到矿工的匹配报价订单的时候，客户会将数据发给矿工，并且双方签署交易订单将其提交到存储市场订单簿。客户可以通过提交的订单来决定数据的物理副本数量。更高的冗余度会有更高的存储故障容忍度。Put: Client stores data in Filecoin.Clients can store their data by paying Storage Miners in Filecoin tokens. The Put protocol is described in detail in Section 5.2.A client initiates the Put protocol by submitting a bid order to the Storage Market orderbook (by submitting their order to the blockchain). When a matching ask order from miners is found, the client sends the piece to the miner. Both parties sign a deal order and submit it to the Storage Market orderbook.Clients should be able to decide the amount of physical replicas of their pieces either by submitting multiple orders (or specifying a replication factor in the order). Higher redundancy results in a higher tolerance of storage faults.
2.  Get：客户从Filecoin检索数据。客户可以通过使用Filecoin 令牌向存储矿工付费来检索任何数据。Get协议在第5.3节有详细描述。客户端通过执行Get协议向检索市场订单簿提交投标订单。当找到匹配的矿工报价订单后，客户会收到来自矿工的碎片。当收到的时候，双方对交易订单进行签名提交到区块链来确认交易成功。Get: Client retrieves data from Filecoin.Clients can retrieve any data stored in the DSN by paying Retrieval Miners in Filecoin tokens. The Get protocol is described in detail in Section 5.3.A client initiates the Get protocol by submitting a bid order to the Retrieval Market orderbook (by gossiping their order to the network). When a matching ask order from miners is found, the client receives the piece from the miner. When received, both parties sign a deal order and submit it to the blockchain to confirm that the exchange succeeded.

#### 挖矿周期（对于存储矿工） Mining Cycle (for Storage Miners)

我们给出一个非正式的挖矿周期概述。

We give an informal overview of the mining cycle.

1.  抵押：存储矿工向网络抵押存储。存储矿工通过在抵押交易中存放抵押品来保证向区块链提供存储。通过 Manage.PledgeSector ，抵押品被抵押一段期限是为了提供服务，如果矿工为他们所承诺提交存储的数据生成存储证明，抵押品就回返还给他们。如果存储证明失败了，一定数量的抵押品就会损失。他们设定价格并向市场订单簿提交报价订单，一旦抵押交易在区块链中出现，矿工就能在存储市场中提供他们的存储。Manage.PledgeSector • inputs:– current allocation table allocTable– pledge request pledge• outputs: allocTable’Pledge: Storage Miners pledge to provide storage to the Network.Storage Miners pledge their storage to the network by depositing collateral via a pledge transaction in the blockchain, via Manage.PledgeSector. The collateral is deposited for the time intended to provide the sendee, and it is returned if the miner generates proofs of storage for the data they commit to store. If some proofs of storage fail, a proportional amount of collateral is lost.

    Once the pledge transaction appears in the blockchain, miners can offer their storage in the Storage Market: they set their price and add an ask order to the market’s orderbook.

    ![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662351231.png)

2.  接收订单：存储矿工从存储市场获取存储请求。他们设定价格并通关过 Put.AddOrders 向市场订单簿提交报价订单，一旦抵押交易出现在区块链中，矿工就能在存储市场中提供他们的存储。Put.AddOrders• inputs: list of orders O1..On• outputs: bit b, equals 1 if successful通过 Put.MatchOrders 来检查是否和客户的报价订单匹配一致。Put.MatchOrders• inputs:– the current Storage Market OrderBook – query order to match Oq

    • outputs: matching orders O1..On

    一旦订单匹配，客户会讲他们的数据发给存储矿工。存储矿工接收到数据的时候，运行Put.ReceivePiece 。数据被接收完之后，矿工和客户签收订单并将其提交到区块链。

    Put.ReceivePiece

    • inputs: – signing key for Mj

    – current orderbook OrderBook

    – ask order Oask

    – bid order Obid

    – piece p

    • outputs: deal order Odeal signed by Ci and Mj

    Receive Orders: Storage Miners get stomge requests from the Storage Market.

    Once the pledge transaction appears in the blockchain (hence in the AllocTable), miners can offer their storage in the Storage Market: they set their price and add an ask order to the market’s ordcrbook via Put.AddOrders.

    ![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662513809.png)

    Check if their orders are matched with a corresponding bid order from a client, via Put:MatchOrders.

    ![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662518981.png)

    Once orders are matched, clients send their data to the Storage Miners. When receiving the piece, miners run Put.ReceivePiece. When the data is received, both the miner and the client sign a deal order and submit it to the blockchain.

    ![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662527118.png)

3.  密封：存储矿工为未来的证明准备碎片。存储矿工的存储切分为扇区，每个扇区包括了分配给矿工的碎片。网络通过分配表来跟踪每个存储矿工的扇区。当存储矿工的扇区填满了，这个扇区就被密封起来。密封是一种缓慢的顺序操作。将扇区中的数据转换成为副本，然后将数据的唯一物理副本与存储矿工的公钥相关联。在“复制证明”期间密封式必须的操作。如下所述在第3.4节。Manage.SealSector • inputs:– miner public/private key pair M– sector index j– allocation table allocTable• outputs: a proof πSEAL, a root hash rtSeal: Storage Miners prepare the pieces for future proofs.

    Storage Miners’ storage is divided in sectors, each sector contains pieces assigned to the miner. The Network keeps track of each Storage Miners’ sector via the allocation table. When a Storage Miner sector is filled, the sector is sealed. Sealing is a slow, sequential operation that transforms the data in a sector into a replica, a unique physical copy of the data that is associated to the public key of the Storage Miner. Sealing is a necessary operation during the Proof-of-Replication as described in Section 3.4.

4.  证明：存储矿工证明他们正在存储所承诺的碎片（数据）。当存储矿工分配数据时，必须重复生成复制证明以保证他们正在存储数据（有关更多详细信息，请参看第3节）证明发布在区块链中，并由网络来验证。Manage.ProveSector• inputs:– miner public/private key pair M– sector index j– challenge c• outputs: a proof πPOS

    Prove: Storage Miners prove they are storing the committed pieces.

    When Storage Miners are assigned data, they must repeatedly generate proofs of replication to guarantee they are storing the data (for more details, see Section 3). Proofs are posted on the blockchain and the Network verifies them.

##### 挖矿周期（对于检索矿工） Mining Cycle (for Retrieval Miners)

我们给出一个非正式的挖矿周期概述。

We give an informal overview of the mining cycle for Retrieval Miners.

1.  收到订单：检索矿工从检索市场得到获取数据的请求。检索矿工设置价格并向市场订单簿增加报价订单，并通过向网络发送报价单来提供数据。Get.AddOrders• inputs: list of orders O1..On• outputs: none然后检索矿工检查是否与客户的报价订单匹配一致。Get.MatchOrders• inputs:

    – the current Retrieval Market OrderBook

    – query order to match Oq

    • outputs: matching orders O1..On

    Receive Orders: Retrieval Miners get data requests from the Retrieval Market.

    Retrieval Miners announce their pieces by gossiping their ask orders to the network: they set their price and add an ask order to the market’s orderbook.

    Then, Retrieval Miners check if their orders are matched with a corresponding bid order from a client.

2.  发送：检索矿工向客户发送数据碎片。一旦订单匹配，检索矿工就将数据发送给客户（第5.3节有详细描述）。当数据被接收完成，矿工和客户就签署交易比ing提交到区块链。Put.SendPieces• inputs: – an ask order Oask– a bid order Obid– a piece p• outputs: a deal order Odeal signed by MiSend: Retrieval Miners send pieces to the client.

    Once orders are matched. Retrieval Miners send the piece to the client (see Section 5.3 for details). When the piece is received, both the miner and the client sign a deal order and submit it to the blockchain.

#### 网络周期 Network Cycle

我们给出一个非正式的网络操作概述。

We give an informal overview of the operations run by the network.

1.  1.  分配：网络将客户的碎片分配给存储矿工的扇区。客户通过向存储市场提交报价订单来启动Put协议。当询价单和报价单匹配的时候，参与的各方共同承诺交易并向市场提交成交的订单。此时，网络将数据分配给矿工，并将其记录到分配表中。Manage.AssignOrders• inputs:– deal orders O1deal..Ondeal– allocation table allocTable• outputs: updated allocation table allocTable’Assign: The Network assigns clients’ pieces to Storage Miners’ sectors.

        Clients initiate the Put protocol by submitting a bid order in the Storage Market.

        When ask and bid orders match, the involved parties jointly commit to the exchange and submit a deal order in the market. At this point, the Network assigns the data to the miner and makes a note of it in the allocation table.

    2.  修复：网络发现故障并试图进行修复所有的存储分配对于网络中的每个参与者都是公开的。对于每个块，网络会检查每个需要的证明都存在，检查它们是否有效，并据此采取行动：
        *   如果有任何证明的丢失或无效，网络会通过扣除部分抵押品的方式来惩罚存储矿工。
        *   如果大量证明丢失或无效（由系统参数Δfault定义），网络会认定存储矿工存在故障，将订单设定为失败，并为同样的数据引入新订单进入市场。
        *   如果所有存储该数据的存储矿工都有故障，则该数据丢失，客户获得退款。

Manage.RepairOrders

• inputs:

– current time t

– current ledger L

– table of storage allocations allocTable

• outputs: orders to repair O1deal..Ondeal, updated allocation table allocTable

Repair: The Network finds faults and attempt to repair them.

All the storage allocations are public to every participant in the network. At every block, the Network checks if the required proofs for each assignment are present, checks that they are valid, and acts accordingly:

1.  1.  *   if any proof is missing or invalid, the network penalizes the Storage Miners by taking part of their collateral,
        *   if a large amount of proofs are missing or invalid (defined by a system parameter Afauit), the network considers the Storage Miner faulty, settles the order as failed and reintroduces a new order for the same piece into the the market,
        *   if every Storage Miner storing this piece is faulty, then the piece is lost and the client gets refunded.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662540837.jpg)

图6：Filecoin DSN 的执行示例

Figure 6: Example execution of the Filecoin DSN, grouped by party and sorted chronologically by row

### 担保和要求 Guarantees and Requirements

以下是Filecoin DSN如何实现完整性、可检索性，公开可验证性和激励兼容性。

The following are the intuitions on how the Filecoin DSN achieves integrity, retrievability, public verifiability and incentive-compatibility.

*   实现完整性：数据碎片以加密哈希命名。一个Put请求后，客户只需要存储哈希即可通过Get操作来检索数据，并可以验证收到的数据的完整性。
*   实现可恢复性：在Put请求中，客户指定副本因子和代码期望擦除类型。假设给定的m个存储矿工存储数据，可以容忍最多f个故障，则该方式是(f, m)-tolerant存储。通过在不同的存储提供商存储数据，客户端可以增加恢复的机会，以防存储矿工下线或者消失。
*   实现公开可验证和可审核性：存储矿工需要提交其存储 (πSEAL, πPOST)的证明到区块链。网络中的任意用户都可以在不访问外包数据的情况下验证这些证明的有效性。另外由于这些证明都是存储在区块链上的，所以操作痕迹可以随时审核。
*   实现激励兼容性：不正式的说，矿工通过提供存储而获得奖励。当矿工承诺存储一些数据的时候，它们需要生成证明。如果矿工忽略了证明就回被惩罚（通过损失部分抵押品），并且不会收到存储的奖励。
*   实现保密性：如果客户希望他们的数据被隐私存储，那客户必须在数据提交到网络之前先进行加密。
*   Achieving Integrity: Pieces are named after their cryptographic hash. After a Put request, clients only need to store this hash to retrieve the data via Get and to verify the integrity of the content received.
*   Achieving Retrievability: In a Put request, clients specify the replication factor and the type of erasure coding desired, specifying in this way the storage to be (f,m)-tolerant. The assumption is that given m Storage Miners storing the data, a maximum of / faults are tolerated. By storing data in more than one Storage Miner, a client can increase the chances of recovery, in ease Storage Miners go offline or disappear.
*   Achieving Public Verifiability and Auditability: Storage Miners are required to submit their proofs of storage (πSEAL, πPOST) to the blockchain. Any user in the network can verify the validity of these proofs, without having access to the outsourced data. Since the proofs are stored on the blockchain, they are a trace of operation that can be audited at any time.
*   Achieving Incentive Compatibility: Informally, miners are rewarded for the storage they are providing. When miners commit to store some data, then they are required to generate proofs. Miners that skip proofs are penalized (by losing part of their collateral) and not rewarded for their storage.
*   Achieving Confidentiality: Clients that desire for their data to be stored privately, must encrypt their data before submitting them to the network.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662709241.jpg)

图7：Filecoin DSN 中 Put 和 Get 协议的说明

Figure 7: Description of the Put and Get Protocols in the Filecoin DSN

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662717601.jpg)

图8：Filecoin DSN 中 Manage 协议的说明

Figure 8: Description of the Manage Protocol in the Filecoin DSN

----------------

## Filecoin 存储与检索市场 Filecoin Storage and Retrieval Markets

Filecoin有两个市场：存储市场和检索市场。这两个市场的结构相同，但设计不同。存储市场允许客户为矿工存储数据而付费。检索市场允许客户为矿工传递数据付费从而检索数据。在这两种情况下，客户和矿工可以设置报价和需求价格或者接受当前报价。这个交易是由 _网络 _——Filecoin全节点拟人化网络——来运行的。网络保证了矿工在提供服务时可以得到客户的奖励。

Filecoin has two markets: the Storage Market and the Retrieval Market. The two markets have the same structure but different design. The Storage Market allows Clients to pay Storage Miners to store data. The Retrieval Market allows Clients to retrieve data by paying Retrieval Miners to deliver the data. In both cases, clients and miners can set their offer and demand prices or accept current offers. The exchanges are run by the Network – a personification of the network of full nodes in Filecoin. The network guarantees that miners are rewarded by the clients when providing the service.

### 验证市场 Veriable Markets

交易市场是促进特定商品和服务交换的协议。它们使得买家和卖家进行交易。对于我们而言，我们要求交易是可验证的：去中心化网络的参与者必须能够在买家和卖家间验证交易。

Exchange Markets are protocols that facilitate exchange of a specific good or service. They do this by enabling buyers and sellers to conduct transactions. For our purposes, we require exchanges to be verifiable: a decentralized network of participants must be able to verify the exchange between buyers and sellers.

我们提出验证市场的概念。它没有单一的实体来管理交易，交易是透明的，任何人都可以匿名参与。验证市场协议使得商品/服务的交易去中心化：订单簿的一致性、订单结算和服务的正确执行可以由参与者——Filecoin里面的矿工和全节点——各自独立验证。我们简化验证市场来进行以下构建：

We present the notion of Verifiable Markets, where no single entity governs an exchange, transactions are transparent, and anybody can participate pseudonymously. Verifiable Market protocols operate the exchange of goods/services in a decentralized fashion: consistency of the orderbooks, orders settlements and correct execution of sendees are independently verified via the participants – miners and full nodes in the case of Filecoin. We simplify verifiable markets to have the following construction:

定义5.1 验证市场是一个有两个阶段的协议：订单匹配和结算。订单是购买意图或者出售商品或服务安全性的表述，订单簿就是所有可用订单的列表。

Definition 5.1. A verifiable Market is a protocol with two phases: order matching and settlement. Orders are statements of intent to buy or sell a security, good or service and the orderbook is the list of all the available orders.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662731936.jpg)

图9：验证市场的通用协议

Figure 9: Generic protocol for Verifiable Markets

### 存储市场 Storage Market

存储市场是验证市场，它允许客户（即买家）请求他们的存储数据，也允许存储矿工（即卖家）提供他们的存储空间。

The Storage Market is a verifiable market which allows clients (i.e. buyers) to request storage for their data and Storage Miners (i.e. sellers) to offer their storage.

#### 需求 Requirements

我们根据以下需求来设计存储市场协议：

*   链式订单簿 重要的是（1）存储空格的订单式公开的，所以最低价格的订单总是网络知名的，客户可以对订单做出明智的决定（2）客户订单必须始终提交给订单，即使他们接受接受最低的价格，这样市场就可以对新的报价做出反应。因此我们要求订单添加到Filecoin区块链，为的时能被加入订单簿。
*   参与者投入资源：我们要求参与双方承诺他们的资源作为避免损害的一种方式。为了避免存储矿工不提供服务和避免客户没有可用的资金。为了参与存储市场，存储矿工必须保证在DSN中存入与其存储量成比例的抵押品（更多详细信息请参看第4.3.3节）。通过这种方式，网络可以惩罚那些承诺存储数据但又不提供存储证明的存储矿工。同样的，客户必须向订单充入特定数量的资金，以这种方式保证在结算期间的资金可用性。
*   故障自处理 只有在存储矿工反复证明他们已经在约定的时间内存储了数据的情况下，订单才会结算给矿工。网络必须能够验证这些证明的存在性和正确性并且它们是按照规则来处理的。在4.3.4节有修复部分的概述。

We design the Storage Market protocol accordingly to the following requirements:

*   In-chain orderbook: It is important that: (1) Storage Miners orders are public, so that the lowest price is always known to the network and clients can make informed decision on their orders, (2) client orders must be always submitted to the orderbook, even when they accept the lowest price, in this way the market can react to the new offer. Hence, we require orders to be added in clear to the Fileeoin blockchain in order to be added to the orderbook.
*   Participants committing their resources: We require both parties to commit to their resources as a way to avoid disservice: to avoid Storage Miners not providing the sendee and to avoid clients not having available funds. In order to participate to the Storage Market, Storage Miners must pledge, depositing a collateral proportional to their amount of storage in DSN (see Section 4.3.3 for more details). In this way, the Network can penalize Storage Miners that do not provide proofs of storage for the pieces they committed to store. Similarly, clients must deposit the funds specified in the order, guaranteeing in this way commitment and availability of funds during settlement.
*   Self-organization to handle faults: Orders are only settled if Storage Miners have repeatedly proved that they have stored the pieces for the duration of the agreed-upon time period. The Network must be able to verify the existence and the correctness of these proofs and act according to the rules outlined in the Repair portion of Subsection 4.3.4.

#### 数据结构 Datastructures

Put 订单 有三种类型的订单：出价订单，询价订单和交易订单。存储矿工创建询价订单添加存储，客户创建出价订单请求存储，当双方对价格达成一致时，他们共同创建处理订单。订单的数据结构和订单参数的明确定义如图10所示。

Put Orders. There are three types of orders: bid orders, ask orders and deal orders. Storage Miners create ask orders to add storage, clients create bid orders to request storage, when both parties agree on a price, they jointly create a deal order. The data structures of the orders are shown in detail in Figure 10\. and the parameters of the orders are explicitly defined.

Put 订单簿 存储市场的订单簿是目前有效和开放的询价，出价和 交易订单的集合。用户可以通过Put协议中定义的方法与订单簿进行交互：AddOrders,MatchOrders如图7所示。

Put Orderbook. The Orderbook in the Storage Market is the set of currently valid and open ask, bid and deal orders. Users can interact with the orderbook via the methods defined in the Put protocol: AddOrders, MatchOrders as described in Figure 7.

订单簿是公开的，并且每个诚实的用户都有同样的订单簿试图。在每个周期，如果新的订单交易（txorder）出现在新的区块中，那它将被添加到订单簿中；如果订单取消、过期或结算，则会被删除。订单将被添加到区块链中，因此在订单簿中，如果订单是有效的：

The orderbook is public and every honest user has the same view of the orderbook. At every epoch, new orders are added to the orderbook if new order transactions (txorder) appear in new blockchain blocks; orders are removed if they are cancelled, expired or settled. Orders are added in blockchain blocks, hence in the orderbook, if they are valid:

定义5.2 我们定义出价，询价，交易订单的有效性：

_（有效出价单）_ 从客户端发出的投标单Ci,Obid:= (hsize, funds[, price,time, coll, coding])>Ci,如果满足下面的条件就是有效的：

*   Ci 在他们的账户里面至少有可用的资金
*   时间没有超时
*   订单必须保证最少的存储周期（这是个系统参数）

_（有效询价单）_ 从存储矿工发出的询价单Mi，Oask:= (hspace, pricei)Mi，如果满足下面的条件就是有效的：

*   Mi承诺为矿工，并且质押期不会在订单周期之前到期
*   空间必须小于Mi的可用存储。Mi在订单中减去承诺的存储（在询价订单和交易订单中）

_（有效交易订单）_ 交易订单Odeal:= (hask, bid,ts)Ci,Mj，如果满足下面的条件就是有效的：

*   询问参考订单Oask，使得：它由Ci签署，且在存储市场的订单簿中没有其他订单涉及它。
*   出价订单参考订单Obid，使得：它由Mj签署，且在存储市场的订单簿中没有其他订单涉及它。
*   ts 不能设置为将来时间或者太早的时间

如果作恶客户端从存储矿工出收到了签名的交易，但从来没有将其添加到订单簿，那么存储矿工就无法重新使用订单中提交的存储。这个字段ts就可以防止这种攻击，因为，在超过ts之后，订单变得无效，将无法在订单簿中提交。

Definition 5.2. We define the validity of bid, ask, deal orders:

(Valid _bid _order): A bid order from client Ct. Obid:= (hsize, funds[, price,time, coll, coding])>Ci, is valid if:

*   Ci has at least the amount of funds available in their account.
*   time is not set in the past
*   The order must guarantee at least a minimum amount of epochs of storage.

(Valid _ask _order): An ask order from Storage Miner Mi, Oask:= (hspace, pricei)Mi, is valid if:

*   Mi has pledged to be a miner and the pledge will not expire before time epochs.
*   space must be less than Mi’s available storage: M, pledged storage minus the storage committed in the orderbook (in ask and deal orders).

(Valid _deal_ order): A deal order Odeal:= (hask, bid,ts)Ci,Mj, is valid if

*   ask references an order Oask such that: it is in the Storage Market OrderBook, no other deal orders in the Storage Market OrderBook mention it, it is signed by Ct.
*   bid references an order Obid such that: it is in the Storage Market OrderBook, no other deal orders in the Storage Market OrderBook mention it, it is signed by Mj.
*   ts is not set in the future or too far in the past.

Remark. If a malicious client receives a signed deal from a Storage Miner, but never adds it to the orderbook, then the Storage Miner cannot re-use the storage committed in the deal. The field ts prevents this attack because, after ts, the order becomes invalid and cannot be submitted in the orderbook.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662743285.jpg)

图10：检索和存储市场的订单数据结构

Figure 10: Orders data structures for the Retrieval and Storage Markets

#### 存储市场协议 The Storage Market Protocol

简而言之，存储市场协议分为两个阶段：订单匹配和结算：

*   订单匹配：客户端和存储矿工通过提交交易到区块链来将订单提交到订单簿（步骤1）。当订单匹配时，客户端发送数据碎片给存储矿工，双方签署交易并提交到订单簿（步骤2）。
*   结算： 存储矿工密封扇区（步骤3a），生成扇区所包含的碎片的存储证明，并将其定期提交到区块链（步骤3b)；同时，其余的网络必须验证矿工生成的证明并修复可能的故障（步骤3c）。

存储市场协议在图11中详细描述。

In brief, the Storage Market protocol is divided in two phases: order matching and settlement:

*   _Order Matching_: Clients and Storage Miners submit their orders to the orderbook by submitting a transaction to the blockchain (step 1). When orders are matched, the client sends the piece to the Storage Miner and both parties sign a deal order and submit it to the orderbook (step 2).
*   _Settlement_: Storage Miners seal their sectors (step 3a), generate proofs of storage for the sector containing the piece and submit them to the blockchain regularly (step 3b); meanwhile, the rest of the network must verify the proofs generated by the miners and repair possible faults (step 3c).

The Storage Market protocol is explained in detail in Figure 11.

### 检索市场 Retrieval Market

检索市场允许客户端请求检索特定的数据，由检索矿工提供这个服务。与存储矿工不同，检索矿工不要求在特定时间周期内存储数据或者生成存储证明。在网络中的任何用户都可以成为检索矿工，通过提供提供检索服务来赚取Filecoin令牌。检索矿工可以直接从客户端或者检索接收数据碎片，也可以存储它们成为存储矿工。

The Retrieval Market allows clients to request retrieval of a specific piece and Retrieval Miners to serve it. Unlike Storage Miners, Retrieval Miners are not required to store pieces through time or generate proofs of storage. Any user in the network can become a Retrieval Miner by serving pieces in exchange for Fileeoin tokens. Retrieval Miners can obtain pieces by receiving them directly from clients, by acquiring them from the Retrieval Market, or by storing them from being a Storage Miner.

#### 需求 Requirements

我们根据以下的需求来设计检索市场协议：

*   链下订单簿 客户端必须能够找到提供所需要数据碎片的检索矿工，并且在定价之后直接交换。这意味着订单簿不能通过区块链来运行-因为这将成为快速检索请求的瓶颈。相反的，参与者只能看到订单簿的部分视图。我们要求双方传播自己的订单。
*   无信任方检索 公平交换的不可能性[10]提醒我们双方不可能没有信任方的进行交流。在存储市场中，区块链网络作为去中心化信任方来验证存储矿工提供的存储。在检索市场，检索矿工和客户端在没有网络见证所交换文件的情况下来交换数据。我们通过要求检查矿工将数据分割成多个部分并将每个部分发送给客户端来达到这个目的，矿工们将收到付款。在这种方式中，如果客户端停止付款，或者矿工停止发送数据，任何一方都可以终止这个交易。注意的是，我们必须总是假设总是有一个诚实的检索矿工。
*   支付通道 客户端当提交付款的时候可以立即进行检索感兴趣的碎片。检索矿工只有在确认收到付款的时候才会提供数据碎片。通过公共账本来确认交易可能会成为检索请求的瓶颈，所以，我们必须依靠有效的链下支付。Filecoin区块链必须支持快速的支付通道，只有乐观交易和仅在出现纠纷的情况下才使用区块链。通过这种方式，检索矿工和客户端可以快速发送Filecoin协议所要求的小额支付。未来的工作里包含了创建一个如[11,12]所述的支付通道网络。

We design the Retrieval Market protocol accordingly to the following requirements:

*   Off-chain orderbook: Clients must be able to find Retrieval Miners that are serving the required pieces and directly exchange the pieces, after settling on the pricing. This means that the orderbook cannot be run via the blockchain – since this would be the bottleneck for fast retrieval requests – instead participant will have only partial view of the OrderBook. Hence, we require both parties to gossip their orders.
*   Retrieval without trusted parties: The impossibility results on fair exchange remind us that it is impossible for two parties to perform an exchange without trusted parties. In the Storage Market, the blockchain network acts as a (decentralized) trusted party that verifies the storage provided by the Storage Miners. In the Retrieval Market, Retrieval Miners and clients exchange data without the network witnessing the exchange of file. We go around this result by requiring the Retrieval Miner to split their data in multiple parts and for each part sent to the client, they receive a payment. In this way, if the client stops paying, or the miner stops sending data, either party can halt the exchange. Note that for this to work, we must assume that there is always one honest Retrieval Miner.
*   Payments channels: Clients are interested in retrieving the pieces as soon as they submit their payments, Retrieval Miners are interested in only serving the pieces if they are sure of receiving a payment. Validating payments via a public ledger can be the bottleneck of a retrieval request, hence we must rely on efficient off-chain payments. The Filccoin blockchain must support payment channels which enable rapid, optimistic transactions and use the blockchain only in case of disputes. In this way, Retrieval Miners and Clients can quickly send the small payments required by our protocol. Future work includes the creation of a network of payment channels as previously seen in references.

#### 数据结构 Data Structures

Get 订单 检索市场中包含有三种类型的订单：客户端创建的出价单 Obid，检索矿工创建的询价单Oask，和存储矿工和客户端达成的交易订单Odeal。订单的数据结构如图10所示。

Get 订单簿 检索市场的订单簿是有效的和公开出价订单，询价订单和交易订单的集合。与存储市场不同，每个用户有不同的订单簿试图，因为订单式在网络中传播的，每个矿工和客户端只会跟踪他们所感兴趣的订单。

Get Orders. There are three types of orders in the Retrieval Market: clients create bid orders Obid Retrieval Miners create ask orders Oask, and deal orders Odeal. are created jointly when a Storage Miner and a client agree on a deal. The datastructures of the orders is shown in detail on Figure 10.

Get Orderbook. The Orderbook in the Retrieval Market is the set of valid and open ask, bid and deal orders. Unlike the Storage Market, every user has a different view of the orderbook, since the orders are gossiped in the network and each miner and client only keep track of the orders they are interested in.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662751005.jpg)

图11：存储市场协议细节

Figure 11: Detailed Storage Market protocol

#### 检索市场协议 The Retrieval Market Protocol

简而言之，检索市场协议分为两个阶段：订单匹配和结算：

订单匹配 客户端和检索矿工通过广播将订单提交给订单簿（步骤1）。当订单匹配的时候，客户端和检索矿工简历小额支付通道（步骤2）。

结算 检索矿工发送小部分的碎片给到客户端，然后对每个碎片客户端会向矿工发送收妥的收据（步骤3）。检索矿工向区块链出示收据从而获得奖励（步骤4）。

该协议在图12中详细解释。

In brief, the Retrieval Market protocol is divided in two phases: older matching and settlement:

*   Order Matching: Clients and Retrieval Miners submit their orders to the orderbook by gossiping their orders (step 1). When orders are matched, the client and the Retrieval Miners establish a micropayment channel (step 2).
*   Settlement: Retrieval Miners send a small parts of the piece to the client and for each piece the client sends to the miner a signed receipt (step 3). The Retrieval Miner presents the deliver}’ receipts to the blockchain to get their rewards (step 4).

The protocol is explained in details in Figure 12.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809322.jpg)

图12：检索市场协议细节

Figure 12: Detailed Retrieval Market protocol

.----------------

## 有用工作共识 Useful Work Consensus

Filecoin DSN 协议可以在任何允许验证的共识协议之上实现 Filecoin 的证明。在本节中，我们将介绍我们如何根据有用工作引导共识协议。Filecoin 矿工生成“时空证明”来参与共识，而不是浪费的 POW 计算。

The Filecoin DSN protocol can be implemented on top of any consensus protocol that allows for verification of the Filecoin’s proofs. In this section, we present how we can bootstrap a consensus protocol based on useful work. Instead of wasteful Proof-of- Work computation, the work Filecoin miners do generating Proof-of-Spacetime is what allows them to participate in the consensus.

有用工作 如果计算的输出对网络来说是有价值的，而不仅仅是为了保证区块链的安全。我们认为矿工在共识协议中所作的工作是有用的。

Useful Work. We consider the w)ork done by the miners in a consensus protocol to be useful^ if the outcome of the computation is valuable to the network, beyond securing the blockchain.

### 动机 Motivation

确保区块链的安全是至关重要的。POW的证明方案往往要求不能重复使用的或者需要大量的浪费计算才能找到谜题的解。

While securing the blockchain is of fundamental importance, Proof-of-Work schemes often require solving puzzles whose solutions are not reusable or require a substantial amount wasteful computation to find.

*   不可重复利用的工作 大多数无许可型的区块链要求矿工解决硬计算难题，譬如反转哈希函数。通常情况下这些解决方案都是无用的，除了保护网络安全之外，没有其他任何价值。我们可以重新设计让这件事有用吗？_尝试重复使用的工作_：已经有几个尝试重复使用挖矿电路进行有用的计算。有些尝试是要求矿工与标准的POW同时进行一些特殊计算，其他一些尝试用有用问题替代POW的依然难以解决。例如，Primecoin重新使用矿工的计算能力来找到新的素数，以太坊要求矿工与工作证明一起执行小程序，同时证明某些数据正在归档。虽然这些尝试中的大多数都执行有用的工作，但在这些计算中浪费的工作量仍然很普遍的。Non-reusable Work: Most permissionless blockchains require miners to solve a hard computational puzzle, such as inverting a hash function. Often the solutions to these puzzles are useless and do not have any inherent value beyond securing the network. Can we re-purpose this work for something useful?_Attempts to re-use work_: There have been several attempts to re-use mining power for useful computation. Some efforts require miners to perform a special computation alongside the standard Proof-of- Work. Other efforts replace Proof-of-Work with useful problems that are still hard to solve. For example, Primecoin re-uses miners5 computational power to find new prime numbers, Ethereum requires miners to execute s|niall programs alongside with Proof-of- Work, and Permacoin offers archival services by requiring miners to invert a hash function while proving that some data is being archived. Although most of these attempts do perform useful work, the amount of wasteful work is still a preva^ lent factor in these computations.
*   浪费的工作 解决难题在机器成本和能力消耗方面是非常昂贵的，特别是如果这些难题完全依赖计算能力。当挖矿算法不能并发的时候，那解决难题的普通因素就是计算的功率。我们可以减少浪费的工作吗？_试图减少浪费_：理想情况下，大部分网络资源应该花费在有用的工作上。一些尝试是要求矿工使用更节能的解决方案。例如，“空间挖矿”（？Spacemint）要求矿工致力于磁盘空间而不是计算；虽然更加节能，但磁盘空间依然”浪费“，因为它们被随时的数据填满了。其他的尝试是用基于权益证明的传统拜占庭协议来代替难题的解决，其中利益相关方在下一个块的投票与其在系统中所占有的货币份额成正比。Wasteful Work: Solving hard puzzles can be really expensive in terms of cost of machinery and energy consumed, especially if these puzzles solely rely on computational power. When the mining algorithm is embarrassingly parallel, then the prevalent factor to solve the puzzle is computational power. Can we reduce the amount of wasteful work?_Attempts to reduce waste_: Ideally, the majority of a network’s resources should be spent on useful work.Some efforts require miners to use more energy-efficient solutions. For example, Spacemint requires miners to dedicate disk space rather than computation; while more energy efficient, theses disks are still “wasted”，since they are filled with random data. Other efforts replace hard to solve puzzles with a traditional byzantine agreement based on Proof-of-Stake, where stakeholders vote on the next block proportional to their share of currency in the system.

我们将着手设计一个基于用户数据存储的有用工作的共识协议。

We set out to design a consensus protocol with a useful work based on storing users’ data.

### Filecoin 共识 Filecoin Consensus

功率容错 在我们的技术报告中，我们提出了功率容错，这是对在参与者对协议结果的影响方面重新构建拜占庭故障的抽象。每个参与者控制了网络总功率n中的一部分功率，其中f是故障节点或作恶节点所控制的功率占比。

Filecoin功率 在Filecoin中，在时刻t，矿工Mi的功率Pt>i是Mi总和的存储任务。Mi的 Iti是网络中Mi总功率的影响因子。

在Filecoin中，功率有以下属性：

*   公开：网络中当前正在使用的存储总量是公开的。通过读取区块链，任何人都可以计算每个矿工的存储任务-因此任何人都可以计算出在任意时间点的每个矿工的功率和总功率。
*   可公开验证的：对于每个存储任务，矿工都需要生成”时空证明“，证明持续提供服务。通过读取区块链，任何人都可以验证矿工的功率声明是否是正确的。
*   变量： 在任意时间点，矿工都可以通过增加新增扇区和扇区补充的抵押来增加新的存储。这样矿工就能变更他们能提供的功率。

#### 功率会计与时空证明

每个∆proof 区块（∆proof 是系统参数），矿工们都必须向网络提交“时空证明”，只有网络中大多数功率认为它们是有效的，才会被城管添加到区块链。在每个区块中，每个圈节点会更新分配表（AllocTable），添加新的存储分配、删除过期的和标记缺少证明的记录。可以通过对分配表的记录来对矿工Mi的功率进行计算和验证。这些可以通过两种方式来完成：

*   全节点验证：如果节点拥有完整的区块链记录，则可以从创始块开始运行网络协议直到当前区块，这个过程中验证每一个分配给Mi的“时空证明”。
*   简单存储验证：假设轻客户端可以访问广播最新区块的信任源。请客户端可以从网络中的节点请求（1）Mi在当前分配表中的记录 （2）该记录被包含在最新区块的状态树中的Merkle路径（3）从创世块到当前区块的区块头。这样请客户端就可以将“时空证明”的验证委托给网络。

功率计算的安全性来自于“时空证明”的安全性。在这个设置里面，Post保证了矿工无法对他们所分配的存储数量说谎。事实上，他们不能声称能够存储超过他们的存储空间的数据，因为这会花费时间来运行PoSt.Setup，另外PoSt.Prove是串行的计算，并不能并行化的快速生成证明。

#### 使用功率达成共识

我们预计通过扩展现在（和未来）的权益证明共识协议来实现Filecoin共识的多种策略，其中权益被替换为分配的存储。我们预计了权益证明协议的改进，我们提出了一个基于我们前期工作，称为预期共识的构建[14]。我们的策略是在每一轮选举一个（或多个）矿工，使得赢得选举的概率与每个矿工分配的存储成比例。

预期共识 预期共识的基本直觉是确定性的，不可预测的。并在每个周期内秘密选举一个小的Leader集合。预期的期望是每个周期内当选的Leader是1，但一些周期内可能有0个或者许多的Leader。Leader们通过创建新区块并广播来扩展区块链网络。在每个周期，每个区块链被延伸一个或多个区块。在某个无Leader的周期内，控区块被添加到区块链中。虽然链中的区块可以线性排序，其数据结构是有向无环图。EC是一个概率共识，每个周期都使得比前面的区块更加确定，最终达到了足够的确定性，且出现不同的历史块链的可能性是足够小的。如果大多数的参与者都通过签署区块链来扩展区块链，加大这个区块所属链的权重，那么这个区块就被确认了。

选举矿工 在每个周期，每个矿工检查他们是否被选为Leader，这类似于完成前面的协议:CoA白皮书和算法。

_译者注：下面的公式表达式请参考英文原版为佳_

定义6.1 如果下面的条件是满足的，则在时刻t 矿工Mi 是Leader：

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809323.png)

其中rand(t)是在时刻t，可以从区块链中提取出来的公开的随机变量，Pt>i是Mi的功率。考虑对于任意的m，L是H(m)的大小，H是一种安全的加密散列函数，其中（m)Mi是Mi对消息m的签名，使得：

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809324.png)

在图13中，我们描述了矿工（ProveElect）和网络节点（VerifyElect）之间的协议。这种选举方案提供了三个属性：公平，保密和公开的可验证性。

*   公平 每个参与者每次选举只有一次试验，因为签名是确定性的，而且t和rand(t)是固定的。假设H是安全的加密散列函数，则H(Mi)/2L必须是从（0，1）均匀选择的实数，因此，可能使得方程等式为true必须是Pti/Σjptj，这等于矿工在在网络中的部分功率。因为这个概率在功率上市线性的，这种可能性在分裂或者汇集功率情况下被保留。注意随机值rand(t)在时刻t之前是未知的。
*   保密 由于有能力的攻击者不拥有Mi用来计算签名的秘钥，考虑到数字签名的假设，这个是可以忽略不计的。
*   公开可验证： 当选Leader i ∈ Lt 可以通过给出t，rand(t)，H(i)/2L，来说服一个有效的验证者。鉴于前面的观点，有能力的攻击者在不拥有获胜秘密秘钥的情况下不能生成证明。

----------------

## 有用工作共识 Useful Work Consensus

Filecoin DSN 协议可以在任何允许验证的共识协议之上实现 Filecoin 的证明。在本节中，我们将介绍我们如何根据有用工作引导共识协议。Filecoin 矿工生成“时空证明”来参与共识，而不是浪费的 POW 计算。

The Filecoin DSN protocol can be implemented on top of any consensus protocol that allows for verification of the Filecoin’s proofs. In this section, we present how we can bootstrap a consensus protocol based on useful work. Instead of wasteful Proof-of- Work computation, the work Filecoin miners do generating Proof-of-Spacetime is what allows them to participate in the consensus.

有用工作 如果计算的输出对网络来说是有价值的，而不仅仅是为了保证区块链的安全。我们认为矿工在共识协议中所作的工作是有用的。

Useful Work. We consider the w)ork done by the miners in a consensus protocol to be useful^ if the outcome of the computation is valuable to the network, beyond securing the blockchain.

### 动机 Motivation

确保区块链的安全是至关重要的。POW的证明方案往往要求不能重复使用的或者需要大量的浪费计算才能找到谜题的解。

While securing the blockchain is of fundamental importance, Proof-of-Work schemes often require solving puzzles whose solutions are not reusable or require a substantial amount wasteful computation to find.

*   不可重复利用的工作 大多数无许可型的区块链要求矿工解决硬计算难题，譬如反转哈希函数。通常情况下这些解决方案都是无用的，除了保护网络安全之外，没有其他任何价值。我们可以重新设计让这件事有用吗？_尝试重复使用的工作_：已经有几个尝试重复使用挖矿电路进行有用的计算。有些尝试是要求矿工与标准的POW同时进行一些特殊计算，其他一些尝试用有用问题替代POW的依然难以解决。例如，Primecoin重新使用矿工的计算能力来找到新的素数，以太坊要求矿工与工作证明一起执行小程序，同时证明某些数据正在归档。虽然这些尝试中的大多数都执行有用的工作，但在这些计算中浪费的工作量仍然很普遍的。Non-reusable Work: Most permissionless blockchains require miners to solve a hard computational puzzle, such as inverting a hash function. Often the solutions to these puzzles are useless and do not have any inherent value beyond securing the network. Can we re-purpose this work for something useful?_Attempts to re-use work_: There have been several attempts to re-use mining power for useful computation. Some efforts require miners to perform a special computation alongside the standard Proof-of- Work. Other efforts replace Proof-of-Work with useful problems that are still hard to solve. For example, Primecoin re-uses miners5 computational power to find new prime numbers, Ethereum requires miners to execute s|niall programs alongside with Proof-of- Work, and Permacoin offers archival services by requiring miners to invert a hash function while proving that some data is being archived. Although most of these attempts do perform useful work, the amount of wasteful work is still a preva^ lent factor in these computations.
*   浪费的工作 解决难题在机器成本和能力消耗方面是非常昂贵的，特别是如果这些难题完全依赖计算能力。当挖矿算法不能并发的时候，那解决难题的普通因素就是计算的功率。我们可以减少浪费的工作吗？_试图减少浪费_：理想情况下，大部分网络资源应该花费在有用的工作上。一些尝试是要求矿工使用更节能的解决方案。例如，“空间挖矿”（？Spacemint）要求矿工致力于磁盘空间而不是计算；虽然更加节能，但磁盘空间依然”浪费“，因为它们被随时的数据填满了。其他的尝试是用基于权益证明的传统拜占庭协议来代替难题的解决，其中利益相关方在下一个块的投票与其在系统中所占有的货币份额成正比。Wasteful Work: Solving hard puzzles can be really expensive in terms of cost of machinery and energy consumed, especially if these puzzles solely rely on computational power. When the mining algorithm is embarrassingly parallel, then the prevalent factor to solve the puzzle is computational power. Can we reduce the amount of wasteful work?_Attempts to reduce waste_: Ideally, the majority of a network’s resources should be spent on useful work.Some efforts require miners to use more energy-efficient solutions. For example, Spacemint requires miners to dedicate disk space rather than computation; while more energy efficient, theses disks are still “wasted”，since they are filled with random data. Other efforts replace hard to solve puzzles with a traditional byzantine agreement based on Proof-of-Stake, where stakeholders vote on the next block proportional to their share of currency in the system.

我们将着手设计一个基于用户数据存储的有用工作的共识协议。

We set out to design a consensus protocol with a useful work based on storing users’ data.

### Filecoin 共识 Filecoin Consensus

我们提出了一个有用工作共识协议，其中网络选择一个矿工创建一个新矿区的概率（我们称之为矿工的投票权）与他们当前网络中正在使用的储量成正比关系。 我们设计 Filecoin 协议，能让矿工们投资存储，而非在算力上并行化采矿计算。 矿工提供存储并重新使用计算来证明数据被存储以参与共识。

We propose a useful work consensus protocol, where the probability that the network elects a miner to create a new block (we refer to this as the voting power of the miner) is proportional to their storage currently in use in relation to the rest of the network. We design the Filecoin protocol such that miners would rather invest in storage than in computing power to parallelize the mining computation. Miners offer storage and re-use the computation for proof that data is being stored to participate in the consensus.

#### 挖矿功率建模 Modeling Mining Power

功率容错 在我们的技术报告中，我们提出了功率容错，这是对在参与者对协议结果的影响方面重新构建拜占庭故障的抽象。每个参与者控制了网络总功率n中的一部分功率，其中f是故障节点或作恶节点所控制的功率占比。

Power Fault Tolerance. In our technical report, we present Power Fault Tolerance, an abstraction that re-frames byzantine faults in terms of participants5 influence over the outcome of the protocol. Every participant controls some power of which n is the total power in the network, and / is the fraction of power controlled by faulty or adversarial participants.

Filecoin功率 在Filecoin中，在时刻t，矿工Mi的功率Pti是Mi总和的存储任务。Mi的Iti是网络中Mi总功率的影响因子。

Power in Filecoin. In Filecoin, the power pti of miner Mi at time t is the sum of the Mi’s storage assignments. The influence Iti of Mi is the fraction of Mi’s power over the total power in the network.

在Filecoin中，功率有以下属性：

*   公开：网络中当前正在使用的存储总量是公开的。通过读取区块链，任何人都可以计算每个矿工的存储任务-因此任何人都可以计算出在任意时间点的每个矿工的功率和总功率。
*   可公开验证：对于每个存储任务，矿工都需要生成”时空证明“，证明持续提供服务。通过读取区块链，任何人都可以验证矿工的功率声明是否是正确的。
*   可变： 在任意时间点，矿工都可以通过增加新增扇区和扇区补充的抵押来增加新的存储。这样矿工就能变更他们能提供的功率。

In Filecoin, power has the following properties:

*   Public: The total amount of storage currently in use in the network is public. By reading the blockchain, anyone can calculate the storage assignments of each miner – hence anyone can calculate the power of each miner and the total amount of power at any point in time.
*   Publicly Verifiable: For each storage assignment, miners are required to generate Proofs-of-Spacetime, proving that the service is being provided. By reading the blockchain, anyone can verify if the power claimed by a miner is correct.
*   Variable: At any point in time, miners can add new storage in the network by pledging with a new sector and filling the sector. In this way, miners can change their amount of power they have through time.

#### 功率会计与时空证明 Accounting for Power with Proof-of-Spacetime

每个∆proof 区块（∆proof 是系统参数），矿工们都必须向网络提交“时空证明”，只有网络中大多数功率认为它们是有效的，才会被城管添加到区块链。在每个区块中，每个圈节点会更新分配表（AllocTable），添加新的存储分配、删除过期的和标记缺少证明的记录。可以通过对分配表的记录来对矿工Mi的功率进行计算和验证。这些可以通过两种方式来完成：

*   全节点验证：如果节点拥有完整的区块链记录，则可以从创始块开始运行网络协议直到当前区块，这个过程中验证每一个分配给Mi的“时空证明”。
*   简单存储验证：假设轻客户端可以访问广播最新区块的信任源。请客户端可以从网络中的节点请求（1）Mi在当前分配表中的记录 （2）该记录被包含在最新区块的状态树中的Merkle路径（3）从创世块到当前区块的区块头。这样请客户端就可以将“时空证明”的验证委托给网络。

Every ∆proof blocks, miners are required to submit Proofs-of-Spacetime to the network, which are only successfully added to the blockchain if the majority of power in the network considers them valid. At every block, every full node updates the AllocTable, adding new storage assignments, removing expiring ones and marking missing proofs.

The power of a miner Mi can be calculated and verified by summing the entries in the AllocTable, which can be done in two ways:

*   Full Node Verification: If a node has the full blockchain log, run the NetworkProtocol from the genesis block to the current block and read the AllocTable for miner Mi. This process verifies every Proof-of-Spacetime for the storage currently assigned to Mi.
*   Simple Storage Verification: Assume a light client has access to a trusted source that broadcasts the latest block. A light client can request from nodes in the network: (1) the current AllocTable entry for miner Mi, (2) a Merkle path that proves that the entry was included in the state tree of the last block, (3) the headers from the genesis block until the current block. In this way, the light client can delegate the verification of the Proof-of-Spacetime to the network.

功率计算的安全性来自于“时空证明”的安全性。在这个设置里面，Post保证了矿工无法对他们所分配的存储数量说谎。事实上，他们不能声称能够存储超过他们的存储空间的数据，因为这会花费时间来运行PoSt.Setup，另外PoSt.Prove是串行的计算，并不能并行化的快速生成证明。

The security of the power calculation comes from the security of Proof-of-Spacetime. In this setting, PoSt guarantees that the miner cannot lie about the amount of assigned storage they have. Indeed, they cannot claim to store more than the data they are storing, since this would require spending time fetching and running the slow PoSt.Setup, and they cannot generates proofs faster by parallelizing the computation, since PoSt.Prove is a sequential computation.

#### 使用功率达成共识 Using Power to Achieve Consensus

我们预计通过扩展现在（和未来）的权益证明共识协议来实现Filecoin共识的多种策略，其中权益被替换为分配的存储。我们预计了权益证明协议的改进，我们提出了一个基于我们前期工作，称为预期共识的构建[14]。我们的策略是在每一轮选举一个（或多个）矿工，使得赢得选举的概率与每个矿工分配的存储成比例。

We foresee multiple strategies for implementing the Filecoin consensus by extending existing (and future) Proof-of-Stake consensus protocols, where stake is replaced with assigned storage. While we foresee improvements in Proof-of-Stake protocols, we propose a construction based on our previous work called Expected Consensus. Our strategy is to elect at every round one (or more) miners, such that the probability of winning an election is proportional to each miner’s assigned storage.

预期共识 预期共识的基本直觉是确定性的，不可预测的。并在每个周期内秘密选举一个小的Leader集合。预期的期望是每个周期内当选的Leader是1，但一些周期内可能有0个或者许多的Leader。Leader们通过创建新区块并广播来扩展区块链网络。在每个周期，每个区块链被延伸一个或多个区块。在某个无Leader的周期内，控区块被添加到区块链中。虽然链中的区块可以线性排序，其数据结构是有向无环图。EC是一个概率共识，每个周期都使得比前面的区块更加确定，最终达到了足够的确定性，且出现不同的历史块链的可能性是足够小的。如果大多数的参与者都通过签署区块链来扩展区块链，加大这个区块所属链的权重，那么这个区块就被确认了。

Expected Consensus. The basic intuition of Expected Consensus EC is to deterministically, unpredictably, and secretly elect a small set of leaders at each epoch. On expectation, the number of elected leaders per epoch is 1, but some epochs may have zero or many leaders. Leaders extend the chain by creating a block and propagating it to the network. At each epoch, the chain is extended with one or multiple blocks. In case of a leaderless epoch, an empty block is added to the chain. Although the blocks in chain can be linearly ordered, its data structure is a direct acyclic graph. EC is a probabilistic consensus, where each epoch introduces more certainty over previous blocks, eventually reaching enough certainty that the likelihood of a different history is sufficiently small. A block is committed if the majority of the participants add their weight on the chain where the block belongs to, by extending the chain or by signing blocks.

选举矿工 在每个周期，每个矿工检查他们是否被选为Leader，这类似于完成前面的协议:CoA[15],白皮书[16]，和算法[17]。

Electing Miners. At every epoch, each miner checks if they are elected leader, this is done similarly to previous protocols: CoA, Snow White, and Algorand.

定义6.1 如果下面的条件是满足的，则在时刻t 矿工Mi 是Leader：

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809325.png)

其中rand(t)是在时刻t，可以从区块链中提取出来的公开的随机变量，Pt>i是Mi的功率。考虑对于任意的m，L是H(m)的大小，H是一种安全的加密散列函数，其中（m)Mi是Mi对消息m的签名，使得：

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809326.png)

Definition 6.1. (EC Election in Filecoin) A miner Mi is a leader at time t if the following condition is met:

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809340.png)

Where rand(i) is a public randomness available that can be extracted from the blockchain at epoch t, pti is the power of Mi. Consider the size of H(m) to be L for any m, H to be a secure cryptographic hash function and <m>Mi to be a message m signed by such that:

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809326.png)

在图13中，我们描述了矿工（ProveElect）和网络节点（VerifyElect）之间的协议。这种选举方案提供了三个属性：公平，保密和公开的可验证性。

*   公平 每个参与者每次选举只有一次试验，因为签名是确定性的，而且t和rand(t)是固定的。假设H是安全的加密散列函数，则H(<t||rand(t)>Mi)/2L必须是从（0,1）均匀选择的实数，因此，可能使得方程等式为true必须是Pti/Σjptj，这等于矿工在在网络中的部分功率。因为这个概率在功率上市线性的，这种可能性在分裂或者汇集功率情况下被保留。注意随机值rand(t)在时刻t之前是未知的。
*   保密 由于有能力的攻击者不拥有Mi用来计算签名的秘钥，考虑到数字签名的假设，这个是可以忽略不计的。
*   公开可验证： 当选Leader i ∈ Lt 可以通过给出t，rand(t)，H(<t||rand(t)>i)/2L，来说服一个有效的验证者。鉴于前面的观点，有能力的攻击者在不拥有获胜秘密秘钥的情况下不能生成证明。

In Figure 13 we describe the protocol between a miner (ProveElect) and a network node (VerifyElect).

This election scheme provides three properties: fairness, secrecy and public veriability.

*   _Fairness_: each participant has only one trial for each election, since signatures are deterministic and t and rand(t) are fixed. Assuming H is a secure cryptographic hash function, then H(<t||rand(t)>Mi)/2L must be a real number uniformly chosen from (0, 1). Hence, the probability for the equation to be true must be Pti/Σjptj, which is equal to tlie miner’s portion of power within the network. Because this probability is linear in power, this likelihood is preserved under splitting or pooling power. Note that the random value rand(i) is not known before time t.
*   _Secret_: an efficient adversary that does not own the secret key Mi can compute the signature with negligible probability, given the assumptions of digital signatures.
*   _Public Verifiability_: an elected leader i ∈ Lt can convince a efficient verifier by showing t, rand(t), H(<t||rand(t)>i))/2L given the previous point, no efficient adversary can generate a proof without having a winning secret key.

![Filecoin 官方白皮书（中英对照）](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin白皮书中英文对照版/20201014/1602662809343.png)

图13：预期共识协议中的领导者选举

Figure 13: Leader Election in the Expected Consensus protocol

## 7 智能合约 Smart Contracts

Filecoin为终端用户提供了两个基本元：Get和Put。 这些基元允许客户以优惠的价格存储数据并从市场中检索数据。尽管基元涵盖了 Filecoin 的默认使用案例，但我们通过支持智能合约的部署，允许在Get和Put之上设计更复杂的操作。 用户可以对我们分类为文件合同以及通用智能合同的新的细粒度存储/检索请求进行编程。 我们整合了一个合同系统和一个Bridge系统，将Filecoin存储装入其他区块链，反之亦然，将其他区块链的功能带入Filecoin。

Filecoin provides two basic primitives to the end users: Get and Put. These primitives allow clients to store data and retrieve data from the markets at their preferred price. While the primitives cover the default use cases for Filecoin, we enable for more complex operations to be designed on top of Get and Put by supporting a deployment of smart contracts. Users can program new fine-grained storage/retrieval requests that we classify as File Contracts as well as generic Smart Contracts. We integrate a Contracts system and a Bridge system to bring Filecoin storage in other blockchain, and viceversa, to bring other blockchains’ functionalities in Filecoin.

我们期望在 Filecoin 生态系统中能有大量的智能合约，我们期待着一个智能合约的开发者社区。

We expect a plethora of smart contracts to exist in the Filecoin ecosystem and we look forward to a community of smart-contract developers.

### 7.1 与其他系统的集成 Contracts in Filecoin

智能合约使得Filecoin的用户可以编写有状态的程序，来花费令牌向市场请求存储/检索数据和验证存储证明。用户可以通过将交易发送到账本触发合约中的功能函数来与智能合约交互。我们扩展了智能合约系统来支持Filecoin的特定操作（如市场操作，证明验证）。

*   文件合约： 我们允许用户对他们提供的存储服务进行条件编程。有几个例子值得一提：（1）承包矿工：客户可以提前指定矿工提供服务而不参与市场 （2）付款策略：客户可以为矿工设计不同的奖励策略，例如合约可以给矿工支付随着时间的推移越来高的费用 ，另一个合约可以由值得信任的Oracle的通知来设置存储的价格。（3）票务服务：合约可以允许矿工存放令牌和用于代表用户的存储/检索的支付 （4）更复杂的操作：客户可以创建合约来运行数据更新。
*   智能合约：用户可以将程序关联到其他系统（如以太坊）他们的交易上,他们不直接依赖存储的使用。我们预见了以下的应用程序：去中心化命名服务，资产跟踪和预售平台。

Smart Contracts enable users of Filecoin to write stateful programs that can spend tokens, request stor-age/retrieval of data in the markets and validate storage proofs. Users can interact with the smart contracts by sending transactions to the ledger that trigger function calls in the contract. We extend the Smart Contract system to support Filecoin specific operations (e.g. market operations, proof verification).

Filecoin supports contracts specific to data storage, as well as more generic smart contracts:

*   File Contracts: We allow users to program the conditions for which they are offering or providing storage services. There are several examples worth mentioning: (1) contracting miners: clients can specify in advance the miners offering the service without participating in the market, (2) payment strategies: clients can design different reward strategies for the miners，for example a contract can pay the miner incresignly higher through time, another contract can set the price of storage informed by a trusted oracle, (3) ticketing services: a contract could allow a miner to deposit tokens and to pay for storage/retrieval on behalf of their users, (4) more complex operations: clients can create contracts thatallowfordataupdate.
*   Smart Contracts: Users can associate programs to their transactions like in other systems (as in Ethereum）which do not directly depend on the use of storage. We foresee applications such as: decentralized naming systems, asset tracking and crowdsale platforms.

### 7.2 与其他系统的集成 Integration with other systems

桥是旨在连接不同区块链的工具；现在正在处理中的，我们计划支持跨链交互，以便能将 Filecoin 存储带入其他基于区块链的平台，同时也将其他平台的功能带入 Filecoin。

*   Filecoin 进入其他平台：其他的区块链系统，如比特币，Zcash，特别是 Ethereum 和 Tezos，允许开发人员写智能合约；然而，这些平台只提供很少的存储能力和非常高的成本。我们计划提供桥将存储和检索支持带入这些平台。我们注意到，IPFS已经被作为几个智能合约（和协议令牌）引用和分发内容的一种方式来使用。增加到Filecoin的支持将允许这些系统以交换Filecoin令牌的方式来保证IPFS存储内容。
*   其他平台进入Filecoin：我们计划提供Filecoin连接其他区块链服务的桥。例如，与Zcash的集成将支持发送隐私数据的存储请求。

are tools that aim at connecting different blockchains; while still work in progress, we plan to support cross chain interaction in order to bring the Filecoin storage in other blockchain-based platforms as well as bringing functionalities from other platforms into Filecoin.

*   Filecoin in other platforms: Other blockchain systems such as Bitcoin , Zcash and in particular Ethereum and Tezos, allow developers to write smart contracts; however，these platforms provide very little storage capability and at a very high cost. We plan to provide a bridge to bring storage and retrieval support to these platforms. We note that IPFS is already in use by several smart contracts (and protocol tokens) as a way to reference and distribute content. Adding support to Filecoin would allow these systems to guarantee storage of IPFS content in exchange of Filecoin tokens.
*   Other platforms in Filecoin: We plan to provide bridges to connect other blockchain services with Filecoin. For example, integration with Zcash would allow support for sending requests for storing data in privacy.

## 8 未来的工作 Future Work

这项工作为Filecoin网络的建设提供了一个清晰和凝聚的道路;但是，我们也认为这项工作将成为今后研究去中心化存储系统的起点。在这个我们识别和填充三类未来 工作。这包括已经完成只是等待描述和发布的工作，提出改进当前协议的开放式问题，和协议的形式化。

This work presents a clear and cohesive path toward the construction of the Filecoin network; however, we also consider this work to be a starting point for future research on decentralized storage systems. In this section we identify and populate three categories of future work. This includes work that has been completed and merely awaits description and publication, open questions for improving the current protocols, and formalization of the protocol.

### 8.1 正在进行的工作 On-going Work

以下主题代表正在进行的工作。

*   •每个块中的 Filecoin 状态树的规范。
*   Filecoin 及其组件的详细绩效估计和基准。
*   完全可实现的 Filecoin 协议规范。
*   赞助检索票务模型，其中通过分配每个可持票花费的令牌，任何客户端C1可以赞助另一个客户端C2的下载。
*   分层共识协议，其中 Filecoin 子网可以在临时或永久分区进行分区并继续处理事务。
*   使用 SNARK / STARK 增量区块链快照。
*   FileCoin-Ethereum 合约接口和协议。
*   使用编织（Braid？）进行区块链归档和区块链间冲压。
*   只有在区块链解决冲突的时候才发布”时空证明”。
*   正式证明实现了 Filecoin DSN 和新型存储证明。

The following topics represent ongoing work.

*   A specification of the Filecoin state tree in every block.
*   Detailed performance estimates and benchmarks for Filecoin and its components.
*   A full implement able Filecoin protocol specification.
*   A sponsored-retrievd ticketing model where 仙y client Cl can sponsor the download of another client C2 by issuing per-piece bearer-spendable tokens.
*   A Hierarchical Consensus protocol where Filecoin subnets can partition and continue processing transactions during temporary or permanent partitions.
*   Incremental blockchain snapshotting using SNARK/STARK
*   Filecoin-in-Ethereum interface contracts and protocols.
*   Blockchain archives and inter-blockchain stamping with Braid.
*   Only post Proofs-of-Spacetime on the blockchain for conflict resolution.
*   Formally prove the realizations of the Filecoin DSN and the novel Proofs-of-Storage.

### 8.2 开放式问题 Open Questions

作为一个整体，有一些公开的问题，其答案有可能可以大大改善网络。尽管事实上，在正式启动之前并不是必须必须解决的问题。

*   一个更好的原始的”复制证明“密封功能，理想情况下是O（n）解码（不是O（nm）），可公开验证，无需SNARK / STARK。
*   “复制证明”功能的一个更好的原语，可以公开验证和透明没有SNARK / STARK。
*   一个透明，可公开验证的可检索证明或其他存储证明。
*   在检索市场中进行检索的新策略（例如，基于概率支付，零知识条件支付）。
*   “预期共识”更好的秘密Leader选举，在每个周期，只有一位当选Leader。
*   更好的可信赖的SNARK设置方案，允许增加扩展公共参数（可以运行MPC序列的方案，其中每个附加的MPC严格降低故障概率，并且每个MPC的输出可用于系统）。

There axe a number of open questions whose answers have the potential to substantially improve the network as a whole, despite the fact that none of them have to be solved before launch.

*   A better primitive for the Proof-of-Replication Seal function, which ideally is O(n) on decode (not O(nm)) and publicly-verifiable without requiring SNARK/STARK.
*   A better primitive for the Proof-of-Replication Prove function, which is publicly-verifiable and transparent without SNARK/STARK.
*   A transparent, publicly-verifiable Proof-of-Retrievability or other Proof-of-Storage.
*   New strategies for retrieval in the Retrieval Market (e.g. based on probabilistic payments, zero knowledge contingent payments)
*   A better secret leader election for the Expected Consensus, which gives exactly one elected leader per epoch.
*   A better trusted setup scheme for SNARKs that allows incremental expansion of public parameters (schemes where a sequence of MPCs can be run, where each additional MPC strictly lowers probability of faults and where the output of each MPC is usable for a system).

### 8.3 证明和正式的验证

由于证明和正式验证的明确价值，我们计划证明Filecoin网络的许多属性，并在未来几个月和几年内开发正式验证的协议规范。几个证明正在进行中还有些正在思考中。但注意，要证明Filecoin的许多属性（如伸缩，离线）将是艰难的，长期的工作。

*   预期共识和变体的正确性证明。
*   功率故障容错正确性的证明，异步1/2不可能导致分叉。
*   在通用组合框架中制定Filecoin DSN，描述Get，Put和Manage作为理想的功能，并证明我们的实现。
*   自动自愈保证的正式模型和证明。
*   正式验证协议描述（例如TLA +或Verdi）。
*   正式验证实现（例如Verdi）。
*   Filecoin激励的博弈论分析。

Because of the clear value of proofs and formal verification, we plan to prove many properties of the Filecoin network and develop formally verified protocol specifications in the coming months and years. A few proofe are in progress and more in mind. But it will be hard, long-term work to prove many properties of Filecoin (such as scaling, offline).

*   Proofs of correctness for Expected Consensus and variants.
*   Proof of correctness for Power Fault Tolerance asynchronous 1/2 impossibility result side-step.
*   Formulate the Filecoin DSN in the universal composability framework, describing Get, Put and Manage as ideal functionalities and prove our realizations.
*   Formal model and proofe for automatic self-healing guarantees.
*   Formally verify protocol descriptions (e.g. TLA-h or Verdi).
*   Formally verify implementations (e.g. Verdi).
*   Game theoretical analysis of Filecoin’s incentives.

## 致谢

这项工作是Protocol Labs团队中多个人的累积努力，如果没有实验室的合作者和顾问的帮助、评论和审查这是不可能完成的。 Juan Benet 在2014年写了原始的 Filecoin 白皮书，为这项工作奠定了基础。他和尼古拉·格雷科（Nicola Greco）开发了新的协议，并与提供了有用的贡献，评论，审查意见的团队其他人合作编写了这份白皮书。特别是大卫，“大卫” Dalrymple 提出了订单范例和其他想法，Matt Zumwalt 改进了在这篇论文中的结构，伊万·米亚佐诺（Evan Miyazono）创建了插图，并完成了这篇论文，在设计协议时，Jeromy Johnson 提出了深刻的见解，Steven Allen 提供了深刻的问题和清晰的说明。我们也感谢所有的合作者和顾问进行有用的对话；尤其是 Andrew Miller 和 Eli Ben-Sasson。

先前版本：QmVcyYg2qLBS2fNhdeaNN1HvdEpLwpitesbsQwneYXwrKV

This work is the cumulative effort of multiple individuals within the Protocol Labs team, and would not have been possible without the help, comments, and review of the collaborators and advisors of Protocol Labs. Juan Benet wrote the original Filecoin whitepaper in 2014, laying the groundwork for this work. He and Nicola Greco developed the new protocol and wrote this whitepaper in collaboration with the rest of the team, who provided useful contributions, comments, review and conversations. In particular David t4davi-dad,J Dalrymple suggested the orderbook paradigm and other ideas, Matt Zumwalt improved the structure of the paper, Evan Miyazono created the illustrations and finalized the paper, Jeromy Johnson provided insights while designing the protocol, and Steven Allen contributed insightful questions and clarifications. We also thank all of our collaborators and advisor for useful conversations; in particular Andrew Miller and Eli Bcn-Sasson.

Previous version: QmZ5fLHwK9d55iyxpke6DJTWxsNR3PHgi6F43jSUgEKx31

白皮书原文地址：https://filecoin.io/filecoin.pdf /