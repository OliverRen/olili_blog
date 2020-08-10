---
title: BIOS_MBR,UEFI_GPT,wim镜像
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

#### Boot的含义

启动的翻译是boot。可是，boot原来的意思是靴子，"启动"与靴子有什么关系呢？ 
原来，这里的boot是bootstrap（鞋带）的缩写，它来自一句谚语：
　　`pull oneself up by one's bootstraps`
  
字面意思是"拽着鞋带把自己拉起来"，这当然是不可能的事情。最早的时候，工程师们用它来比喻，计算机启动是一个很矛盾的过程：
==必须先运行程序，然后计算机才能启动，但是计算机不启动就无法运行程序！==

早期真的是这样，必须想尽各种办法，把一小段程序装进内存，然后计算机才能正常运行。所以，工程师们把这个过程叫做"拉鞋带"，久而久之就简称为boot了。

------------

#### 计算机的启动过程 bios->mbr

##### BIOS

上个世纪70年代初，==只读内存==（read-only memory，缩写为ROM）发明，开机程序被刷入ROM芯片，计算机通电后，第一件事就是读取它。

> 注:现代的nios都较大,所以时写在flash闪存中的.

这块芯片里的程序叫做==基本輸出輸入系統（Basic Input/Output System）==，简称为**BIOS**。

###### 硬件自检
BIOS程序首先检查，计算机硬件能否满足运行的基本条件，这叫做==硬件自检==（Power-On Self-Test），缩写为POST。
如果硬件出现问题，主板会发出不同含义的蜂鸣，启动中止。如果没有问题，屏幕就会显示出CPU、内存、硬盘等信息。

###### 启动顺序
硬件自检完成后，BIOS把控制权转交给下一阶段的启动程序。
这时，BIOS需要知道，下一阶段的启动程序"具体存放在哪一个设备。也就是说，BIOS需要有一个外部储存设备的排序，排在前面的设备就是优先转交控制权的设备。这种排序叫做==启动顺序（Boot Sequence）==。
打开BIOS的操作界面，里面有一项就是"设定启动顺序"。

##### MBR

BIOS按照"启动顺序"，把控制权转交给排在第一位的储存设备。
这时，计算机读取该设备的第一个扇区，也就是读取最前面的512个字节。如果这512个字节的最后两个字节是0x55和0xAA，表明这个设备可以用于启动；如果不是，表明设备不能用于启动，控制权于是被转交给"启动顺序"中的下一个设备。
这最前面的512个字节，就叫做==主引导记录（Master boot record，缩写为MBR）==。

> 注:所以可以引导启动的盘就意味着时写入了这512字节的mbr.

###### 主引导记录的结构
"主引导记录"只有512个字节，放不了太多东西。它的主要作用是，告诉计算机到硬盘的哪一个位置去找操作系统。
主引导记录由三个部分组成：
1. 第1-446字节：调用操作系统的机器码。
2. 第447-510字节：分区表（Partition table）。
3. 第511-512字节：主引导记录签名（0x55和0xAA）。

> 即我们恢复数据要查找的 `55AA`

其中，第二部分"分区表"的作用，是将硬盘分成若干个区。

###### 分区表
硬盘分区有很多好处。考虑到每个区可以安装不同的操作系统，"主引导记录"因此必须知道将控制权转交给哪个区。
分区表的长度只有64个字节，里面又分成四项，每项16个字节。所以，一个硬盘最多只能分四个一级分区，又叫做==主分区==。

每个主分区的16个字节，由6个部分组成：
1. 第1个字节：如果为0x80，就表示该主分区是激活分区，控制权要转交给这个分区。四个主分区里面只能有一个是激活的。
2. 第2-4个字节：主分区第一个扇区的物理位置（柱面、磁头、扇区号等等）。
3. 第5个字节：主分区类型。
4. 第6-8个字节：主分区最后一个扇区的物理位置。
5. 第9-12字节：该主分区第一个扇区的逻辑地址。
6. 第13-16字节：主分区的扇区总数。

