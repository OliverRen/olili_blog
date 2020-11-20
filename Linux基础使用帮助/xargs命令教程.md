---
title: xargs命令教程
tags: 
---

本文由于阮一峰大佬写的太好,直接拿过来备忘了

转载自其 [阮一峰的网络日志](https://www.ruanyifeng.com/blog/2019/08/xargs-tutorial.html)

`xargs`是 Unix 系统的一个很有用的命令，但是常常被忽视，很多人不了解它的用法。

#### 标准输入与管道命令

Unix 命令都带有参数，有些命令可以接受"标准输入"（stdin）作为参数。

`$ cat /etc/passwd | grep root`

上面的代码使用了管道命令（`|`）。管道命令的作用，是将左侧命令（`cat /etc/passwd`）的标准输出转换为标准输入，提供给右侧命令（`grep root`）作为参数。

因为`grep`命令可以接受标准输入作为参数，所以上面的代码等同于下面的代码。

`$ grep root /etc/passwd`

但是，大多数命令都不接受标准输入作为参数，只能直接在命令行输入参数，这导致无法用管道命令传递参数。举例来说，`echo`命令就不接受管道传参。

`$ echo "hello world" | echo`

上面的代码不会有输出。因为管道右侧的`echo`不接受管道传来的标准输入作为参数。

#### xargs命令的作用

