---
title: iptables配置方法
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

#### iptables的基本规则

iptables 工作在第三层，即网络层 但是iptables的规则却在kernel中

##### iptables的功能：
过滤功能 Netfilter: 网络过滤器, Framework
地址转换功能
 NAT: Network Address Translation
 SNAT:源地址转换（POSTROUTING）
 DNAT:目的地址转换（PREROUTING）
 
 ##### iptables包含的表格
 
 - ==filter==: 策略过滤 iptables 默认的表格  包含三个链 INPUT, OUTPUT, FORWARD 应该在此三道门中做过滤
 - ==nat==: 地址转换啦  PREROUTING, POSTROUTING, OUTPUT
 - ==mangle==: 作用是改变服务类型而使用的表  PREROUTING, INPUT, FORWARD, OUTPUT, POSTROUTING

其中nat  和filter 是配置和使用iptables中最常用的两个，务必要熟悉。
其表格优先级为 ==raw-->mangle-->nat-->filter==，通过下面的图片可以很清楚的明白iptables表格的匹配流程

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/iptables配置方法/2020810/1597053573375.jpg)

------------

#### iptables的命令

**iptables -t 表名table**
+ filter
+ nat
+ mangle
+ raw
+ security

**iptables 链表名chain**
PREROUTING
INPUT
FORWARD
OUTPUT
POSTROUTING

**option指令 链表名chain**
+ -A --append chain 追加
+ -C --check chain 校验
+ -D --delete chain 删除
+ -I --insert chain 插入
+ -R --replace chain 替换

+ -L --list chain 列出
	+ 示例: iptables -t nat -n -L 使用-n将ip地址和端口显示为数字模式
	+ 示例: iptables -L -v 使用-v将大数显示位易读的文本
+ -S --list-rules chain 

+ -N --new-chain chain 创建新链
+ -X --delete-chain chain  删除链
+ -E --rename-chain oldchain newchain 重命名链
+ -F --flush chain 清空
+ -Z --zero chain 清空计数器
+ -P --policy chain 改变策略

**add,delete,insert,replace的参数**

+ -4 --ipv4
+ -6 --ipv6
+ -p--protocol {tcp|udp|icmp} 协议
+ -s --source address/mask 源地址
+ -d --destination address/mask 目标地址
+ -m --match 显示表示使用匹配模式
+ -j --jump target 目标模式
+ -i --in-interface 入口网络接口
+ -o --out-interface 出口网络几口

**隐式扩展和显示扩展**

使用 `man iptables-extensions`  查看帮助文档

隐式扩展的几个举例

-p tcp
--sport PORT
--dport PORT
--tcp-flags ACK,SYN,RST,FIN SYN = --syn
--tcp-flags ACK,SYN,RST,FIN SYN,ACK,RST,FIN
--sport 22:23

-p UDP
--sport PORT
--dport PORT

-p icmp
--icmp-type
	8: echo-request
	0: echo-reply
	
几个常用的配置示例

1. 开启ssh
`iptables -A INPUT  -d 192.168.0.100/32 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT `
`iptables -A OUTPUT -s 192.168.0.100 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT `

2. web访问
`iptables -A INPUT  -d 192.168.0.100/32 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT `
`iptables -A OUTPUT -s 192.168.0.100 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT `

	
	