---
title: Win10网络邻居无法访问nas的解决方法
tags: 小书匠语法
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

#### 开启SMB协议

在 设置 - 应用 - 程序和功能 - 启用和关闭windows功能 中,勾选上 SMB1.0/CIFS 文件共享支持,然后重启

#### 开启来宾登录

在 开始 - 运行 - gpedit.msc组策略 - 计算机配置 - 管理模板 - 网络 - Lanman工作站,启用不安全的来宾登录,然后重启

#### 修改注册表 AllowInsecureGuestAuth 项

在 开始 - 运行 - regedit注册表 - `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters`,修改 AllowInsecureGuestAuth的值为1确定,然后重启.