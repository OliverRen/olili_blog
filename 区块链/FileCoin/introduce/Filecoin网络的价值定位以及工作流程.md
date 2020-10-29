---
title: Filecoin网络的价值定位以及工作流程
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

#### Filecoin 网络的价值定位

[本文Source](https://ipfs.cn/news/info-101279.html)

1. 可验证存储 :Filecoin协议以加密验证的方式检验用户的数据是否正在被存储，而 不需要信任云存储提供商或其他中介；

2. 开放性参与:  任何拥有足够硬件设备和接通互联网的人都可以参与Filecoin网络；

3. 存储分布可实现本地优化:  Filecoin以一种高效且经济的方式来将数据存储在网络和用户附近将增加网络的实用性，用户想获取的网站或视频可以选择就近的Filecoin矿工节点托管；

4. 灵活的存储选择:  作为一个开放的平台，Filecoin网络将支持许多由开发者社区基 于协议基础上进行改进或打造的附加工具和辅助服务； 

5. 网络由社区共同打造:  Filecoin为网络参与者提供了成为网络成功利益相关者的机 会，网络也因此会越来越强大。

#### Filecoin 网络的工作流程

1. 在Filecoin经济中，存在三个不同的市场以及5大主要的参与者：

	- 存储市场：**存储矿工** 出租可用的数字化存储，这些存储将由Filecoin网络进行验证， 相反，存储用户通过支付filecoin来存储其数据。存储定价基于可用的存储容量和存储合约的期限。 
	- 检索市场：用户将Filecoin支付给 **检索矿工** 以获得他们提供的数据副本。
	- 参与者相互进行代币交易从而将filecoin流转到 **用户、矿工和其他代币持有者** 手中。

	PS:其实还有其他的 维修矿工,或者应用,服务提供方等.

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin网络的价值定位以及工作流程/20201029/1603973924250.png)

2. 存储订单的流程

	- 用户向矿工发起交易
	- 矿工接受交易，数据开始进行传输
	- 矿工将数据封装在扇区，矿工提供扇区证明并开始获得区块奖励
	- 用户从矿工处检索文件 ，并支付费用

3. 检索的流程

	首先，用户提出对特定数据的查询需求，检索矿工节点使用 gossipsub在矿工网络中传播这些查询；然后，拥有此内容的检索矿工返回包含价格信息的检 索提案，用户使用支付通道与选定的检索矿工交换数据并支付。