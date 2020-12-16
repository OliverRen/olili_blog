---
title: 02_PoRep和PoSt算法源代码导读
tags: 
---

[toc]

#### Filecoin代码模块依赖关系

从PoRep以及PoSt存储证明的角度来看，Filecoin代码模块由如下三层组成：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116244668.png)

rust-fil-proofs是存储证明的具体实现，通过Rust语言实现。rust-fil-proofs模块依赖bellman项目（零知识证明）。bellman项目是ZCash项目使用的零知识证明模块。bellman项目也是用Rust语言实现。在go-filecoin的rustverifier.go文件实现go到rust语言的调用。

#### rust-fil-proofs的框架

rust-fil-proofs功能主要由四个子模块组成：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116272937.png)

filecoin-proofs实现了filecoin存储证明的接口，依赖其他两个模块：storage-proofs（存储证明的逻辑）和 sector-base （数据存储的接口）。这两个模块又依赖于storage-backend模块实现数据的存储。

相关代码就在这四个目录中：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116284446.png)

#### PoRep的生成和验证逻辑

PoRep就是Proof of Replicate，数据存储证明。模块之间的调用关系如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116302525.png)

node.go代码在启动挖矿时，每120个区块调用一次SealAllStagedSectors函数（将所有的Staged的Sector数据进行Seal）。顺便说一句，用户的数据存储时分成一个个的Sector（目前设置为256M）。Sector有三个状态：Staging（数据还未写满，并且未超时），Staged（数据已经写满或者超时），Sealed（数据已经Seal并存储）。

在filecoin-proof模块接收到请求后，确认目前所有的Staged的Sector，并对每个Sector进行Seal。

核心逻辑在rust-fil-proofs/filecoin-proofs/src/api/internal.rs代码的seal函数。seal函数原型如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116313493.png)

seal函数对in_path的原始数据，进行复制并存储到out_path。在seal的过程中，提供Sector的属性，证明人的id以及Sector的id。

- Replica ID

	对每一个Seal过的Sector，设置一个Replica ID。Replica ID是一个Hash值，计算过程如下：

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116352267.png)

	相应实现是rust-fil-proofs/storage-proofs/src/porep.rs的replica_id函数。

- 整体逻辑

	PoRep的生成逻辑包括两部分：1/数据的复制（replicate）2/数据的复制证明。Step1/Step3实现复制的证明，Step2实现数据的复制。

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116380917.png)

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116389474.png)

- 数据复制逻辑

	PoRep算法的全称是ZigZag-DRG-PoRep。整体流程示意如下：

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116488157.png)

	Sector中未Seal的原始数据首先依次分成一个个小数据，每个小数据32个字节。这些小数据之间按照DRG（Depth Robust Graph）建立连接关系。按照每个小数据的依赖关系，通过VDE（Verifiable Delay Encode）函数，计算出下一层的所有小数据。整个PoRep的计算过程分为若干层（目前代码设置为4层），仔细观察每一层的DRG关系的箭头方向，上一层向右，下一层就向左，因此得名ZigZag（Z字型）。

	VDE以及ZigZag设置的参数查看 `rust-fil-proofs/filecoin-proofs/src/api/internal.rs`：

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116521486.png)

	每一层的计算逻辑示意如下：

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116528995.png)

	每一层的输入称为d（data），每一层的VDE的结果称为r（replica）。对每一层的输入，建构默克尔树，树根为comm_d, 整个树的数据结构称为tree_d。对每一层的输出，建构默克尔树，树根为comm_r，整个树的数据结构称为tree_r。

	再介绍两个术语：TAU，AUX。

	__TAU__: 希腊字母，一棵或者多棵Merkle树的树根都称为TAU。

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116547347.png)

	__AUX__: Auxiliary的简称，一棵或者多棵Merkle树的结构称为AUX。

	对于一层replica来说，TAU包括comm_d和comm_r，AUX包括tree_d和tree_r。

	对于整个PoRep来说，也就是多层replica来说，TAU以及AUX示意如下：

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116569083.png)

	其中的comm_r_star是每层comm_r的数据和replica id数据Hash的结果。

	具体实现的源代码请看两个函数：

	1. `rust-fil-proofs/storage-proofs/src/layered_drgporep.rs`中的Layers的replicate函数

	1. `rust-fil-proofs/storage-proofs/src/drgporep.rs`中的PoRep的replicate函数

