---
title: 23_Lotus日志控制
tags: 
---

日志控制目前很简单,其中`level`可以设定为 `debug`,`info`,`warn`,`error`

`lotus log set-level <level>`

也可以对部分系统进行日志输出的控制,你可以使用 `lotus log list` 来列举出来所有的系统

对指定的系统进行日志输出的控制

`lotus log set-level --system chain debug`

TIPS:

`GOLOG_OUTPUT`,`GOLOG_FILE`,`GOLOG_LOG_FMT` 这些环境变量可以用来控制输出的格式,文件位置和格式.


