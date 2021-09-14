---
title: arweave入坑注意事项
tags: 
---

[toc]

首先吐槽一下官方的 miner guide 真的是简陋,连个参数说明都不全,得一边看源码一边去 discord 问

不做主观判断,不做横向比较,只做笔记

使用系统 Ubuntu 20.04

内存理论上 8G 就够,不过越多当然越好,由于randomX做pow,所以高频率低cl延迟的内存会更好,比如 DDR4 3600 CL14

带宽不是关键因素,但是有公网固定IP,或者 ip nat 会更好更稳定

#### 文件打开数设置

如果简单的用 ulimit 或 更新 `/etc/security/limits.conf` 文件会发现内核对数值设置是有上限的,所以需要先修改内核设置

```
cat >> /etc/sysctl.conf << EOF

#提高文件打开数
fs.file-max=1000000
#修改内核文件打开数
fs.nr_open=9000001
EOF
sysctl -p
```

然后再改配置文件,写的啰嗦了,反正能用就行,值官方建议在100万以上

```
cat >> /etc/security/limits.conf << EOF
*               soft            nofile  1000000
*               hard            nofile  1000000
*               soft            nproc   1000000
*               hard            nproc   1000000
root            soft            nofile  1000000
root            hard            nofile  1000000
root            soft            nproc   1000000
root            hard            nproc   1000000
EOF
```

最后记得确认一遍,毕竟谁也不知道那个启动加载文件中就写了一句

```
cat /etc/sysctl.conf
cat /etc/security/limits.conf
cat /etc/profile | grep ulimit
cat /etc/rc.local | grep ulimit 
cat ~/.bashrc | grep ulimit
ulimit -n
```

#### 出块流程简述

翻译自官方wiki,从这里我们得以判断服务器的配置大概

Arweave网络中的挖掘包含多个阶段:  

1. 在需要出新块的时候,为节点选择一个全网范围的子集 (所有数据的10%) 作为下面搜索空间读取数据的范围.
2. 候选块的 metadata 和 一个随机数(nonce,即计算步骤1随机获得) 使用 randomX 进行哈希
3. 得出一个大整型数被减少到搜索空间读取数据给定的范围内(等比?取余?我不确定),称之为挑战字节,矿工必须能够访问到该数据才可以进入下一步
4. 矿工会讲爆款挑战字节的 chunk 块从磁盘读取到内存中,如果矿工无法读取到该chunk,则从第二步换一个nonce重新开始 
5. 矿工读取到了数据,需要再做一次merkle 证明,以确定本地保存了该 chunk,即有之前的块(实现 proof of history)
6. 候选快的 metadata ,上述数据的 merkle 证明,之前的 chunk 块,随机数 nonce 一起通过 randomX 进行哈希 (计算步骤2)
7. 计算得出的结果会和网络难度级别比较,如果不符合则重新从第二阶段开始
8. 当节点产生了一个有效的候选块,则 spora证明和block header会被广播到网络中

所以,简而言之,依然是一个 pow 的事情,算法变成 randomX,不能跟门罗一样啊,所以加一个本地数据进行hash,顺便把这个加进去的东西叫做 POH 搞得高大上一点,仅仅这一点点改变,造就了一个完全不同的应用,恰好适用.

从流程可以看出,本身 pow 依然是一个 randomX 的算力比较,但是每一次hash后都需要读盘,所以磁盘io和iops都需要很强才行.**目前是一个 cpu,ram,disk 之间均衡的一个游戏**

目前看来 HDD 单盘是肯定没戏唱的, HDD raid0, io也许能提升,但是 4k 和 iops 依然稀烂. 所以目前还是需要 nvme 协议的 SSD 才行.同时这个项目由于其特性永久存储,所以数据量不可能和 filecoin 做对比.目前的 10多T 是一个很容易全部包含的数量级

#### 服务器 Spora 哈希率的估算

1. 服务器cpu能提供的 randomX hash,这个可以通过 benchmark,也可以直接查硬件,一般来说获得的数值都是根据CPU来设置线程的,但是在 AR 中并非设置所有线程来执行 randomX为最佳,他有step1,step2,还有io线程.所以整体上数值肯定会小于理论值.我下面提供了一个表可以查询一下常见的CPU,这个值作为 $1
2. 磁盘带宽估算,以GiB/s 为单位 `hdparm -t /dev/sda` ,这个值作为 $2
3. 本地存储了全网多少分之一的数据,本地数据可以查看 chunk 目录(du -sh /path/to/data/dir/chunk_storage ,下面有可以看到准确数值 metrics方法),全网么看一下区块链浏览器,这个值作为 $3

