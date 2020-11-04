---
title: Ubuntu自动更新配置
---

gnome中只要点点鼠标就可以设置更新项和更新周期配置,其实配置文件都是在 `/etc/apt/下`

配置更新项

```
vim  /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
//      "${distro_id}:${distro_codename}-security";
//      "${distro_id}:${distro_codename}-updates";
//      "${distro_id}:${distro_codename}-proposed";
//      "${distro_id}:${distro_codename}-backports";
};
```

配置更新周期

```
vim   /etc/apt/apt.conf.d/10periodic
APT::Periodic::Update-Package-Lists "1";   //显示更新包列表  0表示停用设置
APT::Periodic::Download-Upgradeable-Packages "1"; // 下载更新包  0表示停用设置
APT::Periodic::AutocleanInterval "7"; // 7日自动删除
APT::Periodic::Unattended-Upgrade "1"; //启用自动更新 0表示停用自动更新
```