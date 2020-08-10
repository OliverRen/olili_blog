---
title: Ifcfg网络接口配置脚本说明
tags: 小书匠语法,技术
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

#### ifcfg

ifcfg
: 是一个简单的脚本替换iconfig命令,可以设置网络接口.此命令的适用范围：RedHat、RHEL、Ubuntu、CentOS、SUSE、openSUSE、Fedora等.

语法:
 ifcfg \[device] \[cmd]  \[address]
 device就是网卡设备，它可能有别名。cmd可以是add、delete、stop。address就是ip地址。
 
 #### 网络配置详解
 > 文件位置: /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE=eth0
网络设备名称

NM_CONTROLLED=yes
是否由NetworkManager服务托管 [^1x]

HWADDR=08:00:27:FC:DF:ED
MAC地址

TYPE=Ethernet
设备类型

PREFIX=24
子网掩码是24位

DEFROUTE=yes
将这个网络设备设置位默认路由

ONBOOT=yes
开机自动启用网络连接 要有网线插上不然ifup不起来

IPADDR=192.168.2.201
IP地址

GATEWAY=192.168.2.1
设置网关

BOOTPROTO=static
设置位none禁止DHCP
设置位static启用静态IP
设置位dhcp开启dhcp

NETMASK=255.255.255.0
子网掩码

DNS1=202.101.172.35
DNS2=8.8.8.8
DNS设置

BROADCAST
广播

UUID=d957cd4b-cdec-472e-8af8-c72c0948fb6e
设备uuid

BRIDGE
设置桥接

IPV6INIT=no
禁止IPV6

USERCTL=no
是否允许非root管理该设备

NAME=''eth1"
网络连接名称

IPV4_FAILURE_FATAL=yes
如果ipv4配置失败则金庸设备

IPV6_FAILURE_FATAL=yes
如果ipv6配置失败则禁用设备

> 一个网络接口配置多个 IP地址,需要注意必须在第一个 IPADDR,GATEWAY写完,最下面才能写第二个,不然由于 GATEWAY2冲突会导致接口起不来
IPADDR2=
NETMASK2=
GATEWAY2=
或者可以直接使用命令 `ifconfig eth 1:1 ip1 netmask netmask1 up` 来新建IP


[^1x]: 
> NM_CONTROLLED 参数
NM_CONTROLLED 设置 yes 表示网卡允许用 NetworkManager 程序管理。它可以降低网络配置使用难度，便于管理无线网络、虚拟专用网等网络连接，适合普通台式机和笔记本电脑使用。
当 NM_CONTROLLED 设为 yes 并有安装运行 NetworkManager 服务，若编辑了网卡配置文件，需要先重启 NetworkManager 再重启 network 服务。
NM_CONTROLLED 设置 no 表示网卡使用传统方式管理而不用 NetworkManager。好处是修改网卡配置文件后直接重启 network 就生效，不受 NetworkManager 干扰。适合用以太网连接的服务器使用。

