计算公式,通常来说,实际hash数是计算值的0.7-0.9之间

`echo "1000000 / (1000000 * ($3 - 1) / $1 + 2 * 1000000 / $1 + 1000000 * 256 / ($2 * 1024 * 1024))" | bc -l`

CPU randomX 的 benchmark,这是门罗币相同的算法,其中32是CPU的线程数,减少和增加都会影响到最后的结果

不要用auto,argon2的实现不同分数差很多,一般来说用掉所有线程分数是最高的

`./bin/randomx-benchmark --mine --init 32 --threads 32 --jit`

硬件对应的分数表, * 表示并不一定准确

```
AMD THREADRIPPER 3990X = 33.81 kh
AMD THREADRIPPER 3970X = 21.35 kh
AMD THREADRIPPER 3960X = 19.79 kh
AMD THREADRIPPER 2990WX = 14.04 kh
AMD THREADRIPPER 2950X = 8.40 kh
AMD THREADRIPPER 2920X = 7.35 kh
AMD THREADRIPPER 1950X = 8.79 kh
AMD THREADRIPPER 1920X = 7.14 kh
AMD THREADRIPPER 1900X = 3.39 kh
AMD RYZEN 9 5950X = 11.99 kh
AMD RYZEN 9 5900X = 10.85 kh
*AMD RYZEN 9 3900 PRO = 6.78 kh
AMD RYZEN 9 3950X = 13.88 kh
AMD RYZEN 9 3900X = 11.41 kh
AMD RYZEN 7 5800X = 6.69 kh
AMD RYZEN 7 3800X = 7.29 kh
AMD RYZEN 7 3700X = 7.22 kh
AMD RYZEN 7 2700X = 4.58 kh
AMD RYZEN 7 2700 = 4.11 kh
AMD RYZEN 7 1700X = 3.96 kh
AMD RYZEN 5 5600X = 5.31 kh
AMD RYZEN 5 3600X = 5.84 kh
AMD RYZEN 5 3600 = 5.79 kh
AMD RYZEN 5 3500X = 3.43 kh
AMD RYZEN 5 3500 = 3.01 kh
AMD RYZEN 5 2600X = 3.13 kh
AMD RYZEN 5 2600 = 3.01 kh
AMD RYZEN 5 1600 = 2.87 kh
AMD RYZEN 5 1500X = 2.39 kh
AMD RYZEN 3 3100 = 3.22 kh
AMD RYZEN 3 1300X = 2.11 kh
AMD RYZEN 3 1200 = 2.05 kh
AMD EPYC 7742 = 30.80 kh
AMD EPYC 7702 = 30.10 kh
AMD EPYC 7R32 = 24.61 kh
AMD EPYC 7502P = 17.71 kh
AMD EPYC 7402P = 14.70 kh
AMD EPYC 7601 = 10.43 kh
AMD EPYC 7571 = 11.62 kh
AMD EPYC 7551P = 10.92 kh
AMD EPYC 7401P = 8.70 kh
AMD EPYC 7302P = 9.45 kh
AMD EPYC 7351P = 7.07 kh
INTEL XEON PLATINUM 8136 = 7.88 kh
INTEL XEON PLATINUM 8160 = 6.65 kh
INTEL XEON GOLD 6242 = 6.24 kh
INTEL XEON GOLD 6154 = 5.88 kh
INTEL XEON GOLD 6126 = 5.06 kh
INTEL XEON GOLD 6132 = 0.45 kh
INTEL XEON GOLD 5122 = 1.79 kh
INTEL XEON SILVER 4216 = 5.78 kh
INTEL XEON SILVER 4214 = 4.38 kh
INTEL XEON BRONZE 3204 = 1.43 kh
INTEL XEON E5-2698 V4 = 4.62 kh
INTEL XEON E5-2687W V4 = 3.21 kh
INTEL XEON E5-2673 V4 = 5.81 kh
INTEL XEON E5-2673 V4 = 5.81 kh
*INTEL XEON E5-2643 V4 = 2.21 kh
INTEL XEON E5-2630 V4 = 2.96 kh
INTEL XEON E5-2609 V4 = 1.54 kh
INTEL XEON E5-4669 V3 = 4.45 kh
INTEL XEON E5-4627 V3 = 3.50 kh
INTEL XEON E5-2680 V3 = 4.04 kh
INTEL XEON E5-2699 V3 = 5.70 kh
INTEL XEON E5-2696 V3 = 5.39 kh
INTEL XEON E5-2678 V3 = 4.48 kh
INTEL XEON E5-2673 V3 = 3.50 kh
*INTEL XEON E5-2670 V3 = 3.16 kh
INTEL XEON E5-2667 V3 = 4.87 kh
INTEL XEON E5-2660 V3 = 3.45 kh
INTEL XEON E5-2630L V3 = 2.81 kh
INTEL XEON E5-2690 V3 = 4.17 kh
INTEL XEON E5-2683 V3 = 3.04 kh
INTEL XEON E5-2640 V3 = 2.69 kh
INTEL XEON E5-2630 V3 = 2.64 kh
INTEL XEON E5-2620 V3 = 2.17 kh
INTEL XEON E7-4880 V2 = 3.85 kh
INTEL XEON E5-2697 V2 = 3.38 kh
INTEL XEON E5-2696 V2 = 3.57 kh
INTEL XEON E5-2695 V2 = 3.15 kh
INTEL XEON E5-2687W V2 = 3.00 kh
INTEL XEON E5-2680 V2 = 2.77 kh
*INTEL XEON E5-2670 V2 = 2.04 kh
INTEL XEON E5 2650L V2 = 1.99 kh
INTEL XEON E5-2660 V2 = 2.70 kh
*INTEL XEON E5-2651 V2 = 2.06 kh
INTEL XEON E5-2650 V2 = 2.38 kh
*INTEL XEON E5-2637 V2 = 1.56 kh
INTEL XEON E5-2630 V2 = 1.87 kh
INTEL XEON E5-2630L V2 = 1.74 kh
INTEL XEON E5-2620 V2 = 1.63 kh
*INTEL XEON E5-2603 V2 = 0.49 kh
INTEL XEON E5-1650 V2 = 1.96 kh
INTEL XEON E5-1607 V2 = 1.32 kh
*INTEL XEON E5-2403 V2 = 0.39 kh
INTEL XEON E7-8837 = 1.61 kh
INTEL XEON E7-8870 = 1.40 kh
INTEL XEON E7-4870 = 2.19 kh
INTEL XEON E5-4640 = 1.84 kh
INTEL XEON E5-4617 = 1.83 kh
*INTEL XEON E5-2690 = 2.24 kh
INTEL XEON E5-2689 = 2.49 kh
INTEL XEON E5-2670 = 2.24 kh
INTEL XEON E5-2660 = 2.16 kh
INTEL XEON E5-2650 = 1.90 kh
INTEL XEON E5-2450L = 1.50 kh
INTEL XEON E5-2640 = 1.66 kh
INTEL XEON E5-2620 = 1.38 kh
INTEL XEON E5-1620 = 1.40 kh
*INTEL XEON E5649 = 0.96 kh
*INTEL XEON E5645 = 1.12 kh
**INTEL XEON E5450 = 0.49 kh
INTEL XEON E5620 = 0.84 kh
INTEL I9-10980XE = 7.14 kh
*INTEL I9-9900K = 4.86 kh
INTEL I7-11700K = 4.17 kh
INTEL I7-10750H = 1.61 kh
INTEL I7-10700K = 4.14 kh
INTEL I7-10710U = 2.14 kh
*INTEL I7-9700K = 3.47 kh
INTEL I7-9750H = 2.04 kh
INTEL I7-8809G = 1.66 kh
INTEL I7-8700K = 2.49 kh
INTEL I7-8700B = 1.89 kh
INTEL I7-8559U = 1.68 kh
INTEL I7-7700K = 2.25 kh
INTEL I7-7700 = 1.99 kh
INTEL I7-6700K = 2.06 kh
INTEL I7-6700 = 1.81 kh
INTEL I7-6850K = 2.45 kh
INTEL I7-5960X = 3.67 kh
INTEL I7-5820K = 2.09 kh
INTEL I7-5775C = 1.68 kh
INTEL I7-4960X = 2.69 kh
INTEL I7-4930K = 2.09 kh
INTEL I7-4790K = 1.96 kh
INTEL I7-4790 = 1.83 kh
INTEL I7-4790 = 1.91 kh
INTEL I7-4770K = 1.89 kh
INTEL I7-4770 = 1.65 kh
INTEL I7-4720HQ = 3.98 kh
INTEL I7-3970X = 2.05 kh
*INTEL I7-3930K = 1.68 kh
INTEL I7-3770K = 1.90 kh
INTEL I7-3770 = 1.83 kh
INTEL I7-2600 = 1.56 kh
*INTEL I5-9600K = 2.31 kh
```

