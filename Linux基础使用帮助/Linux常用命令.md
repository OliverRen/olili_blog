---
title: Linux常用命令
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

- CTRL+ALT+F(x) 切换命令行终端和Xwindow
在命令行输入startx可以直接开启Xwindow

- 开机自动启动脚本文件 /etc/rc.local

- 环境变量文件 /etc/profile , 修改完成后需要 source /etc/profile .

- 文件权限位,默认是10位
第一位是文件类型 \[- 文件] \[d 目录] \[l 软链接文件]
后面的9位每3位分别代表 \[所有者=u] \[所属组=g] \[其他人=o]
r=读=1 w=写=2 x=执行=4



- 查看磁盘空间
df -h

- 当前目录
du -sh

- file 查看文件类型

- cat 查看文件内容
- tac 倒序查看文件内容

- sort 排序内容

- od 查看二进制文件

分段逐步读取
- more 不能向上,看完会输出在屏幕
- less 可以上下,看完Q退出不会显示在屏幕
读取头几行
- head -n #
读取最后几行
- tail -n #
持续观察一个文件的结果

- cut 切割命令
cut -d ":" -f 1,7 /etc/passwd

-find
-whichis 
-which 
-locate
-updatedb 

- top命令

top命令分为两个部分,上面显示关于系统整体性能,下面显示各个进程信息

系统整体性能区中
第一行显示任务队列信息,同 uptime 命令

| 内容 | 含义 |
| --- | --- |
| 11:09:36 | 当前时间 |
| up 349 days | 系统运行时间，格式为时:分 |
| 12 users | 当前登录用户数 |
| load average : 0.07, 0.11, 0.21 | 系统负载，即任务队列的平均长度。三个数值分别为 1分钟、5分钟、15分钟前到现在的平均值。load avarage 小于 3 系统良好，大于5 则有严重的性能问题。注意，这个值还应当除以CPU数目。 |

第二行为进程信息

| 内容 | 含义 |
| --- | --- |
| 166 total | 进程总数 |
| 1 running | 正在运行的进程数 |
| 165 sleeping | 睡眠的进程数 |
| 0 stopped | 停止的进程数 |
| 0 zombie | 僵尸进程数 |

第三行为CPU信息,多个CPU多行

| 内容 | 含义 |
| --- | --- |
| 1.2%us | 用户空间占用CPU百分比 |
| 0.4%sy | 内核空间占用CPU百分比 |
| 0.0%ni | 用户进程空间内改变过优先级的进程占用CPU百分比 |
| 97.9%id | 空闲CPU百分比 |
| 0.2%wa | 等待I/O的CPU时间百分比 |
| 0.0%hi | CPU硬中断时间百分比 |
| 0.3%si | CPU软中断时间百分比 |
| 0.0%st | .  |

第四行为内存信息

| 内容 | 含义 |
| --- | --- |
| 32947976k total | 物理内存总量 |
| 32649576k used | 使用的物理内存总量 |
| 298400k free | 空闲内存总量 |
| 483656k buffers | 用作内核缓存的内存量 |

第五行为交换区信息

| 内容 | 含义 |
| --- | --- |
| 2104504k total | 交换区总量 |
| 1349936k used | 使用的交换区总量 |
| 754568k free | 空闲交换区总量 |
| 24875996k cached | 缓冲的交换区总量 |

进程信息区中

| 列名 | 含义 |
| --- | --- |
| PID | 进程id |
| PPID | 父进程id |
| RUSER | Real user name |
| UID | 进程所有者的用户id |
| USER | 进程所有者的用户名 |
| GROUP | 进程所有者的组名 |
| TTY | 启动进程的终端名。不是从终端启动的进程则显示为 ? |
| PR | 优先级 |
| NI | nice值。负值表示高优先级，正值表示低优先级 |
| P | 最后使用的CPU，仅在多CPU环境下有意义 |
| %CPU | 上次更新到现在的CPU时间占用百分比 |
| TIME | 进程使用的CPU时间总计，单位秒 |
| TIME+ | 进程使用的CPU时间总计，单位1/100秒 |
| %MEM | 进程使用的物理内存百分比 |
| VIRT | 进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES |
| SWAP | 程使用的虚拟内存中，被换出的大小，单位kb。 |
| RES | 进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA |
| CODE | 可执行代码占用的物理内存大小，单位kb |
| DATA | 可执行代码以外的部分(数据段+栈)占用的物理内存大小，单位kb |
| SHR | 共享内存大小，单位kb |
| nFLT | 页面错误次数 |
| nDRT | 最后一次写入到现在，被修改过的页面数。 |
| S | 进程状态：D=不可中断的睡眠状态R=运行S=睡眠T=跟踪/停止Z=僵尸进程 |
| COMMAND | 命令名/命令行 |
| WCHAN | 若该进程在睡眠，则显示睡眠中的系统函数名 |
| Flags | 任务标志，参考 sched.h |

