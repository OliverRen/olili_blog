---
title: 31_Lotus常用命令集合
tags: 
---

[toc]

### 查看链上数据

```
# 1. 查看 chain head
lotusdaemon chain head
# 2. 查看指定的消息
lotusdaemon chain getmessage <msg-cid>
# 3. 查看指定区块内容
lotusdaemon chain getblock <block-cid>
# 4. 查看链上最新的 30 个区块
lotusdaemon chain list --count=30
# 5. 解码 message 参数
lotusdaemon chain decode params <to-addr> <method> <params>
# e.g
lotusdaemon chain decode params t01003 16 gUkAiscjBInoAAA=
{
  "AmountRequested": "10000000000000000000"
}
```

### 钱包操作

```
# 1. 创建钱包
lotusdaemon wallet new bls
lotusdaemon wallet new secp256k1
# 2. 查看钱包列表
lotusdaemon wallet list
# 3. 查看余额
lotusdaemon wallet balance <address>
# 4. 导出钱包私钥
lotusdaemon wallet export <address>
# 5. 导入钱包私钥
lotusdaemon wallet import # 然后在交互命令输入私钥
# 6. 使用指定的钱包签名消息
lotusdaemon wallet sign <address> <hex-message> # 消息必须是 16 进制编码的
# 7. 删除钱包
lotusdaemon wallet delete <address>

# 转账
lotusdaemon send <address> <amount>
# e.g 转 100 个 FIL 到 f3xxxx 钱包
lotusdaemon send f3xxxx 100 
# 从指定钱包转账
lotusdaemon send --from=<f3yyyy> f3xxxx 100
```

### 节点快照操作

```
# 1. 导出最小区块快照
lotusdaemon chain export --skip-old-msgs=true --recent-stateroots=900 lotus_chain_minimal.car
# 2. 导入快照
lotusdaemon daemon --import-snapshot=lotus_chain_minimal.car --halt-after-import=true
```

### 消息池操作

```
# 1. 查看消息池待打包消息
lotusdaemon mpool pending 
lotusdaemon mpool pending --local # 只查看本地消息
# 2. 根据条件过滤查找
lotusdaemon mpool find --from=<from-address> --method=<method> --to=<to-address> 
# 3. 替换消息（提高手续费，自动设置 gas 费）
lotusdaemon mpool replace --auto <cid>
# 4. 替换消息，手动指定 gas 费
lotusdaemon mpool replace --gas-feecap=xxxx --gas-premium=xxx --gas-limit=xxxx <cid>
```

### 网络管理

```
# 1. 获取当前 daemon p2p 连接地址
lotusdaemon net listen
# 2. 查看当前 daemon 连接的所有节点
lotusdaemon net peers
# 3. 打印当前节点连接 ID
lotusdaemon net id
# 4. 通过 peerId 查找连接信息
lotusdaemon net findpeer <peer-id>
# 5. 查看 p2p 节点评分(通常分数越高的节点越稳定)
lotusdaemon net scores
12D3KooWMFnHUpW4rQkAe8e1yN4kVjecNouoPvYJ4k1ueUE4SEAo, 36.650167
```

### 订单操作

```
# 1. 导入数据分片
lotusdaemon client import <file>
# 2. 查询所有头部 Miner 存储订单报价
lotusdaemon client list-asks
#   查看指定的 Miner 存储订单报价
lotusdaemon client query-ask t01003
Ask: t01003
Price per GiB: 0.0000000005 FIL
Verified Price per GiB: 0.00000000005 FIL
Max Piece size: 512 MiB
Min Piece size: 256 B
# 3. 向指定的 Miner 提交存储订单
lotusdaemon client <cid> <miner> <price> <duration>
# e.g
lotusdaemon client deal bafk2bxxx t01003 0.000001FIL 518400
# 4. 客户查看订单状态
lotusdaemon client inspect-deal --proposal-cid=bafyxxx
# 5. miner 发布订单，开始密封
lotus-miner storage-deals pending-publish --publish-now
# 对于发布失败的订单，可以重新发布订单
lotus-miner storage-deals retry-publish <deal-cid>
# 6. miner 查看订单列表
lotus-miner storage-deals list
# 7. lotus client 查看订单列表
lotusdaemon client list-deals
# 列出正在传输的订单
lotusdaemon client list-transfers
```

### 扇区管理

```
# 1. 质押一个 CC 扇区
lotus-miner sectors pledge
# 2. 查看扇区列表
lotus-miner sectors list
# 3. 查看单个扇区的状态
lotus-miner sectors status <sector-id>
# 查看扇区详细状态日志
lotus-miner sectors status --log <sector-id> 
# 4. 删除扇区
lotus-miner sectors remove --really-do-it <sector-id>
# 5. 扇区续期 详细见扇区续期文档
lotus-miner sectors extend --new-expiration=<epoch> <sectorIds...>
# e.g
lotus-miner sectors extend --new-expiration=1595712 0 1 2 3...
# 6. 检查扇区的声明周期(查看即将过期的扇区)
lotus-miner sectors check-expire
# 7. 查看已过期的扇区
lotus-miner sectors expired
# 8. 删除所有过期的扇区
lotus-miner sectors expired --remove-expired=true
# 9. 手动开始某个扇区的密封流程
lotus-miner sectors seal <sector-id>
# 10. 批量提交 PreCommitSector/ProveSector 消息
lotus-miner sectors batching precommit --publish-now # PreCommitSector
lotus-miner sectors batching commit --publish-now # CommitSector
# 11. 更改扇区状态
lotus-miner sectors update-state --really-do-it <sector-id> <new-state>
```

### Snap-Up 操作 (CC sector=>deal sector)

```
# 1. 标记某个扇区进入 snap-up
lotus-miner sectors snap-up <sector-id>
# 2. 终止 snap-up 操作
lotus-miner sectors abort-upgrade --really-do-it <sector-id>
```