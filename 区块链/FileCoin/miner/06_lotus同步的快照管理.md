---
title: 06_lotus同步的快照管理
tags: 
---

**lotus同步的快照管理**

1. UPDATE

	这里通过文件导入区块链快照的部分进行了更新 [doc 通过lotus 同步区块链](https://docs.filecoin.io/get-started/lotus/chain/#syncing)

2. 全节点 FullNode 的镜像导入

	`lotus daemon --import-chain https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/complete_chain_with_finality_stateroots_latest.car`

3. 快照镜像导入
	
	如果不是区块链的浏览器,我们可以使用一个可信的状态快照来进行快速导入,这里不是全部数据,这个文件大概都是7GB大小,可以很快开始工作,并且是定时可以重置lotus节点的,国内由于网络问题,建议下载好后进行导入,否则会花费非常多的时间
	
	`lotus daemon --import-snapshot https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car`
		
4. 区块数据的快照 snapshot 管理

	- `lotus chain export <file>` 导出区块链
	- `lotus daemon --import-snapshot <file>` 无链校对导入区块链
	- `lotus daemon --import-chain <filename>` 从链上校对导入区块链
	- `lotus export --skip-old-msgs --recent-stateroots=900 <filename>` 创建修剪过的快照可以如下方式创建

5. 缩减目前的lotus已经同步的链数据,其实就是停掉daemon后,把现在的数据全部删除.然后使用可信快照来进行快速导入,上面也提到了这个7GB的快照是可以反复重置lotus节点的
	
	```
	lotus daemon stop;
	rm -rf ~/.lotus/datastore/chain/*
	lotus daemon --import-snapshot https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car
	```