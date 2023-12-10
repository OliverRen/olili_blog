---
title: Gitlab私有化部署
---

[toc]

原公司服务器迁移,部署一个新的Gitlab来保存代码,服务器4C内存8G以上对于10-20人的小团队戳戳有余,单个代码库尽量不要超过2G

### 安装

系统选择 Ubuntu 22.04LTS,纯粹因为个人喜好,采用官方Linux安装包方式安装,程序冗余也没有很大的问题,Gitlab都保存在了自己的目录中并且具有很良好的配置性.

``` sh?linenums
apt update
apt install -y curl openssh-server ca-certificates tzdata perl
# 配置环境
curl -fsSL https://packages.gitlab.cn/repository/raw/scripts/setup.sh | /bin/bash
# 安装
EXTERNAL_URL="https://gitlab.example.com" apt install gitlab-jh
```

### 配置

- 主配置文件 `/etc/gitlab/gitlab.rb`
- 更新版本后配置不会合并,而是保存在 `/etc/gitlab/gitlab.rb.template`
- 配置差异查看方式 `gitlab-ctl diff-config`

### 备份和恢复

- 备份配置文件 `gitlab-ctl backup-etc`,备份在 `/etc/gitlab/config_backup`
- 定时备份配置文件 `gitlab-ctl backup-etc --delete-old-backups && cd /etc/gitlab/config_backup && cp $(ls -t | head -n1) /data/gitlab/backup/`
- 恢复配置文件
	```
	# Rename the existing /etc/gitlab, if any
	sudo mv /etc/gitlab /etc/gitlab.$(date +%s)
	# Change the example timestamp below for your configuration backup
	sudo tar -xf gitlab_config_1487687824_2017_02_21.tar -C /
	gitlab-ctl reconfigure
	```
- 备份数据库 `gitlab-backup create`
- 定时备份数据库 `0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1`
- 恢复数据库 需要带上时间戳 `gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce`

### 常用维护命令

- 查看系统状态 `gitlab-ctl status`
- 更改配置文件后使之生效 `gitlab-ctl reconfigure`
- 开启服务 `gitlab-ctl start`
- 重启服务 `gitlab-ctl restart`
- 关闭服务 `gitlab-ctl stop`
- 移除未在gitlab的lfs对象引用 `gitlab-rake gitlab:cleanup:orphan_lfs_files`

### 默认端口

- 默认端口 80/443
- shell 22
- postgreSQL 5432
- redis 6379
- puma    8080
- gitlab workhorse 8181
- nginx 8060
- prometheus 9090
- node 9100
- redis exporter 9121
- postgreSQL exporter 9187