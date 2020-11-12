---
title: windows远程连接帮助
---

[toc]

##### 使用cmd查看远程端口
1. cmd命令行下输入,在输出的内容中查找svchost.exe进程下 TermService服务对应的PID
`tasklist  /svc | findstr Service`
2、输入以下命令即可找到对应PID就能找到对应远程端口
`netstat  -ano | findstr #PID#`

##### 修改windows远程端口
`regedit` 
打开注册表,在注册表编辑器中找到以下PortNamber键，改为要使用的远程端口,如10000。
`HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp{color}`

##### 不能使用RDO等模拟XP登录方式的客户端登录

- 在服务器上打开==远程==,选择允许远程连接到此计算机,取消选中==仅允许运行使用网络级别身份验证的远程桌面的计算机连接(建议)==.因为XP登录方式是不支持网络级别身份验证的.
- 老版本中mstsc管理员登录参数是 console,新版本都是 admin
- 在高版本的服务器系统上,比如大于 server 2008的系统上,还需要额外修改组策略
	- 开始 运行 输入gpedit.msc
	- 定位到 计算机配置 管理模板 Windows组件 远程桌面服务 远程桌面会话主机 安全
	- 修改策略 ==远程(RDP)连接要求使用指定的安全层== 修改为RDP

##### 默认最大远程登录连接为2个,不管是单个账户还是多个账户

因为默认server系统的最大远程登录连接就是2个,超过这个数目需要使用license server进行授权,但官方给予了120天的Grace period来配置license server。如果超过120天后仍然没有可用的license server,则会报错 ==由于没有远程桌面授权服务器可以提供许可证，远程会话被中断。请跟服务器管理员联系。==,此时只能使用 `mstsc /admin /v:ipaddress`来强制使用管理员登录

##### 安装使用==远程桌面服务==角色后,突然不能登录了

原因基本同上,超出120天后就无法登录,只能用 admin 方式强制登录
我们可以选择删除这个角色所对应的服务,然后只用默认的2个连接登录
**或者我们可以对 Grace period做一些投机取巧**

