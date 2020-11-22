---
title: 01_Systemd入门教程
tags: 
---

作者： 阮一峰

转载地址:  

- [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)

**由来**

历史上，[Linux 的启动](http://www.ruanyifeng.com/blog/2013/08/linux_boot_process.html)一直采用[`init`](https://en.wikipedia.org/wiki/Init)进程。

下面的命令用来启动服务。

``` shell
$ sudo /etc/init.d/apache2 start
# 或者
$ service apache2 start
```

这种方法有两个缺点。
1. 一是启动时间长。`init`进程是串行启动，只有前一个进程启动完，才会启动下一个进程。
2. 二是启动脚本复杂。`init`进程只是执行启动脚本，不管其他事情。脚本需要自己处理各种情况，这往往使得脚本变得很长。

**Systemd 概述**

Systemd 就是为了解决这些问题而诞生的。它的设计目标是，为系统的启动和管理提供一套完整的解决方案。

根据 Linux 惯例，字母`d`是守护进程（daemon）的缩写。 Systemd 这个名字的含义，就是它要守护整个系统。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Linux守护进程的启动方法/2020814/1597386177597.jpg)

（上图为 Systemd 作者 [Lennart Poettering](https://en.wikipedia.org/wiki/Lennart_Poettering)）

使用了 Systemd，就不需要再用`init`了。Systemd 取代了`initd`，成为系统的第一个进程（PID 等于 1），其他进程都是它的子进程。

``` shell
$ systemctl --version
```

上面的命令查看 Systemd 的版本。

Systemd 的优点是功能强大，使用方便，缺点是体系庞大，非常复杂。事实上，现在还有很多人反对使用 Systemd，理由就是它过于复杂，与操作系统的其他部分强耦合，违反"keep simple, keep stupid"的[Unix 哲学](http://www.ruanyifeng.com/blog/2009/06/unix_philosophy.html)。

![Systemd 架构图](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Linux守护进程的启动方法/2020814/1597386177603.png)