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

#### 远程开机软件