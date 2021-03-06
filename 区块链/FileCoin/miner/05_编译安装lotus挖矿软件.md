---
title: 05_编译安装lotus挖矿软件
tags: 
---

**编译安装lotus并同步区块**

1. 使用git克隆lotus库
	
	```
	git clone https://github.com/Filecoin-project/lotus.git
	
	git checkout <branch_or_tag>
	# 选择网络
	git checkout master # mainnet
	git checkout ntwk-calibration # calibration-net
	git checkout ntwk-nerpa # nerpa-net
	```
	
2. 对支持 SHA 扩展指令的cpu使用环境变量标记 rust FFI [Native Filecoin FFI section](https://docs.Filecoin.io/get-started/lotus/installation/#native-Filecoin-ffi)
	
	`export RUSTFLAGS="-C target-cpu=native -g"`
	
	`export FFI_BUILD_FROM_SOURCE=1`
	
	所以如果做编译二进制要区分这两个环境变量即可,仅编译时需要,需要注意的是官方明确有说明,使用这两个编译选项需要单独在本地编译,不会产生可移植二进制文件.	
	
3. 编译安装lotus
	
	```
	git submodule update
	make clean deps all
	
	make install

	# 安装服务 可以简单的 make install-all-services
	make install-daemon-service
	make install-chainwatch-service
	make install-miner-service
	# 其他有用的工具包括 `lotus-stats`,`lotus-pcr`,`lotus-health`,`lotus-shed`
	
	# 建议执行的安装是
	make install install-all-services lotus-shed
	```
	
4. 查看可执行文件 `lotus`	,`lotus-miner`	,`lotus-worker`	应该在 `/usr/local/bin` 下
5. 启动 lotus的守护进程 ,或者通过命令创建 `systemd service`来同步区块

	`lotus daemon`

6. 运行daemon后开始同步区块,可以使用以下命令来查看同步情况.

	`lotus sync status` ,  `lotus sync wait`