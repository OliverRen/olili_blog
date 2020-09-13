---
title: Mysql使用帮助
tags: 小书匠语法,技术
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

#### 通过rpm安装
1.最简单的就是yum 
```shell
yum install -y mysql-server mysql mysql-devel
```
2.使用官网的rpm包安装
[链接地址](http://dev.mysql.com/downloads/repo/yum/)

#### 通过源码方式安装
1.卸载旧版本
```shell
# 查询旧版本
rpm -qa | grep mysql
# 普通删除模式
rpm -e mysql
# 强力删除
rpm -e --nodeps mysql
```
2.编译安装
```shell
# 安装编译代码需要的包
yum -y install make gcc-c++ cmake bison-devel  ncurses-devel
# 官网下载mysql包
wget http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.14.tar.gz
# 解压
tar xvf mysql-5.6.14.tar.gz
# 编译安装
# 编译的参数可以参考
# http://dev.mysql.com/doc/refman/5.5/en/source-configuration-options.html
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci

make && make isntall
```
3.配置
```shell
# 查询mysql用户和用户组
cat /etc/passwd
cat /etc/group
# 新增mysql用户和用户组
groupadd mysql
useradd -g mysql mysql
# 修改mysql用户对mysql文件权限
chown -R mysql:mysql /usr/local/mysql
# 初始化配置脚本
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
# tips:需要注意配置文件的搜索顺序
# 1./etc
# 2.$basedir/
# 配置path
vim /etc/profile
--- vim begin ---
PATH=/usr/local/mysql/bin:$PATH
export PATH
--- vim end ---
source /etc/profile
```
4.启动
```shell
# 服务启动脚本
cp support-files/mysql.server /etc/init.d/mysql
chkconfig mysql on
service mysql start
# 连接mysql
mysql -u root
```
5.设置root密码
```sql
# 设置root密码
SET PASSWORD = PASSWORD('123456');
# 设置root远程访问and密码
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.16.%' IDENTIFIED BY 'password' WITH GRANT OPTION;
# 创建用户
CREATE user 'test'@'192.168.10.%' identified by 'abc@123';
# 设置权限
GRANT ALL PRIVILEGES ON *.* TO 'test'@'192.168.1.%' IDENTIFIED BY 'abc@123' WITH GRANT OPTION; 
# 设置密码
SET PASSWORD FOR 'username'@'host' = PASSWORD('newpassword');
# 删除权限
REVOKE privilege ON databasename.tablename FROM 'username'@'host'; 
# 删除用户
 DROP USER 'username'@'host'; 
```
6.配置防火墙开启3306端口即可

#### mysql高可用
1.使用mysql-master-ha配置主从同步
[MHA安装配置](https://blog.csdn.net/lichangzai/article/details/50470771)
2.在MHA配置中实现VIP切换的脚本
[MHA 实现VIP切换用到脚本](https://blog.csdn.net/lichangzai/article/details/50503960)
3.使用keepalived代替MHA实现VIP
[Keepalived VIP配置使用](https://blog.csdn.net/lichangzai/article/details/50484455)

#### mysql修改编码方式
```mysql
show variables like "%character%";
# 默认的数据库编码方式都是latin1,我们需要改成utf8
在创建数据库的时候指定默认字符集
create database mydb charset=utf8;
```

``` shell
vim mysql.conf
在[client]下增加 default-character-set=utf8
在[mysqld]下增加 default-character-set=utf8
在[mysqld]下同时增加 init_connect='SET NAMES utf8'
service mysqld restart
```

#### mysql常用命令
```mysql
# 测试是否支持编码
set names utf8l
# 查看数据库的编码
show character set;
# 查看支持的存储引擎
show engines
# 创建本地连接用户
grant all on dbname.* to username@localhost identified by 'password';
# 创建远程用户
grant all privileges on dbname.* to username@'iparea' identified by 'password' with grant option;
# 删除用户
delete from user WHERE User="username" and Host="localhost";
flush privileges;
# 全局变量
show GLOBAL VARIABLES
# 慢日志
log_slow_queries
# 没有索引的查询语句
log_queries_not_using_indexes
# 访问次数最多的慢日志
mysqldumpslow -s c -t 20 slowlog.log
# 返回包含指定字符的sql语句
mysqldumpslow -t 10 -s t -g "sql语句" slowlog.log
```