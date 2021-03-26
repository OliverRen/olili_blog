---
title: Snapraid使用备注
tags: 
---

[toc]

关键字:奇偶校验,文件级别的冗余raid

#### 什么是 snapraid

SnapRAID 是一个目录级别的冗余存储方案，它与 RAID 的原理有相似的地方，但它并不是 RAID。SnapRAID 与 RAID 的主要区别有：

*   SnapRAID 不会对数据进行条带化存储。RAID 通常会使用[数据条带化](https://en.wikipedia.org/wiki/Data_striping)，一个文件可能会被分散存储到多块磁盘上，这样的优点是读取的时候可以加速（多块磁盘同时读取），但条带化也是上节所说的 data lock-in 的根源——你不能拆出一块盘单独读写。
*   SnapRAID 是工作于文件系统之上的。RAID 工作于文件系统之下，直接对磁盘区块进行操作，用磁盘区块上的比特计算校验数据，而 SnapRAID 是通过读取文件系统里的文件之后再进行计算的。
*   SnapRAID 是非实时的。RAID 每时每刻都在工作，磁盘区块上的数据一旦发生变更就会重新计算校验数据，而 SnapRAID 可以在用户选择的时间进行重新计算。

SnapRAID 相比 RAID 的优点主要有：

*   **数据独立**。不需要对磁盘做特殊处理，可以直接将已有数据的磁盘（甚至可以是不同文件系统的）加入 SnapRAID，SnapRAID 也不会改变这些已有的数据；一个文件不会被分散到多个磁盘，随时可以拆下来一块磁盘正常读写里面的数据；当磁盘阵列收到文件读写请求时，也只需要一块磁盘响应，而不是所有的磁盘全部从待机状态启动，开始寻道。
*   **抗灾能力**。当磁盘列阵中同时损坏的磁盘数量超出预期而无法修复数据时，SnapRAID 的抗灾能力更强。例如：在 3 + 1 的 RAID 场景下，坏一块没事，如果同时坏了两块，所有的磁盘上的数据都将无法读取（因为条带化）；但如果是 3 + 1 的 SnapRAID，就算同时坏两块，剩下两块里的数据依然可以正常读取。
*   **配置灵活**。标准的 RAID 等级中，RAID 5 最多承受 1 块磁盘同时损坏，RAID 6 最多承受 2 块磁盘同时损坏；而 SnapRAID 可以配置 1 到 6 块校验盘，最多承载 6 块磁盘同时损坏，因此可以组建更大的磁盘阵列而不提升风险（维持数据盘与校验盘的比例不变）。更重要的是，无论是增加还是减少磁盘，SnapRAID 都可以无痛完成，无需清空磁盘数据。
*   恢复误删文件。由于 RAID 是实时计算校验数据的，当文件被删除时，这一改动立刻就会被同步到校验数据里；而 SnapRAID 在用户请求的时候才进行同步，因此用户可以用 SnapRAID 从校验数据重新构建被误删除的文件。当然了，更可靠、更持久的的误删除防护还是应该用增量备份来完成。
*   空间利用率高。在磁盘阵列中，校验盘的大小应大于等于数据盘中最大的那块。使用 SnapRAID 时，你可以「[超售](https://en.wikipedia.org/wiki/Resource_contention)」。比如数据盘是 6 TB 的但是只装了一半（3 TB），你把 4 TB 的磁盘作为校验盘也是可以的（因为此时校验数据最多只有 3 TB），只要在校验文件膨胀到接近 4 TB 的时候将校验文件挪到更大的磁盘里即可。同样的，校验盘里未被校验文件填满的剩余空间也可以用来存储一些「丢了也无所谓」的不重要数据。此外，由于 SnapRAID 工作于文件系统之上，你可以选择性地排除掉一些不想做冗余的目录和文件，以节省空间。

#### snapraid的配置

看官方文档和示例已经足够,相当的简单

PS:由于我硬盘很多,所以用了 mount-point ,msdn或者google搜索 windows-mount-point 即可,本质上是挂在不分配盘符,直接挂在到目录

```

# Example configuration for snapraid for Windows
# 官方网址 https://www.snapraid.it/

# Defines the file to use as parity storage
# It must NOT be in a data disk
# Format: "parity FILE [,FILE] ..."
# 校验文件的位置
# 显然，校验文件不能放在数据盘上，否则就没有意义了
parity C:\DisksParity\C1\snapraid\snapraid.parity

# Defines the files to use as additional parity storage.
# If specified, they enable the multiple failures protection
# from two to six level of parity.
# To enable, uncomment one parity file for each level of extra
# protection required. Start from 2-parity, and follow in order.
# It must NOT be in a data disk
# Format: "X-parity FILE [,FILE] ..."
# 如需添加更多的校验文件则继续添加
# 最多是 6 份校验，承受磁盘磁盘阵列中最多同时坏掉 6 块盘的情况
# 2-parity F:\snapraid.2-parity
# 3-parity G:\snapraid.3-parity
# 4-parity H:\snapraid.4-parity
# 5-parity I:\snapraid.5-parity
# 6-parity J:\snapraid.6-parity
# 2-parity C:\DisksParity\C2\snapraid\snapraid.parity
# 3-parity C:\DisksParity\C3\snapraid\snapraid.parity
# 4-parity C:\DisksParity\C4\snapraid\snapraid.parity

# Defines the files to use as content list
# You can use multiple specification to store more copies
# You must have least one copy for each parity file plus one. Some more don't hurt
# They can be in the disks used for data, parity or boot,
# but each file must be in a different disk
# Format: "content FILE"
# 重要的索引文件，建议保存多份（内容是一样的）
content C:\Disks3T\D1\snapraid\snapraid.content
content C:\Disks3T\D2\snapraid\snapraid.content
content C:\Disks3T\D3\snapraid\snapraid.content
content C:\Disks3T\D4\snapraid\snapraid.content
content C:\Disks3T\E1\snapraid\snapraid.content
content C:\Disks3T\E2\snapraid\snapraid.content
# content C:\Disks4T\E3\snapraid\snapraid.content
# content C:\Disks4T\E4\snapraid\snapraid.content
# content C:\Disks4T\F1\snapraid\snapraid.content
# content C:\Disks4T\F2\snapraid\snapraid.content
# content C:\Disks4T\F3\snapraid\snapraid.content
# content C:\Disks4T\F4\snapraid\snapraid.content

# Defines the data disks to use
# The name and mount point association is relevant for parity, do not change it
# WARNING: Adding here your boot C:\ disk is NOT a good idea!
# SnapRAID is better suited for files that rarely changes!
# Format: "data DISK_NAME DISK_MOUNT_POINT"
# 指定数据盘及其挂载点
# 这里不一定要写确切的挂载点，可以是这块盘上的任意目录
# 目录以外的内容会被完全忽略
disk d1 C:\Disks3T\D1\
disk d2 C:\Disks3T\D2\
disk d3 C:\Disks3T\D3\
disk d4 C:\Disks3T\D4\
disk d5 C:\Disks3T\E1\
disk d6 C:\Disks3T\E2\
disk d7 C:\Disks4T\E3\
disk d8 C:\Disks4T\E4\
disk d9 C:\Disks4T\F1\
disk d10 C:\Disks4T\F2\
disk d11 C:\Disks4T\F3\
disk d12 C:\Disks4T\F4\

# Excludes hidden files and directories (uncomment to enable).
# 忽略所有隐藏文件和目录（不做冗余）
# 在 Unix-like 里就是 . 开头的文件和目录
# 在 Windows 里就是带隐藏属性的文件和目录
nohidden

# Defines files and directories to exclude
# Remember that all the paths are relative at the mount points
# Format: "exclude FILE"
# Format: "exclude DIR\"
# Format: "exclude \PATH\FILE"
# Format: "exclude \PATH\DIR\"
# 排除列表与包含列表
exclude *.unrecoverable
exclude Thumbs.db
exclude \$RECYCLE.BIN
exclude \System Volume Information
exclude \Program Files\
exclude \Program Files (x86)\
exclude \Windows\
exclude \tmp\
exclude \lost+found\
exclude *.nobackup
exclude *.nobackup\
exclude \snapraid\
exclude snapraid.parity
exclude snapraid.content

# Defines the block size in kibi bytes (1024 bytes) (uncomment to enable).
# WARNING: Changing this value is for experts only!
# Default value is 256 -> 256 kibi bytes -> 262144 bytes
# Format: "blocksize SIZE_IN_KiB"
blocksize 256

# Defines the hash size in bytes (uncomment to enable).
# WARNING: Changing this value is for experts only!
# Default value is 16 -> 128 bits
# Format: "hashsize SIZE_IN_BYTES"
hashsize 16

# Automatically save the state when syncing after the specified amount
# of GB processed (uncomment to enable).
# This option is useful to avoid to restart from scratch long 'sync'
# commands interrupted by a machine crash.
# It also improves the recovering if a disk break during a 'sync'.
# Default value is 0, meaning disabled.
# Format: "autosave SIZE_IN_GB"
# 生成校验数据时，每处理 10 GiB 数据自动保存一次，方便断点继续
autosave 32

# Defines the pooling directory where the virtual view of the disk
# array is created using the "pool" command (uncomment to enable).
# The files are not really copied here, but just linked using
# symbolic links.
# This directory must be outside the array.
# Format: "pool DIR"
# pool C:\pool

# Defines the Windows UNC path required to access disks from the pooling
# directory when shared in the network.
# If present (uncomment to enable), the symbolic links created in the
# pool virtual view, instead of using local paths, are created using the
# specified UNC path, adding the disk names and file path.
# This allows to share the pool directory in the network.
# See the manual page for more details.
#
# Format: "share UNC_DIR"
# share \\server

# Defines a custom smartctl command to obtain the SMART attributes
# for each disk. This may be required for RAID controllers and for
# some USB disk that cannot be autodetected.
# In the specified options, the "%s" string is replaced by the device name.
# Refers at the smartmontools documentation about the possible options:
# RAID -> https://www.smartmontools.org/wiki/Supported_RAID-Controllers
# USB -> https://www.smartmontools.org/wiki/Supported_USB-Devices
#smartctl d1 -d sat %s
#smartctl d2 -d usbjmicron %s
#smartctl parity -d areca,1/1 /dev/arcmsr0
#smartctl 2-parity -d areca,2/1 /dev/arcmsr0

```

#### 常用操作

- 创建空文件用于测试
fsutil file createnew C:\Disks3T\D1\test.txt 2048000000
- 修改cmd到utf-8
chcp 65001

- 查看状态
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf status -v
- 查看smart,并预估磁盘损坏的时间
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf smart -v
- 查看变更
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf diff
- 查看相同的文件 计算内容hash
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf dup

- 执行同步
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf sync
- 对空目录执行同步
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf --force-empty sync
- 执行擦洗
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf -p 5 -o 20 scrub

- 回滚文件
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf fix -f FILE
- 回滚目录
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf fix -f DIR/
- 回滚目录中丢了的数据
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf fix -m -f DIR/
- 回滚所有删除了的数据
snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf fix -m

#### 坑

虽然官方说了数据内容是 utf-8 的,但是他的 -f 参数匹配pattern的时候不支持中文.我了个去

win10 当 nas 系统没什么不好...毕竟我用的是服务器 .嘿嘿嘿

千万不要自动跑sync.得判断返回值啊.跟我一样写点脚本手动运行不好吗.

举个例子:

``` sync.bat
@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

chcp 65001

snapraid -c C:\userProgram\tool\SnapRaid\snapraid.conf sync

pause
```