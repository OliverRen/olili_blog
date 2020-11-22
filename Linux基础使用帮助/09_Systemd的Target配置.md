---
title: 09_Systemd的Target配置
tags: 
---

**Target的配置文件**

Target 也有自己的配置文件。

``` shell
$ systemctl cat multi-user.target

[Unit]
Description=Multi-User System
Documentation=man:systemd.special(7)
Requires=basic.target
Conflicts=rescue.service rescue.target
After=basic.target rescue.service rescue.target
AllowIsolate=yes
```

注意，Target 配置文件里面没有启动命令。

上面输出结果中，主要字段含义如下。

`Requires`字段：要求`basic.target`一起运行。

`Conflicts`字段：冲突字段。如果`rescue.service`或`rescue.target`正在运行，`multi-user.target`就不能运行，反之亦然。

`After`：表示`multi-user.target`在`basic.target` 、 `rescue.service`、 `rescue.target`之后启动，如果它们有启动的话。

`AllowIsolate`：允许使用`systemctl isolate`命令切换到`multi-user.target`。

-----------------------------

修改配置文件后重启

修改配置文件以后，需要重新加载配置文件，然后重新启动相关服务。

``` shell
# 重新加载配置文件
$ sudo systemctl daemon-reload

# 重启相关服务
$ sudo systemctl restart foobar
```