---
title: 09_lotus套件升级
tags: 
---

首先要明确官方软件升级的主要部分,只需要更新daemon,或只需要更新miner

所有需要停机升级的时候都需要参考 `安全的升级和重启miner` 部分,否则轻则造成当天算力下降,重则会导致消减.

**Lotus套件升级**

其实就相当于`git pull`后重新安装,但很多编译和参数本地直接就有,更新时相当快的,一般2-3分钟即可

- 关闭所有的 seal miner 和 worker
- 关闭 lotus daemon
- git pull
- 执行安装
	
	``` shell
	# SHA指令集特有
	export RUSTFLAGS="-C target-cpu=native -g"
	export FFI_BUILD_FROM_SOURCE=1
	
	git pull
	git checkout <tag_or_branch>		
	git submodule update
	make clean deps all
	make install

	#安装服务 可以简单的 make install-all-services
	make install-daemon-service
	make install-chainwatch-service
	make install-miner-service
	# 其他有用的工具包括 `lotus-stats`,`lotus-pcr`,`lotus-health`,`lotus-shed`
	
	# 建议执行的安装是
	make install install-all-services lotus-shed
	```
	
- 启动 daemon `systemctl start lotus-daemon`	
- 启动 miner `systemctl start lotus-miner`
- 启动 worker `systemctl start lotus-worker`

如果你在测试环境,如果你需要重置所有本地数据,那么需要备份的包括 lotus钱包,node数据和miner配置,然后删除掉 $LOTUS_PATH , $LOTUS_MINER_PATH , $LOTUS_WORKER_PATH

**安全的升级和重启miner**

需要考虑的因素包括: 

- 需要离线多久
- proving时间期限的分布如何
- 是否存在交易和检索
- 是否有正在进行的密封操作

1. 重启前,建议对lotus程序进行升级,同时下载更新挖矿参数到ssd上 $FIL_PROOFS_PARAMETER_CACHE
2. 必须确认有时间窗口可以进行重启,使用命令 `lotus-miner proving info` 确认 deadline open有对 current epoch的时间窗口,也可以使用 `lotus-miner proving deadlines` 来确认将来24小时内的分布.
3. 检查交易 `lotus-miner storage-deals list`, `lotus-miner retrieval-deals list` , `lotus-miner data-transfers list` . 并暂时禁用交易 `lotus-miner storage-deals selection reject --online --offline` , `lotus-miner retrieval-deals selection reject --online --offline`. 当miner 重启完成后,需要使用以下命令恢复交易 `lotus-miner storage-deals selection reset`, `lotus-miner retrieval-deals selection reset`.
4. 检查当前正在进行的密封行为 `lotus-miner sectors list`
5. 