---
title: 16_lotus-worker的使用
tags: 
---

**Lotus miner seal worker**

`lotus miner`本身可以执行密封过程的所有阶段,他本身就可以作为一个完整功能的`worker`

但是 P1阶段的CPU的密集型任务会影响到后面的`winningPoSt`和`windowPoSt`的提交,主miner只专注于执行 WindowPoSt 和 WinningPoSt

所以我们可以创建管道让 worker来负责密封的部分阶段.

这部分是关乎于压榨机器性能最重要的部分,涉及到了filecoin的证明系统 [SDR算法](https://github.com/filecoin-project/rust-fil-proofs/) .

一个 worker 最多运行两个任务,每个任务作为一个插槽成为一个 window 窗口. 

最终数据取决于可用的cpu核心数和GPU的数量

比如 有多核CPU 和 一个 GPU的机器上:

*   2个_PreCommit1_任务（每个任务使用1个核心） 
*   1个_PreCommit2_任务（使用所有可用核心 只有1个GPU）
*   1个_提交_任务（使用所有可用的内核或使用GPU,C1很短,主要是C2只有1个GPU）
*   2个_解封_任务（每个使用1个核心）

当然实际测试中并不一定总是需要128GiB内存那么多,当然多总是好的. 

使用命令 `lotus-worker run <flags>` 启动worker

需要注意的是不同的 worker 与 miner 要设置不同的 `$LOTUS_WORKER_PATH` 和 `$TMPDIR` 的环境变量

如果一台主机上运行多个 worker ,需要通过 `--listen`指定不同的监听端口

启动`lotus-worker`可选的工作flags参数如下

```
   --addpiece		enable addpiece (default: true)
   --precommit1		enable precommit1 (32G sectors: 1 core, 128GiB Memory) (default: true)
   --unseal			enable unsealing (32G sectors: 1 core, 128GiB Memory) (default: true)
   --precommit2		enable precommit2 (32G sectors: all cores, 96GiB Memory) (default: true)
   --commit			enable commit (32G sectors: all cores or GPUs, 128GiB Memory + 64GiB swap) (default: true)
```

**lotus-miner的有关配置**

切记Lotus Miner 配置中的 `MaxSealingSectors`,`MaxSealingSectorsForDeals`控制了可以同时 seal 的 sector 数量. `Storage`配置中如果要将工作全部分配给worker,则需要将对应的设置为false

```
[Storage]
  AllowAddPiece = true
  AllowPreCommit1 = true
  AllowPreCommit2 = true
  AllowCommit = true
  AllowUnseal = true
```

**重启 worker**

可以随时重新启动 Lotus Seal Worker,但是他们如果正在执行密封的某一个步骤的话,重新后需要从最后一个检查点重新开始.而且如果是在 C2阶段最多只有3次尝试的机会.

**更改worker的存储位置**

- 停止 worker
- 迁移数据
- 对 $LOTUS_WORKER_PATH进行设置
- 重新启动 worker

需要注意的是不同线程的 worker 之间的数据(同一个阶段)是不支持转移和共享的.