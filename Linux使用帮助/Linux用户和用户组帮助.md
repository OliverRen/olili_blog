---
title: Linux用户和用户组帮助
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

每个用户拥有一个UserId,操作系统实际使用的是用户ID，而非用户名
每个用户属于一个主组，属于没有,一个或者多个附属组
每个组拥有一个GroupId
每个进程以一个用户身份运行，并受该用户可访问的资源限制
每个可登陆用户拥有一个指定的shell，系统用户最大的特点就是没有shell,是不能登录的

用户的Id位32位，从0开始，但为兼容老式系统，限制在60000以下。
用户Id的分为以下3种
root用户 id=0
系统用户 1-499
普通用户 500+

-----------------
**用户,用户组的相关命令**

1.  使用 `useradd` 创建用户
	- 在 `/etc/passwd` 中添加用户信息
	- 如果使用 `passwd` 命令添加密码,则密码将加密后保存在 `/etc/shadow`
	- 为新建的用户创建 home 目录,使用 `-d` 参数可以指定 home 目录
	- 将 `/etc/skel` 中的文件复制到 home 目录
	- 创建一个与用户相同名称的用户组,新建用户将会属于这个组,使用 `-g` 参数指定主组,使用 `-G`参数指定附属组,最多31个使用`,`分隔
	- 使用 `-s` 参数指定新建用户的登录shell
	- 使用 `-u` 参数指定新建用户的userId	  

2.  使用 `usermod` 修改用户
	- `-l` 新的登录名称
	- `-u` 新的用户id
	- `-d` 新的home目录
	- `-g`,`-G` 主组和附属组
	- `-L` 锁定用户登录; `-U` 解锁可以登录;

3.  使用 `userdel` 删除用户
	- `-r` 同时删除home目录和邮件池

4.  创建一个组 `groupadd name`

5.  修改组 `groupmod name`

6.  删除组 `groupdel name`

7.  修改文件权限 `chmod`

8.  修改文件归属 `chown -R username:usergroup folder`

---------------

**详细解说 `/etc/passwd`**

在/etc/passwd 中，每一行都表示的是一个用户的信息；一行有7个段位；每个段位用:号分割，比如下面是我的系统中的/etc/passwd 的两行：
``` passwd
beinan:x:500:500:beinan sun:/home/beinan:/bin/bash
linuxsir:x:501:502::/home/linuxsir:/bin/bash
```

- 第一字段：用户名（也被称为登录名）；在上面的例子中，我们看到这两个用户的用户名分别是 beinan 和linuxsir；
- 第二字段：口令；在例子中我们看到的是一个x，其实密码已被加密保存到/etc/shadow 文件中；
- 第三字段：用户id
- 第四字段：用户组id
- 第五字段：用户名全称，这是可选的，可以不设置，在beinan这个用户中，用户的全称是beinan sun ；而linuxsir 这个用户是没有设置全称；
- 第六字段：用户的家目录所在位置；beinan 这个用户是/home/beinan ，而linuxsir 这个用户是/home/linuxsir ；
- 第七字段：用户所用SHELL 的类型，beinan和linuxsir 都用的是 bash ；所以设置为/bin/bash ；

---------------

**详细解说 `/etc/shadow`**

/etc/shadow 文件的内容包括9个段位，每个段位之间用:号分割；我们以如下的例子说明；
``` shadow
beinan:$1$VE.Mq2Xf$2c9Qi7EQ9JP8GKF8gH7PB1:13072:0:99999:7:::
linuxsir:$1$IPDvUhXP$8R6J/VtPXvLyXxhLWPrnt/:13072:0:99999:7::13108:
```

- 第一字段：用户名（也被称之为登录名），在例子中有峡谷两条记录，也表示有两个用户beinan和linuxsir
- 第二字段：被加密的密码，如果有的用户在此字段中是x，表示这个用户不能登录系统，也可以看作是虚拟用户，不过虚拟用户和真实用户都是相对的，系统管理员随时可以对任何用户操作；
- 第三字段：表示上次更改口令的天数（距1970年01月01日），上面的例子能说明beinan和linuxsir这两个用户，是在同一天更改了用户密码，当然是通过passwd 命令来更改的，更改密码的时间距1970年01月01日的天数为13072；
- 第四字段：禁用两次口令修改之间最小天数的功能，设置为0
- 第五字段：两次修改口令间隔最多的天数，在例子中都是99999天；这个值如果在添加用户时没有指定的话，是通过/etc/login.defs来获取默认值，PASS_MAX_DAYS 99999；您可以查看/etc/login.defs来查看，具体的值；
- 第六字段：提前多少天警告用户口令将过期；当用户登录系统后，系统登录程序提醒用户口令将要作废；如果是系统默认值，是在添加用户时由/etc/login.defs文件定义中获取，在PASS_WARN_AGE 中定义；在例子中的值是7 ，表示在用户口令将过期的前7天警告用户更改期口令；
第七字段：在口令过期之后多少天禁用此用户；此字段表示用户口令作废多少天后，系统会禁用此用户，也就是说系统会不能再让此用户登录，也不会提示用户过期，是完全禁用；在例子中，此字段两个用户的都是空的，表示禁用这个功能；
- 第八字段：用户过期日期；此字段指定了用户作废的天数（从1970年的1月1日开始的天数），如果这个字段的值为空，帐号永久可用；在例子中，我们看到beinan这个用户在此字段是空的，表示此用户永久可用；而linuxsir这个用户表示在距1970年01月01日后13108天后过期，算
起来也就是2005年11月21号过期；哈哈，如果有兴趣的的弟兄，自己来算算，大体还是差不多的;)；
- 第九字段：保留字段，目前为空，以备将来Linux发展之用；

---------------

**详细解说 `/etc/group`**

在/etc/group 中的每条记录分四个字段：
`group_name:passwd:GID:user_list`
　　
- 第一字段：用户组名称；
- 第二字段：用户组密码；
- 第三字段：groupId
- 第四字段：用户列表，每个用户之间用,号分割；本字段可以为空；如果字段为空表示用户组为GID的用户名；

-------------------
  
**详细解说 `/etc/gshadow`**  
    
 /etc/gshadow是/etc/group的加密资讯文件，比如用户组（Group）管理密码就是存放在这个文件。
 /etc/gshadow和/etc/group是互补的两个文件；
 对于大型服务器，针对很多用户和组，定制一些关系结构比较复杂的权限模型，设置用户组密码是极有必要的。
 比如我们不想让一些非用户组成员永久拥有用户组的权限和特性，这时我们可以通过密码验证的方式来让某些用户临时拥有一些用户组特性，这时就要用到用户组密码；
 
/etc/gshadow 格式如下，每个用户组独占一行;
`groupname:password:admin,admin,…:member,member,...`

- 第一字段：用户组
- 第二字段：用户组密码，这个段可以是空的或!，如果是空的或有!，表示没有密码；
- 第三字段：用户组管理者，这个字段也可为空，如果有多个用户组管理者，用,号分割；
- 第四字段：组成员，如果有多个成员，用,号分割；


