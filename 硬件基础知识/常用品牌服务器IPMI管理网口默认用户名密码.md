---
title: 常用品牌服务器IPMI管理网口默认用户名密码
tags: 
---

[toc]

#### 服务器

- 宝德4卡服务器

	默认用户名：ADMIN        密码：11111111
	
- 超微服务器

	默认用户名：ADMIN   密码：admin000

	默认用户名：ADMIN   密码：ADMIN

- 浪潮服务器

	型号:NF5270M4 管理地址：手动配置 默认用户名：admin   密码：admin

	型号:NF5270M2 管理里地址：192.168.1.100 默认用户名：admin   密码：admin

- IBM服务器

	IBM P小型机ASMI 管理地址：hmc1:192.168.2.147 用户名：admin 密码：admin

    管理地址：hmc1:192.168.3.147 用户名：admin 密码：admin

	IBM X系列MM端口  管理地址：192.168.70.125/25 用户名：USERID 密码：PASSW0RD

- 华为服务器

	E6000 系列 管理地址：10.10.1.101-10.10.1.110 用户名：root 密码：Huawei12#$

	RH2288 v3 系列 管理地址：192.168.2.100 用户名：root 密码：Huawei12#$

	RH2288 v5系列 管理地址：192.168.2.100 用户名：Administrator 密码：Admin@9000

	T600 系列 管理地址：10.10.1.101-10.10.1.102 用户名：root 密码：Huawei12#$

	X6000系列 管理地址：10.10.1.101-10.10.1.104 用户名：root 密码：Huawei12#$

- H3C服务器
	
	R4900-G2系列 管理地址：192.168.1.2/24 用户名：admin 密码：Password@_

- Dell服务器

	IDRAC系列 管理地址：192.168.0.120 用户名：root 密码：calvin

- 联想服务器

	RQ940系列 管理地址：192.168.0.120 用户名：lenovo 密码：len0vO

	RD530/RD630/RD540/RD640 管理地址：手动配置   用户名：lenovo     密码：lenovo

	万全R520系列 管理地址：手动该设置 用户名：lenovo 密码：lenovo

- 曙光服务器

	I840-G25系列 管理地址：手动设置 用户名：admin 密码：administrator
	
#### 数据存储中心

- IBM存储

	DS存储 用IBM DS Storage Manager Client管理软件连接
	
	port1 A控192.168.128.101/24        

    port1 B控192.168.128.102/24        

	port2 A控192.168.129.101/24

    port2 B控192.168.129.102/24

	v5030 T口管理地址：192.168.0.1 用户名：superuser 密码：passw0rd

	V7000 上管理口地址： 192.168.70.121 用户名：superuser 密码：passw0rd 
	
	下 管理口地址：192.168.70.122
	
- 华为存储

	OceanStor 5300 V3/5500  V3(V300R003C00/V300R003C10版本)

	A管理口地址：192.168.128.101/24 用户名：admin 密码：Admin@storage

	B管理口地址：192.168.128.102/24

	OceanStor 5300 V3/5500  V3(V300R003C20版本)

	A管理口：192.168.128.101/16

	B管理口：192.168.128.102/16 用户名：admin 密码：Admin@storage

	OceanStor 5600 V3/5800 V3/6800 V3(V300R003C00/V300R003C10版本)

	A管理口：192.168.128.101/16

	B管理口：192.168.128.102/16 用户名：admin 密码：Admin@storage

	OceanStor 5600 V3/5800 V3/6800 V3(V300R003C20版本)

	A管理口：192.168.128.101/16

	B管理口：192.168.128.102/16 用户名：admin 密码：Admin@storage

	以上默认的内部心跳IP 双控：127.127.127.10-11/24

	四控：127.127.127.10-13/24 　 　

	以上维护网口IP 172.31.128.101/16

	172.31.128.102/16

- 华赛存储

	S1200系列 默认管理地址：192.168.168.1 用户名：root 密码：password

	V1000/S500系列 默认管理地址：192.168.128.101-102/24 用户名：admin     密码：123456

- Dell存储

	MD3600系列 默认管理地址：192.168.128.101/102 连接方式：用DELL MDSM软件连接

- 联想EMC

	5100系列 默认管理地址：1.1.1.1/1.1.1.2 用户名：root 密码：lenovo

- 曙光存储

	DS800-G35系列 默认地址：192.168.0.210/192.168.0.220    用户名：admin   密码：admin

- 宏杉存储

	MS系列 默认地址：192.168.0.210/192.168.0.220 用户名：admin 密码：admin

- 同有存储

	NetStor iSUM450G2系列   默认地址：192.168.0.200  用户名：administator 密码：password