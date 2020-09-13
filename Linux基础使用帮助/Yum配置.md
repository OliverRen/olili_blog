---
title: Yum配置
tags: 小书匠语法,技术
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

#### yum简介

yum，是Yellow dog Updater, Modified 的简称，是杜克大学为了提高RPM 软件包安装性而开发的一种软件包管理器。起初是由yellow dog 这一发行版的开发者Terra Soft 研发，用python 写成，那时还叫做yup(yellow dog updater)，后经杜克大学的Linux@Duke 开发团队进行改进，遂有此名。yum 的宗旨是自动化地升级，安装/移除rpm 包，收集rpm 包的相关信息，检查依赖性并自动提示用户解决。yum 的关键之处是要有可靠的repository，顾名思义，这是软件的仓库，它可以是http 或ftp 站点，也可以是本地软件池，但必须包含rpm 的header，header 包括了rpm 包的各种信息，包括描述，功能，提供的文件，依赖性等。正是收集了这些header 并加以分析，才能自动化地完成余下的任务。

yum 的理念是使用一个中心仓库(repository)管理一部分甚至一个distribution 的应用程序相互关系，根据计算出来的软件依赖关系进行相关的升级、安装、删除等等操作，减少了Linux 用户一直头痛的dependencies 的问题。这一点上，yum 和apt 相同。apt 原为debian 的deb 类型软件管理所使用，但是现在也能用到RedHat 门下的rpm 了。

yum 主要功能是更方便的添加/删除/更新RPM 包，自动解决包的倚赖性问题，便于管理大量系统的更新问题。

yum 可以同时配置多个资源库(Repository)，简洁的配置文件（/etc/yum.conf），自动解决增加或删除rpm 包时遇到的依赖性问题，保持与RPM 数据库的一致性。

-----------

#### yum的安装

只能通过rpm来进行安装了,yum的基础安装包括
- yum                                    // RPM installer/updater
- yum-fastestmirror              // Yum plugin 用来选择最快的仓库镜像
- yum-metadata-parser        // yum的元数据分析程序
其他可以自己选择安装

----------

#### yum的配置
yum 的配置文件分为两部分：main 和repository

*   main 部分定义了全局配置选项，整个yum 配置文件应该只有一个main。常位于/etc/yum.conf 中。
*   repository 部分定义了每个源/服务器的具体配置，可以有一到多个。常位于/etc/yum.repo.d 目录下的各文件中。

Main配置的说明

``` yum.main.conf
[main]
cachedir=/var/cache/yum
//yum 缓存的目录，yum 在此存储下载的rpm 包和数据库，默认设置为/var/cache/yum

keepcache=0
//安装完成后是否保留软件包，0为不保留（默认为0），1为保留

debuglevel=2
//Debug 信息输出等级，范围为0-10，缺省为2

logfile=/var/log/yum.log
//yum 日志文件位置。用户可以到/var/log/yum.log 文件去查询过去所做的更新。

pkgpolicy=newest
//包的策略。一共有两个选项，newest 和last，这个作用是如果你设置了多个repository，而同一软件在不同的repository 中同时存在，yum 应该安装哪一个，如果是newest，则yum 会安装最新的那个版本。如果是last，则yum 会将服务器id 以字母表排序，并选择最后的那个服务器上的软件安装。一般都是选newest。

distroverpkg=redhat-release
//指定一个软件包，yum 会根据这个包判断你的发行版本，默认是redhat-release，也可以是安装的任何针对自己发行版的rpm 包。

tolerant=1
//有1和0两个选项，表示yum 是否容忍命令行发生与软件包有关的错误，比如你要安装1,2,3三个包，而其中3此前已经安装了，如果你设为1,则yum 不会出现错误信息。默认是0。

exactarch=1
//有1和0两个选项，设置为1，则yum 只会安装和系统架构匹配的软件包，例如，yum 不会将i686的软件包安装在适合i386的系统中。默认为1。

retries=6
//网络连接发生错误后的重试次数，如果设为0，则会无限重试。默认值为6.

obsoletes=1
//这是一个update 的参数，具体请参阅yum(8)，简单的说就是相当于upgrade，允许更新陈旧的RPM包。

plugins=1
//是否启用插件，默认1为允许，0表示不允许。我们一般会用yum-fastestmirror这个插件。

bugtracker_url=http://bugs.centos.org/set_project.php?project_id=16&ref=http://bugs.centos.org/bug_report_page.php?category=yum

# Note: yum-RHN-plugin doesn't honor this.
metadata_expire=1h

installonly_limit = 5

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d
```

> 除了上述之外，还有一些可以添加的选项，如：
exclude=selinux*　　
// 排除某些软件在升级名单之外，可以用通配符，列表中各个项目要用空格隔开，这个对于安装了诸如美化包，中文补丁的朋友特别有用。
exclude=kernel*
// 比如禁止升级操作系统内核
gpgcheck=1　　
// 有1和0两个选择，分别代表是否是否进行gpg(GNU Private Guard) 校验，以确定rpm 包的来源是有效和安全的。这个选项如果设置在[main]部分，则对每个repository 都有效。默认值为0。

仓库配置的说明

``` yum.repository.conf
```

------------

#### 配置本地yum源
1. 挂载系统安装盘
mount /dev/cdrom /mnt/cdrom
2. 配置本地yum源
一般在 /etc/yun.repos.d/ 下会有若干repo文件,Base是网络源配置文件,Media则是本地源配置文件
我们将baseurl修改正确,同时将enabled设置位1
3. 禁用默认的yum网络源

------------

#### 使用 fastestmirror插件

肉身在哪决定了你使用官方源的网络速度,还好我们有这个 自动选择最快的yum源 的插件.
安装完成后会在yum的pluginconf.d配置目录下生成 fastestmirror.conf,我们可以在其 hostfilepath 字段指定的文件内将知道的yum源写入.

#### yum第三方源的配置
有需要的时候一般都可以根据第三方的指示来添加,并且一般都需要GPG的签名校验