#### 官方原生软件 arweave 的使用

首先通过官方软件来理解一下挖矿过程中可以配置的东西,以及可能影响性能的一些参数,使用的软件版本为 arweave 2.4.4.0

一般来说,对于功能或者特性的开关位是通过命令行参数来进行配置,而具体参数可以在命令行也可以在配置文件,我们以一个例子来看

启动命令

```
./bin/start enable randomx_jit enable randomx_cache_qos enable randomx_large_pages enable randomx_hardware_aes config_file config.sys
```

配置文件 config.sys

```
{
data_dir: "/data/arweave",	
mine: true,
sync_jobs: 4,	
stage_one_hashing_threads: 10,	
stage_two_hashing_threads: 5,	
io_threads: 10,	
randomx_bulk_hashing_iterations: 12,	
max_connections: 300,	
disk_space: 20,	
max_disk_pool_buffer_mb: 5000,	
max_disk_pool_data_root_buffer_mb: 1500,	
mining_addr: "1p53qU4bUS4WyIILqnYtsuowdL6MsvEqN-HwIfyfi60",	
peers: [
188.166.200.45,
188.166.192.169,
163.47.11.64,
139.59.51.59,
138.197.232.192
],	
port: 1984	
}
```

下面就来一个一个说明,参数意义和参数取值的方法