- PS 进程管理命令
ps -ef / ps aux

| 列名 | 含义 | 
| --- | --- |
| USER | 用户名 |
| PID |  进程ID（Process ID）|
| PPID | 父进程的进程ID（Parent Process id）  |
| %CPU | 进程的cpu占用率  |
| %MEM | 进程的内存占用率  |
| VSZ |  进程所使用的虚存的大小（Virtual Size）  |
| RSS | 进程使用的驻留集大小或者是实际内存的大小，Kbytes字节 |
| TTY | 与进程关联的终端（tty）|
| STAT | 进程的状态 |
| START | 进程启动时间和日期  |
| TIME | 进程使用的总cpu时间  | 
| COMMAND | 正在执行的命令行命令 |

STAT状态位常见的异常字符

| 列名 | 含义 | 
| --- | --- |
| D |（Uninterruptible sleep）无法中断的休眠状态（通常 IO 的进程 |
| R |（Runnable）正在运行或在运行队列中等待  |
| S |（Sleeping）休眠中, 受阻, 在等待某个条件的形成或接受到信号  |
| T |（Terminate）停止或被追踪；|
| W | 进入内存交换  （从内核2.6开始无效）|
| X | 死掉的进程   （基本很少見）|
| Z |（Zombie）僵尸进程；  |
| < | 优先级高的进程  |
| N | 优先级较低的进程  |
| L | 有些页被锁进内存；  |
| s | 进程的领导者（在它之下有子进程|
| l | 多进程的（使用 CLONE_THREAD, 类似 NPTL pthreads |
| + | 位于后台的进程组；|

- vmstat 虚拟内存统计
vmstat是Virtual Meomory Statistics（虚拟内存统计）的缩写，可对操作系统的虚拟内存、进程、CPU活动进行监控。他是对系统的整体情况进行统计，不足之处是无法对某个进程进行深入分析。
通常使用vmstat interval count（表示在5秒时间内进行5次采样）命令测试。将得到一个数据汇总他能够反映真正的系统情况。
注意：报告的第一行值显示的是从系统启动以来的平均值（无用）。第二行之后才显示的是当前值。
列数据说明:
1.procs:
r：在运行队列中等待的进程数，【这个值也可以判断是否需要增加CPU(长期大于1)】
b：在等待io的进程数 。
2.memory: linux内存监控内存
swpd：现时可用的交换内存（单位KB）。【如果 swpd 的值不为0，或者还比较大，比如超过100M了，但是 si, so 的值长期为 0，这种情况我们可以不用担心，不会影响系统性能。 】
free：空闲的内存（单位KB）。
buff: 作为buffer cache的内存，对块设备的读写进行缓冲（单位：KB）。
cache：作为page cache的内存, 文件系统的cache（单位：KB）。【如果 cache 的值大的时候，说明cache住的文件数多，如果频繁访问到的文件都能被cache住，那么磁盘的读IO bi 会非常小。】
3.swap : linux内存监控swap交换页面
si: 从磁盘交换到内存的交换页数量，单位：KB/秒。【内存够用的时候，这2个值都是0，如果这2个值长期大于0时，系统性能会受到影响。磁盘IO和CPU资源都会被消耗。】
so: 从内存交换到磁盘的交换页数量，单位：KB/秒。【常有人看到空闲内存(free)很少或接近于0时，就认为内存不够用了，实际上不能光看这一点的，还要结合si,so，如果free很少，但是si,so也很少(大多时候是0)，那么不用担心，系统性能这时不会受到影响的。】
4.io: linux 内存监控 io块设备
bi: 发送到块设备的块数，单位：KB/秒。【随机磁盘读写的时候，这2个 值越大（如超出1M），能看到CPU在IO等待的值也会越大】
bo: 从块设备接收到的块数，单位：KB/秒。
5.system: linux 内存监控 system 系统
in: 每秒的中断数，包括时钟中断。【上面这2个值越大，会看到由内核消耗的CPU时间会越多】
cs: 每秒的环境（上下文）转换次数。
6.cpu: 内存监控 cpu
cs： 。以百分比表示。
us：用户进程消耗的CPU时间百分比【us 的值比较高时，说明用户进程消耗的CPU时间多，但是如果长期超过50% 的使用，那么我们就该考虑优化程序算法或者进行加速了】
sy：系统内核消耗的CPU时间百分比【sy 的值高时，说明系统内核消耗的CPU资源多，这并不是良性的表现，我们应该检查原因。】
wa: IO等待消耗的CPU时间百分比【wa 的值高时，说明IO等待比较严重，这可能是由于磁盘大量作随机访问造成，也有可能是磁盘的带宽出现瓶颈(块操作)。】
id：中央处理器的空闲时间 。以百分比表示。

