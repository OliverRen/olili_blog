---
title: 20_lotus-miner生命周期与安全的重启进程
tags: 
---

[toc]

LotusMiner是一个非常关键的角色,要重新启动或者关闭它需要考虑以下几点

- 矿工机计划离线多久
- 矿工机证明期限的存在和分布
- 当前正在进行的检索支付通道的存在
- 正在进行的密封操作

#### 减少离线时间

考虑到矿工是需要不断的向网络发送PoSt时空证明的,所以 lotusminer 角色应该尽可能的少的处于离线状态

- 重新启动 lotusminer 之前,确保整个lotus组件是完全ok的.升级编译完成
- 确保证明参数已经下载到高速的ssd上,这是通过 $FIL_PROOFS_PARAMETER_CACHE 来配置的

#### 确保最大的 proving dealine之前的post已经发出

因为每30分钟一次的PoSt的缺失会导致算力的损失,所以需要根据 `lotus-miner proving info`来查看

如果一个deadline开始的高度在当前区块之前,说明正在做post,这时候不应该进行重启

比如下表中, `Deadline Open`实在 454高度,当前epoch是500.说明还有未证明的post在等待发送,这时候不能重启.

```
$ lotus-miner proving info

Miner: t01001
Current Epoch:           500
Proving Period Boundary: 154
Proving Period Start:    154 (2h53m0s ago)
Next Period Start:       3034 (in 21h7m0s)
Faults:      768 (100.00%)
Recovering:  768
Deadline Index:       5
Deadline Sectors:     0
Deadline Open:        454 (23m0s ago)
Deadline Close:       514 (in 7m0s)
Deadline Challenge:   434 (33m0s ago)
Deadline FaultCutoff: 384 (58m0s ago)
```

下表显示了当前区块497.但是下一个证明是658,如果区块中有故障,那么只有大约45分钟,在这之前有 `Declare faults`的机会,这叫做 `Deadline FaultCutoff`.

如果miner没有错误,那么大约有1个小时,需要保留一段时间给运算的开始,表上显示有 658-497高度可以离线.

```
$ lotus-miner proving info

Miner: t01000
Current Epoch:           497
Proving Period Boundary: 658
Proving Period Start:    658 (in 1h20m30s)
Next Period Start:       3538 (in 25h20m30s)
Faults:      0 (0.00%)
Recovering:  0
Deadline Index:       0
Deadline Sectors:     768
Deadline Open:        658 (in 1h20m30s)
Deadline Close:       718 (in 1h50m30s)
Deadline Challenge:   638 (in 1h10m30s)
Deadline FaultCutoff: 588 (in 45m30s)
```

上述 `lotus-miner proving info` 只能看到当前对下一个 deadline 之间的数据

你也可以使用 `$ lotus-miner proving deadlines` 来查看将来多个 deadline 之间 (24小时内)的数据

#### 查看当前正在进行交易和数据传输

```
# 存储交易
lotus-miner storage-deals list
# 检索交易
lotus-miner retrieval-deals list
# 数据传输
lotus-miner data-transfers list
```

要重启前需要禁用交易进入,防止出现交易中断

```
# 禁用在线和离线的存储交易
lotus-miner storage-deals selection reject --online --offline
# 禁用在线和离线的检索交易
lotus-miner retrieval-deals selection reject --online --offline
```

需要注意的是这其实会覆盖 lotusminer 的 config 中的配置

当矿工恢复启动后或通过配置文件修改

```
# 恢复存储交易
lotus-miner storage-deals selection reset
# 恢复检索交易
lotus-miner retrieval-deals selection reset
```

#### 检测当前正在封装的sector

`lotus-miner sectors list`

当然直接重启也是可以的,但是sector会恢复到正在进行的阶段之前的检查点,大概就是 P1,P2,C会重新执行.

TIPS:重启worker,和上面一样,重启worker也会将正在进行的工作恢复到之前的检查点,P1会重新封装,P2最多只有3次重试机会