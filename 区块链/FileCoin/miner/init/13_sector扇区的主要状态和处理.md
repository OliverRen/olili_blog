---
title: 13_sector扇区的主要状态和处理
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

