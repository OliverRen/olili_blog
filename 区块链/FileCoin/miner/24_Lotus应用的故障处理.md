---
title: 24_Lotus应用的故障处理
tags: 
---

[toc]

#### 编译错误

首先要看编译的具体错误

主要思路是本地的源代码有改过删除重新 `git clone`

或

```
git check <master>
git reset origin/<master> --hard
make clean
```

#### 在中国编译

主要有以下几点

- `git clone`慢,如果有代理可以挂代理
- `go`模块中也是`git clone`,如果有代理可以挂代理
- `go`模块可以使用 `GOPROXY`环境变量或使用 `go env`来使用国内的代理
- `cargo`和`rust`的依赖可以使用国内交通大学的镜像源

#### Error: initializing node error: cbor input had wrong number of fields

主要考虑是lotus的 `LOTUS_PATH` 中已经存在了和启动编译代码网络分支不同,要么删掉已经存在的同步数据,要么重新编译正确网络的分支源代码

#### Error: Failed to connect bootstrap peer

`WARN  peermgr peermgr/peermgr.go:131  failed to connect to bootstrap peer: failed to dial : all dials failed * [/ip4/147.75.80.17/tcp/1347] failed to negotiate security protocol: connected to wrong peer`

考虑是源代码没有更新,`git pull`后重新编译即可

#### Error: other peer has different genesis!

`ERROR hello hello/hello.go:81 other peer has different genesis!`

考虑自己的 `LOTUS_PATH` 已经过时,这尽在测试网的时候有过重置网络才有可能发生

删除掉已经同步的数据重新同步链网络即可

#### Config: Open files limit

Lotus将尝试自动设置文件描述符(FD)限制。如果不工作，您仍然可以配置您的系统，以允许高于默认值。

#### Error: Routing: not found

`Error: Routing: not found`

错误的意思是worker想要尝试连接的miner不在线.

#### RPC Error: request bigger than maximum

`ERROR	rpc	go-jsonrpc/server.go:90	RPC Error: request bigger than maximum 104857600 allowed`

如果RPC服务器公开给外部请求，出于安全考虑，有一个最大请求大小。默认值是100 MiB，但是可以使用启动服务器的各个CLI命令的api-max-req-size CLI参数进行调整。

#### Signal killed

`/usr/local/go/pkg/tool/linux_amd64/link: signal: killed
make: *** [Makefile:68: lotus] Error 1`

编译错误,确认硬件是否已经达到了最低的要求

#### 本地链同步分叉如何恢复

`chain linked to block marked previously as bad`

可以强制重新同步

```
lotus sync unmark-bad --all
lotus chain sethead --epoch <number>
```