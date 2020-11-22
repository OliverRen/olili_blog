---
title: 04_Systemd单元Unit的配置内容
tags: 
---

1. 概述

每一个 Unit 都有一个配置文件，告诉 Systemd 怎么启动这个 Unit 。

Systemd 默认从目录`/etc/systemd/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录`/usr/lib/systemd/system/`，真正的配置文件存放在那个目录。

`systemctl enable`命令用于在上面两个目录之间，建立符号链接关系。

``` shell
$ sudo systemctl enable clamd@scan.service
# 等同于
$ sudo ln -s '/usr/lib/systemd/system/clamd@scan.service' '/etc/systemd/system/multi-user.target.wants/clamd@scan.service'
```

如果配置文件里面设置了开机启动，`systemctl enable`命令相当于激活开机启动。

与之对应的，`systemctl disable`命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。

``` shell
$ sudo systemctl disable clamd@scan.service
```

配置文件的后缀名，就是该 Unit 的种类，比如`sshd.socket`。如果省略，Systemd 默认后缀名为`.service`，所以`sshd`会被理解成`sshd.service`。

2. 配置文件的状态

`systemctl list-unit-files`命令用于列出所有配置文件。

``` shell
# 列出所有配置文件
$ systemctl list-unit-files

# 列出指定类型的配置文件
$ systemctl list-unit-files --type=service
```

这个命令会输出一个列表。

``` shell
$ systemctl list-unit-files

UNIT FILE              STATE
chronyd.service        enabled
clamd@.service         static
clamd@scan.service     disabled
```

这个列表显示每个配置文件的状态，一共有四种。
*   enabled：已建立启动链接
*   disabled：没建立启动链接
*   static：该配置文件没有`[Install]`部分（无法执行），只能作为其他配置文件的依赖
*   masked：该配置文件被禁止建立启动链接

注意，从配置文件的状态无法看出，该 Unit 是否正在运行。这必须执行前面提到的`systemctl status`命令。

``` shell
$ systemctl status bluetooth.service
```

一旦修改配置文件，就要让 SystemD 重新加载配置文件，然后重新启动，否则修改不会生效。

``` shell
$ sudo systemctl daemon-reload
$ sudo systemctl restart httpd.service
```

3. 配置文件的格式

配置文件就是普通的文本文件，可以用文本编辑器打开。

`systemctl cat`命令可以查看配置文件的内容。

``` systemd.conf
$ systemctl cat atd.service

[Unit]
Description=ATD daemon

[Service]
Type=forking
ExecStart=/usr/bin/atd

[Install]
WantedBy=multi-user.target
```

从上面的输出可以看到，配置文件分成几个区块。每个区块的第一行，是用方括号表示的区别名，比如`[Unit]`。注意，配置文件的区块名和字段名，都是大小写敏感的。

每个区块内部是一些等号连接的键值对。

``` systemd.conf
[Section]
Directive1=value
Directive2=value
. . .
```

注意，键值对的等号两侧不能有空格。

4. 配置文件的区块

`[Unit]`区块通常是配置文件的第一个区块，用来定义 Unit 的元数据，以及配置与其他 Unit 的关系。它的主要字段如下。
*   `Description`：简短描述
*   `Documentation`：文档地址
*   `Requires`：当前 Unit 依赖的其他 Unit，如果它们没有运行，当前 Unit 会启动失败
*   `Wants`：与当前 Unit 配合的其他 Unit，如果它们没有运行，当前 Unit 不会启动失败
*   `BindsTo`：与`Requires`类似，它指定的 Unit 如果退出，会导致当前 Unit 停止运行
*   `Before`：如果该字段指定的 Unit 也要启动，那么必须在当前 Unit 之后启动
*   `After`：如果该字段指定的 Unit 也要启动，那么必须在当前 Unit 之前启动
*   `Conflicts`：这里指定的 Unit 不能与当前 Unit 同时运行
*   `Condition...`：当前 Unit 运行必须满足的条件，否则不会运行
*   `Assert...`：当前 Unit 运行必须满足的条件，否则会报启动失败

`[Install]`通常是配置文件的最后一个区块，用来定义如何启动，以及是否开机启动。它的主要字段如下。
*   `WantedBy`：它的值是一个或多个 Target，当前 Unit 激活时（enable）符号链接会放入`/etc/systemd/system`目录下面以 Target 名 + `.wants`后缀构成的子目录中
*   `RequiredBy`：它的值是一个或多个 Target，当前 Unit 激活时，符号链接会放入`/etc/systemd/system`目录下面以 Target 名 + `.required`后缀构成的子目录中
*   `Alias`：当前 Unit 可用于启动的别名
*   `Also`：当前 Unit 激活（enable）时，会被同时激活的其他 Unit

`[Service]`区块用来 Service 的配置，只有 Service 类型的 Unit 才有这个区块。它的主要字段如下。
*   `Type`：定义启动时的进程行为。它有以下几种值。
*   `Type=simple`：默认值，执行`ExecStart`指定的命令，启动主进程
*   `Type=forking`：以 fork 方式从父进程创建子进程，创建后父进程会立即退出
*   `Type=oneshot`：一次性进程，Systemd 会等当前服务退出，再继续往下执行
*   `Type=dbus`：当前服务通过D-Bus启动
*   `Type=notify`：当前服务启动完毕，会通知`Systemd`，再继续往下执行
*   `Type=idle`：若有其他任务执行完毕，当前服务才会运行
*   `ExecStart`：启动当前服务的命令
*   `ExecStartPre`：启动当前服务之前执行的命令
*   `ExecStartPost`：启动当前服务之后执行的命令
*   `ExecReload`：重启当前服务时执行的命令
*   `ExecStop`：停止当前服务时执行的命令
*   `ExecStopPost`：停止当其服务之后执行的命令
*   `RestartSec`：自动重启当前服务间隔的秒数
*   `Restart`：定义何种情况 Systemd 会自动重启当前服务，可能的值包括`always`（总是重启）、`on-success`、`on-failure`、`on-abnormal`、`on-abort`、`on-watchdog`
*   `TimeoutSec`：定义 Systemd 停止当前服务之前等待的秒数
*   `Environment`：指定环境变量

Unit 配置文件的完整字段清单，请参考[官方文档](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)。