---
title: 一键安装KMS服务脚本
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

#### 前言及声明

在我们安装好windows之后都需要进行激活,我们都知道现在可以使用kms进行激活,那么你知道这样的kms服务是怎么来的嘛?

本文转载自: [秋水逸冰](https://teddysun.com/) » [一键安装KMS服务脚本](https://teddysun.com/530.html)
使用kms激活方式可以参考 [03k.org](https://03k.org/kms.html)

KMS，是 Key Management System 的缩写，也就是密钥管理系统。这里所说的 KMS，毋庸置疑就是用来激活 VOL 版本的 Windows 和 Office 的 KMS 啦。这样的服务在 Github 上已经有[开源代码](https://github.com/Wind4/vlmcsd)实现了。

> VOL:即批量授权版本,不是零售版本.一般简写为VL,VL 版本的镜像一般内置 GVLK 密钥，用于 KMS 激活。

#### 脚本的安装方法

本文就是在这个开源代码的基础上，开发了适用于三大 Linux 发行版的一键安装 KMS 服务的脚本。

关于脚本
- 系统支持：CentOS 6+，Debian 7+，Ubuntu 12+
- KMS 服务安装完成后会加入开机自启动。
- 默认记录日志，其日志位于 /var/log/vlmcsd.log。

1. 使用root用户登录，运行以下命令：
`wget --no-check-certificate https://github.com/teddysun/across/raw/master/kms.sh && chmod +x kms.sh && ./kms.sh`

2. 安装完成后，输入以下命令查看端口号 1688 的监听情况
`netstat -nxtlp | grep 1688`

3. 返回监听状况如下
```
tcp	0	0 0.0.0.0:1688	0.0.0.0:*		LISTEN      3200/vlmcsd         
tcp	0	0 :::1688		:::*			LISTEN      3200/vlmcsd 
```

4. 服务控制命令
```
启动：/etc/init.d/kms start
停止：/etc/init.d/kms stop
重启：/etc/init.d/kms restart
状态：/etc/init.d/kms status
```

5. 卸载
`./kms.sh uninstall`

#### kms服务的使用方法

**查询GVLK密钥** 
Office 2016：https://technet.microsoft.com/zh-cn/library/dn385360(v=office.16).aspx
Office 2013：https://technet.microsoft.com/ZH-CN/library/dn385360.aspx
Office 2010：https://technet.microsoft.com/ZH-CN/library/ee624355(v=office.14).aspx
Windows：https://docs.microsoft.com/zh-cn/windows-server/get-started/kmsclientkeys

下面就和使用其他人提供的kms服务一样了:

**Windows VL版本激活**
1. 使用管理员权限运行 cmd 查看系统版本，命令如下：
`wmic os get caption`
2. 使用管理员权限运行 cmd 安装从上面列表得到的 key，命令如下：
`slmgr /ipk xxxxx-xxxxx-xxxxx-xxxxx-xxxxx`
3. 使用管理员权限运行 cmd 将 KMS 服务器地址设置为你自己的 IP 或 域名，后面最好再加上端口号（:1688），命令如下：
`slmgr /skms Your IP or Domain:1688`
这一步是最主要的操作,如果替换使用其他人提供的kms服务,一般也是修改这里的kms服务地址即可
4. 运行手动激活
`slmgr /ato`

**Office VL版本激活**
找到你的 Office 安装目录，32 位默认一般为 C:\Program Files (x86)\Microsoft Office\Office16
64 位默认一般为 C:\Program Files\Microsoft Office\Office16
Office16 是 Office 2016，Office15 就是 Office 2013，Office14 就是 Office 2010。
打开以上所说的目录，应该有个 OSPP.VBS 文件。

1. 使用管理员权限运行 cmd 进入 Office 目录，命令如下：
`cd "C:\Program Files (x86)\Microsoft Office\Office16"`
2. 使用管理员权限运行 cmd 注册 KMS 服务器地址：
`cscript ospp.vbs /sethst:Your IP or Domain`
3. 使用管理员权限运行 cmd 手动激活 Office，命令如下：
`cscript ospp.vbs /act`

#### 注意事项

注意： KMS 方式激活，其有效期只有 ==180== 天。
每隔一段时间系统会自动向 KMS 服务器请求续期，请确保你自己的 KMS 服务正常运行。

**常见错误的对策**
如果遇到在执行过程报错，请按以下步骤检查：
1，你的 KMS 服务器是否挂了？
2，你的 KMS 服务是否正常开启？
3，你的系统或 Office 是否为批量 VL 版本？
4，你的系统或 Office 是否修改过 Key 或未安装 GVLK Key？
5，你是否以管理员权限运行 cmd？
6，你的网络连接是否正常？
7，你的本地 DNS 解析是否正常？
8，如果你排除了以上的对策，那请根据错误提示代码自行搜索原因。