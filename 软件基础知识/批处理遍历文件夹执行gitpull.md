---
title: 批处理遍历文件夹执行gitpull
tags: 
---

`Windows`

``` bat
echo off & color 0A

for /d %%f in (D:\code\*) do (
D:
cd %%f
chdir
git pull
)
pause
```

`linux`

``` shell
#/bin/bash
path=/data0/code
folderlist=`ls $path|grep -v '^$'`
for i in $folderlist
    do
    cd $path/$i
    git pull

    done
```