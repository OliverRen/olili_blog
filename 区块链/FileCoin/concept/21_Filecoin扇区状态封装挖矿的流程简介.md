---
title: Filecoin扇区状态封装挖矿的流程简介
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

1. 流程说明

Filecoin扇区封装的这个挖矿过程和BTC挖矿是有非常多的不同的.比特币的矿机属于发布了一个问题,大家去比赛谁先能解答出来,谁就有记账权就可以获得出块奖励.其挖矿是指在一段时间内的交易进行打包生成block账本做交易信息的确认,这个往整个网络中记录新区快的过程就是挖矿的过程.

而Filecoin则不同,Filecoin这里的挖矿我的理解其实是可以用POS来阐述的.大家先通过运算向网络封装并不断证明一直承诺的有效空间.然后根据矿工个人占整个网络中的算力比例来获得出块权,通过应答挑战来爆块.

这里简单介绍一下参与到Filecoin挖矿的普通流程

- 系统 ubuntu 20.04 安装挖矿软件 lotus套件并运行相关的程序.
- 通过上面的程序lotus同步完链数据.
- 创建bls钱包地址
- 创建节点并加入到网络
- 在Filecoin挖矿中是需要质押Fil的,所以需要购买或者借贷Fil给control和worker地址打入Fil
- 通过lotus-miner开始挖矿,大概步骤是获取存储订单,数据密封,生成复制证明,验证数据,在下次windowPoSt后形成有效算力,获得出块权,提供时空证明,获得出块奖励.

Filecoin是存储挖矿，矿工根据其实际封装了多少数据并向链上提交了复制证明从而获得有效算力（有效存力），有效算力越高，矿工获得区块奖励的概率越大。

算力越大的矿工，获得区块打包的权利或者概率越大，这里就有赢票率和出块率的参数。赢票率就是赢得选票的概率，出块率就是获得区块奖励的概率。

我们做个对比，比特币挖矿所购买的矿机算力是恒定的，买了矿机接入互联网之后，每天产多少个币就是一个恒定的值；而Filecoin是存储挖矿，Filecoin的算力是根据封装了多少有效数据来计算的，今天封装了1T，算力就是1T，而算力也在不断累积中。

需要注意的是，最短扇区生命周期被设置为6个月，最长的扇区生命周期由证明算法确定，初步而言最长扇区生命周期为18个月，也就是540天。扇区在其生命周期结束时会自然到期，此外，矿工也可以延长其扇区的周期。

那么，有效算力是挖矿的基础，矿工的算力越高，赢票率越大，相应获得区块奖励的概率也就越大，挖矿收益也相应越高。而扇区封装封装效率越快、有效算力增长速度自然越快，有效算力占比越高，其出块率也就相应越高，产币量就越大。

2. 官方spec-actor的源码

```
	/////
	// Now decide what to do next
	//
	/*
				*   Empty <- incoming deals
				|   |
				|   v
			    *<- WaitDeals <- incoming deals
				|   |
				|   v
				*<- Packing <- incoming committed capacity
				|   |
				|   v
				*<- PreCommit1 <--> SealPreCommit1Failed
				|   |       ^          ^^
				|   |       *----------++----\
				|   v       v          ||    |
				*<- PreCommit2 --------++--> SealPreCommit2Failed
				|   |                  ||
				|   v          /-------/|
				*   PreCommitting <-----+---> PreCommitFailed
				|   |                   |     ^
				|   v                   |     |
				*<- WaitSeed -----------+-----/
				|   |||  ^              |
				|   |||  \--------*-----/
				|   |||           |
				|   vvv      v----+----> ComputeProofFailed
				*<- Committing    |
				|   |        ^--> CommitFailed
				|   v             ^
		        |   SubmitCommit  |
		        |   |             |
		        |   v             |
				*<- CommitWait ---/
				|   |
				|   v
				|   FinalizeSector <--> FinalizeFailed
				|   |
				|   v
				*<- Proving
				|
				v
				FailedUnrecoverable
				UndefinedSectorState <- ¯\_(ツ)_/¯
					|                     ^
					*---------------------/
	*/
```

3. 流程说明

`[Handle Deal]`
首先在 `lotus-miner sectors pledge` 执行后会执行 incoming deal 过程,这个时间可以进行配置.

`[Empty]`
startCC begin 

`[Packing]`
开始Packing即 addPiece cpu 1 core+disk 32g写入unseal 随机填充数据也需要一点时间不过忽略不计,注意会有等待deal的时间

`[PreCommit1(SealPreCommit1Failed)]`
32g会被拆成32 Byte的小node,然后通过SDR算法计算出11层的merkel树 cpu 1 core+disk 15.18\*32g写入cache 时间主要根据IO.不过不是线性,单线程5.5H,4线程也不过是6H

`[PreCommit2(SealPreCommit2Failed)]`
主要是GPU运算进行压缩P1计算出的merkel树得到root根,这里需要计算8层, gpu+cpu all core+disk 16.18\*32g写入seal 时间也差不多根据cpu+gpu,最快25min,最长35min

`[PreCommitting(PreCommitFailed)]`
发送交易 Method:PreCommitSector 把P2计算得到的默克尔树的根提交上链,以此证明矿机的加密能力和已经完成了扇区密封的复制证明,需要等待交易确认,主要看 lotus-daemon.忽略不计

`[WaitSeed]`
强制等待150epoch大约75分钟 wait seed,需要等待这个将来的高度获取随机数seed作为种子,通过零知识证明来抽查P2密封的扇区内文件碎片是否真的存储了.

`[(ComputeProofFailed)]`
需要CPU执行一些hash运算 

`[Commiting(CommitFailed)]`
主要还是CPU+GPU执行运算,抽出对应文件碎片,计算出到默克尔根的文件路径,验证需要的文件中的值,gpu+cpu all core,期望时间在1.5H,一般不会超过2H,PS当然这里的时间有出入.根据最快的计算可能c1只要数十秒,c2需要25分钟即可.不过就算1.5h也不是主要耗时操作.

`[CommitWait]`
等待,提交c2计算的根,以证明文件的确被存储着

`[Method:ProveCommitSector]`发送交易 需要等待交易确认

`[FinalizeSector(FinalizeFailed)]`
完成后会把seal中的磁盘擦除,写入storage,扇区密封结束

`[Proving]`
PoRep

4. lotus bench mark result:

| 时间 | 操作 | 换算 |
| --- | --- | --- |
| 封装 | 封装 | 封装 |
| 870097300267 | add | 0.2417H = 14M 30S |
| 19675090466708 | p1 | 5.4653H = 5H 28M |
| 2160057571490 | p2 | 0.6000H = 36M |
| 44283547951 | c1 | 0.0123H = 44S |
| 5573822383169 | c2 | 1.5483H = 1H 32M 53S |
| 校验 | 校验 | 校验 |
| 28487520 | verify | 0.03S |
| 19463753783027 | unseal | 5.4065H = 5H 24M 24S |
| 出块 | 出块 | 出块 |
| 155197 | candidate | 几乎为0 |
| 4285092397 | winning proof hot | 4.28S |
| 8356540927 | winning proof cold | 8.35S |
| 20039908 | winning post hot | 0.02S |
| 57527449 | winning post cold | 0.05S |
| 时空证明 | 时空证明 | 时空证明 |
| 973861248741 | window proof hot | 0.2705H	= 16M 14S |
| 1077144420908 | window proof cold | 0.2992H = 18M |
| 63166446 | window post hot | 0.06S |
| 6744654407 | window post cold | 6.74S |

