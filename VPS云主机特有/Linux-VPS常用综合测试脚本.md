---
title: Linux-VPS常用综合测试脚本
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

转载自 https://www.mrkevin.net/share/1383.html
这类脚本是综合测试VPS基础信息、硬盘IO、带宽和网络延迟等项目的一键式脚本

1. 秋水逸冰大佬的Bench.sh脚本
显示当前测试的各种系统信息；
下载测试取自世界多处的知名数据中心的测试点
IO 测试三次，并显示平均值
`wget -qO- bench.sh | bash https://github.com/teddysun/across/blob/master/bench.sh`

2. 老鬼大佬的SuperBench测试脚本
在秋水逸冰的基础上加入了独服通电时间，服务器虚拟化架构等内容
`wget -qO- --no-check-certificate https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
https://github.com/oooldking/script/blob/master/superbench.sh`

3. Zbench
脚本由漏水和kirito，基于Oldking大佬 的 SuperBench，然后加入Ping以及路由测试的功能，还能生成测评报告，分享给其他人查看测评数据
`wget -N --no-check-certificate https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZBench-CN.sh && bash ZBench-CN.sh`

4. LemonBench [比较全的测试]
LemonBench工具(别名LBench、柠檬Bench)，是一款针对Linux服务器设计的服务器性能测试工具。通过综合测试，可以快速评估服务器的综合性能，为使用者提供服务器硬件配置信息。
`curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast`

5. UnixBench测试脚本
UnixBench是一个类unix系（Unix，BSD，Linux）统下的性能测试工具，一个开源工具，被广泛用与测试linux系统主机的性能。Unixbench的主要测试项目有：系统调用、读写、进程、图形化测试、2D、3D、管道、运算、C库等系统基准性能提供测试数据。
`wget --no-check-certificate https://github.com/teddysun/across/raw/master/unixbench.sh
chmod +x unixbench.sh
./unixbench.sh`

6. 回程路由测试
从你的 Linux(X86/ARM)/Mac/BSD 系统环境下发起 traceroute 请求，附带链路可视化，兼容性更好，支持 JSON 格式
```
wget https://cdn.ipip.net/17mon/besttrace4linux.zip
unzip besttrace4linux.zip
./besttrace -q 1 这里是目标IP
```
