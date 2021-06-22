---
title: 远程开关机WoL
tags: 
---

[toc]

#### 远程关机

cmd 下 shutdown 命令就可以了

- shutdown.exe -a　取消关机　　
- shutdown.exe -s   马上关机　　
- shutdown.exe -f　强行关闭应用程序 尽量不要加 -f 参数
- shutdown.exe -m \\IP or computer name　可以是计算机名,也可以是ip,远程关机　　
- shutdown.exe -i　显示“远程关机”图形用户界面，但必须是Shutdown的第一个参数 　　　
- shutdown.exe -l　注销当前用户　　
- shutdown.exe -r　关机并重启　　
- shutdown.exe -s -t 时间　设置关机倒计时　　
- shutdown.exe -h 休眠

远程关机在windows下拒绝访问的解决方案,这其实时windows的安全策略阻止了远程关机,但是shutdown.exe没有这个参数啊

所以如果安全系数要求不高,局域网内的机器,直接添加everyone权限即可

- win+R 输入 secpol.msc
- win+R 输入 gpedit.msc-计算机配置-安全设置-本地策略
- 控制面板-管理工具-本地安全策略

本地策略-用户权限分配-从远程系统强制关机,添加everyone即可

如果上述方法不可用,那么换一个思路,将要关机的目标计算机凭据添加到本地计算机中即可.

你可以直接搜索 凭据管理器 打开后在 windows凭据中添加, 需要单独添加普通凭据即可.这里mstsc时保存的凭据是不行的,因为会带有 termsrv 前缀只有远程桌面服务可用,需要单独进行添加.另外在使用 msdn 账户的时候可以使用 MicrosoftAccount\XXXXXXX 的形式来进行添加,当然如果使用msdn账户的话,在shutdown指定目标机器的时候,目标机器一定要能联网

#### 远程开机原理

网络开机叫做Wake-on-LAN，缩写是WoL。过程很简单，即通过发送一组特殊格式的网络封包（Magic Packet）给某个MAC地址的电脑，让该电脑从睡眠模式甚至是关机模式苏醒，即从ACPI的Sx(S3，S4，S5)模式返回S0运行模式。

固件需要保证网络设备和网口（Phy）的电源在Sx的情况下保持供电，以用来监听网络中的Magic Packet。这通常都是通过写一组主板芯片组的寄存器来实现的。

Magic Packet 看起来是这样的

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/远程开关机WoL/2021215/1613402954320.png)

它通常被发送的该机器的UDP端口7和9。如果网卡在Sx的状态收到了这组封包，它就知道有人要开机，它会通过PME#或者其他方式唤醒电脑。

#### 远程开机设置

BIOS打开WoL,窍门就是寻找Wake up、NIC、PME、PCI等等。

我们同样需要在操作系统里面开启WoL。打开设备管理器，找到你的网卡，右键点击并选择属性：
1. 电源管理中的唤醒
2. 网卡高级设置里的唤醒

如果无法成功,检查这几个点:
- 网卡是否支持网络唤醒
- 网卡的远程唤醒功能是否开启，到设备管理器>网卡>属性>电源 查看
- 主板是否开启网卡唤醒功能
- 如果局域网有路由器，防火墙是否拦截

#### 远程开机软件

1. depicus 的 wolcmd [https://www.depicus.com/wake-on-lan/wake-on-lan-cmd](https://www.depicus.com/wake-on-lan/wake-on-lan-cmd)
2. depicus 的 wol gui [https://www.depicus.com/wake-on-lan/wake-on-lan-gui](https://www.depicus.com/wake-on-lan/wake-on-lan-gui)

很老了,可以结合 monitor 进行一下问题定位

3. WakeMeOnLan 有中文版本 [https://www.nirsoft.net/utils/wake_on_lan.html](https://www.nirsoft.net/utils/wake_on_lan.html)

推荐使用该版本