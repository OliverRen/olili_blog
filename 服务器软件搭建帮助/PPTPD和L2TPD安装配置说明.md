---
title: PPTPD和L2TPD安装配置说明
---

[toc]

- 安装 EPEL 源,官方原生的rpm源太落后了
*[EPEL]: Extra Packages for Enterprise Linux

`yum install epel-release -y`

- 安装相应软件
`yum install -y wget openswan ppp pptpd xl2tpd`

- 网络规划
公网IP： 103.114.162.2 eth0
l2tpd 网关(localip) 10.0.1.1    客户端： 10.0.1.100-10.0.1.199
pptpd 网关(localip) 10.0.1.2    客户端： 10.0.1.200-10.0.1.254
nat转发： 10.0.1.0/24 => eth0 \[103.114.162.2]

- 系统设置允许转发
``` sysctl.conf
vim /etc/sysctl.conf
net.ipv4.ip_forward = 1
# for ipsec
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
```
使用 `sysctl -p` 使生效

- 配置 pptpd
`vim /etc/pptpd.conf`
```pptpd.conf
# localip是VPN连接成功后，VPN server（就是你启动pptpd服务）的地址
localip 10.0.1.2
# remoteip是指可分配给VPN client的地址或地址段
remoteip 10.0.1.200-254
```
`vim /etc/ppp/options.pptpd`
```options.pptpd
ms-dns 8.8.8.8
ms-dns 8.8.4.4
```

- 配置使用用户
`vim /etc/ppp/chap-secrets`
```chap-secrets
# Secrets for authentication using CHAP
# client        server  secret                  IP addresses
ijiabao         pptpd   123456                 *
ijiabao         l2tpd   123456                 *
# 或者通配
ijiabao * 123456 *
```

> 此时在客户端连接,应该就可以访问了

- 配置L2TP
需要注意的是文件中的注释内容不是#号,而是;分号
`vim /etc/xl2tpd/xl2tpd.conf`
```xl2tpd.conf
listen-addr=103.114.162.2
ipsec saref=yes
[Ins default]
ip range=10.0.1.100-10.0.1.199
local ip=10.0.1.1
```
`vim /etc/ppp/options.xl2tpd`
```options.xl2tpd
ms-dns 8.8.8.8
ms-dns 8.8.4.4
require-mschap-v2
```

- 配置ipsec
> 保持默认即可,需要检查 virtual_private 是否有IP段

`vim /etc/ipsec.conf`
``` ipsec.conf
confi setip
	virtual_private=%v4:10.0.0.0/8,%v4:172.100.0.0/12,%v4:25.0.0.0/8,%v4:100.64.0.0/10,%v6:fd00::/8,%v6:fe80::/10
```

- 设置预共享密钥 PSK
`vim /etc/ipsec.secrets`
```ipsec.secrets
include /etc/ipsec.d/*.secrets
103.114.162.2 %any: PSK "abcdefg"
```

> 此时可以测试连接L2TP

- 防火墙配置

1. pptpd tcp-1723
2. l2tpd udp-500,udp-4500,udp-1701
3. 添加GRE,否则隧道失败 `ipv4 filter INPUT 0 -p gre -j ACCEPT`

> 此时可以vpn拨入,但无法上网

- 防火墙NAT转发
1. 地址伪装 `--add-masquerade`
2. 自动调整MTU `ipv4 filter FORWARD 0 -p tcp -i ppp+ -j TCPMSS --syn --set-mss 1356`
3. 转发 xen=`ipv4 -t nat POSTROUTING -o eth0 -j MASQUERADE -s 10.0.1.0/24`
4. 转发OpenVZ=`ipv4 -t nat POSTROUTING -s 10.0.1.0/24 -j SNAT --to-source VPS公网IP`

- 排错
1. 查看服务 pptpd,l2tpd,ipsec
2. 查看ipsec有无错误 `ipsec verify`

- 参考命令
允许防火墙伪装IP：
`firewall-cmd --add-masquerade`
开启47及1723端口：
`firewall-cmd --permanent --zone=public --add-port=47/tcp`
`firewall-cmd --permanent --zone=public --add-port=1723/tcp`
`iptables -I INPUT -p tcp --dport 1723 -j ACCEPT`
`iptables -I INPUT -p udp --dport 1701 -j ACCEPT
iptables -I INPUT -p udp --dport 500 -j ACCEPT
iptables -I INPUT -p udp --dport 4500 -j ACCEPT`
允许gre协议：
`firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p gre -j ACCEPT`
`firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p gre -j ACCEPT`
`iptables -I INPUT -p gre -j ACCEPT`
设置规则允许数据包由eth0和ppp+接口中进出
`firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i ppp+ -o eth0 -j ACCEPT`
`firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i eth0 -o ppp+ -j ACCEPT`
设置转发规则，从源地址发出的所有包都进行伪装，改变地址，由eth0发出：
`firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o eth0 -j MASQUERADE -s 192.168.0.0/24`
其它，端口映射：
`firewall-cmd --permanent --add-forward-port=port=1122:proto=tcp:toport=22:toaddr=192.168.100.3`
设置ppp的MTU和主网卡一致,先ifconfig查看MTU
add `/sbin/ifconfig $1 mtu 1500` >> /etc/ppp/ip-up

- 参考文件配置 /etc/ipsec.conf
``` ipsec.conf
config setup
        protostack=netkey
        nat_traversal=yes
        virtual_private=%v4:10.0.0.0/8,%v4:172.100.0.0/12,%v4:25.0.0.0/8,%v4:100.64.0.0/10,%v6:fd00::/8,%v6:fe80::/10
conn L2TP-PSK-NAT
    forceencaps=yes
    also=L2TP-PSK-noNAT
conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=103.114.162.2
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
```

- 参考文件配置 sysctl.conf
``` sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
# net.ipv4.conf.$eth.rp_filter = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
```