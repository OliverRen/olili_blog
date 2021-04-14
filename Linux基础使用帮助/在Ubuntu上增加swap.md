---
title: 在Ubuntu上增加swap
---

[toc]

swap即内存交换分区,当内存不够的时候也可以救急

主要命令为 ==mkswap==,==swapon==,==swapoff==,==swaplabel==

查看交换信息 
`swapon --show` 
`free -h` 
`df -h` 

创建交换分区 
原来的写法是 `dd if=/dev/zero of=/swapfile bs=1024 count=1024` 
但现在更推荐  `fallocate -l 1G /swapfile` 他直接操作文件对应的磁盘空间而不需要使用0来填充

更改权限  
`chmod 600 /swapfile` 

标记文件为交换空间 
`mkswap /swapfile` 

启用交换空间 
`swapon /swapfile` 

永久保留交换文件 
需要在fstab中加入挂载 
`echo '/swapfile swap swap defaults 0 0' | tee -a /etc/fstab` 

调整交换分区相关的参数swappiness,设置ram到交换空间的频率 0-100.服务器越低越好
`cat /proc/sys/vm/swappiness`
`sysctl vm.swappiness=10` 或将 `vm.swappiness=10` 写入 `/etc/sysctl.conf`


