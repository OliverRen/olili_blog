---
title: 31_Lotus常用命令集合
tags: 
---

[toc]

# 查看链上数据

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

# 钱包操作