---
title: 使用smartmontools监控硬盘做邮件通知
---

[toc]

[官方网站连接](https://www.smartmontools.org/)

- 不同的文件系统(xfs,reiserfs,ext4)都有自己的检测和修复工具
- 一般的修复也需要dmesg和/var/log/messages中查看日志才能判定
- 简单的文件系统修复可以用fsck来尝试修复
- 但是我们要防患于未然,尽可能先通过告警防止硬盘出现故障的时候数据不可修复

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




。其实就是利用硬盘SMART的自检程序。 。 。
首先通过dmesg工具，确认一下硬盘的设备符号。例如一个IDE硬盘连接到Primary IDE 总线上的Slave位置，硬盘设备符号是/dev/hdb，hdb中的h代表IDE，如果显示为sdb，则代表SATA和SCSI，最后一个字幕b代表Primary总线，第二块硬盘即Slave位置，确认硬盘是否打开了SMART支持：
```