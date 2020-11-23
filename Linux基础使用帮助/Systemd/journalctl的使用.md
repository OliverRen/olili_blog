---
title: journalctl的使用
tags: 
---

使用systemd来管理服务后最简单的就是需要看到日志了

在linux系统中,两个日志服务 rsyslog和systemd-journal。

rsyslog是传统的系统日志服务，它会把所有日志都记录到`/var/log/`目录下的各个日志文件中,永久性的保存。

systemd-journal 是syslog 的补充,收集来自内核、启动过程早期阶段、标准输出、系统日志、守护进程启动和运行期间错误的信息,它会默认把日志记录到`/run/log/journal`中，仅保留一个月的日志，且系统重启后也会消失。但是当新建 `/var/log/journal` 目录后，它又会把日志记录到这个目录中，永久保存。

**首先介绍日志的清理方法**

- 查询journald日志占用的空间 `journalctl --disk-usage`

- 清空日志内容 

	方式1删除文件 `rm -rf /run/log/journal/* ` or `rm -rf /var/log/journal/*`

	方式2设置vacuum

	配置保存时长 `journalctl --vacuum-time=1w`

	配置日志大小 `journalctl --vacuum-size=500M`

- 重启服务 `systemctl restart systemd-journald.service`

**查看日志**

`journal -u service_name` 如果有换行可以使用箭头或 `--no-pager` 选项