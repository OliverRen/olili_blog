---
title: 矿机ubuntu初始化
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

#### 系统安装 和 初始化

分区
- efi分区 with boot
- swap 需要大容量swap
- /

系统目前都是最小化安装 ubuntu 20.04 Desktop,将系统语言改为英语
	
sudo passwd root
修改root密码

修改apt源为阿里云

`apt install openssh-server`
安装openssh-server
`apt install openssh-client=1:8.4p4`
如果出现 openssh-client版本依赖问题,先安装对应版本覆盖
安装完后就可以离开服务器了

无用软件清理 装desktop弊病
`apt remove thunderbird totem rhythmbox empathy brasero simple-scan gnome-mahjongg aisleriot gnome-mines cheese transmission-common gnome-sudoku`
删除
thunderbird		邮件客户端
totem			视频播放器
rhythmbox		音频播放器
empathy			即时通讯
brasero			刻录软件
simple-scan		扫描仪
gnome-mahjongg aisleriot gnome-mines cheese gnome-sudoku	游戏
transmission-common	下载软件
gnome-orca		屏幕阅读

安装基本工具
`apt install vim gparted sysstat net-tools nvtop htop screen`

修改打开文件进程数
```
cat >> /etc/security/limits.conf << EOF
*		soft		nofile	655350
*		hard		nofile	655350
*		soft		nproc	655350
*		hard		nproc	655350
root		soft		nofile	655350
root		hard		nofile	655350
root		soft		nproc	655350
root		hard		nproc	655350
EOF
```

bash优化
`vim ~/.bashrc`
把 `alias ll='ls -alFh'`

vim编辑器优化
ubuntu也可以修改 /etc/vim/vimrc 全局的
```
cat >> ~/.vimrc << EOF
set fenc=utf-8
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936
set nocp
set number
set ai
set si
set tabstop=4
set sw=4
set ruler
set incsearch
set showmatch
set ignorecase
set pastetoggle=<F9>
map <F12> gg=G
autocmd InsertLeave * se nocul  "
autocmd InsertEnter * se cul    "
:inoremap ( ()<ESC>i
:inoremap ) <c-r>=ClosePair(')')<CR>
:inoremap [ []<ESC>i
:inoremap ] <c-r>=ClosePair(']')<CR>
:inoremap " ""<ESC>i
:inoremap ' ''<ESC>i
function! ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endfunction
filetype plugin indent on
set completeopt=longest,menu
syntax on
EOF
```

优化内核参数 视机器仅需要执行部分
```
sysctl_config(){

cp /etc/sysctl.conf /etc/sysctl.conf.bak
cat > /etc/sysctl.conf << EOF
#CTCDN系统优化参数
#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
#关闭路由转发
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
#关闭sysrq功能
kernel.sysrq = 0
#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144
#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800
#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1
#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1
#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 30
#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000
#修改防火墙表大小，默认65536
net.netfilter.nf_conntrack_max=655350
net.netfilter.nf_conntrack_tcp_timeout_established=1200
# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
EOF
        
/sbin/sysctl -p
echo "sysctl set OK!!"
}
```