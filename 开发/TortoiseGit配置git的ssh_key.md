---
title: TortoiseGit配置git的ssh_key
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

如果使用TortoiseGit作为github本地管理工具，TortoiseGit使用扩展名为ppk的秘钥，而不是ssh-keygen生成的rsa密钥。
也就是说使用ssh-keygen -C “username@email.com” -t rsa产生的密钥TortoiseGit中不能用。
而基于github的开发必须要用到rsa密钥，因此需要用到TortoiseGit的putty key generator工具来生成既适用于github的rsa密钥也适用于TortoiseGit的ppk密钥。

1. 打开TortoiseGit下的PuttyGen
2. 使用Generate或Load然后Save成ppk后缀的密钥.
3. 将ssh密钥在github导入
4. 运行TortoiseGit下的Pageant程序
5. 在Pageant中将刚才保存的ppk密钥文件导入