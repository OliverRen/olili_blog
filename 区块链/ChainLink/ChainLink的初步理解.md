---
title: ChainLink的初步理解
tags: 小书匠语法,技术
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

#### 我的理解

**chainlink的主要价值**

即将区块链下的,单一的,中心化的,不可信的内容,使用类似零知识证明的方式,分配到多个独立的node节点来进行执行,回复后汇总,使之成为一个去中心化,可信的数据被智能合约来使用.

**chainlink实现的主要功能**

- 以太坊上的 link代币合约 ==erc667 token== (transfer and call with data)
- 以太坊上的 Oracle预言机,即用来部署node并与以太坊账户捆绑
- 以太坊上智能合约的 ChainlinkClient和Aggregate框架,使客户合约能够方便集成,开箱即用
- 适配器 统一化的可执行操作单元
- 适配器中的Bridge适配器可以通过最低依赖接入外部的api,这使node具有了无限想象力的外部功能



- [外部适配器的详细说明](https://medium.com/chainlink/chainlink-external-adapters-e9f99cd6cb62)
- [以太坊主网上的外部适配器的节点](https://docs.chain.link/docs/chainlinks-ethereum-mainnet)
- [官方的explorer](https://explorer.chain.link/)
- [社区第三方出品的market.link](https://market.link/)
- [社区第三方出品的reputation.link](https://www.reputation.link/)
- [Github](https://github.com/smartcontractkit/chainlink)

#### 名词解释

这一部分主要来自于chainlink的中文社区

- 适配器 Adapter

适配器是一个负责执行特定功能的软件。Chainlink节点内置了一些适配器，被称为核心适配器（Core Adapters），也可以通过桥接器（Bridges）与用户自定义的外部适配器（External Adapters）连接。Chainlink节点默认的核心适配器包括：

	*   Bridge
	*   Copy
	*   EthBytes32
	*   EthInt256
	*   EthTx
	*   EthUint256
	*   HTTPGet
	*   HTTPPost
	*   JSONParse
	*   Multiply
	*   NoOp
	*   NoOpPend
	*   Sleep

- 结果 Answer

在执行所有安全检查和聚合之后，从oracle服务生成的结果。

- 桥接器 Bridge

桥接器是Chainlink节点与外部适配器的连接。外部适配器以独立的服务运行，桥接器可以帮助节点与这些是适配器进行通信。

如果你想要向你的节点添加一个新的外部适配器，你可以通过界面或命令行来创建桥接器。在Chainlink节点内部，桥接器的名称必须是唯一的，但是可以与其他桥接器共享一个URL。你也可以为每个桥接器分别设置不同的确认数，和额外支付数量。一旦桥接器添加到节点中，桥接器的名字可以在工作规范中作为任务类型。

- 消费者合约 Consumer (Contract)

oracle获取到的结果的接受者。消费者一般来说是发起请求的合约，但也不必须是。我们提供了一个方法，`addExternalRequest`，可以帮助消费行业检查结果而不用亲自发起请求。

- Encumbrance Parameters

Encumbrance Parameters是服务协议的一部分，可以在链上执行。更多关于Encumbrance Parameters的内容可以在[wiki](https://github.com/smartcontractkit/chainlink/wiki/Protocol-Information#encumbrance)里找到。

- 外部适配器 External Adapter

外部适配器使Chainlink可以更方便的扩展，提供对自定义计算或指定API的整合功能。

Chainlink节点与外部适配器通过发送携带有JSON数据的POST请求来实现通信。更多关于外部适配器的信息可以在 [开发者](doc:%E5%BC%80%E5%8F%91%E8%80%85) 找到。

- 函数选择器 Function Selector

函数选择器指定了以太坊上被调用的函数。它是以太坊事务中函数调用的调用数据的前四个字节。Solidity合约中内置了一个方法来获取函数选择器`this.myFunction.selector`，此处`myFunction`合约中的非重载方法。

- 启动器 Initiator

执行Job规范的触发器。可用的启动器有：

	*   runlog
	*   cron
	*   ethlog
	*   runat
	*   web
	*   execagreement

目前只有`runlog`和`execagrement`可以通过向节点运营商转账来使用。启动器使用节点配置的MINIMUM_CONTRACT_PAYMENT大小来决定请求所需要的支付金额，如果在JobID或SAID配置了指定支付额的桥接器，需要再加上额外的金额。

- Job

Job Spec的简称。

- JobID

与Job Spec关联的ID。每个节点中都是唯一确定的，即使两个规范的内容完全一样，也不能重名。

- Job Run

Job Run 用于记录Job Spec的执行结果。Job Run由一系列的请求参数、作业规范中每一个任务规范的任务运行过程（TaskRun）、以及Job Run的最终结果组成。

- 作业规范 Job Spec

作业规范（Job Specification）是由Oracle节点完成的一项特定工作。作业规范主要由两部分组成：

1.  启动器（Initiator）列表，`initiators`，列出了作业规范可以被触发执行的所有方式。
2.  任务（Task）列表，指定了执行作业规范的所有计算步骤。任务列表有时候指的是作业管道（Job Pipeline），因为所有的任务都是按顺序执行，前一个任务的结果作为下一个任务的输入。

- 预言机 Oracle

将链上计算与链下资源联系起来的实体。技术上讲由两部分构成：Oracle节点和Oracle合约。

- 预言机合约 Oracle Contract

Oracle的链上组成部分。Oracle合约是消费合约传递和接受链下资源的接口。

- 预言机节点 Oracle Node

Oracle的链下组成部分。

- 请求者 Requester

从Oracle请求数据的智能合约或外部账户（External Owned Account）。请求者与消费者不是同一个实体，但是一般来说扮演同样角色。

- 请求参数 Requeste Parameters

当Job Run开始执行，填写所有的任务规范（Task Specs）的全部定义。请求者（Requester）可以指定在请求Job Run可以通过在请求中传递JSON数据来指定其余的作业规范（Job Spec）的定义。JSON会在每个任务运行（Task Run）执行前与每一个任务规范（Task Spec）合并。

- 运行 Run

Job Run的简称。有时也指Task Run。

- 运行结果 Run Result

运行结果是作业规范（Job Spec）或任务规范（Task Spec）的执行结果。运行结果有JSON blob，运行状态（Run Status）和可选的错误字段组成。运行结果存储在Job Run和Task Run之中。

- 运行状态 Run Status

每个Job Run和Task Run都有一个状态字段由于表示当前的进度。运行状态可以是以下几种状态：

	*   Unstarted
	*   In Progress
	*   Pending Confrimations
	*   Pending Bridge
	*   Pending Sleep
	*   Errored
	*   Completed

- SAID

服务协议（Service Agreement）ID。

- 服务协议 Service Agreement

服务协议有作业规范Job Spec和一系列Encumbrance parameters组成，在创建者和多个Chainlink节点之间共享。服务协议信息参见[wiki](https://github.com/smartcontractkit/chainlink/wiki/Protocol-Information#service-agreements)。

- 规范 Spec

任务规范Job的缩写。

- 任务 Task

Task规范的缩写。

- 任务规范 Task Spec

任务规范Task Spec定义为在作业规范（job specification）中有特定适配器执行的单个任务。任务规范（Task Spec）包括`type`字段，指定执行它的适配器。另外，Task Spec可以指定额外的`params`传递给它的适配器，`confirmations`指定Task Run执行之前需要等待的确认块数。

- 任务运行 Task Run

单个任务规范（Task Spec）执行的结果。Task Run包括了Task Spec作为输入和Run Result作为执行的输出。

#### 流程示例

------------
我们来看一个 Aava的质押实例 

1. 用户发起提现请求
0xef5bc2eb4180a320bd4d07980947f59f40d28804
2. Aave: aETH Token
0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04
3. 交易是
0x241424791bc3a0970452c3ec57b4a1c8e07920dfb687f02a9887003383b4cc38
4. Token开始对Pool执行调用 Aave: Lending Pool Core
0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3
5. 通过多次合约调用后由 chainlink的用户合约
0x76B47460d7F7c5222cFb6b6A75615ab10895DDe4
6. 对chainlink的 Aggregator 发起获取汇率的请求

------------
chainlink部分

1. Aggregator执行触发的外部账户地址
0xd8Aa8F3be2fB0C790D3579dcF68a04701C1e33DB
2. 对chainlink的 LEND / ETH feed Aggregator
0x1EeaF25f2ECbcAf204ECADc8Db7B0db9DA845327
3. 发起交易
0x31285e3ab1929cbdab2edaf8e1a1568bdcf118246e3b284c24fb0a1154668f81
4. Aggregator在chainlink合约上分发了请求到不同的node,这里先 internal call到chainlink
0x514910771AF9Ca656af840dff83E8264EcF986CA
5. **我们看一个node,这里会使用delegatecall切换到node合约的环境中执行** (CALL修改的是被调用者的storage，而CALLCODE修改的是调用者的storage)
6. 0x049bd8c3adc3fe7d3fc2a44541d955a537c2a484
转发过来的请求会告诉node合约执行完成job后直接回调 Aggregator

------------
node 执行链外操作

1. node的操作账户 
0x2ad9b7b9386c2f45223ddfc4a4d81c2957bae19a
2. 对node合约
0x049bd8c3adc3fe7d3fc2a44541d955a537c2a484
3. 发起交易,该交易主要的请求方法是  fulfillOracleRequest
0x02229e6438f23b70768a46bbfa9624236fc4fce748cedfa73eb5c59f599eb908
4. node合约对 指定的回调合约执行请求,这里是 Aggregator
0x1EeaF25f2ECbcAf204ECADc8Db7B0db9DA845327

总结:
1. 用户通过自己控制的外部账户向自己的客户合约发起请求,触发需要 chainlink需要外部数据
2. 用户可以选择直接使用指定的node上指定的JobId的任务来执行,这会直接请求该node的Oracle合约(事实上依然是先到chainlink token合约的)
3. 用户也可以通过 Aggregator 发起请求,这会在 Aggregator分发请求和聚合结果(事实上会有一个chainlink token合约的过程)
4. node节点通过Oracle合约收到请求后顺序执行适配器,这会转到链下执行
5. node节点执行完成后,通过捆绑到node的以太坊外部账户发起对node Oracle合约的调用
6. node Oracle会通过请求中指定的回调地址和回调方法执行回调.提交答案并获得link奖励

目前来看一次调用的收费一般只有0.1link,但是eth的手续费都要0.01eth左右
从成本上来考虑1link差不多要=0.1eth才匹配,这是一个相当简单的数学模型不是吗
如果link继续火爆.那么说明link的价格依然有很大的向上空间