---
title: 33_使用lotus-shed
---

[toc]

lotus-shed 是一个强大的工具集合,很多时候可以代替在线上执行 lotus,lotus-miner 的相关操作,即直接与链交互的操作很多都可以使用 lotus-shed

lotus-shed 工具依赖 FullNode Api, 所以我们先要把 LOTUS_PATH 或者 FULLNODE_API_INFO 环境变量导出来

1. 创建 miner 账号

`lotus-shed miner create <sender> <owner> <worker> <sector-size>`

2. miner 提现收益

`lotus-shed actor withdraw --actor=<miner-addr> <amount>`

3. 终止错误扇区

`lotus-shed sectors terminate --actor=<miner-addr> --really-do-it <sector-number>`

4. 更改owner

```
# 1. 先用旧的 owner 私钥签名消息，发起更换 owner 请求
lotus-shed actor set-owner --really-do-it --actor=<miner-id> <new-address> <old-address>
# 2. 再用新的 owner 私钥签名消息，确认更换操作
lotus-shed actor set-owner --really-do-it --actor=<miner-id> <new-address> <new-address>
```

5. 更改 worker

```
# 1. 提交一笔更换 Worker 地址提案的消息
lotus-shed actor propose-change-worker --really-do-it --actor=<miner-id> <new-address>
# 2. 经过一定的区块高度在会后，再发一起一笔确认提案的消息
lotus-shed actor confirm-change-worker --really-do-it --actor=<miner-id> <new-address>
```

6. 更改 control 地址

`lotus-shed actor control set --really-do-it=true <address>`