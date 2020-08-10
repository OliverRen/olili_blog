---
title: 通过ssh反向连接和公钥自动登录
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

在Internet上去主动连接一台内网是不可能的,一般的解决方案分两种:
一种是端口映射（Port Forwarding），将内网主机的某个端口Open出防火墙，相当于两个外网主机通信；
另一种是内网主机主动连接到外网主机，又被称作反向连接（Reverse Connection），这样NAT路由/防火墙就会在内网主机和外网主机之间建立映射，自然可以相互通信了。但是，这种映射是NAT路由自动维持的，不会持续下去，如果连接断开或者网络不稳定都会导致通信失败，这时内网主机需要再次主动连接到外网主机，建立连接。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/通过ssh反向连接和公钥自动登录/2020810/1597053583712.png)

如上图，如果两台机器都是在内网中,那么就需要一台公网的中间服务器 ,客户端C要访问服务器A.先从A建立A->B的反向代理连接.这时客户端C就可以通过访问服务器B的转发端口,再经过服务器B这个代理,访问到服务器A.

1.  **设置免密码登录**
在内网服务器A上生产公钥和私钥，并把公钥内容拷到服务器B的~/.ssh/authorized_keys里

$ `ssh-keygen -t rsa`
(一直按Enter，最后在~/.ssh/下生成密钥)

$ `ssh-copy-id -i ~/.ssh/id_rsa.pub user@hostB`
把本机的公钥追到hostB的 ~/.ssh/authorized_keys 里

$ `ssh -l userB serverB`
于是服务器 A上的用户就可以用直接ssh免密码登录到服务器B上了

2.  **用ssh建立反向链接**
在内网服务器A上执行
$ `ssh -NfR 1234:localhost:22 userB@123.123.123.123 -p 22`

上面命令中,
-N表示不执行远程命令
-f表示后台运行
-R则针对后面的绑定参数进行端口映射。
整体意思是：将本机（服务器A）的22与远程服务器的1234端口进行绑定，相当于远程端口映射(Remote Port Forwarding)。
  
这时在服务器B上sshd会listen本地1234端口
$ `ss -ant`
 
State      Recv-Q Send-Q        Local Address:Port          Peer Address:Port
LISTEN     0      128               127.0.0.1:1234                     *:*

3.  **客户端C通过如下步骤可访问到服务器A**
1.通过ssh连接到服务器B
$ `ssh userB@服务器B地址`

2.通过刚刚建立的反向通道，连接到服务器A
$ `ssh localhost -p 1234`

4.  **使用autossh监听ssh链路状态自动连接反向代理**
搞定完上面的步骤，已经可以从外网连接到服务器A了，但是这种方式还存在问题，服务器A->服务器B的链路是不稳定的，随时可能会断开，这时候可以用autossh这个命令，它可以帮助监听链路的连接情况，断开时可帮我们自动重连。
`autossh -M 5678 -NR 1234:localhost:22 userB@123.123.123.123 -p 22`
比之前的命令添加的一个-M 5678参数，负责通过5678端口监视连接状态，连接有问题时就会自动重连，去掉了一个-f参数，因为autossh本身就会在background运行

> autossh还有很多参数，用来设置重连间隔等等。

5.  机器重启后的自动运行autossh
这时就需要以daemon方式执行，相当于root去执行autossh, ssh，这时刚才普通用户目录下的 `.ssh/authorized_keys` 文件会不起效。
有两种办法解决:
第一种是用autossh的参数指定.ssh路径；
第二种是以普通用户 ==user1== 的身份执行daemon
`/bin/su -c '/usr/bin/autossh -M 5678 -NR 1234:localhost:2223 user1@123.123.123.123 -p2221' - user1`

将上面命令放入下面各启动方式中，根据自己系统自己配置：
SysV：/etc/inid.d/autossh
Upstart: /etc/init/autossh.conf
systemd: /usr/lib/systemd/system/autossh.service
