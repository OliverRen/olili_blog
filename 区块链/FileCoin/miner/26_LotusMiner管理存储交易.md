---
title: 26_LotusMiner管理存储交易
tags: 
---

在矿工的生存内,lotus客户端可以向整个网络发布矿工要求的存储价格,并应答存储提议和执行传输与交易

存储交易的几个主要的阶段分别是 
- 数据传输 (transfer 用于在线交易) 或数据导入 (import 用于离线交易); 
- 矿工对带有交易数据的sector进行密封; 
- 矿工每24小时不间断的在订单时间内对 sector 进行时空证明

#### 启用和禁用存储交易

miner对交易的启用和禁用可以有两种方法:
	- 配置法,修改 $LOTUS_MINER_PATH/config.toml 文件下的 `[DealMaking]`,然后重新启动 miner
	- 命令法,由于修改配置需要重启 miner,所以较为推荐使用命令法来进行修改,同时命令也会修改文件中的值,如果后续真的重新了矿机,其配置也是生效的

要禁用存储交易 `lotus-miner storage-deals selection reject --online --offline`

要启用存储交易 `lotus-miner storage-deals selection reset`

你可以使用命令 `lotus-miner storage-deals selection list` 来进行校验

#### 设定存储交易的要价

达成存储交易一方面需要有需求,另外一方面就是矿工的价格和条件了.

这是由矿工进行设置的,只要达成条件,那么矿工就可以自动的接受.

这是由命令 `lotus-miner storage-deals set-ask` 来设置的. 举例如下:

``` shell
lotus-miner storage-deals set-ask \
  --price 0.0000001 \
  --verified-price 0.0000001  \
  --min-piece-size 128MiB \
  --max-piece-size 32GB
```

上述例子即矿工将交易价格设置为 每GiB每epoch的价格为 0.0000001 FIL（100 nanoFIL）

也就是说用户每过30秒存储的每GB数据就要支付 100 nanoFIL

所以如果客户需要存储 5GiB的数据一周,那么就需要支付 

`5GiB * 100nanoFIL/GiB_Epoch * 20160 Epochs = 10080 microFIL`.

矿工也可以使用 `--help` 选项来查看设置交易的最大和最小交易量

矿工可以使用命令 `lotus-miner storage-deals get-ask` 查看自己的要价

使用命令 `lotus-miner storage-deals list -v` 来查看当前正在进行的交易,这个命令会显示

- 交易创建时。
- 正在存储的DataCID。
- 提交它的客户的钱包地址。
- 大小和持续时间（以时间段为单位）（每个时间段30秒）

相对的客户可以使用 `lotus client query-ask <minerID>` 来查询指定矿工的要价.

#### 使用过滤器限制交易 Piece CID过滤

这主要是通过配置文件中 `[DealMaking]` 中的 `Filter` 来实现的

他可以通过一个外部程序或者脚本返回 true 来接受交易,否则就拒绝.

如果要禁止接单直接把 lotusminer 下 config.toml 的  `Filter = ""` 改成  `Filter = "false"` 重启miner 就可以了

如果有一些内容不是很好,黄色啊之类的,那么可以通过cid进行阻止他们传入.下列命令接受一个文件,文件内容应该每行包括一个cid.

`lotus-miner storage-deals set-blocklist blocklist-file.txt`

可以使用命令 `lotus-miner storage-deals get-blocklist` 查看阻止列表 

或使用命令 `lotus-miner storage-deals reset-blocklist` 来清除列表

#### 交易等待

在sector中接受多个交易,操作效率就更高,这减少了密封和验证的操作.这主要是由配置中的 `[Sealing]` 的 `WaitDealsDelay` 来控制的,即等待多少时间.

#### 离线交易数据的导入

离线交易的数据导入,使用命令 `lotus-miner deals import-data <dealCid> <filePath>`

