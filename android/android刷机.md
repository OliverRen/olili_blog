---
title: android刷机
tags: 小书匠语法
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

#### 资源

首先说论坛,由于android刷机需要下载大量的资源和大佬们验证,所以论坛是必须的

国内的机锋论坛2020.9.1正式关闭回复,不过目前搜索搜索信息还是可以的,唯一的替代是智友邦,相对来说信息量少很多

所以建议直接去外网 xda,这是最大最全的 android 开发者论坛了

- [机锋论坛](http://bbs.gfan.com/)
- [智友邦](http://bbs.zhiyoo.net/)
- [XDA](https://www.xda-developers.com/)

#### 术语解释

ROOT:
root时linux中的超级管理员,也是 Android中的最高用户权限,不过ROOT和刷机并没有什么关联,ROOT是进入系统后才产生作用的,一般只建议通过卡刷刷入 SuperSU的包

恢复ROOT:
一般通过线刷官方的rom都可以自动恢复出厂状态

刷机:
简单的解释就是给手机重装系统

刷机方式:
andoird通用方法是 recovery卡刷. 另外三星有特有的 Odin线刷.

什么是卡刷:
利用 Recovery,通过设备上的SD卡中的 zip卡刷包进行操作刷机.可以放 root包获取root权限,放rom包刷系统.一般可以通过 开机键+音量加号进入

什么是线刷:
通过Odin三星特有,用数据线链接电脑,在电脑上操作Odin软件即可,需要通过 开机键+音量减号进入;
通过FastBoot,俗称引导模式执行刷机.

ROM:
即操作系统安装时需要的安装盘

驱动:
设备与PC连接设别的程序

BootLoader:
引导加载程序.是设备加电后执行的第一段代码,在它完成 CPU 和相关硬件的初始化之后，再将操作系统映像或固化的嵌入式应用程序装在到内存中然后跳转到操作系统所在的空间，启动操作系统运行。可形象的理解为硬件锁。当 BL 被锁住时，你的手机便只认可官方的固件（简单说就是能够操纵硬件的系统底层程序，如官方的 Recovery），如果 BL 发现手机中的系统不是被指定的，就会阻止其启动。没有解锁BL,就无法执行刷机

解锁BootLoader:
手机的厂商不同，解锁 BL 的方式也不同，一般来说，解锁 BL 有“官解”和“强解”两种方式。“官解”，就是“官方解锁”，一般是通过官方网站申请解锁，如小米申请解锁的网站。当官方不提供 BL 解锁渠道时，可以利用手机当中的一些软件漏洞来强制解锁 BL，不过这种解锁方式并不安全。PS：解锁之前请务必关闭查找手机功能，否则会解锁失败。

什么是Recovery:
你可以理解为安装系统的 winPE

什么是第三方Recovery:
一般设备出厂肯定是带有Recovery的,但是一般都是用来重置恢复出厂设置的,无法执行刷机,所以需要一个第三方Recovery.

如何刷入第三方 Recovery:
刷入第三方 Recovery 的方法有很多,但是前提都是手机已经解锁 BL,一般都是采用线刷来进行刷入.可以考虑的第三方Recovery有 TWRP(Team Win Recovery Project) 和 CWMRecovery.

双清 wipe:
可以理解为设备的磁盘格式化,一般包括 WIPE DATA/FACTORY RESET 和 WIPE CACHE PARTITION, 在advance中还有 WIPE DALVIK CACHE 和 WIPE BATTERY STATS.字面意思,刷机只需要双清前面2个即可.

#### 刷机流程介绍(三星)

解锁BL为前提

准备软件:kies驱动安装连接PC;Odin线刷软件;第三方Recovery包;第三方rom包

首先需要安装驱动,三星可以使用 kies,其他设备可以选择官方或第三方应用宝等软件,自动安装

当连接到PC后可以在设备管理器看到即可,需要在设备上打包开发人员选项并且开启USB调试,一般是版本号连续按几下即可

完全关机,通过电源+音量减号开始线刷,按一下音量加进入下载模式

打开Odin,可以看到在ID:COM有连接,也可以看log

取消所有复选框,通过 PDA或者现在是AP选择 Recovery包,刷入

大概几秒即可完成,将第三方rom复制到SD卡上插入

通过电源+音量加号进入Recovery卡刷

执行双清

通过SD卡执行卡刷

完成后重新开机

