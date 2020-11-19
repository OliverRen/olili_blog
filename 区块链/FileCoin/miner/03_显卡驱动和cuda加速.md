---
title: 03_显卡驱动和cuda加速
---

[toc]


**显卡驱动和cuda加速**

查看本地的 nvidia显卡设备

`apt install ubuntu-drivers-common`

`ubuntu-drivers devices`

可以使用apt直接安装,但是驱动和cuda都很大,建议都使用下载好之后安装.

虽然在安装ubuntu的时候我已经勾选了专用软件和显卡驱动的选项,但是由于用到的是 NVIDIA RTX3080,不知道是不是因为太新了,所以并没有检测出来专用驱动,没办法只能自行安装了.

PS : 可以尝试添加PPA源使用apt的安装方式,当然要这个源有方案之后

``` shell
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
```

CUDA工具包其中其实也已经包含了显卡的驱动程序,但是cuda只是一个工具包,他是可以多个版本进行安装的.所以并不一定要安装cuda中的显卡驱动,具体可以看后面的安装过程,需要注意的是 cuda文件名上标记的版本号是支持的最低的显卡驱动的版本,所以如果自己安装显卡驱动的话,是一定需要在这个版本之上的.

强烈建议自己单独分别安装GPU驱动和CUDA加速器,网络下载有时会非常的蛋疼

1. 准备工作

显卡驱动 : 从官方网站下载 [download](https://www.nvidia.cn/geforce/drivers/) , 我下载的版本是 NVIDIA-Linux-x86_64-455.23.04.run

CUDA工具 : [download](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=runfilelocal)
	
2. 禁用开源驱动 nouveau编辑文件 blacklist.conf

``` shell
sudo gedit /etc/modprobe.d/blacklist.conf
blacklist nouveau
blacklist intel
options nouveau modeset=0
# 更新
sudo update-initramfs -u
# 重启
sudo reboot
# 验证
lsmod | grep nouveau
```

3. 删除干净历史安装

``` shell
# 驱动如果是 runfile安装的
sudo NVIDIA-*.run -uninstall
# 驱动如果是使用apt安装的
sudo apt remove nvidia*

# 卸载CUDA,CUDA默认是安装在 /usr/local/cuda-*下的
sudo uninstall_cuda_*.pl
```
	
4. 禁用 x window服务

网上教程都安装,重启,并停止了 lightdm,其实ubuntu 20.04是使用了gdm的.直接停止后尝试安装,当然如果有用向日葵之类的软件进行远程控制的话,建议切换到lightdm,因为gdm压根就连不上会被中断
``` shell
# 更新 apt
sudo apt update

# 有可能的 lightdm 然后完成需要重启
sudo apt install lightdm 
# 如果安装了lightdm需要关闭
sudo service lightdm stop
sudo systemctl stop lightdm

# 直接关闭gdm
sudo systemctl stop gdm
```
	
5. 安装驱动文件

如果是  Server 版本的系统安装时会有 x module的缺失,直接ok即可

```
 nvidia-installer was forced to guess the X library path '/usr/lib64' and X module path
           '/usr/lib64/xorg/modules'; these paths were not queryable from the system.  If X fails to find the
           NVIDIA X driver module, please install the `pkg-config` utility and the X.Org SDK/development
           package for your distribution and reinstall the driver.
```
	
进入runfile文件所在的目录,赋予权限,然后开始安装
``` shell
sudo chmod a+x NVIDIA*.run

# NVIDIA*.run -h 可以输出帮助
# NVIDIA*.run -A 可以输出扩展选项

# 执行安装
sudo ./NVIDIA-Linux-x86_64-396.18.run --no-x-check --no-nouveau-check --no-opengl-files 
# 我们已经自己禁用了x-window
# 我们已经手动禁用了nouveau
# 由于ubuntu自己有opengl,所以我们不用安装opengl,否则会出现循环登录的情况

# 安装过程
大概说是NVIDIA驱动已经被Ubuntu集成安装,可以在软件更新器的附加驱动中找到,我就是因为3080显卡找不到才需要自己安装的,所以直接继续
The distribution-provided pre-install script failed! Are you sure you want to continue?
选择 yes 继续.
Would you like to register the kernel module souces with DKMS? This will allow DKMS to automatically build a new module, if you install a different kernel later?
选择 No 继续.
是否安装 NVIDIA 32位兼容库
选择NO继续
Would you like to run the nvidia-xconfig utility to automatically update your x configuration so that the NVIDIA x driver will be used when you restart x? Any pre-existing x confile will be backed up.
选择 Yes 继续

# 安装完成
# 挂载专用驱动 正常来说会自动挂载
modprobe nvidia
检查驱动是否成功
nvidia-smi
nvidia-settings 是ui界面的配置

# 开启图形界面,之前如果安装了lightdm则启动之
sudo systemctl start lightdm
sudo systemctl start gdm

sudo reboot

# ps : 如重启后出现分辨率为800*600,且不可调的情况执行下面命令
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
sudo touch /etc/X11/xorg.conf
sudo reboot	
```
	
6. 安装CUDA

进入runfile文件目录,添加执行权限后执行安装

``` shell
sudo sh ./cuda_*.run --no-opengl-libs
# 同驱动安装一样,这里也不需要安装opengl库

# 安装过程
Do you accept the previously read EULA?
accept
然后通过界面选择安装项,注意安装的东西

# 安装完成,会输入大概如下的Summary
===========
= Summary =
===========

Driver : Not Selected
Toolkit : Installed in /usr/local/cuda-11.1/
Samples : Installed in /home/rxc/, but missing recommended libraries

Please make sure that
 -   PATH includes /usr/local/cuda-11.1/bin
 -   LD_LIBRARY_PATH includes /usr/local/cuda-11.1/lib64, or, add /usr/local/cuda-11.1/lib64 to /etc/ld.so.conf and run ldconfig as root

To uninstall the CUDA Toolkit, run cuda-uninstaller in /usr/local/cuda-11.1/bin
***WARNING : Incomplete installation! This installation did not install the CUDA Driver. A driver of version at least .00 is required for CUDA 11.1 functionality to work.
To install the driver using this installer, run the following command, replacing <CudaInstaller> with the name of this run file : 
	sudo <CudaInstaller>.run --silent --driver

Logfile is /var/log/cuda-installer.log

# 安装CUDA工具需要自行设置path,编辑 .bashrc 或者 /etc/profile全局文件
gedit ~/.bashrc 
export PATH=/usr/local/cuda-8.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH

# Please make sure that
# -   PATH includes /usr/local/cuda-11.1/bin
# -   LD_LIBRARY_PATH includes /usr/local/cuda-11.1/lib64, or, add /usr/local/cuda-11.1/lib64 to /etc/ld.so.conf and run ldconfig as root
```

7. 测试
	
``` shell
cd /usr/local/cuda-8.0/samples/1_Utilities/deviceQuery
sudo make -j4
# 这里-j4是因为是4核cpu,可以4个jobs一起跑
./deviceQuery
```