---
title: 34_SplitStore
---

[toc]

0. lotus 1.5.1

第一次暴露出来的一个概念,不过实现与现在的有区别,已经过时了

1. lotus 1.11.1 SplitStore V1

SplitStore 功能最早是在 1.11.1 正式加入代码开始测试的,对 lotus daemon 的存储分成 hotstore 和 coldstore . 并分别可以选择存储的方式,一开始最主要的用途就是将 coldstore 进行 discard 丢弃用来减少 lotus daemon 的本地存储空间占用.

```
[Chainstore]
  EnableSplitstore = true
  [Chainstore.Splitstore]
    ColdStoreType = "discard"
#    HotStoreType = "badger"
#    MarkSetType = "badger"
#    HotStoreMessageRetention = 0
    HotStoreFullGCFrequency = 20

```

2. lotus 1.17.1

需要备注的是在版本号 次版本号为奇数时的版本更像一个预览版本,偶数才是强制更新和大版本更正式的版本号.

所以我们就会看到,明明 1.18.0 才是 V9 的强制更新版本,但是 splitstore 的第二个更新版本去却是在 1.17.1 总加入的

在这个版本中,有将 hotstore -> coldstore 的 auto prune and GC 通过cli命令暴露出来以手动执行,自动prune的频率是通过配置文件中的 HotStoreFullGCFrequency = 20 指定的,默认的 20 大概是一周左右的时间,手动执行的命令是 `lotus chain prune <flags>`

3. lotus 1.19.0 - SplitStore v2（Beta)

可以说是 SplitStore V2 较为正式一个版本了,虽然还是 beta 不过基本的功能点都有了

HotStoreType , 目前只可选择存储在本地 `badger`

ColdStoreType , 可选 `universal` 全节点, `messages` 只存储链上消息 ,`discard` 丢弃只保留3600高度在hotstore ,

MarkSetType , prune compactions合并 和 全GC 的时候需要占用临时的空间,如果内存大于48G,可以选择 `map` ,否则只能选择 本地文件 `badger`

HotStoreFullGCFrequency 执行多少次 compactions 后执行全 GC.20默认值大约是一周的时间

lotus-shed : 工具集中也加入了对 SplitStore 的支持,包括 rollback,clear,check,info