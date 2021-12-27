---
title: 搭建nfs服务和使用
tags: 
---

[toc]

环境 ubuntu20.04 

#### 服务端

1.安装

`apt install nfs-kernel-server`

2.配置

```
mkdir -p /data

vim /etc/exports

/data *(rw,sync,no_subtree_check,no_root_squash)

# 实际测试的时候并不觉得需要共享多个路径,所以对 nfs4 并没有太大需求
# 需要注意 第二段要写 * ,如果使用了本地的hostname,客户端通过IP并不能访问共享目录
# 保险期间给共享目录 777 权限
```

3.使用

```
# 查看共享目录
showmount -e localhost
# 如果客户端使用命令报错 clnt_create: RPC: Program not registered
# 一般是服务端第一次配置后没有重启rpc程序,需要按照顺序重启
systemctl stop nfs-server.service
systemctl stop rpcbind.service
systemctl start rpcbind.service
systemctl start nfs-server.service

# 重新export共享目录 无需重启服务
exportfs -rv

# 查看nfs运行
nfsstat

# 查看rpc执行
rpcinfo

# nfs默认使用端口111
netstat -nltpa | grep 111
```

#### 客户端

windows机器需要安装系统功能 Services for NFS 全选,然后使用 mount 命令或直接通过samba都可以直接访问
```
mount 10.1.53.87:/data H:
或
\\10.1.53.87\data
```

获取访问权限,windows访问nfs默认的uid和gid是-2

```
需要读写权限的需要修改注册表
通过修改注册表将windows访问NFS时的UID和GID改成0即可，步骤如下
1、在运行中输入regedit，打开注册表编辑器；
2、进入HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default条目；
3、选择新建----QWORD值，新建AnonymousUid，AnonymousGid两个值，值为0；
4、重启电脑 注册表才会生效
```

linux机器需要安装并挂载

```
apt install nfs-common
mkdir -p /mnt/data
mount -t nfs 10.1.53.87:/data /mnt/data
```