> 因此，一个最简单的判断Linux下内存是否足够的办法是，只要基本没用到swap，这台机器的内存就是足够的。

- free 查看内存使用情况
即直接读取 /proc/meminfo 文件
对应用程序来讲是buffers/cached 是等于可用的，因为buffer/cached是为了提高文件读取的性能，当应用程序需在用到内存的时候，buffer/cached会很快地被回收。所以从应用程序的角度来说，可用内存=系统free memory+buffers+cached

- iostat  磁盘io监控

iostat 命令用来显示存储子系统的详细信息,通常用它来监控磁盘IO的情况,需要特别注意iostat统计结果中的 %iowait 值,这表示 IO 性能的等待系统增大

iostat -x 1 10
返回结果说明

| 列名 | 说明 |
| --- | --- |
| Blk_read/s | 每秒块(扇区)读取的数量 | 
| Blk_wrtn/s | 每秒块(扇区)写入的数量 |
| Blk_read | 总共块(扇区)读取的数量 |
| Blk_wrtn | 总共块(扇区)写入的数量 |
| rrqm/s | 队列中每秒钟合并的读请求数量 |
| wrqm/s | 队列中每秒钟合并的写请求数量 |
| r/s | 每秒钟完成的读请求数量 |
| w/s | 每秒钟完成的写请求数量 |
| rsec/s | 每秒钟读取的扇区数量 |
| wsec/s | 每秒钟写入的扇区数量 |
| avgrq-sz | 平均请求扇区的大小 |
| avgqu-sz | 平均请求队列长度 |
| await | 平均每次请求的等待时间 |
| util | 设备的利用率 |

应用 : 查看linux服务器硬盘IO负载
top命令查看 CPU wa :IO等待所占用的CPU时间的百分比,高于30%时判定IO压力很高
yum install sysstat.使用 iostat -x 1 10查看%util所占用的百分比,接近100%说明产生的IO请求过多
vmstat -1 查看等待资源的进程数
IO负荷压力测试,在当前目录创建一个2G的文件 time dd if=/dev/zero bs=1M count=2048 of=direct_2G
监控脚本 monitor_io_stats.sh
``` shell
#!/bin/sh
/etc/init.d/syslog stop
echo 1 > /proc/sys/vm/block_dump
sleep 60

dmesg | awk '/(READ|WRITE|dirtied)/ {process[$1]++} END {for (x in process) \
print process[x],x}' |sort -nr |awk '{print $2 " " $1}' | \
head -n 10

echo 0 > /proc/sys/vm/block_dump
/etc/init.d/syslog start
```

- lsof : 列出某个应用程序打开的文件信息
注：root用户运行lsof命令

1、不带任何参数运行lsof会列出所有进程打开的所有文件。（lsof -h 查看参数）  
  
2、列出哪些进程使用某些文件  
`lsof /usr/xxx/1.log`
  
3、 递归查找某个目录中所有打开的文件   
lsof +D /usr/xxx/logs
等价于： lsof | grep '/usr/xxx/logs'    
  
4、查找某个程序打开的所有文件  
lsof -c httpd; 可逗号分隔多个进程名称，如lsof -c httpd,smbd    
  
5、 列出某个用户打开的所有文件    
lsof -u root 列出根用户使用的文件    
lsof -u root -c httpd 列出根用户运行的或者apache进程使用的所有文件       
lsof -a -u root -c httpd 列出根用户运行的且apache进程使用的文件    
  
6、 列出所有由某个PID对应的进程打开的文件      
lsof -p PID    
  
7、列出系统中开放端口及运行在端口上的服务的详细信息  
lsof -i 列出所有打开了网络套接字（TCP和UDP）的进程    
lsof -i tcp 列出所有TCP网络连接    
lsof -i :port 使用某个端口的进程    
  