- 复制证明逻辑

	复制数据完成后，需要提供零知识的证明。该证明逻辑需要花很多篇幅仔细介绍，涉及到QAP，KCA，Groth16，同态隐藏，双线性映射。后续的文章会详细讲解相关逻辑。本文先有些概念：需要生成证明（Proof）需要有两步：setup以及prove。

	setup：设置证明的参数

	prove：提供需要证明的内容，包括公共数据(public inputs)，私有数据（private inputs)以及Groth的参数。在2.b中的代码中可以看出，

	PoRep证明的公共数据包括原始数据的comm_d，最后一层的comm_r和comm_r_star。

	PoRep证明的私有数据包括所有层的comm_r/comm_d和每一层的tree_r/tree_d。

	值得特别提出的是，PoRep提交到Filecoin区块链上的数据是：PoRep的公共数据和复制证明数据。

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116654984.png)

	整个数据复制的过程时间比较长，目前1G的数据需要消耗40～50分钟。

- 复制验证逻辑

	在某个存储矿工生成PoRep后，通过CommitSector接口向区块链提交证明信息。在Filecoin区块链的所有矿工接收到CommitSector的Message交易时，调用VerifySeal进行复制验证，大体流程如下：

	![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116684503.png)

	具体实现的源代码请查看`rust-fil-proofs/storage-proofs/src/api/internal.rs`的verify_seal函数。
	
#### PoSt的生成和验证逻辑

- PoSt生成逻辑

PoSt的生成是基于最近的存储状态，所以提交PoSt的证明最好能在一个区块之内（30秒）完成。PoSt生成逻辑的调用关系如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116751364.png)

在新的区块生成时（OnNewHeaviestTipSet函数），每个提供存储的矿工会检查是否需要提供PoSt的证明。如果需要，则调用generatePoSt函数生成证明。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116761088.png)

generatePoSt函数提供两个参数：所有提交到区块链上的comm_r信息以及随机挑战信息 （ChallengeSeed)。所有提交到区块链上的comm_r信息通过区块链查询可以获取。ChallengeSeed通过currentProvingPeriodPoStChallengeSeed函数生成，生成逻辑如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608116769823.png)

简单的说，就是从当前区块高度往前看几个TipSet，找出某一个TipSet中众多区块中的最小Ticket。该Ticket就是ChallengeSeed。

在最新的代码逻辑中，PoSt每两个Sector会生成一个Proof，也就是post_adapter实现的逻辑。提交到区块链上的是众多Proof的列表。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608125982779.png)

VDFPostCompound::setup函数设置验证相关参数。VDFPostCompound::prove函数需要四个参数：

a. setup函数设置的参数

b. Public数据（comm_r的数据列表，随机挑战信息）

c. 私有数据（Seal数据构成的Merkle树的结构信息）

d. Groth相关的参数信息

具体实现的源代码请查看rust-fil-proofs/storage-proofs/src/api/internal.rs的generate_post_fixed_sectors_count函数。

prove函数实现的逻辑就是白皮书中的PoSt的框架图：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608125992746.png)

- PoSt验证逻辑

在某个存储矿工生成PoSt证明后，通过SubmitPoSt接口向区块链提交证明信息。在Filecoin区块链的所有矿工接收到SubmitPoSt的Message交易时，调用VerifyPoST进行复制验证，大体流程如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/02_PoRep和PoSt算法源代码导读/20201216/1608126015924.png)

具体实现的源代码请查看rust-fil-proofs/storage-proofs/src/api/internal.rs的verify_post_fixed_sectors_count函数。

总结：PoRep是对某个Sector数据存储的证明，每个Sector一次。PoSt是一系列已经Seal过的Sector的存储证明，每隔一段时间一次。两个证明的核心是Groth16零知识验证算法，基于Bellman项目。