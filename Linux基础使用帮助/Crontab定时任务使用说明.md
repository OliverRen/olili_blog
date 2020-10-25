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

* [安装](#%E5%AE%89%E8%A3%85)
* [主要命令](#%E4%B8%BB%E8%A6%81%E5%91%BD%E4%BB%A4)
* [crontab相关文件说明](#crontab%E7%9B%B8%E5%85%B3%E6%96%87%E4%BB%B6%E8%AF%B4%E6%98%8E)
* [crontab的执行](#crontab%E7%9A%84%E6%89%A7%E8%A1%8C)
* [crontab文件的格式和一些例子](#crontab%E6%96%87%E4%BB%B6%E7%9A%84%E6%A0%BC%E5%BC%8F%E5%92%8C%E4%B8%80%E4%BA%9B%E4%BE%8B%E5%AD%90)
* [cron的环境变量问题](#cron%E7%9A%84%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F%E9%97%AE%E9%A2%98)
* [Ubuntu cron开启日志](#ubuntu-cron%E5%BC%80%E5%90%AF%E6%97%A5%E5%BF%97)


#### 安装

yum或apt安装即可.

#### 主要命令

- `crontab -u` 指定用户
- `crontab -l` 查看设定的定时任务
- `crontab -e` 编辑用户的定时任务
- `crontab -r` 删除定时任务
- `crontab [file]` 用指定的文件代替当前的contab设置

#### crontab相关文件说明

- `/usr/lib/cron/cron.allow` : 表示谁能使用crontab命令。如果它是一个空文件表明没有一个用户能安排作业。
- `/usr/lib/cron/cron.deny` : 则只有不包括在这个文件中的用户才可以使用crontab命令。如果它是一个空文件表明任何用户都可安排作业。

> 两个文件同时存在时cron.allow优先，如果都不存在，只有超级用户可以安排作业。

#### crontab的执行

cron服务每分钟读取一次 `/etc/crontab`,该文件设定是系统级别的定时任务

用户使用crontab -e配置针对的是用户的,每次编辑完某个用户的cron设置后，cron自动在`/var/spool/cron`下生成一个与此用户同名的文件.

此用户的cron信息都记录在这个文件中，这个文件是不可以直接编辑的，只可以用crontab -e 来编辑。

cron启动后每过一份钟读一次这个文件，检查是否要执行里面的命令。因此此文件修改后不需要重新启动cron服务。

> crontab 是用来让使用者在固定时间或固定间隔执行程序之用，换句话说，也就是类似使用者的时程表。-u user 是指设定指定 user 的时程表，这个前提是你必须要有其权限(比如说是 root)才能够指定他人的时程表。如果不使用 -u user 的话，就是表示设定自己的时程表。

#### crontab文件的格式和一些例子

1. 基本格式 : 

```
M	H	D	m	d	cmd
*	*	*	*	*	command
分	时	日	月	周	命令
```

- M: 分钟（0-59）。每分钟用 \*或者 \*/1表示
- H：小时（0-23）。（0表示0点）
- D：天（1-31）。 Day of Month
- m: 月（1-12）。
- d: 一星期内的天（0~6，0为星期天）。Day of Week
- cmd要运行的程序，程序被送入sh执行，这个shell只有USER,HOME,SHELL这三个环境变量

* `*` 表示 ==每==.每分钟,每小时,每天 依此类推
* `a-b` 表示 ==从a到b== 都要执行, 从1分-5分,从2时-4时,依此类推
* `*/n` 表示 ==每n执行一次== ,每5分钟执行一次,每1小时执行一次,依此类推
* `a,b,c` 表示 ==在a,b,c执行一次==, 如 10分,20分,30分执行一次,依此类推

2. crontab文件的一些例子：

`30 21 * * * /usr/local/etc/rc.d/lighttpd restart` </br>
上面的例子表示每晚的21:30重启apache。

`45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart` </br>
上面的例子表示每月1、10、22日的4 : 45重启apache。

`10 1 * * 6,0 /usr/local/etc/rc.d/lighttpd restart` </br>
上面的例子表示每周六、周日的1 : 10重启apache。

`0,30 18-23 * * * /usr/local/etc/rc.d/lighttpd restart` </br>
上面的例子表示在每天18 : 00至23 : 00之间每隔30分钟重启apache。

`0 23 * * 6 /usr/local/etc/rc.d/lighttpd restart` </br>
上面的例子表示每星期六的11 : 00 pm重启apache。

`* */1 * * * /usr/local/etc/rc.d/lighttpd restart` </br>
每一小时重启apache

`* 23-7/1 * * * /usr/local/etc/rc.d/lighttpd restart` </br>
晚上11点到早上7点之间，每隔一小时重启apache

`0 11 4 * mon-wed /usr/local/etc/rc.d/lighttpd restart` </br>
每月的4号与每周一到周三的11点重启apache

`0 4 1 jan * /usr/local/etc/rc.d/lighttpd restart` </br>
一月一号的4点重启apache

#### cron的环境变量问题

就算是用户级别的定时任务,由于在运行crontab的时候是non_login方式调用程序的,所以只会加载 `/ect/environment`

并不会加载 `/etc/profile`,`/etc/bashrc` ,`~/.bash_profile`, `~/.bashrc`,这些是需要用户登录的

所以需要通过在 crontab 定义任务自行添加环境变量,这一点和 systemd 的管理方式是类似的.

以下方法可以参考:

1. 在 cron 任务中直接执行 source,例如 `* * * * * source ~/.bashrc && task`
2. 在 cron 任务的脚本中执行初始化 例如 
	```
	#!/bin/sh
	
	. /etc/profile
	```
3. 如果你实在有些环境变量是针对特定程序的,那么只能是在 cron 任务的脚本中自行 export 来指定环境变量


#### Ubuntu cron开启日志

ubuntu默认没有开启cron日志记录,需要修改 `rsyslog` 来开启

```
# 编辑配置
vim /etc/rsyslog.d/50-default.conf 
# 取消该句前面的注释
cron.* /var/log/cron.log
# 重启 rsyslog
service rsyslog restart
```

需要注意的是 cron 默认会把任务的执行结果和错误信息发送到邮箱,如果没有配置邮件服务器,你会得到一个info日志提示 `No MTA installed, discarding output`

所以在定义任务需要重定向标准输出和错误输出:

```
其中 >> 为追加输出,若只需要最后一次执行结果可以使用 > 覆盖输出
2为错误输出stderr &1为标准输出stdout的文件描述符
故意思为将标准输出追加重定向到 /var/log/task.log,同时将错误输出也输出到标准输出,即也输出到log文件
0 2 * * * task >> /var/log/task.log 2>&1
```