最后的四个字节（"主分区的扇区总数"），决定了这个主分区的长度。也就是说，一个主分区的扇区总数最多不超过2的32次方。
如果每个扇区为512个字节，就意味着单个分区最大不超过2TB。再考虑到扇区的逻辑地址也是32位，所以单个硬盘可利用的空间最大也不超过2TB。如果想使用更大的硬盘，只有2个方法：一是提高每个扇区的字节数，二是增加扇区总数。

##### HARD DISK
这时，计算机的控制权就要转交给硬盘的某个分区了，这里又分成三种情况。

###### 情况A：卷引导记录
上一节提到，四个主分区里面，只有一个是激活的。计算机会读取激活分区的第一个扇区，叫做==卷引导记录（Volume boot record，缩写为VBR）==。
**卷引导记录**的主要作用是，告诉计算机，操作系统在这个分区里的位置。然后，计算机就会加载操作系统了。

###### 情况B：扩展分区和逻辑分区
随着硬盘越来越大，四个主分区已经不够了，需要更多的分区。但是，分区表只有四项，因此规定有且仅有一个区可以被定义成"扩展分区"（Extended partition）。
所谓"扩展分区"，就是指这个区里面又分成多个区。这种分区里面的分区，就叫做==逻辑分区"（logical partition）==。
计算机先读取扩展分区的第一个扇区，叫做"扩展引导记录"（Extended boot record，缩写为EBR）。它里面也包含一张64字节的分区表，但是最多只有两项（也就是两个逻辑分区）。
计算机接着读取第二个逻辑分区的第一个扇区，再从里面的分区表中找到第三个逻辑分区的位置，以此类推，直到某个逻辑分区的分区表只包含它自身为止（即只有一个分区项）。因此，扩展分区可以包含无数个逻辑分区。

> 但是，似乎很少通过这种方式启动操作系统。如果操作系统确实安装在扩展分区，一般采用下一种方式启动。

###### 情况C：启动管理器 boot loader
在这种情况下，计算机读取"主引导记录"前面446字节的机器码之后，不再把控制权转交给某一个分区，而是运行事先安装的"启动管理器"（boot loader），由用户选择启动哪一个操作系统。

> Linux环境中，目前最流行的启动管理器是Grub。



##### OS
控制权转交给操作系统后，操作系统的内核首先被载入内存。
以Linux系统为例，先载入/boot目录下面的kernel。内核加载成功后，第一个运行的程序是/sbin/init。它根据配置文件（Debian系统是/etc/initab）产生init进程。这是Linux启动后的第一个进程，pid进程编号为1，其他进程都是它的后代。
然后，init线程加载系统的各个模块，比如窗口程序和网络程序，直至执行/bin/login程序，跳出登录界面，等待用户输入用户名和密码。
至此，全部启动过程完成

##### 总结流程

```flow
st=>start: 读取ROM/Flash中的BIOS
op1=>operation: BIOS执行硬件自检
op2=>operation: BIOS读取启动顺序依次读取指定设备的MBR
cond1=>condition: 512字节末尾是否时55AA 是 or 否
op3=>operation: 启动设备MBR选择
para=>parallel: 转交分区表活动分区 or 运行boot loader
op4=>operation: 根据卷引导记录或扩展引导记录加载操作系统
op5=>operation: 根据用户选择加载操作系统
e=>end: 启动操作系统

st->op1->op2->cond1
cond1(no)->op2
cond1(yes)->op3->para
para(path1, left)->op4->e
para(path2, right)->op5->e
```

-------------------

#### 谈谈UEFI启动流程的7个阶段

##### 关于UEFI标准

UEFI(Unified Extensible Firmware Interface Forum)的简称 ，是目前从智能手机到打印机，笔记本电脑，服务器，甚至超级计算都被广泛应用的技术标准，其中它与传统BIOS的不同之处可以用3句话进行概括：

- 规范了各种接口标准
- 为不同的操作系统提供统一的接口
- 代码开源

##### UEFI启动流程

``` flow!
st=>start: 开始
op1=>operation: SEC
op2=>operation: PEI
op3=>operation: DXE
op4=>operation: BDS
op5=>operation: TSL
op6=>operation: RT
op7=>operation: AL
end=>end: 结束

st(right)->op1(right)->op2(right)->op3(right)->op4(right)->op5(right)->op6(right)->op7(right)->end
```

