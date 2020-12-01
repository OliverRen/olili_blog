---
title: win10最快开启无线热点
tags: 
---

通过windows命令行开启

1. 管理员打开win10的cmd程序

2. 输入 `netsh wlan set hostednetwork mode=allow ssid=<ssid> key=<password>`

3. 输入 `netsh wlan start hostednetwork`

4. 关闭 `netsh wlan stop hostednetwork`