- 开始 运行 regedit 打开注册表
- 定位到 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TerminalServer\RCM\GracePeriod`
- 右键 GracePeriod 项,给当前的administrator添加权限
	- 开始 运行 gpedit.msc 打开组策略
	- 定位到 用户配置 管理模板 系统 阻止访问注册表 选择禁用,有可能需要 `gpupdate /force` 并重启
	- 在注册表的GracePeriod项,右键选择权限 高级 更高 高级 选择当前的administrator 并赋予全部控制权限.
-  在右边窗口删除二进制项，只保留default项
-  重启机器

##### 使用==远程桌面服务== (RDS:Remote Desktop Service)

远程桌面服务是一项由若干角色服务组成的服务器角色。在 Windows Server 2012 中，远程桌面服务包含以下角色服务：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746516.png)

Windows Server 2012默认情况下，只能提供两个用户远程桌面登陆，而通过安装远程桌面服务里的远程桌面会话主机和远程桌面授权，并对其进行配置，即可实现多用户远程登录。下面通过介绍如何配置远程桌面会话主机和远程桌面授权，以及如何通过微软获取许可证激活许可服务器。

###### 安装桌面会话主机和远程桌面授权

1. 在桌面右下角点击服务器管理器图标，打开“服务器管理器”，点击“添加角色和功能”，选择“基于角色或基于功能的安装”，出现以下的安装界面

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746510.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746511.png)

2. 在下边界面直接点击下一步 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746502.png)

3. 选择远程桌面服务，点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746512.png)

4. 在向导界面中点击下一步 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746514.png)

5. 在远程桌面服务角色安装向导中点击下一步 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746517.png)

6. 选择“桌面会话主机”和“远程桌面授权 ”，在弹出的窗口中点击“添加功能”，点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746520.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746522.png)

7. 在以下界面选择安装 ，安装完成后，出现以下界面提示需重启服务器，在下面界面上点击关闭然后重启计算机。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746689.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746525.png)

###### web申请激活码 

需要注意以下几个前提,强烈不推荐此方法 会有作死的风险

> - 系统选择装批量版本,即不是零售版本
> - 使用kms通用验证码进行激活,有些配置会在域中配置好的,否则单机的淘宝key有些是有坑的

1. 在服务器管理器上点击 工具 终端服务 远程桌面授权管理，打开远程桌面授权管理器,有些这里没有这个选项,直接在 远程桌面服务 这个角色下找到 本地的服务器,右键中的 ==RD 授权诊断程序== 就是检测RDS服务是否正常的程序, ==RD授权管理器== 即远程桌面授权管理
2. 选择本地服务器,当前激活状态应该是 ==未激活==,右键选择属性

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746592.png)

3. 在属性对话框中，连接方法选择“Web浏览器”，记下对话框中出现的产品ID（00184-90000-00001-AT259），在获取服务器许可证时，需在网页上注册此ID。注意：如果终端服务器授权中没有服务器，请选择连接，然后输入本机服务器IP地址。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746656.png)

4. 选择“必需信息”，按下图所示填写：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746654.png)

5. 在Internet Explorer浏览器地址栏中输入 [activate.microsoft.com链接地址](https://activate.microsoft.com)，点击GO ，开始注册并获取服务器许可密码向导。确保已选中“启用许可证服务器”项后单击"下一步"按钮。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746608.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746722.png)

6. 在下面界面中，输入“产品ID：00184-90000-00001-AT259”，按下图填写所需信息后，点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746736.png)

7. 在如下信息中，直接点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746738.png)

8. 可以得到“已成功处理您的许可证服务器启动申请。你的许可证ID是：GCYCQ-7TM97-CMFKD-67X26-XY92Q-6BB7V-3PRVX”，记录此服务器ID号。在“需要此时获取客户机许可证吗”中选择”是” 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746706.png)

9. 在下边界面中，如没有许可证，在许可证程序选择“企业协议”，确定信息无误后，继续”下一步”。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746721.png)

10. 在如下界面，“产品类型”选择“Windwos Server 2008 R2远程桌面服务器每用户访问许可”；
	最大用户数（比如为"600"）；
	在“注册号码”中输入从微软获得的七位注册号码
	（如果没有许可证，尝试输入~~5296992、6565792、4954438、6879321~~），再点击“下一步”。
	
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746928.png)	
	
11. 在下边界面直接点击下一步 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746930.png)

12. 在下边界面中，记录许可证服务器ID：GCYCQ-7TM97-CMFKD-67X26-XY92Q-6BB7V-3PRVX”和“许可证密钥ID：V8M42-2KDYD-JM6GV-DBXGG-C4XGB-F39F6-Y3PVX”，然后点击完成。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746931.png)

###### 激活服务器的RDS

1. 在 ==RD 授权管理器== 中右键 属性,确保连接方式是 ==Web浏览器==
2. 	选择服务器，点击右键选择“激活服务器”。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746929.png)

3. 在激活服务器向导中点击下一步 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746933.png)

4. 在连接方法处选择WEB 浏览器，然后点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746932.png)

5. 输入==许可服务器ID==：GCYCQ-7TM97-CMFKD-67X26-XY92Q-6BB7V-3PRVX，然后点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746934.png)

6. 选择立即启动许可安装向导，下一步 。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746936.png)

7. 直接下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746935.png)

8. 输入许可密钥ID：V8M42-2KDYD-JM6GV-DBXGG-C4XGB-F39F6-Y3PVX ，点击下一步。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747062.png)

9. 服务器许可证激活向导完成，点击完成

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747061.png)

###### 配置远程桌面会话主机的授权服务器

即服务器是远程桌面会话主机,本机上有远程桌面授权服务,本机的远程桌面会话主机要显示的指向这个服务

1. 在 ==RD授权诊断程序== 中查看当前服务器授权状态,应该会有黄色的未配置远程桌面会话主机服务器的授权模式的提示

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113746937.png)

2. 开始 运行 gpedit.msc 打开组策略
3. 定位到 计算机配置 管理模板 windows组件 远程桌面服务 远程桌面会话主机 授权,找到 ==使用指定的远程桌面许可服务器== 和 ==设置远程桌面授权模式==

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747063.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747065.png)

4. 设置“使用指定的远程桌面许可证服务器”为启用，并在“要使用的许可证服务器”中，设置当前服务器的IP或者主机名。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747064.png)

5. 启用“设置远程桌面授权模式”，设置授权模式为“按用户”，如下图所示。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747090.png)

6. 在远程桌面会话主机下， 找到 “连接”，按如下图所示设置 ==限制限制连接数量== 和 ==将远程桌面服务用户限制到单独的远程桌面==

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747067.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747068.png)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/windows远程连接帮助/2020811/1597113747066.png)

将远程桌面服务用户限制到单独的远程桌面设置会指定一个用户账户能登录几个终端连接

7. 在运行里输入`gpupdate /force`,强制执行本地组策略，重启服务器，整个配置过程完成。