1. enable randomx_jit 确切的不知道,在bench的时候大概知道是jit效率最高
2. enable randomx_cache_qos 大概知道是randomx时可以配置 qos
3. enable randomx_large_pages 开启大内存页提高效率,当然是需要先进行配置的,ubuntu默认应该都是没有的,而且你也要有更多的内存才行
4. enable randomx_hardware_aes 新的CPU都支持 aes ,开启应该也是默认值
5. data_dir 默认是在软件当前目录进行数据的下载,通过data_dir可以指定不同的目录

	这里需要展开说一下,由于挖矿所需要的主要数据肯定要在SSD中,而且需要若干TB,一般来说可能是用 raid0 , mdadm ,lvm来组装若干的硬盘,性能肯定是 raid0>mdadm>lvm stripe ,灵活性正好反过来.对于挖矿锁需要的次要数据,其实也是相当的大,比如 wallet_list 也是全部都会保存在本地的,那么我们可以用 hdd+ssd 的方式来使用,通过 mount 或者 软连接的方式进行分磁盘存储,其中 `chunk_storage` 和 `rocksdb` 需要保存在高速SSD中,比如
	
	```
	The output of df -h should look like:
	/dev/hdd1    5720650792 344328088 5087947920 7%  /your/dir
	/dev/nvme1n1 104857600  2097152   102760448  2%  /your/dir/chunk_storage
	/dev/nvme1n2 104857600  2097152   102760448  2%  /your/dir/rocksdb
	```
	
	ext4 是最稳定的 linux 文件系统,单只能包含 4M目录条目,肯定是不够的,所以需要通过使用tune2fs命令和e2fsck -D命令增加large_dir和dir_index来实现
	
	官方不推荐 xfs ,因为一旦异常关闭,文件有可能损坏,这个跟 filecoin 封装数据不同,损坏了就需要再下载,不过我们可以留一个备份.所以我依然用了 xfs
	
	**注意:不要使用引导根目录来存储weave，因为引导程序grub2不支持large_dir设置。如果您在引导分区上实现了large_dir，则系统将不再引导**	
	
6. mine 开启挖矿
7. sync_jobs 从区块链中下载数据的任务数,在一开始本地没有数据的时候建议 关闭 mine,并把 sync_jobs改为 200 进行快速数据下载,当然更关键的是下面的peer链接质量
8. stage_one_hashing_threads step1的 randomX 线程数
9. stage_two_hashing_threads step2 的randomX 线程数
10. io_threads 执行io读取的线程数,很多时候减少上面2个参数,提高 io 线程数最后的 spora率会更高

	这里提一下线程数设置的简单方法,主要是通过日志来进行分析,因为本地数据同步会越来越多.一开始关掉 mine 也是尽可能先同步数据,在数据同步到一定量的时候,通过日志来分析.
	recall bytes computed/s 应该大概等于 Miner spora rate 除以你保存数据的份额	
	如果读取到的数量太少,考虑增加 io_threads 减少 stage_one_hashing_threads.所以一开始可以设置所有的 randomX 线程,然后慢慢降低
	
11. randomx_bulk_hashing_iterations 意义不确定,但是服务器越强,randomx_bulk_hashing_iterations 可以设置的越高需要进行测试,比如设置为128是一个比较大的数值了
12. max_connections 连接数管理
13. disk_space 同步数据本地磁盘占用控制 GB
14. max_disk_pool_buffer_mb 和 max_disk_pool_data_root_buffer_mb 大概都是buffer类的把...
15. mining_addr 挖出块后获得奖励的地址

	创建一个地址最简单的方式是通过浏览器扩展,在线离线都是可以的,直接商店搜索 Arweave web archiver and wallet
		
