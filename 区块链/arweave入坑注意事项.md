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


 
在生成块的时候，为节点选择一个网络范围内的搜索子空间(网络的10%)来读取随机数据。  
候选块的元数据和随机数(nonce)使用RandomX散列在一起。  
这个哈希的输出——一个非常大的整数——被减少到搜索空间大小给定的范围内。 这个数字被添加到搜索空间的基础上(在步骤1中计算)，并用作“挑战字节”——矿工必须在数据集中证明他们可以访问以便继续挖掘过程的一个点。  
现在，矿机尝试将包含质询字节的块从磁盘读取到内存中。 如果矿机没有保存给定块的副本，则从第二阶段开始重新启动采矿过程。  
然后，矿机根据需要读取或重新创建在数据集中适当位置包含给定字节的证明(Merkle证明)。  
然后使用RandomX将块元数据、Merkle证明、块和临时散列在一起。  
该哈希的输出被解释为一个数字，然后根据网络中的当前难度级别进行验证。 在网络中，每个区块生产周期中除了一次尝试外，所有的尝试都将失败，这些矿工将从第二阶段重新开始。  
当节点产生了一个有效的候选块的证明，SPoRA证明和块头被分发到网络的其他部分。  


