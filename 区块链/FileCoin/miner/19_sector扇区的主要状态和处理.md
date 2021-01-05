---
title: 19_sector扇区的主要状态和处理
tags: 
---

**升级扇区**

升级抵押的扇区以存储与交易相关的实际数据 `lotus-miner sectors mark-for-upgrade <sector number>`

**故障扇区的处理原则**

在未上链之前如果可以通过手工恢复状态重新封装,则重新封装,实在不行再`remove`

如果已经上链,如果数据可以恢复,则通过第二天的`PoSt`恢复算力,如果不能则需要使用工具`terminate`

**处理手册**

扇区的状态可以通过`lotus-miner sectors status --log <x>`来查看

当扇区卡在封装前`deal`阶段,可以尝试使用`lotus-miner sectors seal <x>`手动封装扇区

当扇区卡在莫名其妙的状态后,可以使用强制修改扇区状态, `lotus-miner sectors update-state --really-do-it <x> state` 来恢复到这个步骤的第一个阶段

当扇区实在无法重新启动,可以使用`lotus-miner sectors remove <x>`来在本地移除他

如果扇区已经上链,但硬盘的确坏了不能恢复,需要编译工具`lotus-shed`,使用命令`lotus-shed sectors terminate <x>`来终结他,当然这会造成消减.

**扇区主要状态**

- ComputeProofFailed
- FinalizeFailed
- FaultReported
- FaultedFinal 我知道错了
- Removed 强制移除
- PreCommit1 重新来一次
- PreCommit2
- FinalizeSector
- WaitSeed
- PackingFailed
- RecoverDealIDs
- SealPreCommit1Failed
- PreCommitFailed
- CommitFailed
- Packing AddPiece状态
- PreCommitWait
- SubmitCommit
- Empty
- FailedUnrecoverable
- Faulty
- Committing 提交错误重新提交
- CommitWait
- Proving
- SealPreCommit2Failed
- Removing
- WaitDeals
- DealsExpired
- RemoveFailed
- PreCommitting

```
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
				|   GetTicket
				|   |   ^
				|   v   |
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

```
	Empty          SectorState = "Empty"
	WaitDeals      SectorState = "WaitDeals"     // waiting for more pieces (deals) to be added to the sector
	Packing        SectorState = "Packing"       // sector not in sealStore, and not on chain
	GetTicket      SectorState = "GetTicket"     // generate ticket
	PreCommit1     SectorState = "PreCommit1"    // do PreCommit1
	PreCommit2     SectorState = "PreCommit2"    // do PreCommit2
	PreCommitting  SectorState = "PreCommitting" // on chain pre-commit
	PreCommitWait  SectorState = "PreCommitWait" // waiting for precommit to land on chain
	WaitSeed       SectorState = "WaitSeed"      // waiting for seed
	Committing     SectorState = "Committing"    // compute PoRep
	SubmitCommit   SectorState = "SubmitCommit"  // send commit message to the chain
	CommitWait     SectorState = "CommitWait"    // wait for the commit message to land on chain
	FinalizeSector SectorState = "FinalizeSector"
	Proving        SectorState = "Proving"
```

**扇区封装流程说明**

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

**扇区状态处理原则**

- P1出错重新运行P1
- P2出错或卡住重新运行P2
- PreCommitFailed查看 on-chain-info,确认完成P2的重新运行 PreCommitting
- CommitFailed重新运行 Committing
- FinalizeFailed 重新运行 FinalizeSector
- 出现 "normal shutdown of state machine",等重启miner