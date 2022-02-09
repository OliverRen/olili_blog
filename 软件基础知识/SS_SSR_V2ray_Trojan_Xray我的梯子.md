---
title: SS_SSR_V2Ray_Trojan_Xray我的梯子
tags: 
---

[toc]

#### 前言

本文只对这些项目之间的关系和部分协议以及他们之间的"爱恨情仇"进行技术科普,不会有任何的onekey保姆操作,同时对于匿名代理不甚了解也不介绍.

由于GFW的存在,使用了包括但不限于 IP封锁,路由黑洞,DNS污染,TCP重置,深度包检测,机器学习流量探测等技术,访问诸如google,twitter,youtube和各种不可言喻的网站是一项道高一尺魔高一丈的艰巨任务

起初不适用代理服务器的一些方式依然是可用的但已经成为了历史,比如使用https代替http请求,比如使用修改本地hosts来访问

但随着GFW的壁垒越来越高,于是就出现了使用特定的中转服务器(境外或可访问目标网站的服务器)来完成数据传输的方式.

起初简单的方式有使用如VPN,ssh代理,p2p,网页代理等方式,但这些通用方式对小白来说难度大,需要专用的服务器,且一般都是全局的,对客户端本来就可访问的流量也会进行代理,或是会有较大的性能影响等等问题,使得一时间使得互联网的世界小了半个地球.

这时候慢慢的就开始有了一些专用的软件,专门用来进行FANQIANG这一操作,收费的软件中记得上名号的有自由门,蓝灯等.

但是作为一个能有免费的干嘛去付钱的人,作为一个自由开源软件世界中的一员,自然就开始去研究折腾拉.

由于使用的服务端或客户端的软件有很多种,所以介绍一般会以其特定的协议或特定的资源来进行分类.

#### Google App Engine (GAE)

这是我最早使用的梯子方式,虽然当时ss已经是主流,但得益于当时GAE资源可以免费使用不需要购买vps或是各种包月套餐,所以这种方式我使用了很长一段时间

GoAgent是使用跨平台语言Python开发、基于GPL自由软件协议的代理软件。它利用Google App Engine（GAE）的服务器充当代理 , 当时通过google账号注册多个 AppId,或是从网络获取到共享的 AppId 列表,可以近乎不限流量的使用服务.

GoAgent分为两个部分即服务端和客户端,服务端需要部署到GAE服务器上，客户端则是作为用户电脑上的代理客户端, 为方便用户使用，GoAgent提供了自动部署工具。其图标使用了Python语言的图标,客户端需要打开一个类似cmd的命令行界面,在我还不算程序员的时期显得非常的hacker.

从2015年8月以后，GoAgent已停止维护，并被开发者删除。GoAgent作者 phuslu 于2015年3月开始开发另一个翻墙软件GoProxy，现已删除。

Everything that has a beginning has an end .

#### Shadowsocks 

我使用 ss 的时间并不长,可能就是 goproxy 关掉后的几个月把.因为币圈ICO大兴后,GFW封的非常厉害,而 ss 当时虽然有各种混淆加密,流量还是被识别了.

Shadowsocks是一种基于Socks5代理方式的加密传输协议，也可以指实现这个协议的各种开发包。各种语言各路大神开发了各种软件包.

Shadowsocks也分为服务器端和客户端，在使用之前，需要先将服务器端程序部署到服务器上面，然后通过客户端连接并创建本地代理。

