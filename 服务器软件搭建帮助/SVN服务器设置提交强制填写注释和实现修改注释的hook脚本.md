---
title: SVN服务器(windows)设置提交强制填写注释和实现修改注释的hook脚本
---

[toc]

> svn自带的示例实现是unix的脚本文件，这里提供的是在windows服务器上的脚本.

#### 强制commit时填写注释

在SVN中，修改了代码要提交时写好注释是个好习惯，但很多人往往忽略了这一点
所以可以通过设置‍pre-commit钩子来强制要求提交代码时要写注释。
在Windows下找到你建立版本库的文件夹中的‍hooks文件夹，新建一个名为‍pre-commit.bat的文件，文件内容如下：

``` bat?linenums
@echo off
setlocal
set REPOS=%1
set TXN=%2
rem check that logmessage contains at least 10 characters
svnlook log "%REPOS%" -t "%TXN%" | findstr ".........." > nul
if %errorlevel% gtr 0 goto err
exit 0
:err
echo Empty log message not allowed. Commit aborted! 1>&2
exit 1
```

#### 修改注释
有时我们需要修改注释，这就要设置‍pre-revprop-change钩子了.
还是在hooks文件夹中，新建一个名为‍pre-revprop-change.bat的文件，文件内容如下：

``` bat?linenums
setlocal
set REPOS=%1
set REV=%2
set USER=%3
set PROPNAME=%4
set ACTION=%5
if not "%ACTION%"=="M" goto refuse
if not "%PROPNAME%"=="svn:log" goto refuse
goto OK
:refuse
echo Cann't set %PROPNAME%/%ACTION%, only svn:log is allowed 1>&2
endlocal
exit 1
:OK
endlocal
exit 0
```