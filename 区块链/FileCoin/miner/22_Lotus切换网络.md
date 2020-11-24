---
title: 22_Lotus切换网络
tags: 
---

切换网络主要的方法是清理后重新编译和安装

其中需要注意的是 LOTUS_PATH 种的数据不同网络是不能通用的,要进行切换

同时还带来了额外的问题,比如需要备份 lotus 中重要的数据

- 首先关闭 `lotus daemon` 节点
- 重新编译,注意需要通过 git checkout 不同的分支切换到其他网络

对于 LOTUS_PATH 目录清理的方式

- 删除 LOTUS_PATH 目录,注意这样做也会删除掉你的 keystore 一定要记得备份
- 使用环境变量或命令行参数指定一个新的 LOTUS_PATH 位置

另外对备份`lotus`数据的备注

- 如果你只是需要备份 LOTUS_PATH ,那么直接拷贝他就可以了,这样依然是一个原网络数据的备份
- 如果你是需要备份钱包则需要使用到 `lotus wallet export`,`lotus wallet import` 相关的命令
- 如果你是需要备份链数据则需要使用到 `lotus chain export` , `lotus daemon --import-snapshot` 相关的命令

