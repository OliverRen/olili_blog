---
title: arweave入坑注意事项
tags: 
---

[toc]

首先吐槽一下官方的 miner guide 真的是简陋,连个参数说明都不全,得一边看源码一边去 discord 问
不做主观判断,不做横向比较,只做笔记
使用系统 Ubuntu 20.04

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

从流程可以看出,本身 pow 依然是一个 randomX 的算力比较,但是每一次hash后都需要读盘,所以磁盘io和iops都需要很强才行.目前是一个 cpu,ram,disk 之间均衡的一个游戏

目前看来 HDD 单盘是肯定没戏唱的, HDD raid0, io也许能提升,但是 4k 和 iops 依然稀烂. 所以目前还是需要 nvme 协议的 SSD 才行.同时这个项目由于其特性永久存储,所以数据量不可能和 filecoin 做对比.目前的 10多T 是一个很容易全部包含的数量级

#### 服务器 Spora 哈希率的估算

1. 服务器cpu能提供的 randomX hash,这个可以通过 benchmark,也可以直接查硬件,一般来说获得的数值都是根据CPU来设置线程的,但是在 AR 中并非设置所有线程来执行 randomX为最佳,他有step1,step2,还有io线程.所以整体上数值肯定会小于理论值.我下面提供了一个表可以查询一下常见的CPU,这个值作为 $1
2. 磁盘带宽估算,以GiB/s 为单位 `hdparm -t /dev/sda` ,这个值作为 $2
3. 本地存储了全网多少分之一的数据,本地数据可以查看 chunk 目录,全网么看一下区块链浏览器,这个值作为 $3

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