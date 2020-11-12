---
title: 搭建docker环境
---

[toc]

`yum install docker-io -y`

配置国内docker hub镜像
```
echo "OPTIONS='--registry-mirror=https://mirror.ccs.tencentyun.com'" >> /etc/sysconfig/docker

systemctl daemon-reload

service docker restart
```