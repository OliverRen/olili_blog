---
title: 25_Lotus客户端存储交易的使用
tags: 
---

#### 使用Lotus客户端来存储数据

术语解释 CAR文件 : [Specification : Content Addressable aRchives](https://github.com/ipld/specs/blob/master/block-layer/content-addressable-archives.md)

概述一下大概的步骤

1. 数据必须打包成 [CAR](https://github.com/ipld/specs/blob/master/block-layer/content-addressable-archives.md) 格式的文件,这是一种内容可寻址的存档文件格式
2. 客户和矿工之间必须有一个存储交易被初始化后,矿工必须接受
3. 数据需要通过网络传输或线下的传输给矿工
4. 矿工需要将数据包含在sector中密封,并且向网络持续的提供时空证明

##### 使用Lotus客户端导入数据

本地导入文件使用 `lotus client import <file>` 即可

如果需要导入整个目录,建议将期打包成car文件或简单的zip打包成一个文件就可以了.

这个命令会返回一个 Data CID,这个CID非常有用,在创建存储交易和检索的时候都会被使用到.

可以使用 `lotus client local` 查询到本已经已经导入的文件

需要文件大于了一个sector的大小,那么久必须要进行切割

目前32GB的是主流方案,这会在创数和密封的时候更快,而更大的64GB的块则在性价比上更有优势

TIPS:如果你使用了自己构建IPLD的car文件,请务必确保使用`--czr`标志来进行导入	

#### 使用Lotus客户端发起存储交易

- 首先你必须要现有上述导入文件的 CID
- 找到一个提供存储的矿工
- 询价
- 发起交易

查询矿工列表在客户端上可以使用 `lotus state list-miners`

询价可以使用 `lotus client query-ask <miner>`

发起交易可以使用 `lotus client deal` 这会发起交互命令来输出CID等信息,当然你也可以直接使用`lotus client deal <data CID> <miner> <price> <duration>` 直接发起交易

需要注意的是 price 的单位, duration 的单位是epoch block,即1代表了大约30秒

TIPS:目前官方的建议在初期网络很小很不稳定的时候,尽量为文件进行10个矿工的存储交易

最后最已经发起的交易可以使用 `lotus client list-deals` 来列出所有的交易.

#### 大量数据或大文件的处理

如果你有非常多的数据需要存储,比如1TB以上的数据,那么就需要注意更多的东西.

1. 最大的存储

filecoin中单个文件的存必须是小于sector大小的,这里通用的都i是 32GiB,即 2^30bytes=1,073,741,824 bytes 而不是 1,000,000,000 bytes

不过由于filecoin数据结构每256个bits中有2个bits被保留用作证明过程中使用,所以单个文件的最大大小就是 `sector_size * 254/256`

| Sector Size | Usable size |
| --- | --- |
| 2KiB | 2,032 bytes |
| 8MiB | 8,323,072 bytes |
| 512MiB | 532,676,608 bytes |
| 32GiB | 34,091,302,912 bytes |
| 64GiB | 68,182,605,824 bytes |

2. 线下传输

当数据量非常大的时候,使用线上传输就变得不太可能,所以有必要使用线下的传输方式

这个过程大概有以下步骤

- 创建 car 文件
- 对文件生成 CID
- 初始化提交一个线下存储交易的提议
- 线下传输文件
- 最后矿工执行交易

使用lotus在不导入的前提下只创建car文件

`lotus client generate-car <inputPath> <outputPath>`

对指定矿工创建文件片的 CID

`lotus client commP <inputCAR filepath> <miner>`

提议线下交易

`lotus client deal --manual-piece-cid=CID --manual-piece-size=datasize <Data CID> <miner> <piece> <duration>`

线下传输可能就是快递发送

矿工操作
	
`lotus-miner deals import-data <dealCID> <filepath>`

只要第一个对该sector的 PoSt 时空证明上链,交易就开始了

#### Lotus检索数据

数据的检索主要是通过向 检索矿工 发起 检索交易 来实现的,在这个协议中,客户同意向检索矿工就获取数据给付一定的费用.

使用使用[付款渠道](https://docs.filecoin.io/build/lotus/payment-channels.html)这种方式,支付会在数据接受到的时候就开始发生转移.

与存储交易不同的是,检索交易更多的会发生在链下

目前,Lotus支持从最初直接存储数据的存储矿工处直接检索

当然根据网络协议的设计,它更应该被有高效快速高带宽,专门进行这种业务的独立检索矿工来实现.

届时,客户就可以在整个网络中检索需要的数据,通过 DHT ,整个链 或外带的一些索引,聚合器来选择最适合他们的检索获取数据的方式.

要从filecoin网络中检索数据,目前大概的流程是这样的

- 首先使用需要获取的数据的CID来向网络询问有哪些矿工存储了这些数据
- 当矿工确认他们存储了具体CID对应的数据后,提供一个获取数据的报价
- 需要发起一个检索交易的提议
- 从矿工处获取数据,确认数据正确,通过[付款渠道](https://docs.filecoin.io/build/lotus/payment-channels.html)进行增量付款,知道整个数据获取结束

当前必须接收全部数据，尽管将来有可能使用IPLD选择器来选择自定义子集进行检索获取数据

通过CID查找存储数据的矿工

`lotus client find <Data CID>`

进行检索交易简化后的命令如下,更多的参数请使用 `--help` 确认

`lotus client retrieve --miner <miner ID> <Data CID> <outfile>`

输出文件如果不存在的话,会在 `lotus`的存储库目录中创建,这会需要2-10分钟

TIPS:如果你是使用自己定义的 IPLD-DAG 序列化的 car 文件,不能自动的转化为一个文件,比如说不是 `unixfs` 格式的,如果是这样就需要加上 `--car` 参数然后获取文件后手动的对DAG进行反序列化

#### 将现有在IPFS中的数据导入Filecoin

首先需要在本地部署 `IPFS Daemon`

在 `$LOTUS_PATH/config.toml` 中修改配置

```
[Client]
UseIpfs = true
```

然后使用命令

```
$ ipfs add -r SomeData
QmSomeData
$ ./lotus client deal QmSomeData t01000 0.0000000001 80000
```

#### 故障排除

- 发起存储交易时

```
WARN  main  lotus/main.go:72  failed to start deal: computing commP failed: generating CommP: Piece must be at least 127 bytes
```

这个错误表示加入filecoin的文件大小最小是 127bytes

- 发起检索交易时获取到了0kb的文件

这说明了要获取的文件还没有被封装上链,需要让矿工确认sector是否封装完成

`lotus-miner sectors list`

当封装完成 `pSet:NO` 会变成 `pSet:YES`