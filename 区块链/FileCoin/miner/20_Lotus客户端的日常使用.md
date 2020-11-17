---
title: 20_Lotus客户端的日常使用
---

[toc]

* [常用操作](#%E5%B8%B8%E7%94%A8%E6%93%8D%E4%BD%9C)
* [钱包管理](#%E9%92%B1%E5%8C%85%E7%AE%A1%E7%90%86)
* [附录-Lotus套件的软件说明](#lotus%E5%A5%97%E4%BB%B6%E7%9A%84%E8%BD%AF%E4%BB%B6%E8%AF%B4%E6%98%8E)

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