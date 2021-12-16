---
title: Ubuntu发送邮件
tags: 
---

[toc]

环境:Ubuntu 20.04

实现,可以用命令行发送邮件,不接收,因为单纯的本机发送肯定不行,所以需要smtp发送

```
# 安装
apt install mailutils ssmtp

# 配置
vim /etc/ssmtp/ssmtp.conf
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=username@163.com

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
mailhub=smtp.163.com:465
AuthUser=username@163.com
AuthPass=86xxxxxxxxx (必须是授权码,并不是密码,看各个邮箱都有不同,163的好找而且不会过期)
UseTLS=Yes

# Where will the mail seem to come from?
#rewriteDomain=

# The full hostname
hostname=hpserver

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
#FromLineOverride=YES

# 配置
vim /etc/ssmtp/revaliases
# sSMTP aliases
#
# Format:       local_account:outgoing_address:mailhub
#
# Example: root:your_login@your.domain:mailhub.your.domain[:port]
# where [:port] is an optional port number that defaults to 25.

# 看注释就知道了吧
root:username@163.com:smtp.163.com:465

# 使用,去垃圾箱找
echo "test" | mail -s "test" xxx@qq.com
```

