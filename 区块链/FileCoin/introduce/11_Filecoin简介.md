---
title: Filecoin简介
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

#### 初识 Filecoin

Filecoin是一种分散式存储网络，可将云存储变成算法市场。矿工通过提供数据存储或检索来获取本地协议令牌（也称为“FIL”），另一方面，客户向矿工付费以存储或分发数据并检索数据。

**我们所说的Filecoin有四大方面的含义**

1. BlockChain :
跟其它区块链项目一样，这是filecoin的基础，一切都是围绕block和chain进行的。

2. 交易市场 :
filecoin拥有两个交易市场，检索市场和存储市场，矿工和用户在这两市场里面达成交易，实现价值交换。

3. 共识机制 :
有交易和区块链必然要有谁记账的问题，filecoin也一样，必然要解决的一个问题是，共识机制。

将矿工当前在网中使用的存储量和生成的时空证明转化为投票的权重，然后节点利用这个权重进行选举产生一个或者多个领导节点，领导节点创建新的block并把它们传播到网络。filecoin的block数据结构采用了DAG结构。

4. 智能合约 :
filecoin采用了两个基本的api供用户使用，数据存储put，数据获取get，在这两种操作的基础上filecoin支持文件合约(File Contracts)，让用户可以有更精细化的控制。

filecoin集成了合约系统和桥系统，把filecoin的存储系统提供给其他区块链系统使用，同时可以让filecoin使用其它区块链的功能。

**Filecoin涉及的一些证明**

- 数据持有证明(PDP): 用户发送数据给矿工存储, 矿工证明数据已经被自己存储
- 可检索证明(PoRet): 和PDP过程类似, 证明矿工存储的数据是可以用来查询
- 存储证明(PoS proofs-of-storage): 利用存储空间进行证明, 工作量证明的一种, 性的论文把名称变成了 PoRep
- 复制证明(PoRep): 保证每份数据都说独立存储, 可以防止女巫攻击, 外源攻击和生成攻击,PoRep 是 PoS 的进化版, 用来证明数据已经被矿工存储
- 工作量证明(PoW): 证明者向检验者证明自己花费了一定资源, PoW 被用在加密货币, 拜占庭共识和其他各种区块链操作系统. BTC使用的就是这种证明
- 空间证明(PoSpace): Filecoin 提出的概念, 存储量的证明, PosSpace 是 PoW 的一种, 不同的是 PoW 使用的计算资源, 而 PsSpace 使用的存储资源
- 时空证明(PoSt): 矿工证明自己花费了 spacetime 资源,即一定时间内存储空间的使用, PoSt 是基于 PoReps 实现

**共识机制**

Filecon在拜占庭容错BTF的基础上提出了改进版的拜占庭容错，影响力容错(Power Fault Tolerance)和预期共识(Expected Consensus)，用来替代能源和计算资源严重浪费的工作量证明（Proof-of-Work）机制。

Power Fault Tolerance:影响力容错 :

这是filecoin协议里面对 PFT的解释，power概念就是矿工的影响力（influence），“Power”是filecoin系统的投票权力的大小度量，根据矿工贡献的Power来计算矿工的投票权有多大，根据信达雅的基本要求，所以称为“影响力容错”。

共识机制的要求:

- 选举秘密进行 （Secret）
- 选举是公平的 （Fair），基于一套规则，在规则的基础上概率起作用
- 最好没轮选举出一个领导人（Single Leader）
- 无法预测（Unpredictable）
- 十分容易验证 （Verifiable）
- 能够承受攻击（Anti-attack）
- 消耗资源不大（Efficient）

预期共识(Expected Consensus，EC)

预期共识实现了前面提到的几乎所有特性，就差一点。这一点就是不能实现单个领导人的选举，每一轮选举出来的领导人可能是多个，也可能没有.

Filecoin的共识机制吸收了共识机制发展中的各种成果，第一次实现了基于有价值的网络的共识算法。它包括：

- 基于存储的工作量证明（POW）共识
- 可扩展的拜占庭容错共识机制
- 权益证明（POS）共识机制

由于预期共识一轮选举可能产生多个领导人，这个问题怎么解决？很简单，都当领导，各自产生区块，而且每一个区块都有效。也就是说同一个高度就可能有多个区块。怎么处理？办法是，把这些区块再打包，称为一个tipset。因此，在Filecoin中，链并不能完全称为区块链，也应该是tipset链。一个tipset里包含一个或多个区块。也有的轮次中的选举没有领导人，怎么办呢？那就跳过，这个高度就是一个空块。这样一来，尽管不够均匀，但形成了链，而且是收敛的。

**存储矿工密封工作的主要操作**

- P1 密封预交付阶段1 PoRep复制证明,此阶段受CPU限制,并且是单线程的,故需要强性能的CPU,SHA扩展的==AMD处理器==在很大程度上加快了此过程
- P2 密封预交付阶段2 波塞冬(Poseidon)哈希算法执行Merkle树生成, 主要使用 GPU
- C1 密封提交阶段1 执行生成证明所必需的准备工作的中间阶段 CPU运算
- C2 该密封阶段涉及创建SNARK 将证明在广播之前进行压缩, GPU

