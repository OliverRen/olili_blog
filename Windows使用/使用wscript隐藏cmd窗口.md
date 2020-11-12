---
title: 使用wscript隐藏cmd窗口
---

```
set ws=WScript.CreateObject("WScript.Shell") 
ws.Run "d:\yy.bat",0
```