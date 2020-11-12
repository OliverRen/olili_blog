---
title: Win10网络邻居无法访问nas的解决方法
---

[toc]

#### 开启SMB协议

在 设置 - 应用 - 程序和功能 - 启用和关闭windows功能 中,勾选上 SMB1.0/CIFS 文件共享支持,然后重启

#### 开启来宾登录

在 开始 - 运行 - gpedit.msc组策略 - 计算机配置 - 管理模板 - 网络 - Lanman工作站,启用不安全的来宾登录,然后重启

#### 修改注册表 AllowInsecureGuestAuth 项

在 开始 - 运行 - regedit注册表 - `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters`,修改 AllowInsecureGuestAuth的值为1确定,然后重启.