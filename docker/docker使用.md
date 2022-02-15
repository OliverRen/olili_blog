---
title: docker使用
---

[toc]

###### 安装

1. 使用官方安装脚本自动安装

安装命令如下：

`curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun`

也可以使用国内 daocloud 一键安装命令：

`curl -sSL https://get.daocloud.io/docker | sh`

2. 手动卸载

`apt remove docker docker-engine docker.io containerd runc`

3. 启动

```
systemctl start docker #启动
systemctl enable docker #配置开机自启
```

4. 配置镜像加速源和dns

对于 systemd管理服务的系统，通过daemon方式载入环境配置
```
/etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://reg-mirror.qiniu.com/",
		......
    ], 
    "dns": [
        "114.114.114.114", 
        "8.8.8.8"
    ]
}

sudo systemctl daemon-reload #重载配置
sudo systemctl restart docker #重启docker

docker info # check info
```

科大镜像：https://docker.mirrors.ustc.edu.cn/
网易：https://hub-mirror.c.163.com/
阿里云：https://<你的ID>.mirror.aliyuncs.com（打开此地址登录你的阿里云账号获取你的专属镜像源 https://cr.console.aliyun.com/#/accelerator）
七牛云加速器：https://reg-mirror.qiniu.com

5. docker运行文件

服务端执行文件 也是docker.service的启动文件

`/usr/bin/dockerd`

客户端执行文件 客户端控制服务端的命令执行文件

`/usr/bin/docker`

运行文件的root docker runtime

`cd /var/lib/docker/`

执行文件的root docker state files

`cd /var/run/docker/`

运行的pid文件

`cat /var/run/docker.pid`

###### 常用命令

```
docker search xxxx	# 搜索镜像
docker pull xxxx	# 下载镜像
docker images 		# 列出所有安装过的镜像
docker rmi hello-world # 删除镜像
docker tag 2b1b7a428627	runoob/centos:dev # 给镜像添加tag

docker run learn/tutorial apt-get install -y net-tools
docker ps -l
docker commit 0d1d learn/net-tools
docker run learn/net-tools ifconfig
# 修改镜像并保存，每一个命令行都会使镜像的layer增加一层，最多层数是有限制的，使用commit来提交，每次commit都是一个新的镜像
# -m:提交的描述，-a:指定作者
-----------------------
docker ps -a		# 查看容器
docker ps -l		# 最后运行的容器

docker run -i -t ubuntu:15.10 /bin/bash		# 运行交互式容器
docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world; sleep 1; done" 		# 后台启动容器
docker stop 2b1b7a428627	# 停止容器
docker restart 2b1b7a428627	# 重启容器
docker rm -f 2b1b7a428627	# 删除容器
docker exec -i -t 243c32535da7 /bin/bash # 进入容器

docker export 2b1b7a428627 > ubuntu.tar 				# 导出容器
cat docker/ubuntu.tar | docker import - test/ubuntu:v1	# 导入容器

docker port 2b1b7a428627	# 查看 -P 或 -p 等指定的端口映射情况
docker logs 2b1b7a428627	# 查看容器内标准输出
-----------------------
docker network create -d bridge test-net # 创建容器互联网络
docker run -itd --name test1 --network test-net ubuntu /bin/bash # 创建容器并加入互联网络
```

###### Dockerfile构建镜像

```
cat Dockerfile 
FROM    centos:6.7
MAINTAINER      Fisher "fisher@sudops.com"

RUN     /bin/echo 'root:123456' |chpasswd
RUN     useradd runoob
RUN     /bin/echo 'runoob:123456' |chpasswd
RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" >/etc/default/local
EXPOSE  22
EXPOSE  80
CMD     /usr/sbin/sshd -D

docker build -t runoob/centos:6.7
```

每一个指令都会在镜像上创建一个新的层，每一个指令的前缀都必须是大写的。

第一条FROM，指定使用哪个镜像源

RUN 指令告诉docker 在镜像内执行命令，安装了什么。。。

然后，我们使用 Dockerfile 文件，通过 docker build 命令来构建一个镜像。

###### docker-compose