![](http://qiniu.imolili.com/小书匠/1593679354064.jpg)

##### SEC 安全验证

1. 接受系统的启动、重启、异常信号
2. Cache AS RAM(CAR)，在Cache上开辟一段空间作为内存使用（此时内存还没初始化，相关C语言运行需要内存和栈的空间）
3. 传递系统参数给PEI阶段

##### PEI EFI前期的初始化

此阶段主要是为DXE阶段做的相关准备工作:
1. 做CPU和相关硬件的初始化，最主要的是内存初始化
2. 将DXE阶段需要的参数以HOB列表形式进行封装，并传递给DXE阶段

##### DXE 驱动执行环境

此阶段主要是进行大量的驱动加载和初始化工作:
1. 通过对固件中所有Driver的遍历，当Driver
2. 当Driver都被执行完成了，系统即完成了初始化

##### BDS 启动设备选择

此阶段主要初始化控制台设备:
1. 加载必要的设备驱动
2. 根据用户选择执行相应启动项

##### TSL 操作系统加载前期

此阶段是OS Loader执行的第一个阶段:
1. 为OS Loader准备执行环境
2. OS Loader调用EXITBootService结束启动服务
3. 进入RT阶段（RunTime）阶段

##### RT OS环境执行时期

此阶段主要是RT随着操作系统运行提供相应服务:
1. OS已经完全获得控制权，RT会清理和回收一些之前UEFI占用资源
2. 这一阶段运行出现错误时，将进入RL修复

##### AL 灾难恢复

此阶段主要根据厂家定义的修复方案进行，UEFI未进行相关规定.

--------------------

#### UEFI的优势

UEFI是BIOS的一种升级替代方案。关于BIOS和UEFI二者的比较，网络上已经有很多相关的文章，这里不再赘述，仅从系统启动原理方面来做比较。UEFI之所以比BIOS强大，是因为UEFI本身已经相当于一个微型操作系统，其带来的便利之处在于：

首先，UEFI已具备文件系统的支持，它能够直接读取FAT分区中的文件:

> 什么是文件系统？简单说，文件系统是操作系统组织管理文件的一种方法，直白点说就是把硬盘上的数据以文件的形式呈现给用户。Fat32、NTFS都是常见的文件系统类型。

其次，可开发出直接在UEFI下运行的应用程序，这类程序文件通常以efi结尾。

既然UEFI可以直接识别FAT分区中的文件，又有可直接在其中运行的应用程序。那么完全可以将==Windows安装程序做成efi类型应用程序，然后把它放到任意fat分区中直接运行即可==，如此一来安装Windows操作系统这件过去看上去稍微有点复杂的事情突然就变非常简单了，就像在Windows下打开QQ一样简单。而事实上，也就是这么一回事。

要知道，这些都是BIOS做不到的。因为BIOS下启动操作系统之前，必须从硬盘上指定扇区读取系统启动代码（包含在主引导记录中），然后从活动分区中引导启动操作系统。对扇区的操作远比不上对分区中文件的操作更直观更简单，所以在BIOS下引导安装Windows操作系统，我们不得不使用一些工具对设备进行配置以达到启动要求。而在UEFI下，这些统统都不需要，==不再需要主引导记录，不再需要活动分区，不需要任何工具，只要复制安装文件到一个FAT32（主）分区/U盘中，然后从这个分区/U盘启动，安装Windows就是这么简单==。后面会有专门的文章来详细介绍UEFI下安装Windows7、8的方法。

-------------------

#### MBR与GPT分区方案对比

##### MBR分区结构

![](http://qiniu.imolili.com/小书匠/1593679928276.png)

为了方便计算机访问硬盘，把硬盘上的空间划分成许许多多的区块（英文叫sectors，即扇区），然后给每个区块分配一个地址，称为逻辑块地址（即LBA）。

在MBR磁盘的第一个扇区内保存着启动代码和硬盘分区表。启动代码的作用是指引计算机从活动分区引导启动操作系统（BIOS下启动操作系统的方式）；分区表的作用是记录硬盘的分区信息。在MBR中，分区表的大小是固定的，一共可容纳4个主分区信息。在MBR分区表中逻辑块地址采用32位二进制数表示，因此一共可表示2^32（2的32次方）个逻辑块地址。如果一个扇区大小为512字节，那么硬盘最大分区容量仅为2TB。

##### MBR分区规则

MBR硬盘的MBR分区表中包含了硬盘上各主分区的分区信息，每个分区信息中都有一段内容（1字节，即8位）用来表示分区类型。

==Windows下可识别的分区类型主要有：==
- 0x42 表示LDM数据分区
- 0x27 表示恢复分区（WinRE分区、Acer等系统备份分区）。
- 0x07 表示普通分区（Windows分区、数据分区。默认分区类型。）
- 0x12 表示OEM分区（康柏、IBM Thinkpad）。
- 0x84 表示OEM分区（Intel Rapid Start technology）。
- 0xDE 表示OEM分区（戴尔）。
- 0xFE 表示OEM分区
- 0xA0 表示OEM分区（Laptop hibernation partition）
- 0xEE 表示该分区表是PMBR，紧随其后的应该是GPT分区表头和GPT分区表，因此这是一块GPT硬盘。
- 0xEF 表示EFI系统分区

Windows正是根据分区表中设定的分区类型决定分区的用途（OEM或其他）和属性（是否隐藏等）。其他大多数分区类型Windows无法识别。

==Windows下更改分区类型的方法==
自Vista开始，系统自带的diskpart分区管理工具已具备更改分区类型的功能。更改分区类型，只需在具有管理员身份的CMD中依次执行以下几个命令即可（括号内为注释内容）：

- Diskpart（打开diskpart工具）
- List disk（可选。帮助查看连接到电脑的所有存储器及其编号）
- Select disk N（选择地N个硬盘，N为硬盘编号）
- List part（可选。帮助查看选定硬盘上的所有分区及其编号）
- Select part N（选定第N个分区，N代表分区编号）
- Set id = xx（设定分区类型，xx代表十六进制分区类型ID，省略0x）

举两个我们可能需要用到的例子：

###### 改变隐藏的OEM分区类型，从而能够查看OEM分区中的内容。

注意：如果还想更改回去，请在select part之后运行detail part记下分区默认的分区类型，方便事后还原。

![](http://qiniu.imolili.com/小书匠/1593680592309.png)

完成图中的操作后，如果没有自动分配盘符，可以尝试重启或在磁盘管理中手动添加“驱动器号”或紧接着图中最后一步执行以下命令添加盘符（e为盘符）。

assign letter=e

同理，如果要将某一个分区设置为OEM分区，只需将其分区类型设置为出厂默认的OEM分区类型ID或12或DE即可。

###### 我们将系统备份映像存放到单独的隐藏分区中，以保护备份映像不受到损坏。

首先，准备一个可容纳备份映像文件的空分区（主分区、逻辑分区都可以），将备份映像按下图所示的路径存放（\sources\install.wim）

然后，配置恢复映像，将分区类型设置为“恢复分区”。如下图所示。

![](http://qiniu.imolili.com/小书匠/1593680641442.png)

完成图中的步骤，用于恢复系统的系统备份分区就被隐藏掉了。如果计算机中还能够看到该分区（有盘符），紧接着图中最后一步运行下面的命令删除盘符：

remove

##### GPT分区结构

![](http://qiniu.imolili.com/小书匠/1593679958463.png)

可以看到，在GTP磁盘的第一个数据块中同样有一个与MBR（主引导记录）类似的标记，叫做PMBR。PMBR的作用是，当使用不支持GPT的分区工具时，整个硬盘将显示为一个受保护的分区，以防止分区表及硬盘数据遭到破坏。UEFI并不从PMBR中获取GPT磁盘的分区信息，它有自己的分区表，即GPT分区表。

GPT的分区方案之所以比MBR更先进，是因为在GPT分区表头中可自定义分区数量的最大值，也就是说GPT分区表的大小不是固定的。在Windows中，微软设定GPT磁盘最大分区数量为128个。另外，GPT分区方案中逻辑块地址（LBA）采用64位二进制数表示，可以计算一下2^64是一个多么庞大的数据，以我们的需求来讲完全有理由认为这个大小约等于无限。除此之外，GPT分区方案在硬盘的末端还有一个备份分区表，保证了分区信息不容易丢失。

##### GPT分区规则

**分区类型**
在GPT分区表中的分区信息中同样有一段用于表示分区类型的内容（16字节，即128位）。Windows下常见的GUID分区类型主要有：

- C12A7328-F81F-11D2-BA4B-00A0C93EC93B            EFI系统分区
- DE94BBA4-06D1-4D40-A16A-BFD50179D6AC         WinRE恢复环境分区、系统备份分区
- E3C9E316-0B5C-4DB8-817D-F92DF00215AE            微软保留（MSR）分区
- EBD0A0A2-B9E5-4433-87C0-68B6B72699C7            基本数据分区
- 5808C8AA-7E8F-42E0-85D2-E1E90434CFB3            逻辑软盘管理工具元数据分区
- AF9B60A0-1431-4F62-BC68-3311714A69AD            逻辑软盘管理工具数据分区
- 37AFFC90-EF7D-4e96-91C3-2D7AE055B174          IBM通用并行文件系统(GPFS)分区
- E75CAF8F-F680-4CEE-AFA3-B001E56EFC2D          存储空间（Storage Spaces）分区
- BFBFAFE7-A34F-448A-9A5B-6213EB736C22           Lenovo OEM分区（一键还原启动分区）
- F4019732-066E-4E12-8273-346C5641494F               Sony OEM分区（一键还原启动分区）

**分区属性**
GPT分区类型用于区别分区的用途，GPT分区表中的分区信息中除了分区类型外，还用了另一段区域（8字节，即64位）来表示分区属性，各位作用如下：

- 0x0000000000000001（0位）  将分区表示为必需分区，不允许用户更改数据（Windows下将标记为OEM分区）
- 0x8000000000000000（63位）   当硬盘被挂载到另一台电脑时默认不分配盘符。
- 0x4000000000000000（62位）  表示该分区不可被检测到。
- 0x2000000000000000（61位）  表述该分区为另一个分区的卷影拷贝。
- 0x1000000000000000（60位）  为分区设置只读属性。

关于分区属性，更详细的介绍参考 [CREATE_PARTITION_PARAMETERS structure](http://msdn.microsoft.com/en-us/library/aa381635(VS.85).aspx)

###### Windows下通常采用以下分区类型和分区属性组合：

- 普通数据分区——EBD0A0A2-B9E5-4433-87C0-68B6B72699C7——0x0000000000000000
- OEM分区——无特定GUID值，OEM决定——0x8000000000000001
- WinRE分区——DE94BBA4-06D1-4D40-A16A-BFD50179D6AC——0x8000000000000001
- EFI系统分区——C12A7328-F81F-11D2-BA4B-00A0C93EC93B——0x8000000000000001
- MSR保留分区——E3C9E316-0B5C-4DB8-817D-F92DF00215AE——0x8000000000000000
- 恢复/备份分区——DE94BBA4-06D1-4D40-A16A-BFD50179D6AC——0x8000000000000001

###### 更改GPT分区类型和分区属性的方法：

在管理员身份的CMD中（Vista以上版本系统）依次执行以下命令即可（括号内为注释内容）：

- Diskpart    （打开diskpart工具）
- List disk    （可选。帮助查看连接到电脑的所有存储器及其编号）
- Select disk N    （选择地N个硬盘，N为硬盘编号）
- List part    （可选。帮助查看选定硬盘上的所有分区及其编号）
- Select part N    （选定第N个分区，N代表分区编号）
- Set id = xx    （设定分区类型，xx代表十六进制GUID分区类型ID）
- gpt attributes = 0xXXXXXXXXXXXXXXXX    （设置分区属性，XXXXXXXXXXXXXXXX代表分区属性）

###### 改变隐藏的OEM分区类型，从而能够查看OEM分区中的内容。

![](http://qiniu.imolili.com/小书匠/1593681193818.png)

同理，如果要将某一个分区设置为OEM分区，只需将其分区类型设置为出厂默认或{EBD0A0A2-B9E5-4433-87C0-68B6B72699C7}或其他非特殊（即上文列表中之外）的GUID，再将其属性设置为0x8000000000000001（隐藏）或0x0000000000000001即可。

###### 我们将系统备份映像存放到单独的隐藏分区中，以保护备份映像不受到损坏。

![](http://qiniu.imolili.com/小书匠/1593681219435.png)

-----------

> 顺便提一下：
U盘安装系统时，bios自检和初始化没问题之后，不是要将U盘上的（U盘安装的话）的MBR里的bootloader加载到内存中运行，这个bootloader就是引导器，根据这个引导器去安装系统，在安装的过程中有个grub-install的步骤，这个时候就是将电脑硬盘上MBR指向的boot loader改成了grub,这样安装完成后会由grub作为boot loader来选择进入的操作系统.

> 使用Universal-USB-Installer和YUMI等软件制作的多合一装机U盘,本质上是做了一个UEFI的启动盘,当然也有可能是legency BIOS启动. 不过最后都是使用GRUB作为 boot loader 来引导到不同的安装镜像上的.

> 而 wim镜像是不一样的概念,是通过dism把wim的安装镜像进行处理,使用Oscdimg进行打包,最后还是需要做一个引导工具才能在系统通电后被引导的.

------------

#### 认识wim格式

wim是微软自Vista开始采用的一种全新的Windows映像格式（Windows Imaging Format）。如果你现在手里有一个微软原版ISO镜像的话，打开镜像中的sources目录你会发现有两个wim格式的文件：install.wim和boot.wim。在镜像中最重要的也就是这两个文件，看看他们的大小就知道。

其中的install.wim文件包含我们要安装的操作系统的所有文件，也就是说我们只需要install.wim这个文件，再配合相关的工具就可以完成系统的安装。那么另外一个boot.wim是干什么的呢？我们从U盘或光盘启动安装系统时会首先进入一个叫做Windows预安装环境的微型操作系统（就是WinPE，微软官方的PE），然后这个环境中启动安装程序完成系统安装。与WinPE相关的系统文件就包含在boot.wim中。

##### 使用DISM工具

早期，主要使用imagex工具来处理wim映像文件，我们需要安装Windows AIK来获取imagex。当然，我们也可以从网络上下载到imagex。到了Win8时代，最新版的Dism工具经过改进已经具备了imagex原有的功能，并且已经包含在了win8/8.1以及Win8/8.1 PE中。

当然，还有其他工具可以用来查看Wim中的文件，比如7z等。这里不作介绍。

###### 简单操作示例

下面我们通过一个例子来演示使用DISM将指定目录中的文件装进wim文件中的具体过程：

为了更好的说明问题，我们可以做一个形象的比喻。我们把一个wim文件比作一个容器，我们可以把这个容器分割成若干个格子，然后在每个格子里存放文件。现在我要做的就是：把我的电脑D:\songs文件夹中的所有文件装进wim文件中并占据一个格子，格子的名字叫做NO.1，并把最终生成的wim文件取名为songs.wim放到D:\中。具体操作为：

1. 首先我们在D:\中创建一个名为temp的文件夹，在操作过程中用这个文件夹作为缓存目录。注：这一步其实并不是必须的，只不过因为在后面的文章中我们要在恢复环境中备份系统，为了避免因默认缓存空间过小导致出现错误，所以设置了这个缓存文件夹。

2. 以管理员身份运行命令提示符，直接输入下面的命令，回车运行：
`Dism /Capture-Image /ImageFile:D:\songs.wim /ScratchDir:D:\Temp /CaptureDir:D:\songs /Name:NO.1`

![](http://qiniu.imolili.com/小书匠/1593681864280.png)

命令中各路径的含义我想就不需要介绍了吧，结合前面我们要达到的目的相信你能明白。这里的Capture-Image就表示捕获映像的意思。操作完成后在D:\中查找一下，看看是不是生成了一个名为songs.wim的文件呢？顺便再观察一下它的大小吧。

3. 现在我们再往D:\songs文件夹中任意添加几个文件，然后再把D:\songs中的所有文件放到songs.wim中的另一个格子中，对应的格子名叫做NO.2，为达到这一目的，此时我们只需要在命令提示符中输入下面的命令，回车即可
`Dism /Append-Image /ImageFile:D:\songs.wim /ScratchDir:D:\Temp /CaptureDir:D:\songs /Name:NO.2`

![](http://qiniu.imolili.com/小书匠/1593681941786.png)

请比较一下上面两条命令的不同之处，因为我们第二次捕获文件是在运行第一条命令后生成的songs.wim文件的基础上操作的，所以用了/Append-Image 命令，即在原有的基础上增加格子（映像）。另外我们使用了不同的格子名，而实际上DISM是允许不同映像同名的。我们用不同的名字是为了容易区分它们。

4. 最后我们再来查看一下songs.wim中包含的内容。操作方法：

`Dism /get-wiminfo /wimfile:D:\songs.wim`

![](http://qiniu.imolili.com/小书匠/1593682003925.png)

上图详细显示了songs.wim文件中包含的格子数量（即映像数量），可以看到第二个映像比第一个映像稍微大一点。但是我们再查看一下songs.wim文件的大小，发现和第一次刚生成时相比大小变化并不大。这是因为这两个格子中的文件大部分都是相同的，而wim中存储文件的机制可以很好的处理这些相同的文件，不让重复文件占用多余的空间。这也是为什么那些包含多个版本系统的镜像其体积并没有相应成倍增长的原因。

##### Windows多合一镜像

**多合一镜像制作原理：**
多合一镜像制作基本上所有的操作都围绕在wim文件（映像文件）的处理上。我们知道wim文件中包含了操作系统的所有文件。一个wim文件可以包含多个版本系统文件，并且能做到相同的文件只存储一次。而多合一镜像其实就是把各版本的系统文件都存储到一个wim文件而已。

###### 所需要用到的命令行工具

1. DISM 
关于DISM，之前也有过初步介绍，这是可以用来处理wim文件的工具。之前，我们用imageX工具来处理映像文件，而新版（Win8/8.1自带）DISM工具已经包含了imageX的大部分功能，与映像相关的操作我们尽量都用DISM来完成。

2. Oscding
这是用来将散装文件打包成ISO镜像文件的工具。

以上工具均可以从微软发布的ADK for win中提取，。下载后选择在线安装，只选择安装“部署工具”。安装后可以在Program Files目录中找到这些工具。比如，64位系统在如下目录：
C:\Program Files (x86)\Windows Kits\{version}\Assessment and Deployment Kit\Deployment Tools

###### 使用命令行工具需要注意的几个问题

1. 权限
系统附带的命令行工具多数需要以管理员身份运行，因此需要以管理员身份运行CMD（或PowerShell），根据权限继承原理，在其中运行的命令行工具也就都具有了管理员权限。

2. 路径
要正常使用命令行工具需要保证CMD（或PowerShell）的当前路径为命令行工具所在目录，或者命令行工具所在目录已被包含在系统的环境变量path当中。在CMD（或Powershell）中输入下面的路径可更改当前路径：

###### 命令详解

1. 查询wim中包含的各映像信息（包括索引、名称和描述）

`dism /get-imageinfo /imagefile:I:\sources\install.wim`

注：索引即编号。上面的命令即为查询I:\sources\install.wim中包含的映像信息。

2. 删除wim中某个映像

`dism /delete-image /imagefile: F:\install.wim /index:1`

注：上面的命令用于删除F:\install.wim中第1个映像。本条命令以及下面的命令都需要对install.wim进行修改，因此需要将install.wim从镜像中复制出来，不可用虚拟光驱加载。

3. 修改wim中某个映像的名称和描述

`imagex /info F:\install.wim 1 “Windows 8 企业版 [32位]” “Windows 8 Enterprise 32bit”`

注：这是修改F:\install.wim中第1个映像的名称（第一个引号内的文字）和描述内容（笫二个引号内的文字），注意使用imageX不允许同一个wim中各映像有重名。

4. 将一个wim中的某个映像复制到另一个wim中

`Dism /export-image /sourceimagefile:I:\sources\install.wim /sourceindex:1 /destinationimagefile:F:\install.wim /destinationname:”Windows 8 企业版 [64位]”`

注：这是将I:\sources\install.wim中的第1个映像复制到F:\install.wim中，即在F:\install.wim中已有映像的基础上再加一个映像，并且将新添加的映像命名为Windows 8 企业版 [64位]。新添加的映像编号最大，即排在最后。F:\install.wim文件可以为空（即不存在），为空时系统会自动创建新的映像文件，映像编号从1开始，此时可以加上/Compress: maximum参数已达到最大压缩效果。可以去掉 /destinationname: ” Windows 8 企业版 [64位] “，即复制映像时保持原映像名称。

5. 将wim中的某个映像升级到更高版本

> 只有零售版镜像（通常都是多版本镜像）中的映像可以升级到高版本，批量授权版（通常都是包含一个版本，比如企业版和大客户专业版镜像）不可以升级。升级映像前需要先装载映像，升级后再提交更改并卸载映像。详细步骤：

- 装载映像

`dism /mount-image /imagefile:F:\install.wim /index:1 /MountDir:E:\Win8`

注：上面的命令用于将E:\install.wim中的第一个映像装载到E:\Win8目录中，需事先创建E:\Win8文件夹。

- 查询可升级版本（即查询装载的映像可升级到哪个版本）

`dism /image:E:\Win8 /get-targeteditions`

- 升级到高版本

`dism /image:E:\Win8 /set-edition:ProfessionalWMC`

注：以上命令将装载到E:\Win8的映像升级到ProfessionalWMC（即媒体中心）版。

- 提交更改并卸载已装载映像

`dism /unmount-wim /mountdir:E:\Win8 /commit`

6. 打包ISO

将制作好的install.wim替换原版镜像中的install.wim即可，这里要注意几点：

- 如果整合映像同时包含32位和64位版本，请选择32位零售版镜像作为母本来打包。因为只有32 位 Windows 安装程序支持跨平台部署（微软官方说明，没有去验证。之前制作8.1多合一时也忽略了这一点）。

- 跳过密钥输入步骤实现安装时自选版本。对于win7，删除sources中的ei.cfg即可；对于Win8/8.1需添加ei.cfg。

- 目前UEFI均为64位，因此只有64位系统支持UEFI引导，要使制作好的镜像支持UEFI引导务必采用64位零售版镜像作为母本打包。要光盘UEFI引导打包时要加上UEFI参数，命令在下面会有说明。

- 用U盘实现UEFI引导，文件系统必须为FAT32，而FAT32单文件大小限制在4G内，如果install.wim超过了4G，此时必须进行映像拆分。命令如下：

`Dism /Split-Image /ImageFile: F:\install.wim /SWMFile:D:\image\install.swm /FileSize:4096`

上面的命令用于将F:\install.wim文件进行拆分，拆分后的文件最大为4G，并且将拆分后的文件存放到了D:\image中，拆分后的第一个文件名为install.swm、第二个为install2.swm，以此类推。打包时将拆分后的所有文件替换原版镜像中的install.wim即可。

- 映像文件超过4.5G时需要指定启动顺序文件，以确保启动文件都位于映像的开头。可参考《Oscdimg 命令行选项》。

- 不建议将不同版本号（例如Win8.1 9月份版和10月份版）整合到一起，因为整合后的文件会比较大。也不建议将不同代的系统整合到一起（比如win7+Win8），在安装时可能会出现问题。

打包命令：制作仅包含传统引导方式（BIOS）的ISO镜像：

`Oscdimg -betfsboot.com -m -u2 -h -udfver102 -lHRM_CCSA_X64FRE_ZH-CN_DV5 -t8/22/2013,22:22:22 E:\isox64 E:\MyISO.iso`

命令解释：

-b：指定要写入的启动扇区文件（这里是BIOS启动方式）
-m：忽略映像的最大大小限制
-u2：生成仅包含 UFD 文件系统的映像
-udfver102：指定了 UDF 文件系统版本 1.02
-l：指定卷标（就是加载镜像后在资源管理器中显示的名称）
-t：为所有文件和目录指定时间戳，资源管理器中文件修改日期统一显示为指定的时间。
E:\isox64 表示要打包的文件所在目录
E:\MyISO.iso 表示最终生成的文件。

制作包含传统引导方式（BIOS）以及UEFI引导的镜像：

`Oscdimg -bootdata:2#p0,e,bEtfsboot.com#pEF,e,bEfisys.bin -m -u2 -h -udfver102 -lHRM_CCSA_X64FRE_ZH-CN_DV5 -t8/22/2013,22:22:22 E:\isox64 E:\MyISO.iso`

这里的-bootdata:2就表示含两种引导方式。