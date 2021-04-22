---
title: Chia
tags: 
---

[toc]

#### 大致认识

看了几天,实际挖了几个图之后跟风写下 chia 指北

首先来看下社区内流传最广的入门资料

- Chia(奇亚) 官网 https://www.chia.net/cn/

	亲切的看到区块链项目原生有 cn 啊,不得不说一句项目方背后的CX团队本地化是非常到位的
	
- 区块浏览器 https://www.chiaexplorer.com/

	搞得我一头雾水,为了和项目宣传的所谓 "环保" ,整个网站设计风格都是绿油油的,还有一颗大树,不得不说,这设计师晚上肯定有加到鸡腿
	
- Github 源码库 https://github.com/Chia-Network
		
	就看这个就好了啊...wiki记得看,基本上关注的所有东西wiki都有
	
- Chia(奇亚) 商业白皮书中文版 [宣传地址](https://www.kuangjiwan.com/news/news-2883.html), [实际地址](https://www.kuangjiwan.com/upload/doc/Chia-Business-Whitepaper-2021-02-09-v1.0.pdf)

	实力自吹,明明白白告诉你项目方想赚钱,清清楚楚告诉你就是来收割的
	
- 技术绿皮书 https://www.chia.net/assets/ChiaGreenPaper.pdf

	脑壳疼,简单的东西写的好复杂
	
- Chia win挖矿教程 https://www.kuangjiwan.com/news/news-2882.html

	好评 直接把新项目挖矿入门简化为 eth 的轻松矿工一般
	
	2个路径会有侵入 `C:\Users\[User]\.chia`,`C:\Users\[User]\AppData\Local\chia-blockchain` ,前者主要是配置,日志,后者为程序注意路径是默认提权的
	
- Chia(奇亚) 常见问题解答 https://www.kuangjiwan.com/news/news-2884.html

	实力自吹版本2,国内本地化的CX团队实力不俗
	
- Chia(奇亚) 命令行参数 https://www.kuangjiwan.com/news/news-2886.html

	简单参数分析.可以用来搞清楚一些基础概念
	
	比如stripe,bucket,队列,ram,cpu之间关系都有提到,很简单
	
- Chia(奇亚)plot 文件规格大小 [落后版本](https://www.kuangjiwan.com/news/news-2887.html) 

	这里官方wiki也是错误的,只有release的软件开挖的地方写了最新的数据
	
	![准确数据](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Chia/2021422/1619090043983.png)
	
- Chia 减半计划表 https://www.kuangjiwan.com/news/news-2889.html

	模仿btc
	
- Chia 多机集群教程 https://www.kuangjiwan.com/news/news-2891.html

	这里我特地贴一下英文原文,其实一点也不复杂,就是因为要求低,可以支持异地组矿池,为了安全要ssl.弄过nginx的肯定都会
	
	```
	This guide allows you to run a harvester on each machine, without having to run a full node, wallet, and farmer on each one. This keeps your system simpler, uses less bandwidth, space, CPU, and also keeps your keys safer. It also makes your overall farm quicker and more efficient when replying to challenges.
	The architecture is composed of one main machine which runs the farmer, full node, and wallet, and other machines which run only the harvester. Only your main machine will connect to the Chia network.
	To secure communication between your harvester and main machine, TLS is used where your main machine will be the private Certification Authority (CA) that signs all certificates. Each harvester must have it's own signed certificate to properly communicate with your main machine.
										   _____  Harvester 1 (certificate A)
										  /
	other network peers  --------   Main machine (CA) ------  Harvester 2 (certificate B)
										  \_____  Harvester 3 (certificate C)
		• First, make sure Chia is installed on all machines and initialized by running the CLI chia init.
		• When creating plots on the other harvesters, use chia plots create -f farmer_key -p pool_key, inserting the farmer and pool keys from your main machine. Alternatively, you could copy your private keys over by using chia keys add, but this is less secure. After creating a plot, run chia plots check to ensure everything is working correctly.
		• Make a copy of your main machine CA directory located in ~/.chia/mainnet/config/ssl/ca to be accessible by your harvester machines; you can share the ssl/ca directory on a network drive, USB key, or do a network copy to each harvester. You must copy the new ssl/ca directory with each version of chia-blockchain, so if you are upgrading from beta -> mainnet you must copy the new ca contents.
	Then for each harvester, follow these steps:
		1. Make sure your main machines IP address on port 8447 is accessible by your harvester machines
		2. Shut down all chia daemon processes with chia stop all -d
		3. Make a backup of any settings in your harvester
		4. Run chia init -c [directory] on your harvester, where [directory] is the copy of your main machine CA directory. This command creates a new certificate signed by your main machine's CA.
		5. Open the ~/.chia/mainnet/config/config.yaml file in each harvester, and enter your main machine's IP address in the remote harvester's farmer_peer section (NOT full_node).
	EX:
	harvester:
	  chia_ssl_ca:
		crt: config/ssl/ca/chia_ca.crt
		key: config/ssl/ca/chia_ca.key
	  farmer_peer:
		host: Main.Machine.IP
		port: 8447
		6. Launch the harvester by running CLI chia start harvester and you should see a new connection on your main machine in your INFO level logs.
		7. To stop the harvester, you run CLI chia stop harvester
	Warning:
	You cannot copy the entire config/ssl directory from one machine to another. Each harvester must have a different set of TLS certificates for your main machine to recognize it as different harvesters. Unintended bugs can occur, including harvesters failing to work properly when the same certificates are shared among different machines.
	Security Concern:
	Since beta27, the CA files are copied to each harvester, as the daemon currently needs it to startup correctly. This is not ideal, and a new way to distribute certificates will be implemented in a subsequent release post mainnet launch. Please be careful when running your harvester that is accessible from the open internet.
	Note:
	Currently (mainnet), the GUI doesn't show harvester plots. The best way to see if it's working is shut down Chia full node and set your logging level to INFO in your config.yaml on your main machine and restart Chia full node. Now you can check the log ~/.chia/mainnet/log/debug.log and see if you get messages like the following:
	[time stamp] farmer farmer_server   : INFO   -> new_signage_point to peer [harvester IP address] [peer id - 64 char hexadecimal]
	[time stamp] farmer farmer_server   : INFO   <- new_proof_of_space from peer [peer id - 64 char hexadecimal] [harvester IP address]
	The new_signage_point message states the farmer sent a challenge to your harvester. The new_proof_of_space message states the harvester found a proof for the challenge. You will get more new_signage_point messages than new_proof_of_space messages.	
	```
	
#### 问题和答案(负面)

1. 能省电省资源吗

	是的,电的确省一点,毕竟不需要一直运算,之需要一个P盘,之后躺着兑彩票就好了,但是肯定不是P完还能存照片的,都写满彩票数据了么
	
2. 存储肯定是机械HDD,那么P盘用什么盘呢

	用SSD是最佳选择,毕竟项目早期速度决定一切,SSD可以单盘并行最大化单机性能,但不能说HDD就不能P.一块机械盘100M左右读写差不多12-15小时也可以出一个k32,HDD可以很多啊.但是请注意 SSD 做软raid0完全没有问题,可以把单机跑到内存极限.但是HDD并不建议做 软raid0.直接单盘跑一个队列,多块硬盘独立挂队列即可
	
3. chia真能去中心化吗

	就跟filecoin现在也就2000多矿工,btc,eth都是asic,fpga一样.chia绝对不是空闲的存储空间人人都有,人人都能挖,P好盘了你挂着不就好了吗.不要电不吵吗,空闲空间我放点小姐姐不行吗,绝对不可能去中心化,一定会跟传统挖矿一样建立大量的pool
	
4. 目前加入矿池好吗

	早期不建议,因为public key是不通的,早期个人稍微挖挖也能出块,不过目前看这速度,少于100万投资很难做到比较久时间,虽然我也不看好chia能做很长时间
	
#### 独立矿工的硬件建议

1. 购买设备主要看投资成本,这是第一要素,比如关于ssd的耐久度和每P出来1T的大致成本,wiki有详细的资料,不贴excel截图了,不过P3700,P3600不愧intel最后的荣光 Het Mlc 再次强势夺魁,我去年买的 S3710 1.2T成绩也不错.牙膏厂NB
2. 功耗,噪音,散热,网络,不要考虑冗余,小手笔用nas存储即可,大手笔用JBOD扩列,单机几百个硬盘他不香吗
3. 盘位永远比盘重要,有大的买大的盘
4. P盘的SSD 3DWPD是最低要求

#### 附录 linux 中对硬盘 smart monitor工具

- NVMe

	https://github.com/linux-nvme/nvme-cli

	https://nvmexpress.org/open-source-nvme-management-utility-nvme-command-line-interface-nvme-cli/

	Reading endurance with NVMe-CLI - this is the gas gauge that shows total endurance used

	`sudo nvme smart-log /dev/nvme0 | grep percentage_used`

	Reading amount of writes that the drive have actually done

	`sudo nvme smart-log /dev/nvme0 | grep data_units_written`

	Bytes written = output * 1000 * 512B

	TBW = output * 1000 * 512B / (1000^4) or (1024^4)

	To find out NAND writes, you will have use the vendor plugins for NVMe-CLI.

	`sudo nvme <vendor name> help`

	Example with an Intel SSD

	`sudo nvme intel smart-log-add /dev/nvme0`

- SATA

	In SATA you can use the following commands

	`sudo apt install smartmontools`

	`sudo smartctl -x /dev/sda | grep Logical`

	`sudo smartctl -a /dev/sda`

	looking for Media_Wearout_Indicator

	note this does also work for NVMe for basic SMART health info

	`sudo smartctl -a /dev/nvme0`

- SAS

	`sg_logs /dev/sg1 --page=0x11`

	look for

	`Percentage used endurance indicator: 0%`