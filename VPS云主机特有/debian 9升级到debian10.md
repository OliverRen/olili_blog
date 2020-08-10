---
title: debian9升级到debian10
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

有些云主机服务商提供的debian版本只有9,我们愉快的几步就可以升级为10

更新：
`apt-get update && apt-get upgrade`

备份一份：
`cp /etc/apt/sources.list /etc/apt/sources.list.orig`

将/etc/apt/sources.list里所有“stretch”替换为“buster”：
`sed -i 's/stretch/buster/g' /etc/apt/sources.list`

再更新一下
`apt-get update && apt-get upgrade`

执行升级命令
`apt-get dist-upgrade`

提示完成后重启
`reboot`

查看下当前debian版本
`lsb_release -a`