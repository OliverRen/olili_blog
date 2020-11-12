---
title: docker使用
---

[toc]

* [docker文件](#docker%E6%96%87%E4%BB%B6)
* [运行配置](#%E8%BF%90%E8%A1%8C%E9%85%8D%E7%BD%AE)
* [网络代理](#%E7%BD%91%E7%BB%9C%E4%BB%A3%E7%90%86)
* [Reference](#reference)

###### docker文件

服务端执行文件 也是docker.service的启动文件

`$:/usr/bin/dockerd`

客户端执行文件 客户端控制服务端的命令执行文件

`$:/usr/bin/docker`

运行文件的root docker runtime

`$:cd /var/lib/docker/`

执行文件的root docker state files

`$:cd /var/run/docker/`

运行的pid文件

`$:cat /var/run/docker.pid`

###### 运行配置

start,reload 等相关运行的环境命令

`$:cat /usr/lib/systemd/system/docker.service`

`$:cd /usr/lib/systemd/system/docker.service.d (mkdir -p /usr/lib/systemd/system/docker.service.d)`

老版本的 centos 使用环境变量文件 不再推荐

`$:cd /etc/sysconfig/docker`

centos 7上推荐在这个目录下创建 \*.conf 文件来覆盖 docker.service 中的指定项

https://docs.docker.com/engine/admin/#/configuring-docker-1

可以指定的项可以参考该文件

https://docs.docker.com/engine/reference/commandline/dockerd/

`$:cd /etc/systemd/system/docker.service.d`

也可以使用daemon.json文件来进行覆盖

https://docs.docker.com/engine/reference/commandline/dockerd/#/linux-configuration-file

确认docker是否使用了环境变量文件

`$:systemctl show docker.service | grep EnvironmentFile eg.>EnvironmentFile=-/etc/sysconfig/docker (ignore_errors=yes)`

找到运行docker的配置文件的位置

`$:systemctl show --property=FragmentPath docker `

`eg.>FragmentPath=/usr/lib/systemd/system/docker.service`

如果重载或者配置，可以在 /usr/lib/systemd/system/ 下放文件

###### 网络代理

示例:使用配置文件覆盖的方式来实现 http proxy

```
$:mkdir /etc/systemd/system/docker.service.d
$:vi /etc/systemd/system/docker.service.d/http-proxy.conf
eg.
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:80/" 
eg.
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:80" "NO_PROXY=localhost,127.0.0.1,docker-registery.somecorporation.com"
$:systemctl daemon-reload #生效
$:systemctl show docker | grep Enviroment
$:systemctl restart docker #重启docker
```

###### Reference

搜索镜像

`$:docker search xxxx`

下载镜像

`$:docker pull xxxx`

查所有的容器列表

`$:docker ps -a`

查看最后运行的镜像

`$:docker ps -l`

检查运行中的镜像

`$:docker inspect [id]`

列出所有安装过的镜像

`$:docker images `

使用本地镜像执行命令

`$:docker run learn/tutorial echo "hello world"`

修改镜像 并保存

`$:docker run learn/tutorial apt-get install -y net-tools`

`$docker ps -l`

只会返回当前操作的镜像
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
0d1d09c846dd        learn/tutorial      "apt-get install -y n"   15 seconds ago      Exited (0) 8 seconds ago                       adoring_rosalind
$:docker commit 0d1d learn/net-tools
$:docker run learn/net-tools ifconfig
```

就可以看到ip配置的返回了

每一个命令行都会使镜像的layer增加一层，最多层数是有限制的（好像是32？）

解决这个问题，要么一行用多个命令连接起来，然后commit，每次commit都是一个新的镜像

要么导出后丢掉历史，然后导入一个新的，重新开始

使用dao cloud提速 docker 的image build/pull

https://account.daocloud.io/signin 注册后,我使用github登陆

docker push可以将镜像发布到官方网站 我的账号是 oliverren