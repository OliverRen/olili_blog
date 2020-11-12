---
title: Lotus客户端的使用
---

[toc]

* [Lotus套件的软件说明](#lotus%E5%A5%97%E4%BB%B6%E7%9A%84%E8%BD%AF%E4%BB%B6%E8%AF%B4%E6%98%8E)
* [常用操作](#%E5%B8%B8%E7%94%A8%E6%93%8D%E4%BD%9C)
* [钱包管理](#%E9%92%B1%E5%8C%85%E7%AE%A1%E7%90%86)
* [JsonRPC的Json Web Token](#jsonrpc%E7%9A%84json-web-token)
* [使用Lotus存储数据](#%E4%BD%BF%E7%94%A8lotus%E5%AD%98%E5%82%A8%E6%95%B0%E6%8D%AE)
* [使用Lotus检索交易](#%E4%BD%BF%E7%94%A8lotus%E6%A3%80%E7%B4%A2%E4%BA%A4%E6%98%93)

#### Lotus套件的软件说明

- `lotus` lotus-daemon的链同步工具和钱包管理工具
- `lotus-miner` 矿工主miner
- `lotus-worker` 矿工执行seal的worker
- `lotus-shed` 所有的工具集

- `lotus-bench` 对硬件进行benchmark的程序
- `lotus-gateway` 通过lotus-daemon来创建一个api server的工具
- `lotus-health` 仅用来查看当前本地链是否健康,需要同步完成

- `lotus-seed` 创世矿工用来封装sectors的工具
- `lotus-pond` 通过2222端口来提供服务的一个cli依赖miner,worker,seed
- `lotus-townhall` 会创建一个genesis cid,需要box运行,但没有更多的说明
- `lotus-pcr` precommit refund工具,用来保证上线时矿工有币

- `lotus-fountain` 开发网代币分发工具 通过7777端口
- `lotus-chainwatch` 开发网监控 写入postgresDB
- `lotus-stats` 对链进行计数统计的程序 需要数据库
- `lotus-wallet` 通过1777端口监听运行,目前不清楚这个wallet和lotus本身的wallet功能有何区别

#### 常用操作

- 查看 windowPoSt
`clear ;echo proving ;lotus-miner info;lotus-miner proving info ; lotus-miner proving deadlines;`

- 查看 sealing
`clear ;echo sealing;lotus-miner sealing jobs;echo  ; lotus-miner sealing workers;lotus-miner sealing sched-diag; echo ; free -h ;`

- 查看 sectors
`clear ;echo sector;lotus-miner sectors list | grep -v Proving;lotus-miner storage list --color;`

- 查看和修改 sector status
`clear ;lotus-miner sectors status --log 0;`
`lotus-miner sectors update-state --really-do-it x Packing`
- 本地移除
`lotus-miner sectors remove --really-do-it x`
- 强制中止扇区 已经上链了
`/usr/local/lib/lotus/lotus-shed sectors terminate --really-do-it x`

- 查询消息的执行
`lotus state exec-trace cid`

- 查看 intel SSD
`intelmas show -a -smart | grep Action`

- 查看 lotus-miner 的log, 执行windowPoSt可以执行 grep `wdpost`,`Submitted window post`
- 查看 lotus-miner 的log,执行开始质押新区快可以执行 grep `stub NewSector`,`Pledge`

- 备份 lotus-miner
	```
	lotus-miner backup backup.cbor
	lotus-miner backup --offline backup.cbor
	lotus-miner init restore --config backup/config.toml --storage-config backup/storage.json backup/backup.cbor
	```

- mpool信息替换
`./lotus mpool pending --local --cids | xargs -L1 ./lotus mpool replace --auto`

- 操作矿工账号的几个方法
`lotus-miner actor withdraw` 提现
`lotus-miner actor  repay-debt` 充值
`lotus-miner actor set-addrs` 设置公网发布地址
`lotus-miner actor set-owner` 设置owner
`lotus-miner actor control` 设置提交windowPoSt的control地址

- 切换矿工的owner
`lotus-miner actor set-owner --really-do-it address`


#### 钱包管理

- 查看钱包
	`lotus wallet list` 查看所有的钱包账户
	`lotus wallet default` 查看默认钱包
	`lotus wallet set-default <address>` 设置一个默认钱包
	`lotus wallt balance` 
	
- 新建钱包
	`lotus wallet new [bls|secp256k1 (default secp256k1)]` 其中bls会生成 t3长地址(对multisig友好),secp256k1即btc的曲线参数会生成t1的短地址,新创建的钱包会在 `$LOTUS_PATH/keystore`
	
- 执行转账
	`lotus wallet send --from=<sender_address> <target_address> <amount>`
	`lotus wallet send <target_address> <amount>`
	
- 导入导出钱包 (你也可以直接copy ~/.lotus/keystore)
	`lotus wallet export <address> > wallet.private`
	`lotus wallet import wallet.private` 
	
- 管理信息池

	`lotus mpool xxxx`
	
- 管理支付渠道

	`lotus paych`
	
- filecoin链状态

	`lotus state`

#### JsonRPC的Json Web Token
	
目前json-rpc接口没有文档,只能看源码

需要注意的是 lotus daemon 提供的api不光可以被应用请求,同时 lotus-miner 和 lotus-worker 也是以来这个 json-rpc 来与 lotus daemon 交互的

- EndPoint
	* `http://[api:port]/rpc/v0` http json-rpc接口
	* `ws://[api:port]/rpc/v0` websocket json-rpc接口
	* `http://[api:port]/rest/v0/import` 只允许put请求,需要一个写权限来添加文件

- 创建JWT
	
	```sh
	# Lotus Node
	lotus auth create-token --perm admin

	# Lotus Miner
	lotus-miner auth create-token --perm admin
	```

	其中有4种权限
	- `read` - 只能读取
	- `write` - 可以写入,包含 read
	- `sign` - 可以使用私钥签名,包含 read,write
	- `admin` - 管理节点的权限,包含 read,write,sign

- 发起请求
	
	``` sh
	# 不需要权限
	curl -X POST \
	 -H "Content-Type:application/json" \
	 --data '{ "jsonrpc":"2.0", "method":"Filecoin.ChainHead", "params":[], "id":3 }' \
	 'http://127.0.0.1:1234/rpc/v0'

	 # 需要权限时,需要传入 JWT
	 curl -X POST \
	 -H "Content-Type:application/json" \
	 -H "Authorization:Bearer $(cat ~/.lotusminer/token)" \
	 --data '{ "jsonrpc":"2.0", "method":"Filecoin.ChainHead", "params":[], "id":3 }' \
	 'http://127.0.0.1:1234/rpc/v0'
	```
	
#### 使用Lotus存储数据

术语解释 CAR文件 : [Specification : Content Addressable aRchives](https://github.com/ipld/specs/blob/master/block-layer/content-addressable-archives.md)

- 数据必须打包到一个CAR文件中,这里可以使用以下命令
	
	`lotus client generate-car <input path> <output path>` </br>
	`lotus client import <file path>`
	
- 列出本地已经导入或者创建car的文件
	
	`lotus client local`
	
- 数据必须切割到指定的扇区大小,如果你自己创建了car文件,确保使用--czr标志来进行导入	
- 查询矿工,询问价格,开始存储交易(在线交易)
	
	`lotus state list-miners` </br>
	`lotus client query-ask <miner>` </br>
	`lotus client deal` 
	
- 扇区文件可以存储的容量,首先计算使用的是1024而不是1000,同时对于每256位 bits,需要保留2位作为证明之需.即32GB的sector可以存储的容量是 2^30\*254\/256 字节
- 离线交易,生成car,然后生成对应所选矿工的piece块的CID,然后提出离线交易
	
	`lotus client generate-car <input path>	<output path>` </br>
	`client commP <inputCAR filepath> <miner>` </br>
	`lotus client deal --manual-piece-cid=CID --manual-piece-size=datasize <Data CID> <miner> <piece> <duration>` </br>
	`lotus-miner deals import-data <dealCID> <filepath>`
	
- 从IPFS中导入数据,首先需要在lotus配置中打开 UseIpfs,然后可以直接将ipfs中的文件进行在线交易
	
	`lotus client deal QmSomeData t0100 0 100`
	
#### 使用Lotus检索交易

- 查询自己的数据被哪些矿工存储
	
	`lotus client find <Data CID>`
	
- 进行检索交易
	
	`lotus client retrieve <Data CID> <out file>`
	