---
title: linux下硬盘检测
tags: 
---

[toc]

#### smart 

查看信息

```
apt install smartmontools
smartctl -A /dev/sda
```

#### badblocks

扫描硬盘

参数

-s 显示进度
-v 显示详细情况
-b 磁盘区块大小
-o 结果输出到文件
-w 执行写入测试 危险,挂载了的盘是不能的

`badblocks -s -v /dev/sda`

#### hdparm

测速

`hdparm -Tt /dev/sda`