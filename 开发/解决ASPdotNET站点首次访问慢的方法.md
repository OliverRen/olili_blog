---
title: 解决ASPdotNET站点首次访问慢的方法
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

IIS应用初始化会在网站第一次创建后或者对应网站的应用程序池回收后，自动开启新程序池，并启动网站初始化，模拟一次正常请求，使网站一直处于在线状态。

1. 修改启用应用程序池（AlwaysRunning）：保证应用程序池在第一次创建或者被回收后，能自动再次重启运行。

![](http://qiniu.imolili.com/小书匠/1594275389144.png)

2. 修改闲置超时1740分钟:长时间没有请求释放资源

![](http://qiniu.imolili.com/小书匠/1594275409800.png)

3. 修改启用网站程序预加载（true）：保证程序池在启动过后，网站能响应预加载动作。

![](http://qiniu.imolili.com/小书匠/1594275425654.png)

4. IIS8之前的项目由于CSP进行签名导致慢的问题

> Microsoft Authenticode：Microsoft Authenticode旨在帮助用户确保谁实际创建了他们正在运行的代码，特别是对于在Internet上下载或运行的代码，并验证代码在发布后未被更改或篡改。例如，经过数字签名，恶意篡改然后在线重新分发的程序将在运行之前向用户显示警告。

> 当程序里面需要调用到一些Authenticode Signed的.NET Assembly的时候，它需要连接到外网来验证数字证书。当服务器是无法连接到外网时，这个校验证书的过程需要等到timeout之后才会结束。

解决办法如下:
这个解决方案是由微软APAC技术支持中心 Internet Developer Support Team提供 https://blogs.msdn.microsoft.com/asiatech_zh-cn/2011/04/24/asp-net/）
请同时在以下两个aspnet.config文件中加入以下内容。
C:\Windows\Microsoft.NET\Framework\v2.0.50727\aspnet.config
C:\Windows\Microsoft.NET\Framework64\v2.0.50727\aspnet.config

```
<?xml version="1.0" encoding="utf-8"?>

<configuration>
    <runtime>
            <generatePublisherEvidence enabled="false"/>
    </runtime>
</configuration>
```

修改以下注册表键值并重起IIS服务，打开注册表regedit，找到以下地址，修改State为00023e00，原先的是00023c00
\[HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing]
"State"=dword:00023e00
然后记得重启一下应用程序池