16. peers 一个数组,或者在命令行可以多次指定的初始链接,例子中是官方推荐的 bootstrap 节点,但是国内链接很差,一半都会通过扫描来拿到低延迟的节点,比如 [virdpool's peers tool](https://explorer.ar.virdpool.com/#/peer_list)
17. port 本地的端口,因为是erlang的,需要通过 empd 通讯 ,所以这里有一个坑,默认的 1984 可能是被占用的,要么直接改,要么设置环境变量 ERL_DIST_PORT

#### 官方软件使用的坑和技巧点

1. 连通性,即公网设置

	由于存在 peer 链接,那么有固定公网IP或者 ip nat 肯定是最通畅的,但是我实在是没有找到 listen address的配置,难道这个这么只能,不需要libp2p那么显式的指定??
	
	对于动态 DHCP 如果拿到公网IP的 那就用 DDNS 来解决,如果有多台服务器,则需要每个都改端口,然后端口转发
	
2. 日志,监控

	日志其实直接看 logs 下文件就可以了, 用 ./bin/logs -f 也可以,比较反人类,其中
	
	- 挖矿的spora算力的日志 `Miner spora rate: ... recall bytes computed/s: ... MiB/s read: ...`
	- 出块的日志 `Produced candidate block`
	- 等待20分钟后出块被确认的日志 `Your block ... was accepted by the network`
	
	监控的话,就走端口 1984 来看 up down 好了, localhost:1984 这可以通过 http 访问,比如
	
	localhost:1984/metrics, v2_index_data_size是你已经下载的数据的字节数，而weave_size是Weave的当前大小
	
3. 关闭挖矿

	./bin/stop
	
	pkill arweave
	
	不要 kill -9 !!!
	
4. 一台机器同步了数据,快速复制到其他机器,虽然通过出块流程我们知道,全网如果数据很大,那么我们每台机器同步不同数据对效率来说会有提升,但是一方面现在的全网数据只有10多T,而且下载数据实在太慢了.所以,做拷贝是可以的,同样的一个冷备份也可以实现了

	- 两台机器都停止挖矿
	- 拷贝文件需要注意 chunk_storage 文件夹 保存了很多稀疏文件,如果要拷贝需要先 tar -Scf 打包,或者例如 cp --sparse=always
	- 最少需要拷贝
		data_sync_state 文件
		chunk_storage_index 文件
		rocksdb/ar_data_sync_db 文件夹
		rocksdb/ar_data_sync_chunk_db 文件夹
		chunk_storage 文件夹
		
5. 使用 systemctl 来控制
	
	强烈不建议, 开 screen 直接 foreward 执行时最好的,当然如果运行的好也是可以的

	```
	[Unit]
	Description=Arweave miner
	After=network.target
	StartLimitIntervalSec=0

	[Service]
	Type=simple
	Restart=always
	RestartSec=1
	User=root
	LimitNOFILE=1000000
	ExecStart=home_path/bin/start  enable randomx_jit enable randomx_cache_qos enable randomx_large_pages enable randomx_hardware_aes config_file home_path/config.sys
	ExecStop=home_path/bin/stop

	[Install]
	WantedBy=multi-user.target
	```
	
6. 最后的分析阶段	

电脑主机主要配置:吃cpu，硬盘，内存。不吃网络，显卡。所以cpu和硬盘一定要好，高性能cpu+NVME固态。
	
#### hpool 矿池接入

为什么用 HPOOL.矿池就那么几个,hpool蛮大的,而且实现,收费都大同小异,hpool在中国

这个有点太简单了.注册,开通,获取 apikey,下载软件,都是可执行文件,配置随便改一改路径就行,没有那么多的设置项,想想就知道,很多调度的东西都通过proxy和矿池对接,本地不需要完整链,只是需要下载hpool自己提供的chunk数据,打包压缩过的,百度网盘下载这个比较尴尬

所以问题反而变成了 **bypy-命令行下使用百度网盘**

- `pip install bypy`
- `bypy info` 获取一个地址进行 百度开放平台 oauth 授权,由于是作为应用接入,所以网盘中只有 /apps/bypy 下才可以读取到数据
- `bypy syncup xxx/bypy upload xxx` 上传 , 我用不到
- `bypy downfile xxx/bypy syncdown/bypy downdir` 下载,直接全部同步走起,给百度贡献了一个会员

#### ankr 一键部署

[Ankr](https://www.ankr.com/) 这个就更简单了,毕竟是收费的,订阅机制,信用卡和usdt都可以,一键!!!就不用写了把