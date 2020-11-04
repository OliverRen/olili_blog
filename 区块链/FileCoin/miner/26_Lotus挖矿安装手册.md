---
title: Lotus挖矿安装手册
tags: 小书匠语法
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

* [准备工作](#%E5%87%86%E5%A4%87%E5%B7%A5%E4%BD%9C)
* [编译安装lotus挖矿软件](#%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85lotus%E6%8C%96%E7%9F%BF%E8%BD%AF%E4%BB%B6)
* [Lotus的配置文件和环境变量](#lotus%E7%9A%84%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%92%8C%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F)
* [Lotus\-miner 官方工具挖矿](#lotus-miner-%E5%AE%98%E6%96%B9%E5%B7%A5%E5%85%B7%E6%8C%96%E7%9F%BF)
* [Lotus\-miner 官方工具挖矿进阶设置](#lotus-miner-%E5%AE%98%E6%96%B9%E5%B7%A5%E5%85%B7%E6%8C%96%E7%9F%BF%E8%BF%9B%E9%98%B6%E8%AE%BE%E7%BD%AE)
  * [防火墙有可能要开启](#%E9%98%B2%E7%81%AB%E5%A2%99%E6%9C%89%E5%8F%AF%E8%83%BD%E8%A6%81%E5%BC%80%E5%90%AF)
  * [矿工自定义存储布局](#%E7%9F%BF%E5%B7%A5%E8%87%AA%E5%AE%9A%E4%B9%89%E5%AD%98%E5%82%A8%E5%B8%83%E5%B1%80)
  * [跑 benchmark 来得知机器封装一个块的时间](#%E8%B7%91-benchmark-%E6%9D%A5%E5%BE%97%E7%9F%A5%E6%9C%BA%E5%99%A8%E5%B0%81%E8%A3%85%E4%B8%80%E4%B8%AA%E5%9D%97%E7%9A%84%E6%97%B6%E9%97%B4)
  * [矿工钱包,分开 owner 地址和 worker 地址,为 windowPoSt设置单独的 control 地址\.](#%E7%9F%BF%E5%B7%A5%E9%92%B1%E5%8C%85%E5%88%86%E5%BC%80-owner-%E5%9C%B0%E5%9D%80%E5%92%8C-worker-%E5%9C%B0%E5%9D%80%E4%B8%BA-windowpost%E8%AE%BE%E7%BD%AE%E5%8D%95%E7%8B%AC%E7%9A%84-control-%E5%9C%B0%E5%9D%80)
  * [Lotus Miner 配置参考](#lotus-miner-%E9%85%8D%E7%BD%AE%E5%8F%82%E8%80%83)
  * [Lotus套件升级](#lotus%E5%A5%97%E4%BB%B6%E5%8D%87%E7%BA%A7)
  * [安全的升级和重启miner](#%E5%AE%89%E5%85%A8%E7%9A%84%E5%8D%87%E7%BA%A7%E5%92%8C%E9%87%8D%E5%90%AFminer)
  * [重启 worker](#%E9%87%8D%E5%90%AF-worker)
  * [更改存储的位置](#%E6%9B%B4%E6%94%B9%E5%AD%98%E5%82%A8%E7%9A%84%E4%BD%8D%E7%BD%AE)
  * [更改worker的存储位置](#%E6%9B%B4%E6%94%B9worker%E7%9A%84%E5%AD%98%E5%82%A8%E4%BD%8D%E7%BD%AE)
* [Lotus mine 抵押扇区 及开始封装算力](#lotus-mine-%E6%8A%B5%E6%8A%BC%E6%89%87%E5%8C%BA-%E5%8F%8A%E5%BC%80%E5%A7%8B%E5%B0%81%E8%A3%85%E7%AE%97%E5%8A%9B)
* [Lotus miner seal worker](#lotus-miner-seal-worker)
* [同时运行 miner 和 worker的CPU分配](#%E5%90%8C%E6%97%B6%E8%BF%90%E8%A1%8C-miner-%E5%92%8C-worker%E7%9A%84cpu%E5%88%86%E9%85%8D)
* [Lotus miner 故障排除](#lotus-miner-%E6%95%85%E9%9A%9C%E6%8E%92%E9%99%A4)
* [Lotus miner 管理交易](#lotus-miner-%E7%AE%A1%E7%90%86%E4%BA%A4%E6%98%93)

本文初次编写为参与 SpaceRace,后在主网上线后做过更新并且删除了 SR 阶段特有的内容

version 2020-11-4

网络信息 [Network Info](https://network.Filecoin.io)

删除测试网络的水龙地址 主网已经没有水龙头了

#### 准备工作

1. APT源更新为网易或阿里云
2. 安装编译工具等,建议使用 

```
sudo apt-get install aptitude
sudo aptitude install XXX

sudo apt update
sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang llvm libhwloc-dev -y

sudo apt upgrade -y
```

3. 设置git代理,如果有代理的话
	
	```
	git config --gloabl http.proxy=http://xxx:1080
	git config --global https.proxy=http://xxx:1080
	
	git config --global --unset http.proxy
	git config --global --unset https.proxy
	```
4. lotus对rust得依赖,需要 cargo 和 rustc 	
	
	`snap install rustup` or
	`rustup install stable` or
	`rustup default stable`

5. cargo配置代理 或配置代理
	
	cargo在编译时需要下载,在 `/home/.cargo`创建config文件,其实使用了sudo会在 /root下,cargo在编译的时候也需要下载,config文件中可以指定代理项,或者也可以直接使用国内镜像的方式
	
	``` cargo.config
	[http]
	proxy = "172.16.0.25:1081"
	[https]
	proxy = "172.16.0.25:1081"
	```	

	``` shell
	# 安环境变量 设置环境变量 RUSTUP_DIST_SERVER(用于更新 toolchain)
	export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
	以及 RUSTUP_UPDATE_ROOT(用于更新 rustup)
	export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
	
	cargo镜像配置,在/home/.cargo下的config文件中配置如下内容
	[source.crates-io]
	registry = "https://github.com/rust-lang/crates.io-index"
	# 指定镜像 下面任选其一
	replace-with = 'sjtu'
	# 清华大学
	[source.tuna]
	registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
	# 中国科学技术大学
	[source.ustc]
	registry = "git://mirrors.ustc.edu.cn/crates.io-index"
	# 上海交通大学
	[source.sjtu]
	registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"
	# rustcc社区
	[source.rustcc]
	registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
	```	

6. lotus 对 golang 得依赖,我们使用golang官网的下载解压方式,需要安装 go 1.14及以上的版本
7. GO的代理	

	```	shell
	go env -w GO111MODULE=on
	go env -w GOPROXY=https://goproxy.io,direct
	
	# 设置不走 proxy 的私有仓库,多个用逗号相隔(可选)
	go env -w GOPRIVATE=*.corp.example.com

	# 设置不走 proxy 的私有组织(可选)
	go env -w GOPRIVATE=example.com/org_name
	```	
8. lotus的中国ipfs代理 `IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"`,或者有良好的网络的时候,也可以使用本地的ipfs节点

------------------------------------------

#### 编译安装lotus挖矿软件

1. 使用git克隆lotus库
	
	`git clone https://github.com/Filecoin-project/lotus.git`
	
2. 对支持 SHA 扩展指令的cpu使用环境变量标记 rust FFI [Native Filecoin FFI section](https://docs.Filecoin.io/get-started/lotus/installation/#native-Filecoin-ffi)
	
	`export RUSTFLAGS="-C target-cpu=native -g"`
	`export FFI_BUILD_FROM_SOURCE=1`
	
3. 编译 lotus
	
	`sudo make clean deps all`
	`sudo make install`
	
4. 查看可执行文件 ==lotus==	,==lotus-miner==	,==lotus-worker==	应该在 ==/usr/local/bin== 下
5. 启动 lotus的守护进程  `lotus daemon`,或者通过命令创建 systemd service
	
	`sudo make install-daemon-service` </br>
	`sudo make install-chainwatch-service` </br>
	`sudo make install-miner-service`  </br>
	其他有用的工具包括 `lotus-stats`,`lotus-pcr`,`lotus-health`
	
6. 运行daemon后开始同步区块,可以使用 `lotus sync status` ,  `lotus sync wait` 来查看同步情况.

	这里通过文件导入区块链快照的部分进行了更新 [doc 通过lotus 同步区块链](https://docs.filecoin.io/get-started/lotus/chain/#syncing)

	如果不是区块链的浏览器,我们可以使用一个可信的状态快照来进行快速导入,这里不是全部数据,这个文件大概都是7GB大小,可以很快开始工作,并且是定时可以重置lotus节点的,国内由于网络问题,建议下载好后进行导入,否则会花费非常多的时间
	
	`lotus daemon --import-snapshot https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car`
	
	如果一定需要全节点,比如说要做一个区块链浏览器的,那么你只能通过全节点进行导入了
	
	`lotus daemon --import-chain https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/complete_chain_with_finality_stateroots_latest.car`
	
7. 区块数据的快照 snapshot 管理

	- `lotus chain export <file>` 导出区块链
	- `lotus daemon --import-snapshot <file>` 无链校对导入区块链
	- `lotus daemon --import-chain <filename>` 从链上校对导入区块链
	- `lotus export --skip-old-msgs --recent-stateroots=900 <filename>` 创建修剪过的快照可以如下方式创建

8. 缩减目前的lotus已经同步的链数据,其实就是停掉daemon后,把现在的数据全部删除.然后使用可信快照来进行快速导入,上面也提到了这个7GB的快照是可以反复重置lotus节点的
	
	```
	lotus daemon stop;
	rm -rf ~/.lotus/datastore/chain/*
	lotus daemon --import-snapshot https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car
	```

---------------------

#### Lotus的配置文件和环境变量

Lotus的配置文件在 ==$LOTUS_PATH/config.toml== ,主要是关于api和libp2p的网络配置,其中api设置的是lotus daemon本身监听的端口,而libp2p则是用在与网络中的其他节点进行交互的设置,其中ListenAddress和AnnounceAddresses可以显示的配置为自己的固定ip和port,当然需要使用multiaddress的格式.

Filecoin相关目录环境变量, 整个本地数据由这些相关目录 和 wallet 及 chain文件组成
* `~/.lotus ($LOTUS_PATH)`
* `~./lotusminer ($LOTUS_MINER_PATH)`
* `~./lotusworker ($LOTUS_WORKER_PATH)`

* `LOTUS_FD_MAX` : Sets the file descriptor limit for the process
* `LOTUS_JAEGER` : Sets the Jaeger URL to send traces. See TODO.
* `LOTUS_DEV` : Any non-empty value will enable more verbose logging, useful only for developers.

Variables specific to the _Lotus daemon_ 

* `LOTUS_PATH` : Location to store Lotus data (defaults to `~/.lotus`).
* `LOTUS_SKIP_GENESIS_CHECK=_yes_` : Set only if you wish to run a lotus network with a different genesis block.
* `LOTUS_CHAIN_TIPSET_CACHE` : Sets the size for the chainstore tipset cache. Defaults to `8192`. Increase if you perform frequent arbitrary tipset lookups.
* `LOTUS_CHAIN_INDEX_CACHE` : Sets the size for the epoch index cache. Defaults to `32768`. Increase if you perform frequent deep chain lookups for block heights far from the latest height.
* `LOTUS_BSYNC_MSG_WINDOW` : Sets the initial maximum window size for message fetching blocksync request. Set to 10-20 if you have an internet connection with low bandwidth.
* `FULLNODE_API_INFO="TOKEN : /ip4/<IP>/tcp/<PORT>/http"` 可以设置本地的lotus读取远程的 lotus daemon

需要注意的是软件默认的路径是跟执行用户有关系的,而且一般都需要root权限来执行相关文件的创建,如果直接使用 sudo 命令启动,则相关的路径文件默认时在 `/root/`下的.同时由于 sudo 命令由于安全性问题是会清除掉用户设置的环境变量的,这里可以考虑在 `sudoers` 文件中保留相关的环境变量,也可以使用 `sudo -E` 参数来附加当前的用户环境变量. 当然建议直接通过 `su -`切换到root

不过最推荐的还是注册成 systemd 服务的方式来进行管理, systemd 加载的环境变量全局文件是 `/etc/systemd/system.conf` 和 `/etc/systemd/user.conf` 中,不过一般都会通过服务注册在 `/etc/systemd/system`下文件中的 `Environment` 来进行配置.如果担心更新lotus重新编译或者执行安装的时候覆盖掉了,可以使用 `systemctl edit service` 来创建 `conf.d/override.conf` 中进行配置

-----------------------

#### Lotus-miner 官方工具挖矿

1. 按照上述文档完整的安装了 Lotus 套件,并且使用 `lotus daemon` 完成 FileCoin 网络的同步,在中国必须要设置好 go的代理参数和 ipfs代理网关.如果 lotus daemon 和 lotus-miner 不是同一台机器,切记需要根据 Lotus客户端的使用 所述,将 lotus daemon 监听改在局域网段,然后创建 admin 权限的 json-rpc token 来让 lotus-miner 使用

2. 设置性能参数环境变量,切记 systemd 服务要单独在服务配置文件中设置
	``` shell
	# See https://github.com/Filecoin-project/bellman
	export BELLMAN_CPU_UTILIZATION=0.875

	# See https://github.com/Filecoin-project/rust-fil-proofs/
	export FIL_PROOFS_MAXIMIZE_CACHING=1 # More speed at RAM cost (1x sector-size of RAM - 32 GB).使用更多的内存来加快预提交的速度
	export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 # precommit 2 GPU acceleration,加快GPU
	export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
	```

3. 设置 lotus node 节点 (当node和miner运行在不同的机器上的时候,详细参看上文的 如何使用 Lotus daemon 或 Lotus-miner监听提供的 json-rpc 接口 章节)
`export FULLNODE_API_INFO=<api_token>:/ip4/<lotus_daemon_ip>/tcp/<lotus_daemon_port>/http`

4. 如果内存过少,则需要添加swap分区,详细可以参看 linux使用文档中的添加swap
	
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

5. 查看 lotus-miner显示支持的GPU和benchmark

	[权威列表](https://github.com/Filecoin-project/bellman#supported--tested-cards)

	[使用自定义的GPU](https://docs.Filecoin.io/mine/lotus/gpus/#enabling-a-custom-gpu)

	[bellperson](https://github.com/Filecoin-project/bellman#supported--tested-cards)

	添加环境变量
	`export BELLMAN_CUSTOM_GPU="GeForce RTX 3080:8704"`

	测试
	`./lotus-bench sealing --sector-size=2KiB`
		
	服务器中有多个GPU，选择特定的GPU运行程序可在程序运行命令前使用：CUDA_VISIBLE_DEVICES=0命令。0为服务器中的GPU编号，可以为0, 1, 2, 3等，表明对程序可见的GPU编号。可以和CPU亲和一样,用逗号隔开	

6. 执行挖矿必须要有 BLS 钱包,即 t3 开头的钱包,默认的创建的 spec256k1 是 t1开头的.

7. 下载 Filecoin矿工证明参数,32GB和64GB时不一样的,强烈建议通过环境变量来设置一个位置保存他们
	
	- filecoin-proof-parameters 默认路径 `/var/tmp/filecoin-proof-parameters/` , `export FIL_PROOFS_PARAMETER_CACHE=/path/to/folder/in/fast/disk`
	- filecoin-parents 默认路径 `/var/tmp/filecoin-parents/` , `export FIL_PROOFS_PARENT_CACHE=/path/to/folder/in/fast/disk2`
	- seal sector的tmp目录 `export TMPDIR=/disk3`

	``` shell
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

13. 其他步骤 这里请看下文 ==进阶设置==

	- 配置自定义存储的布局,这要求一开始使用 --no-local-storage
	- 编辑 lotus-miner 的配置
	- 了解什么是关机和重启矿机的好时机
	- 发现或者说通过运行基准测试来得到密封一个sector的时间 ExpectedSealDuration
	- 配置额外的worker来提高miner的密封sector的能力
	- 为 windowPost设置单独的账户地址.

--------------------

####  Lotus-miner 官方工具挖矿进阶设置

##### 防火墙有可能要开启

- 1234 lotus daemon api
- 2345 lotus-miner api
- 24001 lotus-miner work
- 2222 ssh

##### lotus和lotus-miner的远程访问

lotus daemon的修改: 修改config中`API`下的`ListenAddress`,重启lotus daemon.通过`lotus auth api-info --perm admin`命令可以获得admin权限的api info key,再客户端机器上可以通过这个环境变量来访问该lotus daemon node的api.


##### 矿工自定义存储布局

首先要在矿工初始化时,使用 `--no-local-storage`.然后可以指定用于 seal密封 (建议在ssd上) 和长期存储的磁盘位置.你可以在 `$LOTUS_MINER_PATH/storage.json` 中设定,其默认值为 `~/.lotusminer/storage.json`.

使用自定义命令行需要lotus-miner运行,设置后需要重启miner

自定义密封位置: `lotus-miner storage attach --init --seal <PATH_FOR_SEALING_STORAGE>`

自定义存储位置: `lotus-miner storage attach --init --store <PATH_FOR_LONG_TERM_STORAGE>`

列出所有存储位置 : `lotus-miner storage list`

##### 跑 benchmark 来得知机器封装一个块的时间

在lotus目录编译 `make lotus-bench`. 运行help可以查看到帮助.大体上命令是这样的

`./lotus-bench sealing --storage-dir /data/bench --sector-size 32GiB --num-sectors 1 --parallel 1 --json-out `

``` json
lotus benchmark result
{
  "SectorSize": 34359738368,
  "SealingResults": [
	{
	  "AddPiece": 870097300267,
	  "PreCommit1": 19675090466708,
	  "PreCommit2": 2160057571490,
	  "Commit1": 44283547951,
	  "Commit2": 5573822383169,
	  "Verify": 28487520,
	  "Unseal": 19463753783027
	}
  ],
  "PostGenerateCandidates": 155197,
  "PostWinningProofCold": 8356540927,
  "PostWinningProofHot": 4285092397,
  "VerifyWinningPostCold": 57527449,
  "VerifyWinningPostHot": 20039908,
  "PostWindowProofCold": 1077144420908,
  "PostWindowProofHot": 973861248741,
  "VerifyWindowPostCold": 6744654407,
  "VerifyWindowPostHot": 63166446
}
```

单位 unit 应该是 tick = 1\/3600000000000 H,这里是自己测试机的结果

| 时间 | 操作 | 换算 |
| --- | --- | --- |
| 封装 | 封装 | 封装 |
| 870097300267 | add | 0.2417H = 14M 30S |
| 19675090466708 | p1 | 5.4653H = 5H 28M |
| 2160057571490 | p2 | 0.6000H = 36M |
| 44283547951 | c1 | 0.0123H = 44S |
| 5573822383169 | c2 | 1.5483H = 1H 32M 53S |
| 校验 | 校验 | 校验 |
| 28487520 | verify | 0.03S |
| 19463753783027 | unseal | 5.4065H = 5H 24M 24S |
| 出块 | 出块 | 出块 |
| 155197 | candidate | 几乎为0 |
| 4285092397 | winning proof hot | 4.28S |
| 8356540927 | winning proof cold | 8.35S |
| 20039908 | winning post hot | 0.02S |
| 57527449 | winning post cold | 0.05S |
| 时空证明 | 时空证明 | 时空证明 |
| 973861248741 | window proof hot | 0.2705H	= 16M 14S |
| 1077144420908 | window proof cold | 0.2992H = 18M |
| 63166446 | window post hot | 0.06S |
| 6744654407 | window post cold | 6.74S |

##### 矿工钱包,分开 owner 地址和 worker 地址,为 windowPoSt设置单独的 control 地址.

矿工钱包可以配置为由几个账户组成,可以使用命令 `lotus-miner actor control list` 查看, 在矿工的init过程中,filecoin网络会给该矿工初始化一个 ==t0== 开头的表示账户id叫做 actor ,actor负责收集所有发送到矿工的币.
	- owner 地址,设计成尽可能离线冷钱包的形式.
	- worker 地址,生产环境中热钱包地址,强烈建议 owner地址和worker地址分开.
	- control 地址

owner是在矿工初始化的时候设置的,只有如下几个场景需要用到owner地址
	- 改变矿工actor的worker地址.
	- 从矿工actor提取代币
	- 提交 WindowPoSt,如果设置了单独的control地址且有余额的情况下是会使用control地址的.

worker地址是矿工每日的工作中使用的:
	- 初始化矿工
	- 修改矿工的peer id和multiaddresses
	- 与市场和支付渠道交互
	- 对新区块进行签名
	- 提交证明,声明错误,当control和owner都不能提交的时候也会用worker的余额来提交 WindowPoSt

control地址是用来提交 WindowPoSt证明的,由于这些证明是提交的消息交易,所以是需要手续费的.但是这个消息比较特殊,因为消减的存在所以提交 WindowPoSt的消息是非常的高价值的.所以使用单独的Control地址来提交这些消息可以避免队首阻塞问题,因为这里也有nonce的概念.control地址可以设置多个.第一个有余额的地址就会被用来提交 WindowPoSt.

`lotus-miner actor control set --really-do-it t3defg...`
`lotus state wait-msg bafy2..`
`lotus-miner actor control list`

==管理余额==

`lotus-miner info` 其中 miner 可用余额可以通过 `lotus-miner actor withdraw <amount>` 提取.

##### Lotus Miner 配置参考

Lotus Miner配置是在初始化 init 步骤之后的,其位置是 `$LOTUS_MINER_PATH/config.toml`, 其默认值是 `~/.lotusminer/config.toml`. 必须重新启动矿机即miner服务才可以使配置生效.

- API部分 主要使为了worker来使用的,默认使绑定在本地环路接口,如果是多机器则需要配置到使用的网络接口
- Libp2p部分 这部分是配置miner嵌入的 Libp2p 节点的,需要配置成miner的公共ip和固定的端口
- PubSub部分用于在网络中分发消息
- Deal Making部分 用于控制存储和检索交易.注意 `ExpectedSealDuration` 应该等于 `(TIME_TO_SEAL_A_SECTOR + WaitDealsDelay) * 1.5`
- Sealing部分 即密封部分配置
- Storage部分 即存储部分,控制矿工是否可以执行某些密封行为
- Fees费用部分

修改miner的gas费率

``` lotusminer/config.toml
[Fees]
MaxPreCommitGasFee = "0.05 FIL"
MaxCommitGasFee = "0.05 FIL"
MaxWindowPoStGasFee = "50 FIL"
```

##### Lotus套件升级

- 关闭所有的 seal miner 和 worker
- 关闭 lotus daemon
- git pull
- 执行安装 
	
	``` shell
	export RUSTFLAGS="-C target-cpu=native -g"
	export FFI_BUILD_FROM_SOURCE=1
	git pull or git checkout <tag_or_branch>		
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
- 如果你需要重置所有本地数据,那么需要备份的包括 lotus钱包,node数据和miner配置,然后删除掉 $LOTUS_PATH , $LOTUS_MINER_PATH , $LOTUS_WORKER_PATH

##### 安全的升级和重启miner

需要考虑的因素包括: 

- 需要离线多久
- proving时间期限的分布如何
- 是否存在交易和检索
- 是否有正在进行的密封操作

1. 重启前,建议对lotus程序进行升级,同时下载更新挖矿参数到ssd上 $FIL_PROOFS_PARAMETER_CACHE
2. 必须确认有时间窗口可以进行重启,使用命令 `lotus-miner proving info` 确认 deadline open有对 current epoch的时间窗口,也可以使用 `lotus-miner proving deadlines` 来确认将来24小时内的分布.
3. 检查交易 `lotus-miner storage-deals list`, `lotus-miner retrieval-deals list` , `lotus-miner data-transfers list` . 并暂时禁用交易 `lotus-miner storage-deals selection reject --online --offline` , `lotus-miner retrieval-deals selection reject --online --offline`. 当miner 重启完成后,需要使用以下命令恢复交易 `lotus-miner storage-deals selection reset`, `lotus-miner retrieval-deals selection reset`.
4. 检查当前正在进行的密封行为 `lotus-miner sectors list`

##### 重启 worker

可以随时重新启动 Lotus Seal Worker,但是他们如果正在执行密封的某一个步骤的话,重新后需要从最后一个检查点重新开始.而且如果是在 C2阶段最多只有3次尝试的机会.

##### 更改存储的位置

这一部分内容和小节1中的自定义配置存储位置其实差不多,但一般更改存储位置都是在已经上线存续运行的时候,需要在线的更新.

通过命令 `lotus-miner storage list` 可以查询到当前 lotus-miner 所使用的存储位置,如果你需要对其进行修改,你需要执行以下步骤: 

- 执行命令拒绝所有存储和检索加以
- 将原数据复制到新的位置,这涉及到大量的数据迁移,所以在下一步停止miner之后,有可能需要再次同步一下数据,防止文件的状态不一致.
- 停止miner
- 编辑 storage.json 文件,这里无法使用命令来进行修改了.直接修改该文件,内容是一个简单的json文件指定了miner可以使用的存储位置,至于存储位置的权重和是否可以seal及storage是在指定位置下有单独的 sectorstorage.json 来进行配置的.
- 启动miner,如果一切正常的话,原来位置的数据就可以进行删除了

当然如果你只是简单的想要增加可用的存储空间以增加存力,那么简单的使用在线命令 `lotus-miner storage attach`就可以实现了.可以不用停止 miner.

##### 更改worker的存储位置

- 停止 worker
- 迁移数据
- 对 $LOTUS_WORKER_PATH进行设置
- 重新启动 worker

需要注意的是不同线程的 worker 之间的数据(同一个阶段)是不支持转移和共享的.

--------------------

#### Lotus mine 抵押扇区 及开始封装算力

抵押扇区是增加有效存力的唯一方式,同时需要根据一个扇区的密封的时间\*1.5来更新配置中的`ExpectedSealDuration`字段.

抵押一个扇区即承诺自己提供一个扇区的容量给网络可用,使用命令 `lotus-miner sectors pledge` , 需要注意的是这会完整的走完整个过程,即肯定是要写入数据的.通过以下命令来进行检查

``` shell
# 查看密封中的工作,这一般会在 $TMPDIR/unsealed 中创建文件
lotus-miner sealing jobs
# 查看密封进度,密封完成时 pSet: NO将变为pSet: YES
lotus-miner sectors list
# 查看密封使用的资源
lotus-miner sealing workers
# 通过log来查看一个扇区密封所需的时间
lotus-miner sectors status --log 0
```

扇区状态 `lotus-miner sectors update-state --really-do-it number state` 

- ComputeProofFailed
- FinalizeFailed
- FaultReported
- FaultedFinal 我知道错了
- Removed 强制移除
- PreCommit1 重新来一次
- PreCommit2
- FinalizeSector
- WaitSeed
- PackingFailed
- RecoverDealIDs
- SealPreCommit1Failed
- PreCommitFailed
- CommitFailed
- Packing AddPiece状态
- PreCommitWait
- SubmitCommit
- Empty
- FailedUnrecoverable
- Faulty
- Committing 提交错误重新提交
- CommitWait
- Proving
- SealPreCommit2Failed
- Removing
- WaitDeals
- DealsExpired
- RemoveFailed
- PreCommitting

升级抵押的扇区以存储与交易相关的实际数据 `lotus-miner sectors mark-for-upgrade <sector number>`

--------------------

#### Lotus miner seal worker

lotus miner本身可以执行密封过程的所有阶段,但是 P1阶段的CPU的密集型任务会影响到后面的 winningPoSt 和 windowPoSt 的提交.所以我们可以创建管道让 worker来负责密封的部分阶段.这部分是关乎于压榨机器性能最重要的部分,涉及到了filecoin的证明系统 [SDR算法](https://github.com/filecoin-project/rust-fil-proofs/) .

一个 worker 最多运行两个任务,每个任务作为一个插槽成为一个 window 窗口. 最终数据取决于可用的cpu核心数和GPU的数量,比如 有多核CPU 和 一个 GPU的机器上:

*   2个_PreCommit1_任务（每个任务使用1个核心） 
*   1个_PreCommit2_任务（使用所有可用核心 只有1个GPU）
*   1个_提交_任务（使用所有可用的内核或使用GPU,C1很短,主要是C2只有1个GPU）
*   2个_解封_任务（每个使用1个核心）

当然实际测试中并不一定总是需要128GiB内存那么多,当然多总是好的. 使用命令 `lotus-worker run <flags>` 启动worker,需要注意的是不同的 worker 与 miner 要设置不同的 `$LOTUS_WORKER_PATH` 和 `$TMPDIR` 的环境变量,如果一台主机上运行多个 worker ,需要通过 `--listen`指定不同的监听端口,可选的 flags 参数如下

```
   --addpiece                    enable addpiece (default: true)
   --precommit1                  enable precommit1 (32G sectors: 1 core, 128GiB Memory) (default: true)
   --unseal                      enable unsealing (32G sectors: 1 core, 128GiB Memory) (default: true)
   --precommit2                  enable precommit2 (32G sectors: all cores, 96GiB Memory) (default: true)
   --commit                      enable commit (32G sectors: all cores or GPUs, 128GiB Memory + 64GiB swap) (default: true)
```

主miner只专注于执行 WindowPoSt 和 WinningPoSt

单独的CPU任务 P1和unseal分配worker -> 3个,最多6个p1,6个unseal

单独的GPU任务 P2 C分配worker -> 1个,最多1个p2,1个c

切记Lotus Miner 配置中的 `MaxSealingSectors`,`MaxSealingSectorsForDeals`控制了可以同时 seal 的 sector 数量. `Storage`配置中如果要将工作全部分配给worker,则需要将对应的设置为false

```
[Storage]
  AllowAddPiece = true
  AllowPreCommit1 = true
  AllowPreCommit2 = true
  AllowCommit = true
  AllowUnseal = true
```

--------------------

#### 同时运行 miner 和 worker的CPU分配

这里可以对 worker 启用多核心加快 SDR 的效率 .通过设置环境变量 `$FIL_PROOFS_USE_MULTICORE_SDR=1`, 然后通过 `taskset -C` 或 systemd 的中的 cpu亲和度参数来绑定相邻边界的4个核心

启动参数:
`lotus-worker run --listen 0.0.0.0:X --addpiece=false --precommit1=true --unseal=true --precommit2=false --commit=false`

通过 taskset:
```
# Restrict to single core number 0
taskset -c 0 <worker_pid | command>
# Restrict to a single core complex (example)
# Check your CPU model documentation to verify how many
# core complexes it has and how many cores in each:
taskset -c 0,1,2,3 <worker_pid | command>
```

通过systemd:
```
# workerN.service
...
CPUAffinity=C1,C2... # Specify the core number that this worker will use.
...
```

--------------------

#### Lotus miner 故障排除

1. 连接问题

- 使用命令查看节点的nat状态 `lotus-miner net reachability`,这需要你连接到足够的peers才能正确反馈,正常的值是 Public
- 检查连接的对等点 peers ,使用命令 `lotus-miner net peers` , 如果过少,可以使用命令 `lotus-miner net connect <address1> <address2>...` 手动连接 [引导节点](https://github.com/filecoin-project/lotus/blob/master/build/bootstrap/bootstrappers.pi) 确保你们实在相同的网络分支中

--------------------

#### Lotus miner 管理交易

这里把交易的内容抽离出来的主要原因是在 filecoin 整个网络的初期特别是小矿工压根是不会牵扯到存储和检索的交易的,并且就算没有存储和检索的交易,单纯的对垃圾数据进行seal也可以增长有效存力,进行出块.

存储交易的几个主要的阶段分别是 1.数据传输 (transfer 用于在线交易) 或数据导入 (import 用于离线交易); 2.矿工对带有交易数据的sector进行密封; 3.矿工每24小时不间断的在订单时间内对 sector 进行时空证明

1. 启用和禁用存储交易

	miner对交易的启用和禁用可以有两种方法:
		- 配置法,修改 $LOTUS_MINER_PATH/config.toml 文件下的 `[DealMaking]`,然后重新启动 miner
		- 命令法,由于修改配置需要重启 miner,所以较为推荐使用命令法来进行修改,同时命令也会修改文件中的值,如果后续真的重新了矿机,其配置也是生效的

	要禁用存储交易 `lotus-miner storage-deals selection reject --online --offline`,要启用存储交易 `lotus-miner storage-deals selection reset`, 你可以使用命令 `lotus-miner storage-deals selection list
	` 来进行校验

2. 设定存储交易的要价

	达成存储交易一方面需要有需求,另外一方面就是矿工的价格和条件了.这是由矿工进行设置的,只要达成条件,那么矿工就可以自动的接受.这是由命令 `lotus-miner storage-deals set-ask` 来设置的. 举例如下:

	``` shell
	lotus-miner storage-deals set-ask \
	  --price 100000000000 \
	  --verified-price  100000000000 \
	  --min-piece-size 56KiB \
	  --max-piece-size 32GB
	```

	上述例子即矿工将交易价格设置为 每GiB每epoch的价格为 100000000000 attoFIL(即100 nanoFIL).所以如果客户需要存储 5GiB的数据一周,那么就需要支付 `5GiB * 100nanoFIL/GiB_Epoch * 20160 Epochs = 10080 microFIL`.

	矿工可以使用命令 `lotus-miner storage-deals get-ask` 查看自己的要价,使用命令 `lotus-miner storage-deals list -v` 来查看当前正在进行的交易 , 相对的客户可以使用 `lotus client query-ask <minerID>` 来查询指定矿工的要价.

3. 使用过滤器限制交易

	这主要是通过配置文件中 `[DealMaking]` 中的 `Filter` 来实现的,他可以通过一个外部程序或者脚本返回 true 来接受交易,否则就拒绝.

4. 封锁内容

	如果有一些内容不是很好,黄色啊之类的,那么可以通过cid进行阻止他们传入.下列命令接受一个文件,文件内容应该每行包括一个cid.

	`lotus-miner storage-deals set-blocklist blocklist-file.txt`

	可以使用命令 `lotus-miner storage-deals get-blocklist` 查看阻止列表 , 或使用命令 `lotus-miner storage-deals reset-blocklist` 来清除列表

5. 在sector中接受多个交易,操作效率就更高,这减少了密封和验证的操作.这主要是由配置中的 `[Sealing]` 的 `WaitDealsDelay` 来控制的,即等待多少时间.

6. 离线交易的数据导入,使用命令 `lotus-miner deals import-data <dealCid> <filePath>`

7. 检索交易的文档暂缺
