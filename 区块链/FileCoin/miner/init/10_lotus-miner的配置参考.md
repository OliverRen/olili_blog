---
title: 10_lotus-miner的配置参考
tags: 
---

**Lotus Miner 配置参考**

Lotus Miner配置是在初始化`init`步骤之后的,其位置是 `$LOTUS_MINER_PATH/config.toml`, 其默认值是 `~/.lotusminer/config.toml`. 必须重新启动矿机即miner服务才可以使配置生效.

- API部分 主要使为了worker来使用的,默认使绑定在本地环路接口,如果是多机器则需要配置到使用的网络接口
- Libp2p部分 这部分是配置miner嵌入的 Libp2p 节点的,需要配置成miner的公共ip和固定的端口
- PubSub部分用于在网络中分发消息
- Deal Making部分 用于控制存储和检索交易.注意 `ExpectedSealDuration` 应该等于 `(TIME_TO_SEAL_A_SECTOR + WaitDealsDelay) * 1.5`
- Sealing部分 即密封部分配置
- Storage部分 即存储部分,控制矿工是否可以执行某些密封行为
- Fees费用部分

**修改miner的gas费率**

``` lotusminer/config.toml
[Fees]
MaxPreCommitGasFee = "0.05 FIL"
MaxCommitGasFee = "0.05 FIL"
MaxWindowPoStGasFee = "50 FIL"
```

