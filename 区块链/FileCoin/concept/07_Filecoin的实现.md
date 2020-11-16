---
title: Filecoin的实现
tags: 
---

#### Filecoin实现方案

Filecoin测试网目前在一个Filecoin实现方案lotus（https://github.com/filecoin-project/lotus/）上运行，网络本身与具体的实施方案无关。

在接下来的几个月中，包括go-filecoin在内的几个（目前已经有四套lotus、go-filecoin、forest以及fuhon 其中Forest（由ChainSafe在Rust中实现）和fuhon（由Soramitsu在C ++中实现））实施方案，将能够在Filecoin测试网上进行互操作。而目前我们测试网都是基于lotus实现，官方为什么实现四套实施方案，主要基于安全考虑（考虑到项目的难度、进度和可控性，具有可在同一网络上互操作的多个软件实现，可以降低一个实现中的重大错误抬高头并破坏整个网络的风险。）

您可以在GitHub上的各个实现中跟踪每个实现的进度：

*   go-filecoin（用Go编写）
*   lotus（用Go语言编写）
*   fuhon（用C ++编写）
*   forest（用Rust编写）

说明：Filecoin协议尚未100%稳定和完成，因此测试网并非是稳定的网络。测试网的目的是让我们发现并且修复bug，测试网启动至今已经被多次攻击，比如内存溢出漏洞、空指针攻击等方式，官方也在根据线上的问题，快速修正问题。测试网网络已经多次被重置。

#### Lotus实现

Lotus/Filecoin项目由三部分组成：

1. Lotus Blockchain部分 – 实现区块链相关逻辑（共识算法，P2P，区块管理，虚拟机等等）。注意的是，Lotus的区块链相关的数据存储在IPFS之上。go语言实现。
2. RUST-FIL-PROOF部分 – 实现Sector的存储以及证明电路。也就是FPS（Filecoin Proving Subsystem）。**Rust语言实现。**
3. Bellman部分 – 零知识证明(zk-SNARK)的证明系统，主要是基于BLS12_381椭圆曲线上，实现了Groth16的零知识证明系统。Lotus官方推荐采用Nvidia的2080ti显卡，也主要做这部分的性能加速。**Rust语言实现。**

Filecoin的存储封印（Sealing）和证明（PoRep & PoSt）是用rust语言编写，而且是单独成篇的，也就是说可以单独拿出来玩。

filecoin复制游戏程序的源码可以到以下地址下载：
https://github.com/filecoin-project/replication-game

如果你不想下载源码，直接下载可执行代码的话，直接到这里：
https://github.com/filecoin-project/rust-fil-proofs/releases