---
title: ZeroTierOne穿透使用说明
---

[toc]

- 先在 [zerotier](https://my.zerotier.com) 登陆申请创建一个network,我使用了google账号登陆

- zerotier节点根据配置不同，可以成为不同等级的节点,root叫做earth,辅助节点叫做moon,完全的客户端就是leaf

- 首先是安装zerotier，[download](https://www.zerotier.com/download/) 根据不同的系统进行安装

- 安装
需要使用GnuPG验证签名的时候使用以下命令
*[GnuPG]:简称 GPG，是 GPG 标准的一个免费实现。不管是 Linux 还是 Windows 平台，都可以使用。GPGneng 可以为文件生成签名、管理密匙以及验证签名。

``` shell
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
```
不需要验证签名的时候使用以下命令
``` shell
curl -s https://install.zerotier.com | sudo bash
```

- 配置moon辅助节点
使用identity.public创建配置模板
``` shell
sudo chmod 777 /var/lib/zerotier-one
cd /var/lib/zerotier-one
sudo zerotier-idtool initmoon identity.public > moon.json
```

然后修改moon.json,将stableEndpoints修改为vps的公网IP/端口
`"stableEndpoints": [ "23.23.23.23/9993" ]`
这里的id就是node值,也是之后客户端使用的id值,sudo zerotier-cli info也可以查看

然后签名生成moon的配置文件
`sudo zerotier-idtool genmoon moon.json`

然后拷贝生成moon文件，例如
`makedir moons.d`
`mv 000000efe9e9a259.moon moons.d/`

重启服务
``` shell
sudo killall -9 zerotier-one
service zerotier-one restart 
/etc/init.d/zerotier-one restart
service zerotier-one start 
zerotier-one -d
```

- 客户端 Leaf 节点配置
这里的deadbeef00是生成的moon文件名id，可以删除掉前导的0
`sudo zerotier-cli orbit deadbeef00 deadbeef00`
【或者】 只要传播这个moon配置文件即可,放在主文件的moons.d文件夹下