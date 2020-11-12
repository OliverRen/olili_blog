---
title: Vim编辑器设置
---

[toc]

> 在终端下使用vim进行编辑时，默认情况下,
编辑的界面上是没有显示行号、语法高亮度显示、智能缩进等功能的。
为了更好的在vim下进行工作，需要手动设置一个配置文件：.vimrc。
在启动vim时，当前用户根目录下的.vimrc文件会被自动读取，该文件可以包含一些设置甚至脚本，所以，一般情况下把.vimrc文件创建在当前用户的根目录下比较方便

``` .vimrc
去掉vi一致性模式
set nocompatible

显示行号
set nummber

检测文件的类型
filetype on

记录历史的行数
set history=1000

背景使用黑色
set background=dark

语法高亮度显示
syntax on

vim使用自动对齐，也就是把当前行的对起格式应用到下一行；
set autoindent
依据上面的对起格式，智能的选择对起方式，对于类似C语言编写上很有用
set smartindent

设置tab键为4个空格
set tabstop=4

设置自动缩进空白长度
set shiftwidth=4

设置匹配模式 括号匹配
set showmatch

设置快速搜索,输入的时候同时搜索
set incsearch

设置自动备份
if has(“vms”)
set nobackup
else
set backup
endif

```

如果设置完后，发现功能没有起作用，检查一下系统下是否安装了vim-enhanced包，查询命令为：
$rpm –q vim-enhanced





















