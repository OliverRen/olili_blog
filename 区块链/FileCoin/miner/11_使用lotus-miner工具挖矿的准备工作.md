---
title: 11_使用lotus-miner工具挖矿的准备工作
tags: 
---

**Lotus-miner官方工具挖矿**

1. 前提是按照前述文件成功安装了`Lotus`套件,并且使用`lotus daemon`已经完成了`Filecoin`网络的同步,你可以使用`lotus sync wait`中断等待确认是否已经完成

2. 在中国必须要设置好 go的代理参数和 ipfs代理网关

3. 如果`lotus daemon`和`lotus miner`不是在同一台机器,则需要使用`json web rpc`的方式创建有`admin`权限的`FULLNODE_API_INFO`的`token`在`lotus miner`这里使用

	`export FULLNODE_API_INFO=<api_token>:/ip4/<lotus_daemon_ip>/tcp/<lotus_daemon_port>/http`

4. 设置性能参数环境变量,切记 systemd 服务要单独在服务配置文件中设置
	
	``` shell
	# See https://github.com/Filecoin-project/bellman
	# CPU使用
	export BELLMAN_CPU_UTILIZATION=0.875

	# See https://github.com/Filecoin-project/rust-fil-proofs/
	# 加内存来获得更快的封装速度
	export FIL_PROOFS_MAXIMIZE_CACHING=1 # More speed at RAM cost (1x sector-size of RAM - 32 GB).使用更多的内存来加快预提交的速度
	# P2阶段的GPU加速
	export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 # precommit 2 GPU acceleration
	export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
	
	# 需要结合CPU亲和来使用相邻的4个Core加快P1中单线程的执行
	FIL_PROOFS_USE_MULTICORE_SDR=1
	```

5. 如果内存过少,则需要添加swap分区,详细可以参看 linux使用文档中的添加swap
	
	``` shell
	sudo fallocate -l 256G /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	# show current swap spaces and take note of the current highest priority
	swapon --show
	# append the following line to /etc/fstab (ensure highest priority) and then reboot
	# /swapfile swap swap pri=50 0 0
	sudo reboot
	# check a 256GB swap file is automatically mounted and has the highest priority
	swapon --show
	```

6. 查看 lotus-miner显示支持的GPU和benchmark

	[权威列表](https://github.com/Filecoin-project/bellman#supported--tested-cards)

	[使用自定义的GPU](https://docs.Filecoin.io/mine/lotus/gpus/#enabling-a-custom-gpu)

	[bellperson](https://github.com/Filecoin-project/bellman#supported--tested-cards)

	添加环境变量
	`export BELLMAN_CUSTOM_GPU="GeForce RTX 3080:8704"`

	测试
	`./lotus-bench sealing --sector-size=2KiB`
		
	服务器中有多个GPU，选择特定的GPU运行程序可在程序运行命令前使用：CUDA_VISIBLE_DEVICES=0命令。0为服务器中的GPU编号，可以为0, 1, 2, 3等，表明对程序可见的GPU编号。可以和CPU亲和一样,用逗号隔开	

6. 执行挖矿必须要有 BLS 钱包,即 t3 开头的钱包,默认的创建的 spec256k1 是 t1开头的.

	`lotus wallet new bls`

7. 下载 Filecoin矿工证明参数,32GB和64GB时不一样的,强烈建议通过环境变量来设置一个位置保存他们
	
	- filecoin-proof-parameters 默认路径 `/var/tmp/filecoin-proof-parameters/` , `export FIL_PROOFS_PARAMETER_CACHE=/path/to/folder/in/fast/disk`
	- filecoin-parents 默认路径 `/var/tmp/filecoin-parents/` , `export FIL_PROOFS_PARENT_CACHE=/path/to/folder/in/fast/disk2`
	- seal sector的tmp目录 `export TMPDIR=/disk3`

	``` shell
	# 预先下载封装需要使用到的参数
	# Use sectors supported by the Filecoin network that the miner will join and use.
	# lotus-miner fetch-params <sector-size>
	lotus-miner fetch-params 32GiB
	lotus-miner fetch-params 64GiB
	```
	
8. 设置环境变量,类似的如果通过systemctl来启动服务的,也需要再 lotus-miner.service.d 下的override文件进行配置

	``` shell
	export LOTUS_MINER_PATH=/path/to/miner/config/storage
	export LOTUS_PATH=/path/to/lotus/node/folder       # when using a local node
	export BELLMAN_CPU_UTILIZATION=0.875
	export FIL_PROOFS_MAXIMIZE_CACHING=1
	export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1        # when having GPU
	export FIL_PROOFS_USE_GPU_TREE_BUILDER=1         # when having GPU
	export FIL_PROOFS_PARAMETER_CACHE=/fast/disk/folder  # > 100GiB!
	export FIL_PROOFS_PARENT_CACHE=/fast/disk/folder2   # > 50GiB!
	export TMPDIR=/fast/disk/folder3               # Used when sealing.
	```
	
9. 矿工初始化,使用 `--no-local-storage` 可以使得我们之后可以配置特定的存储位置而不是直接执行.配置文件一般是在 `~/.lotusminer/` 或 `$LOTUS_MINER_PATH` 下. 关于矿工的钱包账户之间的区别请参看 使用官方Lotus-miner执行挖矿的常见问题中的矿工钱包. 注意该命令需要owner发送消息需要代币

	`lotus-miner init --owner=<bls address>  --worker=<other_address> --no-local-storage`
	
10. 需要一个公网ip来进行矿工设置.编辑 `$LOTUS_MINER_PATH/config.toml`, 其默认值是 `~/.lotusminer/config.toml`

	``` toml
	[libp2p]
	  ListenAddresses = ["/ip4/0.0.0.0/tcp/24001"] # choose a fixed port
	  AnnounceAddresses = ["/ip4/<YOUR_PUBLIC_IP_ADDRESS>/tcp/24001"] # important!
	```

11. 当的确可以访问该公网ip时,启动 lotus-miner
	
	`lotus-miner run` 或 `systemctl start lotus-miner`

12. 公布矿工地址 
	
	`lotus-miner actor set-addrs /ip4/<YOUR_PUBLIC_IP_ADDRESS>/tcp/24001`
	
13. 连接性问题

	- 使用命令查看节点的nat状态 `lotus-miner net reachability`,这需要你连接到足够的peers才能正确反馈,正常的值是 Public
	- 检查连接的对等点 peers ,使用命令 `lotus-miner net peers` , 如果过少,可以使用命令 `lotus-miner net connect <address1> <address2>...` 手动连接 [引导节点](https://github.com/filecoin-project/lotus/blob/master/build/bootstrap/bootstrappers.pi) 确保你们实在相同的网络分支中

14. 其他步骤 这里请看下文 ==进阶设置==

	- 配置自定义存储的布局,这要求一开始使用 --no-local-storage
	- 编辑 lotus-miner 的配置
	- 了解什么是关机和重启矿机的好时机
	- 发现或者说通过运行基准测试来得到密封一个sector的时间 ExpectedSealDuration
	- 配置额外的worker来提高miner的密封sector的能力
	- 为 windowPost设置单独的账户地址.
