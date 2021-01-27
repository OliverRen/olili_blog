---
title: ulimit的补充
tags: 
---

lotus-miner的报错

Ulimit 问题：Too many open files (os error 24)

miner 在运行过程中可能会出现这个错误 Too many open files (os error 24)， 导致程序退出，解决的方法就是设置系统中最大允许的文件打开数量：

ulimit 命令分别可以作用于 soft 类型和 hard 类型，soft 表示可以超出，但只是警告 hard 表示绝对不能超出，两者的值一般是不一样的:

- 查看当前值（默认是 soft 值）：
	`ulimit -a | grep -ni "open"`
- 查看当前值 soft 值：
	`ulimit -Sa | grep -ni "open"`
- 查看当前值 hard 值：
	`ulimit -Ha | grep -ni "open"`
- 临时修改（只对当前 Shell 有用，修改立即生效）：修改为 1048576 （默认修改的是 soft 值）：
	`ulimit -n 1048576  - 等效于 ulimit -Sn 1048576`
- 临时修改 hard 值为 1048576
	`ulimit -Hn 1048576`
- 可同时修改 soft 和 hard 的值：
	`ulimit -SHn 1048576`
- 针对正在运行中的miner进程，可以通过以下命令修改：
	`prlimit --pid <PID> --nofile=1048576:1048576`
- 通过以下命令查看修改：
	`cat /proc/<PID>/limits`
- 永久修改（重新登录或重启生效）: 把文件 /etc/systemd/user.conf  和 /etc/systemd/system.conf 中的字段修改如下：
	`DefaultLimitNOFILE=1048576`
- 并修改 /etc/security/limits.conf 文件，添加如下内容：
	`* hard nofile 1048576 换行 * soft nofile 1048576`