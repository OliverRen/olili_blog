---
title: NVIDIA-System-Management-Interface
tags: 
---

[toc]

nvidia显卡驱动和cuda管理的管理命令 `nvidia-smi`,

![nvidia-smi](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/NVIDIA-System-Management-Interface/2021127/1611735815836.png)

```
#帮助
nvidia-smi -h

#持续监控gpu状态 （-lms 可实现毫秒级监控）
nvidia-smi -l 3   #每三秒刷新一次状态，持续监控

#列出所有GPU，大写L
nvidia-smi -L

#查询所有信息
nvidia-smi -q

#查询特定卡的信息，0.1.2.为GPU编号
nvidia-smi -i 0

#显示特定的信息  MEMORY, UTILIZATION, ECC, TEMPERA-TURE, POWER, CLOCK, COMPUTE, PIDS, PERFORMANCE, SUPPORTED_CLOCKS, #PAGE_RETIREMENT, ACCOUNTING 配合-q使用
nvidia-smi -q -d MEMORY

#监控线程
nvidia-smi pmon

#监控设备
nvidia-smi dmon
```

#此外还有一系列可以配置模式的属性，可以直接利用nvidia-smi配置
#详情：http://developer.download.nvidia.com/compute/DCGM/docs/nvidia-smi-367.38.pdf
