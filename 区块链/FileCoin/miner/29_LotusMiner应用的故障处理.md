---
title: 29_LotusMiner应用的故障处理
tags: 
---

[toc]

- Error: Can't acquire bellman.lock

`mining block failed: computing election proof: github.com/filecoin-project/lotus/miner.(*Miner).mineOne`

无法获取到锁,这是在 `TMPDIR` 下的文件

- Error: Failed to get api endpoint

`lotus-miner info WARN  main  lotus-storage-miner/main.go:73  failed to get api endpoint: (/Users/user/.lotusminer) %!w(*errors.errorString=&{API not running (no endpoint)}):`

这说明 `lotus daemon` 还没有准备好

- Error: Your computer may not be fast enough

`CAUTION: block production took longer than the block delay. Your computer may not be fast enough to keep up`

机器不够好

- Error: No space left on device

如果看到这种情况，则意味着扇区承诺写入了太多的数据，$TMPDIR这些数据默认是根分区（这在Linux安装程序中很常见）。通常，您的根分区不会获得最大的存储分区，因此您需要将环境变量更改为其他变量。