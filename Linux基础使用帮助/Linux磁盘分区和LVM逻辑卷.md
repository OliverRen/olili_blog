---
title: Linux磁盘分区和LVM逻辑卷
---

[toc]

常见的硬盘可以划分为主分区,扩展分区和逻辑分区,其中扩展分区可以视作一个特殊的主分区类型,在扩展分区可以创建逻辑分区.用常用的SCSI硬盘来说,在Linux系统中我们看到的是 /dev/ 目录下的 sda,sdb,sdc...的设备.在一块硬盘上(sda)上进行分区,那么第一个主分区就是 sda1,第二个主分区就是 sda2, 以此类推.

在Linux中,新磁盘也是需要分区,格式化,挂载等若干个步骤才能使用的,挂载硬盘分区必须指定一个目录作为挂载点.一个设备分区的文件可以挂载到多个目录下,如果你需要停用卸载,尽可能卸载挂载点,而不是直接卸载设备分区文件.

由于初始的分区对不同的挂载点分配的磁盘空间不合理或后期使用发现不够了,要么删除转移数据,要么就只能重装,所以在一开始配置的时候我们可以使用LVM逻辑卷,后期使用动态调整逻辑卷就可以轻松的进行空间管理了.

#### LVM机制的基本概念

通过LVM技术整合所有的磁盘资源进行分区，然后创建PV物理卷形成一个资源池，再划分卷组，最后在卷组上创建不同的逻辑卷，继而初始化逻辑卷，挂载到系统中使用。

LVM对比传统硬盘存储的优点:

1. 统一管理：整合多个磁盘或分区形成一个资源池
2. 灵活性：可以使用不同磁盘、不同分区来组成一个逻辑卷
3. 可伸缩性：逻辑卷和卷组的容量都可以使用命令来扩展或者缩减，且不会影响破坏原有数据
4. 支持热插拔
5. 支持在线数据移动
6. 设备命名方便
7. 镜像卷：可以很方便的做数据镜像
8. 卷快照：把逻辑卷中的数据快照保存到新的逻辑卷进行备份

- PV Physical Volume 物理卷,整个磁盘,或使用fdisk等工具创建分磁盘分区
- VG Volume Group 卷组,一个或多个物理卷组合而成的整体
- Logical Volume 逻辑卷,从卷组中分割出来的一块空间,可以用来创建文件系统

![LVM](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Linux磁盘分区和LVM逻辑卷/2020109/1602213675290.png)

![LVM管理命令](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Linux磁盘分区和LVM逻辑卷/2020109/1602211449334.png)

#### 创建LVM步骤

如果没有以下用到的命令,也许你需要 `sudo apt install lvm2`,以下命令都需要 sudo 权限.

- 查看磁盘分区, 输入 `fdisk -l`

- 对磁盘进行分区 
	
	输入 `fdisk /dev/sdb` ,直到你输入w写入分区表之前信息都是在内存中的.主要的命令可以通过输入m来获取帮助.常用的有p查看分区信息,n新建分区,d删除分区,t转换设备格式
	
	- 输入n进入分区
	- 创建主分区输入p
	- 分区号从1开始
	- 输入起始分区扇区和结束分区扇区
	- 如果要做成LVM逻辑卷需要进行设备格式id的转换,输入t
	- 格式转换通过id来指定,可以通过帮助查看所有可用的设备id	 
	
	我们假定还有一块硬盘来做试验,通过 `fdisk /dev/sdc` 重复以上步骤.	  
	  
- 将磁盘分区做成物理卷,输入`pvcreate /dev/sdb1 /dev/sdc1` 创建两块硬盘的分区为物理卷.
- 合并物理卷为卷组,输入 `vgcreate vg1 /dev/sdb1 /dev/sdc1` 即将物理卷 sdb1和 sdc1组合成卷组 vg1
- 从卷组中分配容量创建逻辑卷,输入 `lvcreate -L 10G -n lv1 vg1`,即从卷组 vg1 中分配10G出来作为逻辑卷 lv1,同上我们再次输入 `lvcreate -L 10G -n lv2 vg1`,再创建逻辑卷 lv2.
- 到这里LVM逻辑卷的分区就完成了,我们对其进行格式化,输入 `mkfs.ext4 /dev/vg1/lv1`,mkfs.ext4 是指定以 ext4分区类型对逻辑卷执行 mkfs,等价于 `mke2fs -t ext4 /dev/vg1/lv1`.同上我们输入 `mkfs.ext4 /dev/vg1/lv2` 对第二个逻辑卷也执行分区.
- 格式化完成我们进行挂载,首先需要创建一个目录,输入 `mkdir /LV1 /LV2`创建了两个测试目录来进行挂载.
- 输入 `mount /dev/vg1/lv1 /LV1` 和 `mount /dev/vg1/lv2 /LV2` 即可完成临时挂载 .我们可以使用 `df -h`来验证是否挂载成功.
- mount命令的临时挂载在系统重启后并不会生效,如果需要永久生效就需要对 `/etc/fstab` 文件进行修改.修改后需要执行 `mount -a` 重新加载 `/etc/fstab` 文件
	
	![永久挂载](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Linux磁盘分区和LVM逻辑卷/2020109/1602212572812.png)
	
#### VG卷组扩容的步骤

新建一个PV物理卷，然后加入VG即可（fdisk创建分区->修改分区类型Linux LVM->向内核注册新分区->创建物理卷->把物理卷加入需要扩容的卷组）。

- 在创建完分区后,有可能需要使用 `partprobe /dev/sdc` 来更新内核分区表,这个命令在磁盘分区完成,但并没有被内核读取到更新时使用.
- 对 /dev/sdc1 创建了物理卷后,我们输入 `vgextend vg1 /dev/sdc1` 将物理卷加入到卷组中.

