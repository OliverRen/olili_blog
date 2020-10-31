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






lotus bench mark result:
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

P1 5.5H cpu -> 6H
UN 5.5H cpu

P2 0.5H gpu -> 0.5H
C  1.5H gpu -> 1.5H

需要注意 wait seed阶段

32GB的sector在封装的时候需要 unseal*1+seal*1+cache*14.18=16.18*32GB的空间

提交的时候GPU至少需要8G的显存,当然大了更好 2070是最低的配置,2060是不能用来做C的.当然P2是可以的.

#### lotus daemon 需要1-2台做主备

随便来个intel cpu.随便来个128g内存.随便来个 ssd系统盘.随便来个 sata盘做存储c













{
[Empty]startCC begin 
[Packing]开始Packing即 addPiece cpu 1 core+disk 32g写入unseal 随机填充数据也需要一点时间不过忽略不计,注意会有等待deal的时间
[PreCommit1(SealPreCommit1Failed)]32g会被拆成32 Byte的小node,然后通过SDR算法计算出11层的merkel树 cpu 1 core+disk 15.18*32g写入cache 时间主要根据IO.不过不是线性,单线程5.5H,4线程也不过是6H
[PreCommit2(SealPreCommit2Failed)]主要是GPU运算进行压缩P1计算出的merkel树得到root根,这里需要计算8层, gpu+cpu all core+disk 16.18*32g写入seal 时间也差不多根据cpu+gpu,最快25min,最长35min
[PreCommitting(PreCommitFailed)]发送交易 Method:PreCommitSector 需要等待交易确认,主要看 lotus-daemon.忽略不计
[WaitSeed]强制等待150epoch大约75分钟 wait seed,需要等待这个将来的高度获取随机数seed作为种子
[(ComputeProofFailed)]需要CPU执行一些hash运算 
[Commiting(CommitFailed)]主要还是CPU+GPU执行运算,验证需要的文件中的值,gpu+cpu all core,期望时间在1.5H,一般不会超过2H
[CommitWait]等待,提交c2计算的根,以证明文件的确被存储着
发送交易 Method:ProveCommitSector 需要等待交易确认
[FinalizeSector(FinalizeFailed)]完成后会把seal中的磁盘擦除,写入storage
[Proving]PoRep
}



	/////
	// Now decide what to do next

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
	
	
	
	P1 6
3*4*14=168
P2 0.5=12
7*1*2*[12]=168
C 1.14=5.25
2*4*4*5.25=168