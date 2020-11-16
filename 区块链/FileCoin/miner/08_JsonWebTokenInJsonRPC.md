---
title: 08_JsonWebTokenInJsonRPC
tags: 
---

[toc]

**JsonRPC**

`JsonRPC`的`Json Web Token`
	
需要注意的是`lotus daemon`提供的api不光可以被应用请求,同时`lotus-miner`和`lotus-worker`也是以来这个`json-rpc`来与`lotus daemon`交互的

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