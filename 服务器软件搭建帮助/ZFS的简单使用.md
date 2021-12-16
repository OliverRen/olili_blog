---
title: ZFS的简单使用
---

[toc]

- 环境是 ubuntu20.04,只是简单挂载,不用做 root
- 使用直通卡连接所用硬盘,不建议硬件raid或IR后供盘
- 并不需要像lvm那样修改tag

```
# 安装
apt update
apt install zfsutils-linux

# 创建raid0 == 普通池
zpool create your-pool /dev/sda /dev/sdb

# 创建raid1 == mirror 可用1/2
zpool create your-pool mirror /dev/sda /dev/sdb

# 创建raid5 == raidZ1 3盘+ 可用(n-1)/n
zpool create your-pool raidz1 /dev/sda /dev/sdb /dev/sdc

# 创建raid6 == raidZ2 4盘 可用(n-2)/n
zpool create your-pool raidz2 /dev/sda /dev/sdb /dev/sdc /dev/sdd

# 创建raid10 == mirror池条带化 可用1/2
zpool create your-pool mirror /dev/sda /dev/sdb mirror /dev/sdc /dev/sdd

# 修改池
zpool add your-pool /dev/sdx
```

```
# 查看池
zpool status

# 更新zfs版本后更新指定池或所有池信息
zpool upgrade your-pool 或 zpool upgrade -a
```