另外由于 shadowsocks 被关键字屏蔽,网民会根据谐音将ShadowsocksR称为“酸酸乳” (SSR），将Shadowsocks称为“酸酸”（SS）。另外，因为Shadowsocks(R)的标志均为纸飞机，所以专门提供Shadowsocks(R)或类似服务（如V2Ray）的网站则就被称为了“机场”。

至于 SSR 则是他人(貌似还是个美女)对 SS 的分支,增加了一些混淆方式.虽然一开始由于开源协议等引起了一定的争议,不过后来也转为了GPL.Apache多重许可

虽然由于被喝茶等原因,ss和ssr的原作者相继删库,但由于有相当多的人fork,所以项目依然存活了下来,有后续的各路大神继续开发.目前依然可以从 https://github.com/shadowsocks/ 找到所有的最新版本.并且有了官网 https://shadowsocks.org/en/index.html 

#### V2Ray

https://github.com/v2ray/v2ray-core

https://www.v2ray.com/

V2Ray，是Victoria Raymond以及其社群团队开发的Project V下的一个工具。Project V是一个工具集合，号称可以帮助其使用者打造专属的基础通信网络。Project V的核心工具称为V2Ray，其主要负责网络协议和功能的实现，与其它Project V通信。V2Ray可以单独运行，也可以和其它工具配合，以提供简便的操作流程。开发过程主要使用Go语言 .

使用时间最长的梯子,现在依然在使用,在GFW和封锁最严厉的时候,流量伪装的 V2Ray 依然能很好的工作.

V2Ray 本身是一个很强大的工具,可以定制网络通信,有点像做软的大宽带线路?多入口多出口,可以定制路由实现最优的网络性能,同时VMESS协议良好的自适应加密,以及流量伪装成https都非常适合当梯子.当然他也可以通过配置作为反向代理实现内网穿透的功能,毕竟cn都是不配有公网IP的.

当然目前我们使用的 V2Ray 都是由 V2Fly社区发布的了, 起因是 V2Ray 项目创始人 Victoria Raymond 突然失联，由于其他维护者没有完整的项目权限，于是大家创建了新的社区：V2Fly，后续关于 V2Ray 的更新都由 V2Fly 社区负责。

VMESS 协议主动识别风波 : 通过重放攻击的方式就能准确判定是否为 VMESS 服务，该事件对 V2Ray 的伤害可以说是致命的，点此查看讨论，此后诞生了 VMESS AEAD。

这是两个非常重量级的 issue 

VMESS协议设计和实现缺陷可导致服务器遭到主动探测特征识别(附PoC) #2523 https://github.com/v2ray/v2ray-core/issues/2523

[Feature Request] 次世代方案：设计一个基于 TLS 的简单协议（VLess） #2526 https://github.com/v2ray/v2ray-core/issues/2526

第一个issue发现了VMESS协议可被重放攻击,当时那个阶段所有的 VMESS+tcp 应该都被识别封锁了,我也赶紧换成了 VMESS+ws+tls ,还买了人生的第一个域名,哈哈哈

第二个issue则是直接抛弃了 VMESS 加密, 数据套了VMESS再套tls不累么,直接创造出了 VLESS 协议,其通道不局限但目前看也是直接使用 tls的.

#### Trojan 和 Trojan-Go

Trojan的创造应该是得益于https的比例上升,其直接将流量伪装成https流量,对了和上面的 VLESS 思路是一致的

本身 Trojan 是 c++实现的,他只是一个工具,比不上 V2Ray 这样一个什么都能干的网络框架,基本上只能用来当梯子

而Trojan-Go是其超集,go实现,多路复用、自定义路由、CDN 转发等等额外功能.

作为一个简单功能,其客户端就显得相当简陋了,相比起 VMESS来说,由于 Trojan 是 HTTPS 通信，所以主要性能消耗在 TLS 这块，在保障安全性的前提下 Trojan 也有相当不错的性能 , 但当 VLESS 和 XTLS 协议发布后就显得没什么优势了.

#### XTLS 

https://github.com/XTLS/Xray-core

https://xtls.github.io/

XTLS 协议的原理是将代理过程中的两条 TLS 请求合并成一条 TLS，减少一次 TLS 加密过程来达到提升性能的目的。

当我们使用基于 TLS 的代理浏览 HTTPS 网站、刷手机 APP 时，其实是两层 TLS：外层是代理的 TLS，内层是网站、APP 的 TLS。

XTLS 从第二个内层 TLS data record 开始，数据不二次加解密，直接转发，无缝拼接了两条货真价实的 TLS，从外面看还是一条连贯的普通 TLS，因此绝大多数流量无需二次加解密了。

XTLS 协议也出自 V2Fly 社区，但是因为 License 问题从 V2Ray-Core 中被移除了 , 最后 XTLS 协议的作者独立出来成立了 XRay 社区。

XRay 是 Project X 项目下的一个核心工具也就是现在的 XRay-Core，和 V2Ray-Core 类似主要负责网络协议、路由等网络通信功能的实现，但在功能上是 V2Ray-Core 的超集，VLESS 两者都有，但是 XTLS 只有 XRay 支持。

即 Project V => Project X , V2Ray => XRay , 而 XTLS 只有后者支持.

#### 使用

对于个人选择，其实线路是体验最大的影响因素，垃圾线路怎么优化都是没用的。

当然没有特殊目的最好不要套 CDN 的，多一次中转，无论如何都会有损耗

而用哪个工具,应该是线选择平台支持多的,毕竟win,mac,android,iphone这么多设备都要有客户端不是,然后再选底层协议.

目前 XRay 作为看起来的最优解,其工具也支持 vmess,vless,trojan等协议,且也有了各个平台上的客户端工具

而 V2Ray+tls伪装 也是最稳定,毕竟是分家的长子,资源总归多一点,如果已经再使用,也无需替换.