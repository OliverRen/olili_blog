---
title: 10_Systemd的定时器实现
tags: 
---

本文转载自 [淼叔cnblog](https://liumiaocn.blog.csdn.net/article/details/89093229)

在这个示例中将会通过一个计时器和一个服务进行关联，达到每分钟调用的目的。

#### 服务示例

```
[root@liumiaocn system]# cat liumiaocn.service 
[Unit]
Description=Systemd Service Sample By liumiaocn
Documentation=https://liumiaocn.blog.csdn.net/

[Service]
WorkingDirectory=/tmp/systemd_working_dir
ExecStart=/bin/sh -c '/usr/bin/echo "hello world" >>/tmp/systemd_working_dir/hello.log'

[Install]
WantedBy=multi-user.target
[root@liumiaocn system]#
```

**需要注意 如果服务中定义了 WorkingDirectory,则该目录必须提前创建,否则就会报 chdir 错误,但没有详细信息**

#### Timer示例

```
[root@liumiaocn system]# cat liumiaocn.timer 
[Unit]
Description=Systemd Sample: say hello every min

[Timer]
OnCalendar=*-*-* *:*:00
Unit=liumiaocn.service

[Install]
WantedBy=timers.target
[root@liumiaocn system]#
```

代码说明：

*   文件名称以timer为后缀，可以清楚地确认出其计时器的作用
*   通过Unit与执行的服务进行关联
*   简单的情况下可以直接设定OnCalendar进行设定

你可以检查 `man systemd.time` 来查看 systemd 能够理解的所有时间单元。