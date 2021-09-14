---
title: arweave入坑注意事项
tags: 
---

[toc]

不做主观判断,不做横向比较,只做笔记
使用系统 Ubuntu 20.04

#### 文件打开数设置

首先吐槽一下官方的 miner guide 真的是简陋,连个参数说明都不全,得一边看源码一边去 discord 问

1. 

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
	
2. aaa

