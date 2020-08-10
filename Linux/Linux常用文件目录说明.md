---
title: Linux常用文件目录说明
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

#### 基本文件系统类型
linux有四种基本文件系统类型：

- 普通文件：如文本文件、c语言源代码、shell脚本等，可以用cat、less、more、vi等来察看内容，用mv来改名；
- 目录文件：包括文件名、子目录名及其指针，可以用ls列出目录文件；
- 链接文件：是指向一索引节点的那些目录条目，用ls来查看时，链接文件的标志用l开头，而文件后以"->"指向所链接的文件；
- 特殊文件：如磁盘、终端、打印机等都在文件系统中表示出来，常放在/dev目录内；

#### Linux系统的路径

![](http://qiniu.imolili.com/小书匠/1592381649729.png)

![](http://qiniu.imolili.com/小书匠/1592383301261.png)

> linux系统中，所有的文件与目录都是由根目录/开始，不是以/开头的就是相对路径；
.：表示当前目录，也可以用./表示；
..：表示上一级目录，也可以用../表示；
~：代表用户自己的宿主目录；

*   /
处于Linux文件系统树形结构的最顶端，我们称它为Linux文件系统的root，它是Linux文件系统的入口。所有的目录、文件、设备都在/之下，它是Linux文件系统最顶层的唯一的目录；
 一般建议在根目录下面只有目录，不要直接存放文件；根目录是linux系统启动时系统第一个载入的分区，所以启动过程中用到的文件应该都放在这个分区中，其中/etc、/bin、/dev、/lib、/sbin这5个子目录都应该要与根目录连在一起，不可独立成为某个分区；

*   /bin
存放所有用户都可以使用的linux基本操作命令；(目录中多是可执行的二进制文件)

*   /boot
包含Linux内核、启动时所需的驱动，和启动时加载的程序；/boot/grub/grub.cfg，用来配置启动加载程序；/boot/vmlinuz，是Linux内核。

*   /dev
设备文件目录，虚拟文件系统，主要存放所有系统中device的相关信息，不论是使用的或未使用的设备，只要有可能使用到，就会在/dev中建立一个相对应的设备文件；设备文件分为2种类型： 字符设备文件和块设备文件,Linux中，“一切都是文件”，也适用于设备。
/dev/console：系统控制台，也就是直接和系统连接的监视器；
/dev/hd：IDE设备文件；
/dev/sd：sata、usb、scsi等设备文件；
/dev/fd：软驱设备文件；
/dev/tty：虚拟控制台设备文件；
/dev/pty：提供远程虚拟控制台设备文件；
/dev/null：所谓"黑洞"，所有写入该设备的信息都将消失，如当想要将屏幕上的输出信息隐藏起来时，只要将输出信息输入到/dev/null中即可；

*   /etc
包含所有系统层面的配置文件；也包含一系列的shell脚本，系统启动时，这些脚本会开启每个系统服务；这个目录中的任何文件都应该是可读的文本文件
简单的将 `/etc` 下的目录分为以下几类:

1.  ==服务器目录== 如samba,http,vsftpd 等服务配置相关的目录
		这里一般都是根据安装的服务软件来创建的
		
2.  ==基本文件== 所有直接放在/etc目录下的文件归类为基本文件；
		aliases：用于设置邮件别名；
		auto.\*：代表的是一系列autofs服务所需要的配置文件，这个服务主要是让管理员可以事先定义出一些网络、本机或光驱等默认的路径；
		auto.master：负责规划目录的分配与使用，目前默认提供三种自动挂载模式；
		auto.misc：文件中的配置都以实体连接本机的磁盘驱动器为主；
		auto.net：并不是一个配置文件，而是一个脚本文件，在使用上其实不须做任何调整；；
		auto.smb：与auto.net一样，都是以个脚本文件；
		bashrc：用户登录功能配置，全局配置，对所有用户生效，主要配置别名；
		profile：与系统环境配置或初始化软件的相关配置，全局配置，对所有用户生效，主要配置变量；
		DIR_COLORS：用于配置ls命令的颜色，主要针对tty登录的用户；
		DIR_COLORS.xterm：用于配置ls命令的颜色，主要针对xterm登录的用户；
		fstab：系统启动时自动挂载文件系统的配置文件；
		inittab：启动时系统所需要的第一个配置文件；也即是init进程的配置文件；
		issue：用户本机登录时，看到的欢迎信息；
		issue.net：用户网络登录时，看到的欢迎信息；
		ld.so.conf：包含ld.so.conf.d/.conf配置；主要是ld.so.conf.d/.conf目录的作用；
		localtime：系统所使用的时区对应的配置文件；对应的时区文件都存在于/usr/share/zoneinfo/
		motd：登录成功的用户显示的信息对应的配置文件；
		mtab：可以当做是检查当前文件系统挂载情况的配置文件；与mount命令结果一致；
		prelink.conf：定义哪些执行文件和函数库是需要预先连接的；
		securetty：主要是login程序在使用的，只要是列在该文件中的接口，就表示是可以使用的接口，相反，若从列表中删除，则无法使用该接口；
		shells：记录目前系统所拥有shell种类的路径，通过cssh命令使用；
		sudoers：sudo命令对应的配置文件，用于配置权限的分配方式；
		sysctl.conf：主要是帮助用户配置/proc/sys目录下所有文件的值，与sysctl命令对应；
		syslogd.conf：是syslogd服务的配置文件
		host.conf：主机名解析配置文件，主要说明解析的方式及顺序；
		hosts：主机名解析配置文件，主要列出所有需要本地解析的主机名与IP地址的对应关系；
		hosts.allow和hosts.deny：linux网络安全机制TCP Wrapper对应的配置文件；
		nsswitch.conf：主要记录系统应如何查询主机名、密码、用户组、网络等，或是查询顺序的编排；
		resolv.conf：记录DNS服务器地址，用于DNS域名解析；
		services：定义了网络服务的默认端口号；
		xinetd.conf：xinetd的主配置文件，目的是为xinetd.d下的所有子服务建立一个标准的规范使其可以遵循；
		anacrontab：属于一种任务计划软件的配置文件，anacrontab软件和crond其实有点相辅相成，crond负责任务计划，而anacrontab则是负责以"间隔多久"为主要的目标；
		at.deny：该文件属于拒绝列表，只要被记录在其中的用户，就无法使用at所提供的任务计划服务；
		at.allow：与at.deny刚好相反；
		crontab：crontab的主配置文件，crond默认会执行的文件可以参考此配置文件；
		cron.deny：该文件属于拒绝列表，只要被记录在其中的用户，就无法使用crond所提供的任务计划服务；
		cron.allow：与cron.deny刚好相反；
		exports：是NFS服务的主配置文件，主要目的就是将本机的目录共享到网络上，供其他人使用；
		group与gshadow：用户组配置文件，group主要保存用户组信息，gshadow主要保存群组密码；
		login.defs：设置系统在建立账号时所参考的配置；
		passwd：主要保存系统用户账号的信息；
		shadow：linux系统通常包经过"hash"处理后的密码存储在这个文件中；
		protocols：通信协议对应端口号的一个对照表，包含协议名称、协议号码、注释等；
		wgetrc：wget程序对应的配置文件，其中有quota、mail header、重传文件的预设次数、firewall和proxy等相关设置；
		init.d：RHEL中所有服务的默认启动脚本都存放在这里；这个是链接文件，链接到/etc/rc.d/init.d；
		csh.cshrc和csh.login： 用户启动c shells执行的初始化配置文件；
		printcap：linux系统中打印机设备对应的配置文件；
3.  ==系统目录== 如sysconfig或网络配置等与系统运行相关的目录
		blkid：此目录所存放的其实是一个块设备ID的临时文件，主要是记录系统中所有区块设备的标签名称、硬件的唯一识别码、文件系统的格式等基本信息；
        bluetooth：linux下使用蓝牙设备所需的配置文件；启动蓝牙检测的主要服务仍是/etc/rc.d/init.d/bluetooth，该程序使用的是hcid.conf配置文件；
		cron.X：cron.X的目录都是给cron软件存放其需要任务计划的文件所使用的，按任务计划时间的长短及配置特性分为cron.d、cron.daily、cron.hourly、cron.monthly、cron.weekly五个主要目录；
		dbus-1：D-BUS的主要配置目录，D-BUS也是一种IPC交流的方式；
		default：这里是存放一些系统软件默认值的目录，存放某些软件执行时的基本参数；
		firmware：这个目录所存放的东西是非常底层的信息，是CPU所需的microcode的实体文件；
		foomatic：与打印机相关的配置目录，实现打印一对多的方式，在foomatic中，可以记录多条打印机数据，让用户只在使用前先行配置所有需要使用的打印机即可；
		hal：全名Hardware Abstraction Layer，是linux一种管理硬件的机制，它会帮所有的应用程序或用户搜集所有PCI及USB等硬件信息，因此，用户可以很简单并实时地通过HAL的方式取得硬件的相关数据；
		isdn：ISDN服务的主要配置目录，里面包含可拨号的用户、电话、联机方式等；
		ld.so.conf.d：这个目录是ldconfig所使用的，更准确的说，它是由/etc/ld.so.conf文件所决定的；ldconfig命令的目的在于将系统中的一些函数库预先存放到内存中，让系统使用时可以比以往通过硬盘的读取速度来的更快，这样可以大幅提高系统性能，尤其当要重复读取时更明显；ldconfig要将哪些函数库丢到内存中，则须看/etc/ld.so.conf文件中所记录的信息；
		logrotate.d：此目录对系统管理员来说，是十分重要的一个目录，因为目录中的文件，记录了如何定期备份系统所需要备份的系统或软件日志文件及备份方式，目录是由logrotate组件所提供的，而里面所有文件是由各软件各自产生的；其主要配置文件是/etc/logrotate.conf；                
		logwatch：logrotate主要是实现如何备份日志文件，这个目录就是记载如何分析日志文件并告诉用户的软件logwatch的配置目录；
		lsb-release.d：LSB是一个由很多人所执行的项目，其目的是将所有的Linux发行版定义为一些共同的标准；
		lvm：这个目录是LVM的基本配置文件，但配置或操作一般都只需要通过LVM提供的命令，而不会用到这个目录，除非要使用到很高级的配置才会更改此文件；
		makedev.d：MAKEDEV软件对应的配置文件目录，MAKEDEV主要用来产生设备文件，也就是说，在/dev目录下的文件都由这个命令产生的，此目录下的文件主要是针对设备文件的定义或属性，目录中存在的设备文件可以由MAKEDEV来创建，否则需要使用mknod命令了；
		modprobe.d：是modprobe命令的住配置目录，一般系统启动默认要加载的模块放在/etc/modprobe.conf中；
		netplug和netplug.d：这两个目录和网络接口的联机与否由直接关系，因为主要是控制联机时的接口操作；
		opt：此目录原本是定义为存放所有额外安装软件的主机配置文件，但目前并没有被使用到，此目录为空；
		pcmcia：这是PCMCIA的配置文件目录，PCMCIA是笔记本电脑不可或缺的接口，需要即插即用的方式，此接口使用较少；
		pm：由pm-utils组件所提供的目录，pm-utils是一套电源管理的工具软件，其中/usr/lib/pm-utils也是主要目录之一；
		ppp：ppp相关的配置文件都放在这个目录中；
		profile.d：这个目录存放的是系统部分的软件配置，但会按不同的shell执行不同的文件，默认所使用的bash会直接执行该目录下所有扩展名为.sh的文件；
		rc.d：主要用来定义在每一个执行阶段必须要执行哪些系统服务或程序，在目录中主要分为三个重要的部分：
		--rc.sysinit：系统一开始启动时所遇到的第一个文件，此脚本文件记录服务启动之前所需准备的所有事情，包括启动时看到的欢迎画面；
		--rcX.d：在rc.sysinit文件之后所要执行的，X是系统启动时的initdefault值，值为几则会转到那个目录下，并执行其中的所有文件，在此目录中，文件一律都由两个英文字母开始K和S，K代表kill，S代表Start；
		--rc.local：系统初始化过程中最后一个执行的脚本文件，可以将需要开机启动的程序或脚本放置在这个脚本文件中，以实现自动运行的目的；
		readahead.d：是readahead程序的主要配置目录，为了加速操作系统的使用速度，readahead_early和readahead_later这两个进程在系统加载时，直接将日常所需要的一些文件，全部先放到硬盘的高速缓存中；
		redhat-lsb：都lsb-release.d目录都是由程序redhat-lsb所提供的；
		rwtab.d：这个目录是一个在启动时会去参考的目录，主要的文件在/etc/rwtab；这是一个系统初期的备份机制；
		sane.d：这是在系统下要使用扫描仪所需的配置目录，主要配置文件是sane.conf，sane为了方便用户在各式的扫描仪连接时都可以使用，因此，在这一目录中放置了很多种不同类型扫描仪的硬件信息，让系统在检测到扫描仪时可以直接使用；
		setuptool.d：这个目录是"setup"系统配置工具的主要配置目录；
		skel：用于初始化用户宿主目录的配置目录，当建立一个用户时，会把此目录下的所有文件复制一份到用户的宿主目录，作为用户的初始化配置；
		sysconfig：非常重要的系统配置文件的存放目录，里面放置了大量系统启动及运行相关的配置文件；
		sysconfig/network-scripts/ifcfg-eth0：网卡eth0对应的配置文件，设置内容包括设备名称、IP地址、广播地址、网关地址、网段、开机是否激活等参数
		udev：udev程序本身是一套设备的管理机制，udev通过sysfs的文件系统，可以正确地掌握目前系统上存在的硬件设备，以及针对每一个硬件设备做出不同的判断与执行；
		yum和yum.repos.d：这两个都是yum的配置目录，是一套在linux下可以自动帮助用户安装、更新、移除等的管理组件，可用来替代rpm包管理方式，主配置文件是/etc/yum.conf；yum是更新方式及外挂程序的配置目录，yum.repos.d是存放定期更新组件内容的信息；		
4.  ==安全性目录==如selinux,或pam.d等管理系统安全性的目录
		audit：这个目录所代表的是一种和目录名称一致的audit安全机制，主要以服务的方式协助管理员持续监控各文件被存取的情况；目录下的audit.rules文件主要是定义一些必要的监控规则；
		pam.d：此目录是Linux-PAM的所有配置文件，配合/lib/security目录中所有觉得函数库，提供Linux下的应用程序认证的机制；
		pam_pkcs11：PAM机制中的一种登录模块，可以让用户通过smart card做登录的操作；
		pki：PKI是一种公开密钥的管理方式，通过这样的管理模式，可以让所有网络传输有更多保障；
		racoon：这个目录是由ipsec-tools组件所提供的，ipsec的主要目的是让系统实现VPN的网路技术，在racoon目录的主配置文件racoon.conf中，定义在ipsec操作中所需要的加密算法种类以及其他细节的配置；
		security：与pam.d目录相辅相成，pam.d中的所有PAM的规则都要用到/lib/security下的PAM函数库，而/etc/security目录中，就是针对这些函数库，提供以配置文件的方式进行细节配置，对希望调整系统安全性部分增加了非常大的方便性；
		selinux：selinux是一个很新的安全性方案，它是一种针对各种文件、目录、设备或daemon等在linux所需使用到的安全性机制，而且其安全性的数据时直接记录在文件系统中；
		wpa_supplicant：这个目录被归类到安全性目录中，是因为其属于无线中安全认证的部分，存在wpa_supplicant.conf配置文件，用户可以在这个目录中加入已知可登陆的AP；

*   /home
通常的配置环境下，系统会在/home下给每个用户分配一个目录(除了root用户)；普通用户只能在自己的目录下写文件。
/home/~/.bashrc：提供bash环境中所需使用的别名；
/home/~/.bash_profile：提供bash环境所需的变量；一般先执行.bashrc后，才会再执行.bash_profile；
/home/~/.bash_history：用户历史命令文件，记录用户曾经输入过的所有命令；(默认为1000条，可以通过HISTSIZE变量更改)
/home/~/.bash_logout：当用户注销的同时，系统会自动执行.bash_logout文件，如果管理员需要记录用户注销的一些额外记录、动作或其他信息，就可以利用这个机制去完成；

*   /lost+found
当系统在运行时，有时会无法避免宕机、断电或不正常重启动，在这样的情况下，当系统重新启动时，发现某些文件写入未完成或其他问题产生，一般会使用fsck进行文件修复，而这些被修复或救回的文件，就会被放在这个目录下，只要是一个文件系统，系统就会自动在该文件系统所在的目录下建立"lost+found"目录

*   misc
自动挂载服务目录，对应autofs服务

*   /lib
包含核心系统程序所使用的共享库文件；​这些文件与Windows中的动态链接库（dll）相似。

*   /media
包含可移动介质的挂载点，如USB驱动器、CD-ROMs等； 这些介质连接到计算机之后，会自动地挂载到这个目录结点下。

*   /mnt
同/media，早些的Linux系统中，/mnt目录包含可移动介质的挂载点

*   /opt
用来存储可能安装在系统中的商业软件

*   /proc
一个由Linux内核维护的虚拟文件系统；包含的文件是内核的窥视孔，这些文件会告诉你内核是怎样监管计算机的。
`/proc` 主要作用可以整理为：
整理系统内部的信息；
存放主机硬件信息；
调整系统执行时的参数；
检查及修改网络和主机的参数;
检查及调整系统的内存和性能;

`/proc`下常用的信息文件有:
/proc/cpuinfo：cpu的硬件信息，如类型、厂家、型号和性能等
/proc/devices：记录所有在/dev目录中相关的设备文件分类方式
/proc/filesystems：当前运行内核所配置的文件系统
/proc/interrupts：可以查看每一个IRQ的编号对应到哪一个硬件设备
/proc/loadavg：系统"平均负载"，3个数据指出系统当前的工作负载
/proc/dma：当前正在使用的DMA通道 
/proc/ioports：将目前系统上所有可看到的硬件对应到内存位置的分配表的详细信息呈现出来
/proc/kcore：系统上可以检测到的物理内存，主机内存多大，这个文件就有多大
/proc/kmsg：在系统尚未进入操作系统阶段，把加载kernel和initrd的信息先记录到该文件中，后续会将日志信息写入/var/log/message文件中
/proc/meminfo：记录系统的内存信息
/proc/modules：与lsmod命令查看到的模块信息完全一致
/proc/mtrr：负责内存配置的机制
/proc/iomem：主要用于储存配置后所有内存储存的明细信息
/proc/partitions：这个文件可以实时呈现系统目前看到的分区
/proc/数字目录：数字目录很多，它们代表所有目前正在系统中运行的所有程序
/proc/bus：有关该主机上现有总线的所有信息，如输入设备、PCI接口、PCMCIA扩展卡及USB接口信息
/proc/net目录：存放的都是一些网络相关的虚拟配置文件，都是ASCII文件，可以查看(与ifconfig、arp、netstat等有关)
/proc/scsi：保存系统上所有的scsi设备信息(包括sata和usb设备的信息)
/proc/sys目录：存放系统核心所使用的一些变量，根据不同性质的文件而存放在不同的子目录中，可以通过/etc/sysctl.conf文件设置和更改其默认值；变量时实时的变更，有很多设置很象是开关，设置后马上生效；
/proc/tty：存放有关目前可用的正在使用的tty设备的信息
/proc/self：存放到查看/proc的程序的进程目录的符号连接，当2个进程查看proc时，这将会是不同的连接；主要便于程序得到它自己的进程目录；
/proc/stat：系统的不同状态信息；
/proc/uptime：系统启动的时间长度；
/proc/version：系统核心版本；

*   /root
root账户的主目录

*   /sbin
包含“系统”二进制文件，它们是完成重大系统任务的程序，通常为超级用户保留

*   /tmp
用来存储由各种程序创建的临时文件；一些配置导致系统每次重新启动时，都会清空这个目录。

*   /usr
包含普通用户所需要的所有程序和文件

*   /usr/bin
包含系统安装的可执行程序，通常这个目录会包含许多程序

*   /usr/lib
包含/usr/bin目录中的程序所用的共享库

*   /usr/local
非系统发行版自带程序的安装目录

*   /usr/local/bin
包含由源码编译的程序

*   /usr/sbin
包含许多系统管理程序

*   /usr/share
包含许多由/usr/bin目录中的程序使用的共享数据；其中包括像默认的配置文件、图标、桌面背景、音频文件等。

*   /usr/share/doc
大多数安装在系统中的软件包会包含一些文档， 可以在此目录找到按照软件包分类的文档

*   /var
动态文件或数据存放目录，默认日志文件都存放在这个目录下，一般建议把此目录单独划分一个分区；
		/var/account：是linux系统下的审核机制(psacct)对应的目录；
		/var/cache：该目录下的文件时所有程序所产生的缓存数据，也就是当应用程序启动时，会将数据留一份在这个目录中；
		/var/empty：默认是sshd程序用到的这个目录，当建立ssh连接，ssh服务器必须使用该目录下的sshd子目录；
		/var/ftp：ftp服务器软件一般默认会将匿名登陆的用户的宿主目录；
		/var/gdm：gdm所使用的目录，里面存放一些系统当前所占用的console记录及通过gdm执行的X windows记录，只有通过gdm窗口的日志才会存放在此；
		/var/lib：该目录下存放很多与应用程序名称同名的子目录，每个子目录下都是应用执行的状态信息；
		/var/lock：每个服务一开始都会在这个目录下产生一个该服务的空文件，主要是避免服务启动冲突；

*   /var/log
包含日志文件、各种系统活动的记录，这些文件非常重要，应该时刻监测它们
1.  /var/log/messages — 包括整体系统信息，其中也包含系统启动期间的日志。此外，mail，cron，daemon，kern和auth等内容也记录在var/log/messages日志中。
2.  /var/log/dmesg — 包含内核缓冲信息（kernel ring buffer）。在系统启动时，会在屏幕上显示许多与硬件有关的信息。可以用dmesg查看它们。
3.  /var/log/auth.log — 包含系统授权信息，包括用户登录和使用的权限机制等。
4.  /var/log/boot.log — 包含系统启动时的日志。
5.  /var/log/daemon.log — 包含各种系统后台守护进程日志信息。
6.  /var/log/dpkg.log – 包括安装或dpkg命令清除软件包的日志。
7.  /var/log/kern.log – 包含内核产生的日志，有助于在定制内核时解决问题。
8.  /var/log/lastlog — 记录所有用户的最近信息。这不是一个ASCII文件，因此需要用lastlog命令查看内容。
9.  /var/log/maillog /var/log/mail.log — 包含来着系统运行电子邮件服务器的日志信息。例如，sendmail日志信息就全部送到这个文件中。
10.  /var/log/user.log — 记录所有等级用户信息的日志。
11.  /var/log/Xorg.x.log — 来自X的日志信息。
12.  /var/log/alternatives.log – 更新替代信息都记录在这个文件中。
13.  /var/log/btmp – 记录所有失败登录信息。使用last命令可以查看btmp文件。例如，”last -f /var/log/btmp | more“。
14.  /var/log/cups — 涉及所有打印信息的日志。
15.  /var/log/anaconda.log — 在安装Linux时，所有安装信息都储存在这个文件中。
16.  /var/log/yum.log — 包含使用yum安装的软件包信息。
17.  /var/log/cron — 每当cron进程开始一个工作时，就会将相关信息记录在这个文件中。
18.  /var/log/secure — 包含验证和授权方面信息。例如，sshd会将所有信息记录（其中包括失败登录）在这里。
19.  /var/log/wtmp或/var/log/utmp — 包含登录信息。使用wtmp可以找出谁正在登陆进入系统，谁使用命令显示这个文件或信息等。
20.  /var/log/faillog – 包含用户登录失败信息。此外，错误登录命令也会记录在本文件中。

除了上述Log文件以外， /var/log还基于系统的具体应用包含以下一些子目录：

*   /var/log/httpd/或/var/log/apache2 — 包含服务器access_log和error_log信息。
*   /var/log/lighttpd/ — 包含light HTTPD的access_log和error_log。
*   /var/log/mail/ –  这个子目录包含邮件服务器的额外日志。
*   /var/log/prelink/ — 包含.so文件被prelink修改的信息。
*   /var/log/audit/ — 包含被 Linux audit daemon储存的信息。
*   /var/log/samba/ – 包含由samba存储的信息。
*   /var/log/sa/ — 包含每日由sysstat软件包收集的sar文件。
*   /var/log/sssd/ – 用于守护进程安全服务。




