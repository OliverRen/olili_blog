---
title: Lotus客户端的使用
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