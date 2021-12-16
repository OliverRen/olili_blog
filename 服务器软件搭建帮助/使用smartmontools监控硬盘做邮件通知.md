---
title: 使用smartmontools监控硬盘做邮件通知
---

[toc]

[官方网站连接](https://www.smartmontools.org/)

- 不同的文件系统(xfs,reiserfs,ext4)都有自己的检测和修复工具
- 一般的修复也需要dmesg和/var/log/messages中查看日志才能判定
- 简单的文件系统修复可以用fsck来尝试修复
- 但是我们要防患于未然,尽可能先通过告警防止硬盘出现故障的时候数据不可修复

环境 ubuntu 20.04,`apt install smartmontools`安装

linux上smartctl的简单使用
``` shell
# 检查该设备是否已经打开SMART技术
smartctl -a <device>

# 使用该命令打开SMART技术
smartctl -s on <device>  

# 后台检测硬盘 短时
smartctl -t short <device>  

# 后台检测硬盘，消耗时间长
smartctl -t long <device>

# 前台检测硬盘，消耗时间短
smartctl -C -t short <device>

# 前台检测硬盘，消耗时间长
smartctl -C -t long <device>

# 中断后台检测硬盘
smartctl -X <device> 

# 显示硬盘检测日志
smartctl -l selftest <device>  

# 显示硬盘错误汇总
smartctl -l error <device> 

# 查看硬盘的smart
smartctl -H <device>

# 查看硬盘详细信息
smartctl -A <device>
```

简单的查看需要登陆服务器敲命令,于是我们需要使用smartd来配置一个邮件告警

`vim /etc/smartd.conf`

参数说明：

-H :  磁盘健康状况 ([ATA only] Check the SMART health status of the disk)

-l selftest : 磁盘自检日志

-l error : 磁盘错误日志

-f  : 检测所有属性值，如果属性值大于阈值，则报警。

-s :  定时执行  ,格式  T/MM/DD/d/HH  ；  （类型/月份/日期/星期几/小时）, 这里的S代表短检测，月份、日期、小时是两位，星期几是一位

-m: 发送邮件

记得要注释掉,直接自行添加 `DEVICESCAN -d removable -n standby -m root -M exec /usr/share/smartmontools/smartd-runner`

上面的配置记住一个 `-a` 都包含了.所以配置很简单 

`/dev/sda -a -m  admin@server.com,root@localhost`

如果要对邮件进行测试,可以添加参数 `-M test` 即可

不过我实际测试配置中 需要写到分区而不是磁盘,即需要写道 /dev/sda1 才行

发送邮件找 mailutis mailx 发送邮件设置文档
