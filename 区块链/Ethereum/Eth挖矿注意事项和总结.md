---
title: Eth挖矿注意事项和总结
tags: 
---

[toc]

1. 挖以太坊的显卡算力,核心频率,显存频率,核心电压,显存电压问题

	我喜欢使用 [minerstat](https://minerstat.com/hardware) 来看一些数据,而且根据显卡显存是三星还是海力士还是镁光都有不一样,大致上调一调看温度就行了,电力消耗在GPU挖矿这里占比不是非常大
	
	原版软件的调整,包括开源矿工,轻松矿工,小飞机(msi afterburner)都是win下gui才能便利的调整
	
	功耗只要保证显存频率,整体功耗越低约好

	显卡型号 | 核心频率增减 | 显存频率增减 | 功耗墙调整 | 预估矿力
	---------|--------------|--------------|------------|---------
	3090 |	    -300 |	    +1000 |	285W |	120 MH/s
	3080 |	    -150 |	    +900 |	220W |	98 MH/s
	3070 |	    -500 |	    +1100 |	130W |	60 MH/s
	3060Ti |	-500 |	    +1200 |	130W |	60 MH/s
	2080Ti |    -200 |	    +1100 |	150W |	57 MH/s
	2080super |	-50 |	  +1000 | 175W | 42 MH/s
	2080 |	     -50 |	       +800 | 155W | 42 MH/s
	2070super |	-50 |	   +800 | 150W | 40 MH/s
	2070 |	     -50 |	       +800 | 125W | 39 MH/s
	2060super |	-50 |	   +850 | 125W | 39 MH/s
	2060 |	     -50 |	       +700 | 115W | 31 MH/s
	1080Ti |	不调整 |   +800 |	175W | 45 MH/s
	1080 |	     不调整 |	 +800 |	125W |	43 MH/s
	1070Ti |	不调整 |	+500 |	135W | 30 MH/s
	1070 |	     不调整 |	 +450 |	115W |	30 MH/s
	1060 6GB | 不调整 | +900 |	80W |	 23 MH/s
	
2. 操作系统选择

	用 win10 相对来说好解决驱动问题,好解决超频和风扇控制问题
	
	用 linux , 特别是 ubuntu 不是说不能改,而且改起来麻烦,要装这装那的. 用 linux 最大的好处估计就是没有 xwindows占用显存了把.毕竟 DAG 越来越大
	
3. 挖矿软件选择

	不是超大规模挖矿,不用选什么 minerOS 之类的
	
	用win10的话,由于 remote 管理的需求,有些人用 开源矿工,轻松矿工 但没必要,抽水过多.批处理写好timeout恢复,写好reboot和autostart,写好failover,除非断电有点麻烦其他没啥问题
	
	我这里用了 phoenixMiner 和 gminer ,对比了一下大差不大 ,费率上 gminer 稍好一点,但帮助文档,和做自动化的话,phoenixMiner 更丰富一点.
	
	但是在linux上,gminer使用可以使用 `--lock_cclock` 参数强制锁频率
	
	所以在 linux 上可以简单的使用 gminer 控制功耗,而在 win 上建议使用phoenix 更好,本身 win平台降频很简单,用 phoenix 可以很好的写自动化

4. 矿池选择

	- 币安矿池 0.5%抽水少,起付日结,算力小所以实际结算并不多
	- F2鱼池 2%老牌,起付日结,算力中
	- spark星火 1%,起付日结,算力最大
		
	纸面上来看星火最佳,但F2鱼池实际收益基本一致,反而币安矿池最少

5. 3060 无锁备注
	
	基本元素
	- 470.05温州老黄驱动
	- 显示器 HDMI 欺骗器
	- 3060需要8x,16x通道

	配置单
	- x58 或 x79 双路,建议 x79 如 浪潮M2220 2011双路x79 有板载vga
	- e5-2600 v1v2 内存8G,16G就够 ssd需要120G+
	- 散热 TDP 要求不高,用底座+下压式即可
	- 显卡转接线(8x->16x)不能超过20cm,或者要带供电
	- bios主要修改 64bit资源需要 above 4G Decoding enabled
	- bios显示需要改为集显,如 VGA Priority,一般叫做 IGFX 或 XXXX VGA 或 onboard
	- bios有mining mode直接开即可
	
6. win10 OC

	需要注意的是原版软件相应的参数是覆盖了小飞机中的设置参数的,但是小飞机最大的作用在于便利的观察
	
	小飞机设置中打开电压配置,可以使用曲线调整相应的频率
	
7. ubuntu OC

	首先需要解决的是驱动问题,最新驱动并不一定是最好的,但最新驱动一般都可以正常工作,省事的话直接上最新驱动
	
	多GPU设置,驱动中的配置主要集中在 nvidia-xconfig , nvidia-settings , nvidia-smi 上,配置路径在 /etc/X11 下,全部需要 root权限执行
	
	- 初始化配置 , `nvidia-xconfig` 这会在 /etc/X11 下创建配置 xorg.conf
	- 设置为多GPU模式,除非你只有一张卡, `nvidia-xconfig --enable-all-gpus` 这会修改配置文件
	- 设置风扇,频率自定义 `nvidia-xconfig --cool-bits=4` 值4只开启风扇,值28可以自定义许多选项，包括超频，功耗和风扇转速,建议加上参数 `nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration`	
	- reboot 重启,等待生效
	- 如果有 xwindow ,那么很简单直接用 `nvidia-settings` 面板即可调整风扇转速,或者使用命令行
		```
		nvidia-settings -a "[gpu:0]/GPUFanControlState=1" 
		nvidia-settings -a "[gpu:1]/GPUFanControlState=1" 
		nvidia-settings -a "[gpu:2]/GPUFanControlState=1" 
		nvidia-settings -a "[gpu:3]/GPUFanControlState=1" 
		nvidia-settings -a "[fan:0]/GPUCurrentFanSpeed=80" 
		nvidia-settings -a "[fan:1]/GPUCurrentFanSpeed=85" 
		nvidia-settings -a "[fan:2]/GPUCurrentFanSpeed=86" 
		nvidia-settings -a "[fan:3]/GPUCurrentFanSpeed=90" 
		```
	- 使用命令 `nvidia-smi` 即可看到结果

	但是我用 linux 不就是为了不要 xwindow 么... 于是方案2,在reboot后安装这个组件 [coolgpus](https://github.com/andyljones/coolgpus)
	
	coolgpus使用模拟 X服务器 的方式来控制风扇转速,所以你不能使用显卡连接了显示器,你不能使用X服务器
	
	- 软件基于python,首先安装pip,首先安装python3,看服务器情况.命令依次如下 
	- `apt install python3`
	- `apt install python3-pip`
	- `pip3 install --upgrade pip`
	- `pip install coolgpus`
	- 使用很简单,暴力方案 `coolgpus --speed 99 99`
	- 风扇曲线方案 `coolgpus --temp 20 40 60 75 --speed 5 35 70 99`
	- 归还风扇控制权,单独运行一次程序无参数,然后 ctrl+c 结束即可

	降频降功率方式需要使用到 Nvidia 的 PowerMizer,编辑 `/etc/X11/xorg.conf` 在 Device 节中复制如下参数并需要重启
	
	```
	Section “Device”
	Identifier “Device0”
	Driver “nvidia”
	VendorName “NVIDIA Corporation”
	Option “Coolbits” “1”
	Option “RegistryDwords” “PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3”
	EndSection
	```
	
	- PowerMizerEnable=0x1 为打开 PowerMizer
	- PerfLevelSrc=0x2222 调节频率方式 0x2222为固定,0x3322为自适应
	-  PowerMizerLevel=0x3 性能级别从 1(高) - 2 - 3(低)
	-  PowerMizerDefault=0x3 默认性能级别从 1(高) - 2 - 3(低)
	-  PowerMizerDefaultAC=0x3 接通AC电源性能级别从 1(高) - 2 - 3(低) (笔记本才有用)
	
	
	