#### LV逻辑卷扩容的步骤

LV逻辑卷时支持在线扩展的,只要卷组中有空余的容量.

- 输入 `lvextend -L +2G /dev/vg1/lv1` 从对应的卷组中分配新增容量,这里只是分配,还不能使用
- 输入 `resize2fs /dev/vg1/lv1` 使用resize命令来进行新增容量的确认.

#### LV逻辑卷缩减的步骤

必须先查看逻辑卷的使用情况,而且不能在线缩减,必须要先卸载.卸载后应当检查文件,以确保文件系统一致性.

- `umount /dev/vg1/lv1` 取消挂载
- `e2fsck -f /dev/vg1/lv1` 检查逻辑卷
- `resize2fs /dev/vg1/lv1 5G` ,`resize2fs /dev/vg1/lv1 -1G`,缩减到和缩减多少的区别.一样这里也只是在lv这里确认缩减
- `lvreduce -L 5G /dev/vg1/lv1` 进行逻辑卷的容量缩减
- `mount /dev/vg1/lv1 /LV1` 重新挂载

#### 减少物理磁盘 磁盘分区

发现有物理磁盘空闲,去掉整个磁盘或某个分区避免浪费.

1. `pvmove /dev/sdb1` 将/dev/sdb1上存储的数据移到其它物理卷中
2. `vgreduce vg1 /dev/sdb1` #将/dev/sdb1从VGtest卷组中移除
3. `pvremove /dev/sdb1` #将/dev/sdb1从物理卷上移除

#### 逻辑卷快照

我们可以直接通过逻辑卷的快照备份线上的数据.把创建的逻辑卷快照挂载到目录上就可以读取数据了.

`lvcreate -L 5G -n lv_backup -s -p r /dev/vg1/lv1` 即对 lv1 创建快照.这会创建一个新的 lv_backup 逻辑卷.

-----------------------------------------------------------------------------------------------------------------------------------------------------

#### 常用操作

```
显示分区信息：
[root@localhost /]# fdisk -l
 

PV：
物理硬盘格式化为物理卷(PV)：
[root@localhost /]# pvcreate /dev/sdb /dev/sdc
显示物理卷(PV)信息：
[root@localhost /]# pvdisplay
[root@localhost /]# pvs
删除物理卷(PV):
[root@localhost /]# pvremove /dev/sdb /dev/sdc
 

VG：
创建卷组(VG),并将物理卷(PV)加入到卷组中:
[root@localhost /]# vgcreate xiaoluo /dev/sdb /dev/sdc
将物理卷(PV)从指定卷组(VG)中移除(使用中PV不能移除)：
[root@localhost /]# vgreduce xiaoluo /dev/sdc
* 从卷组(VG)中移除缺失物理硬盘：
[root@localhost /]# vgreduce --removemissing centos
显示卷组(VG)信息：
[root@localhost /]# vgdisplay
[root@localhost /]# vgs
增加卷组(VG)空间：
[root@localhost mnt]# vgextend xiaoluo /dev/sdd
删除卷组(VG):
[root@localhost /]# vgremove xiaoluo
 

LV:
基于卷组(VG)创建逻辑卷(LV)
[root@localhost /]# lvcreate -n mylv -L 2G xiaoluo
显示逻辑卷(LV)信息：
[root@localhost /]# lvdisplay
[root@localhost /]# lvs
格式化逻辑卷(LV):
[root@localhost /]# mkfs.ext4 /dev/xiaoluo/mylv
挂载逻辑卷(LV):
[root@localhost /]# mount /dev/xiaoluo/mylv /mnt
卸载逻辑卷(LV):
[root@localhost /]# umount /mnt
删除逻辑卷(LV):
[root@localhost /]# lvremove /dev/xiaoluo/mylv
* 激活修复后的逻辑卷(LV)：
[root@localhost /]# lvchange -ay /dev/centos
增加逻辑卷(LV)空间：
[root@localhost mnt]# lvextend -L +3G /dev/xiaoluo/mylv
更新逻辑卷(LV):
[root@localhost mnt]# resize2fs /dev/xiaoluo/mylv
检查逻辑卷(LV)文件系统：
[root@localhost /]# e2fsck -f /dev/xiaoluo/mylv
减少逻辑卷(LV)空间：
[root@localhost /]# resize2fs /dev/xiaoluo/mylv 4G
[root@localhost /]# lvreduce -L -1G /dev/xiaoluo/mylv
 

增加新硬盘：
[root@localhost /]# fdisk -l
[root@localhost /]# pvcreate /dev/sdb
[root@localhost /]# pvs
[root@localhost /]# vgextend centos /dev/sdb
[root@localhost /]# vgs
[root@localhost /]# lvextend -L +15G /dev/centos/data
[root@localhost /]# lvs
[root@localhost /]# resize2fs /dev/centos/data
[root@localhost /]# df -lh
 

卸载硬盘：
[root@localhost /]# df -lh
[root@localhost /]# umount /data
[root@localhost /]# e2fsck -f /dev/centos/data
[root@localhost /]# resize2fs /dev/centos/data 37G
[root@localhost /]# lvreduce -L -10G /dev/centos/data
[root@localhost /]# mount /dev/centos/data /data
[root@localhost /]# df -lh
[root@localhost /]# ll /data
[root@localhost /]# pvs
[root@localhost /]# vgreduce centos /dev/sdb
[root@localhost /]# pvremove /dev/sdb
[root@localhost /]# fdisk -l
```