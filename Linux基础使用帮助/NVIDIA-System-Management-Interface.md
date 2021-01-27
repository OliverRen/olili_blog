---
title: NVIDIA-System-Management-Interface
tags: 
---

[toc]

#### nvidia-smi 命令的输出含义

nvidia显卡驱动和cuda管理的管理命令 `nvidia-smi`

![nvidia-smi](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/NVIDIA-System-Management-Interface/2021127/1611735815836.png)

显示的表格中：

Fan：                     风扇转速（0%--100%），N/A表示没有风扇

Temp：                 GPU温度（GPU温度过高会导致GPU频率下降）

Perf：                    性能状态，从P0（最大性能）到P12（最小性能）

Pwr：                     GPU功耗

Persistence-M：   持续模式的状态（持续模式耗能大，但在新的GPU应用启动时花费时间更少）

Bus-Id：               GPU总线，domain:bus:device.function

Disp.A：                Display Active，表示GPU的显示是否初始化

Memory-Usage：显存使用率

Volatile GPU-Util：GPU使用率

ECC：                   是否开启错误检查和纠正技术，0/DISABLED, 1/ENABLED

Compute M.：     计算模式，0/DEFAULT,1/EXCLUSIVE_PROCESS,2/PROHIBITED

#### 基本用法

详情：http://developer.download.nvidia.com/compute/DCGM/docs/nvidia-smi-367.38.pdf

```
帮助
nvidia-smi -h

持续监控gpu状态 （-lms 可实现毫秒级监控）
nvidia-smi -l 3   #每三秒刷新一次状态，持续监控

列出所有GPU，大写L
nvidia-smi -L

查询所有信息
nvidia-smi -q

查询特定卡的信息，0.1.2.为GPU编号
nvidia-smi -i 0

显示特定的信息  MEMORY, UTILIZATION, ECC, TEMPERA-TURE, POWER, CLOCK, COMPUTE, PIDS, PERFORMANCE, SUPPORTED_CLOCKS, #PAGE_RETIREMENT, ACCOUNTING 配合-q使用
nvidia-smi -q -d MEMORY

监控线程
nvidia-smi pmon

监控设备
nvidia-smi dmon
```

#### 设备修改选项

```
设置持久模式：0/DISABLED,1/ENABLED
nvidia-smi –pm 0/1

切换ECC支持：0/DISABLED, 1/ENABLED
nvidia-smi –e 0/1

重置ECC错误计数：0/VOLATILE, 1/AGGREGATE
nvidia-smi –p 0/1

设置计算应用模式：0/DEFAULT,1/EXCLUSIVE_PROCESS,2/PROHIBITED
nvidia-smi –c

GPU复位
nvidia-smi –r

设置GPU虚拟化模式
nvidia-smi –vm

设置GPU运行的工作频率。e.g. nvidia-smi –ac2000,800
nvidia-smi –ac xxx,xxx

将时钟频率重置为默认值
nvidia-smi –rac

切换-ac和-rac的权限要求，0/UNRESTRICTED, 1/RESTRICTED
nvidia-smi –acp 0/1

指定最大电源管理限制（瓦特）
nvidia-smi –pl

启用或禁用计数模式，0/DISABLED,1/ENABLED
nvidia-smi –am 0/1

清除缓冲区中的所有已记录PID，0/DISABLED,1/ENABLED
nvidia-smi –caa
```
