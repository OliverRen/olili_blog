---
title: 搭建FTP文件服务器
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

`yum install vsftpd -y`

配置
```
配置FTP权限
vsftpd的配置目录是 /etc/vsftpd 包含以下配置文件
vsftpd.conf 为主配置文件
ftpusers 配置禁止访问ftp服务器的用户列表
user_list 配置用户访问控制

vim /etc/vsftpd/vsftpd.conf
# 禁止匿名用户
anonymous_enbale=NO
# 禁止切换根目录
chroot_local_user=YES

创建ftp用户
useradd oliver
passwd oliver
12345678

限制用户不能登陆服务器
usermod -s /sbin/nologin oliver

为用户分配ftp的主目录
/data/ftp 为主目录, 该目录不可上传文件
/data/ftp/pub 文件只能上传到该目录下
mkdir -p /data/ftp/pub

创建欢迎文件
echo "Welcome to use FTP service." > /data/ftp/welcome.txt
设置访问权限
chmod a-w /data/ftp && chmod 777 -R /data/ftp/pub
分配用户的主目录
usermod -d /data/ftp oliver
```
