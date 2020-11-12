---
title: Ubuntu设置root密码
---

普通账户登录后,输入 `sudo passwd root` 经过当前用户密码的验证后即可设置root密码了

使用 `su -` 即可带有 root 环境变量切换到用户root了,但是需要记住,切换后是会切到root的home目录的,如果正好是要删除root权限的文件,在 su 后一定要重新切换目录
