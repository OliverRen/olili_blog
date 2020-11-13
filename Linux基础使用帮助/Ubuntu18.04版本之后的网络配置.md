---
title: Ubuntu18.04版本之后的网络配置
tags: 
---

[Netplan](https://netplan.io/) —— **抽象网络配置生成器** ，是一个用于配置 `Linux` 网络的简单工具。 通过 `Netplan` ，你只需用一个 `YAML` 文件描述每个网络接口需要配置成啥样即可。 根据这个配置描述， `Netplan` 便可帮你生成所有需要的配置，不管你选用的底层管理工具是啥。

#### 工作原理

`Netplan` 从 `/etc/netplan/*.yaml` 读取配置，配置可以是管理员或者系统安装人员配置； 也可以是云镜像或者其他操作系统部署设施自动生成。 在系统启动阶段早期， `Netplan` 在 `/run` 目录生成好配置文件并将设备控制权交给相关后台程序。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Ubuntu18.04版本之后的网络配置/20201113/1605250399254.png)

`Netplan` 目前支持以下两种 **网络管理工具** ：

*   `NetworkManager`
*   `Systemd-networkd`

#### 配置

1. 使用 NetworkManager 管理网络设备,默认使用DHCP启动设备

```
network:
    version: 2
    renderer: NetworkManager
```

2. 使用 Systemd-networkd 配置,这需要在 `/etc/netplan` 下进行配置,默认会读取 `*.yaml` 的配置文件

```
network:
    ethernets:
        enp0s3:
            addresses: []
            dhcp4: true
    version: 2
```

```
network:
    ethernets:
        enp0s8:
            addresses: [10.0.0.2/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8,8.8.4.4]
            dhcp4: no
    version: 2
```

#### 命令

`netplan` 操作命令提供两个子命令：

*   `netplan generate` ：以 `/etc/netplan` 配置为管理工具生成配置；
*   `netplan apply` ：应用配置(以便生效)，必要时重启管理工具；

------------------------------

本文主要内容来自
作者：fasionchan
链接：https://www.jianshu.com/p/174656635e74
