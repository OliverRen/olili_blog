---
title: linux下CPU频率运行模式
tags: 
---

[toc]

#### 常见的CPU频率运行模式

1. ondemand：系统默认的超频模式，按需调节，内核提供的功能，不是很强大，但有效实现了动态频率调节，平时以低速方式运行，当系统负载提高时候自动提高频率。以这种模式运行不会因为降频造成性能降低，同时也能节约电能和降低温度。一般官方内核，还有CM7的默认的方式都是ondemand。
	流畅度： 一般，流畅  快升快降
2. interactive：交互模式，直接上最高频率，然后看CPU负荷慢慢降低，比较耗电。  Interactive 是以 CPU 排程数量而调整频率，从而实现省电。InteractiveX 是以 CPU 负载来调整 CPU 频率，不会过度把频率调低。所以比 Interactive 反应好些，但是省电的效果一般 
	流畅度： 最高，极流畅  快升慢降
3. conservative：保守模式，类似于ondemand，但调整相对较缓，想省电就用他吧。Google官方内核，kang内核默认模式。 
	流畅度： 高，流畅  慢升快降
4. smartass：聪明模式，是I和C模式的升级，该模式在比i模式不差的响应的前提下会做到了更加省电
	流畅度： 最高，流畅
5. performance：性能模式！只有最高频率，从来不考虑消耗的电量.
	流畅度：最最高 最大性能
6. powersave 省电模式，通常以最低频率运行
	流畅度： 极低  最高节能
7. userspace：用户自定义模式，系统将变频策略的决策权交给了用户态应用程序，并提供了相应的接口供用户态应用程序调节CPU 运行频率使用。也就是长期以来都在用的那个模式。可以通过手动编辑配置文件进行配置
	流畅度：根据设置而定
8. Hotplug：类似于ondemand, 但是cpu会在关屏下尝试关掉一个cpu，并且带有deep sleep，比较省电。
	流畅度：一般，流畅
	
#### 配置运行模式

系统中对CPU频率运行模式的调整一般都是采用 `governor` 来进行调整的,该文件的位置一般是在 `/sys/devices/system/cpu/cpu{num}/cpufreq/scaling_governor`

多数Linux发行版都已经默认启用了这个功能，但是Debian 4.0和Archlinux还没有，需要经过简单的设置才行。辨别方式很简单只要看是否有上面路径中的 cpufreq 文件夹即可

这样使用内核模块来管理CPU频率是最简单的,直接手动修改该文件中的内容就可以直接生效了

```
#!/bin/bash
cpu_num=`cat /proc/cpuinfo | grep "processor"| wc -l`

for((i=0;i<${cpu_num};i++))
do
    echo performance > /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor
    ret=$?
    if [ $ret -ne 0 ];then
        echo "set cpu${i} fail"
    fi
done
```

如果想要重启后自动生效,或者要使用软件来进行管理,那么可选项是比较多的,比如

- sysfsutils
- cpufrequtils
- cpudynd
- cpufreqd
- powernowd
- powersaved
- speedfreqd

#### sysfsutils通过配置文件开机自动生效 cpu governor

1. 安装sysfsutils
2. 编辑/etc/sysfs.conf，增加如下语句 : `devices/system/cpu/cpu<core number>/cpufreq/scaling_governor=<governor>`

<core number>	是CPU逻辑核心的编号，从0开始，有多少个逻辑核心就添加多少条该条数据。

<governor>			是调节器类型，允许的值有performance powersave ondemand interactive conservative.

ps:该方法我并没有实验成功,尽可能还是使用内核方法调节把.这样重启后还可以自动回复