8、列出所有与某个描述符关联的文件  
lsof -d 2 列出所有以描述符2打开的文件    
lsof -d 0-2 列出所有描述符为0，1，2的文件    
lsof -d mem 列出所有内存映射文件    
lsof -d txt 列出所有加载在内存中并正在执行的进程   
   
9、分析lsof -i 命令运行输出结果  
  lsof 的每一项输出都对应着一个打开了特定端口的服务，输出的最后一列，如：tcp ip:port1->ip2:port (ESTABLISHED) ip1:port 对应本地机器和开放的端口，ip2:port 对应远程机器和开放的端口；  
  若要列出本机当前开放的端口，可使用：  
lsof -i | grep ":[0-9]\+->" -o | grep "[0-9]\+" -o | sort | uniq     
     
使用 lsof 恢复意外删除的文件
只要此时系统中还有进程正在访问该文件,我们可以通过lsof命令从 /proc 目录下恢复该文件的内容
例如 由于误操作将 /var/log/messages 文件删除掉了
lsof /var/log/messages
根据进程号PID下的文件描述符查看对应的文件
/proc/{PID}/fd/{文件描述符}
通过IO重定向恢复文件
cat /proc/{PID}/fd/{文件描述符} > /var/log/messages

- netstat 查看网络连接和端口的工具
==默认不显示LISTEN相关==
==-a (all)显示所有选项==
-t (tcp)仅显示tcp相关选项
-u (udp)仅显示udp相关选项
==-n 拒绝显示别名，能显示数字的全部转化成数字。==
-l 仅列出有在 Listen (监听) 的服務状态
==-p 显示建立相关链接的程序名==
-r 显示路由信息，路由表
-e 显示扩展信息，例如uid等
-s 按各个协议进行统计
-c 每隔一个固定时间，执行该netstat命令。
提示：LISTEN和LISTENING的状态只有用-a或者-l才能看到

-- tcpdump 网络抓包(转储)分析工具
1）监听指定网卡（-i $interface）  
tcpdump -i eth1  
注：如果没有权限，则加上sudo  
sudo tcpdump -i eth1  
   
2）监听指定端口（加port xxx）  
sudo tcpdump -i eth1 port 12345  
   
3）监听指定端口的TCP请求（加tcp）  
sudo tcpdump -i eth1 tcp port 12345  
还可以监听其他协议，如ip,ip6,arp,tcp,udp等  
  
4）监听指定IP（加host xxx.xxx.xx.xxx）  
sudo tcpdump -i eth1 host 10.10.10.106  
可以指定是源地址和目的地址src/dst  
sudo tcpdump -i eth1 src host 10.10.10.106  
sudo tcpdump -i eth1 dst host 10.10.10.106  
如果要同时监听IP和端口，则要用and关键字  
sudo tcpdump -i eth1 host 10.10.10.106 and port 80  
  
5）展示详细信息（加-v -vv -vvv）  
sudo tcpdump -i eth1 -v tcp port 12345  
   
6）将请求信息保存到文件（加-w filename）  
sudo tcpdump -w 20131218.pcap -i eth1 -v tcp port 12345  
  
7）捉包时打印包数据到屏幕上（加-X）  
sudo tcpdump -X -i eth1 -v tcp port 12345  
  
8）指定捉包数据的长度（加-s $num）  
sudo tcpdump -X -s 1024 -i eth1 -v tcp port 12345  
（如果不指定，则会捉默认的96字节，太小了）  
将长度加大后，可以展示更详细的数据  
  
9）以ASCII方式显示数据包（加-A）方便查看数据  
sudo tcpdump -A -X -s 1024 -i eth1 -v tcp port 80  
（不过大部分服务器都gzip了，不一定能捉到明文数据）  
  
10）捉取指定数量的包（加-c $num）  
sudo tcpdump -A -X -s 1024 -i eth1 -v tcp -c 10 port 80  

- route
添加到主机的路由
route add –host 192.168.1.11 dev eth0
route add –host 192.168.1.12 gw 192.168.1.1

添加到网络的路由
route add –net 192.168.1.11 netmask 255.255.255.0 dev eth0
route add –net 192.168.1.11 netmask 255.255.255.0 gw 192.168.1.1
route add –net 192.168.1.0/24 dev eth1

添加默认网关
route add default gw 192.168.2.1

删除路由
route del –host 192.168.1.11 dev eth0