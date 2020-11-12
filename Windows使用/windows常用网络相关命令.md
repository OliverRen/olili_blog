---
title: windows常用网络相关命令
---

[toc]

###### 题外话 cmd修改代码页 即修改编码
在cmd命令行输入 `CHCP 65001` 即可修改UTF-8编码
如果还有乱码的错误,可以在窗口属性的字体标签中修改为 Lucida Console即可

###### Ping命令 查看主机响应
-t 持续ping目标主机知道接受到停止信号
-a 将目标ip解析成主机名
-n 对目标主机的ping的次数
-l ping包的大小
-f 设置ip包的DF位

###### Ipconfig 网卡和ip配置
/all 所有的主机网卡配置
/renew 更新适配器的DHCP配置
/release 更新DHCP租约器
/displaydns 显示DNS缓存信息

###### nslookup 查看dns信息
nslookup 域名 
-querytype 查看域名下的某应用服务器

###### arp 查看mac地址
arp -a 显示所有arp信息
arp -s 绑定静态arp
arp -d删除arp信息

###### netstat 查看网络连接状态
-a 显示所有连接及监听端口
-e 显示以太网信息
-n 不进行IP到域名的转换
-p 值显示指定的协议
-s 显示每个协议的状态

###### tracert 追踪到目标地址的中间路由器转发 ICMP协议
-d 不进行ip到主机名的解析
-h 搜索的最大路由跳数
-w 超时时间

###### route 查看当前主机的路由命令
route print 打印主机上的路由表
add
change
delete

###### 由于系统缓冲区空间不足或队列已满，造成套接字连接失败的解决办法
修改两个注册表

1. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters\MaxUserPort`
如果没有，则手动创建 DWord（32位）  ”数值数据“改为十进制65534 或者认为适当的值。
此值表示 用户最大使用的端口数量，默认为5000。

2. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters\TCPTimedWaitDelay`
如果没有，则手动创建 DWord（32位）  ”数值数据“改为十进制30 或者你认为适当的值。
此值表示一个关闭后的端口等待多久之后可以重新使用，默认为120秒，也就是2分钟才可以重新使用。

最后重启