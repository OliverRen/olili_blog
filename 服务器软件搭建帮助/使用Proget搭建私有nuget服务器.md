---
title: 使用Proget搭建私有nuget服务器
---

[toc]

.NET Core项目完全使用Nuget 管理组件之间的依赖关系，Nuget已经成为.NET 生态系统中不可或缺的一个组件，从项目角度，将项目中各种组件的引用统统交给NuGet，添加组件/删除组件/以及更新组件即可一键完成，大大提升工作效率，减少不必要的引用报错。从运维角度，可在不影响老版本的情况下发布新版本，可统一管理公司各个项目中组件版本不一和各个版本组件的使用情况，减少故障发生以并使得项目稳定运行。

nuget.org 有个指南Hosting Packages Overview 告诉你如何自己搭一个nuget Server，下面社区版本有几个相关方案推荐,可以实现自己搭建Nuget Server.我们选择了ProGet,它是一个商业软件，支持nuget、npm、docker等，也是.NET生态应用，而且还提供了免费版本，博客园也是用ProGet，具体参看dudu的文章 [《用ProGet搭建内部的NuGet服务器》](http://www.cnblogs.com/dudu/p/5147284.html)。

ProGet的更新版本较快,安装的版本有可能会用很久,请参考 [http://inedo.com/support/documentation/proget/installation/manual](http://inedo.com/support/documentation/proget/installation/manual),大体上使用手动安装的绿色版本有如下几个步骤:

1. 下载手动安装包
2. 使用sqlserver数据库创建ProGet数据库,使用脚本初始化数据库
3. 使用IIS建立站点指向 webapp,我使用的版本应用程序池必须设置为经典模式,修改web.config中的数据库连接
4. 需要再 [my.inedo.com](my.inedo.com) 创建一个账号,即可得到免费版本的 License Key.进行本地激活
5. 对服务进行配置,修改保存packages的物理路径等.