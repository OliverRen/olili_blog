---
title: debian9升级到debian10
---

[toc]

有些云主机服务商提供的debian版本只有9,我们愉快的几步就可以升级为10

更新：
`apt-get update && apt-get upgrade`

备份一份：
`cp /etc/apt/sources.list /etc/apt/sources.list.orig`

将/etc/apt/sources.list里所有“stretch”替换为“buster”：
`sed -i 's/stretch/buster/g' /etc/apt/sources.list`

再更新一下
`apt-get update && apt-get upgrade`

执行升级命令
`apt-get dist-upgrade`

提示完成后重启
`reboot`

查看下当前debian版本
`lsb_release -a`