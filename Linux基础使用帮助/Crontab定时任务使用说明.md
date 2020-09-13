---
title: Crontab定时任务使用说明
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

1.  安装并检查crontab服务

`yum install vixie-cron` 
安装后台服务

`yum install crontabs`
安装配置程序

`crontab -l`
查看设定的定时任务

2.  crontab相关文件说明

`/usr/lib/cron/cron.allow` 
表示谁能使用crontab命令。如果它是一个空文件表明没有一个用户能安排作业。

`/usr/lib/cron/cron.deny`
则只有不包括在这个文件中的用户才可以使用crontab命令。如果它是一个空文件表明任何用户都可安排作业。

> 两个文件同时存在时cron.allow优先，如果都不存在，只有超级用户可以安排作业。

每次编辑完某个用户的cron设置后，cron自动在`/var/spool/cron`下生成一个与此用户同名的文件，此用户的cron信息都记录在这个文件中，这个文件是不可以直接编辑的，只可以用crontab -e 来编辑。cron启动后每过一份钟读一次这个文件，检查是否要执行里面的命令。因此此文件修改后不需要重新启动cron服务。

cron服务每分钟读取自 `/var/spool/cron` 所有文件实际执行的任务 
还需要读一次 `/etc/crontab`
所以使用crontab -e配置针对的是用户的,而编辑/etc/crontab是针对系统的

3.  crontab命令说明

使用权限 : ==所有使用者==
使用方式 :

* crontab file \[-u user]
用指定的文件替代目前的crontab。

* crontab- \[-u user]
用标准输入替代目前的crontab.

* crontab -l \[user]
列出用户目前的crontab.

* crontab -e \[user]
编辑用户目前的crontab.

* crontab -d \[user]
删除用户目前的crontab.

* crontab -c dir
指定crontab的目录。

> crontab 是用来让使用者在固定时间或固定间隔执行程序之用，换句话说，也就是类似使用者的时程表。-u user 是指设定指定 user 的时程表，这个前提是你必须要有其权限(比如说是 root)才能够指定他人的时程表。如果不使用 -u user 的话，就是表示设定自己的时程表。

4.  crontab文件的格式：

基本格式 : 
M H D m d cmd.
*　　*　　*　　*　　*　　command
分　 时　 日　 月　 周　 命令
M: 分钟（0-59）。每分钟用 \*或者 \*/1表示
H：小时（0-23）。（0表示0点）
D：天（1-31）。 Day of Month
m: 月（1-12）。
d: 一星期内的天（0~6，0为星期天）。Day of Week
cmd要运行的程序，程序被送入sh执行，这个shell只有USER,HOME,SHELL这三个环境变量

`*` 表示 ==每==.每分钟,每小时,每天 依此类推
`a-b` 表示 ==从a到b== 都要执行, 从1分-5分,从2时-4时,依此类推
`*/n` 表示 ==每n执行一次== ,每5分钟执行一次,每1小时执行一次,依此类推
`a,b,c` 表示 ==在a,b,c执行一次==, 如 10分,20分,30分执行一次,依此类推

5.  crontab文件的一些例子：

`30 21 * * * /usr/local/etc/rc.d/lighttpd restart`
上面的例子表示每晚的21:30重启apache。

`45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart`
上面的例子表示每月1、10、22日的4 : 45重启apache。

`10 1 * * 6,0 /usr/local/etc/rc.d/lighttpd restart`
上面的例子表示每周六、周日的1 : 10重启apache。

`0,30 18-23 * * * /usr/local/etc/rc.d/lighttpd restart`
上面的例子表示在每天18 : 00至23 : 00之间每隔30分钟重启apache。

`0 23 * * 6 /usr/local/etc/rc.d/lighttpd restart`
上面的例子表示每星期六的11 : 00 pm重启apache。

`* */1 * * * /usr/local/etc/rc.d/lighttpd restart`
每一小时重启apache

`* 23-7/1 * * * /usr/local/etc/rc.d/lighttpd restart`
晚上11点到早上7点之间，每隔一小时重启apache

`0 11 4 * mon-wed /usr/local/etc/rc.d/lighttpd restart`
每月的4号与每周一到周三的11点重启apache

`0 4 1 jan * /usr/local/etc/rc.d/lighttpd restart`
一月一号的4点重启apache