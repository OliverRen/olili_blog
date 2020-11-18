---
title: 18_P2和C阶段得GPU绑定
tags: 
---

P2阶段和C2阶段主要是通过 GPU 来执行工作,那么这里可以使用环境变量来隔离进程所使用的GPU

我们通过 `CUDA_VISIBLE_DEVICES` 来配置,这和CPU亲和度类似,也是使用GPU序号来指定即可

`CUDA_VISIBLE_DEVICES=1`

只有编号为1的GPU对程序是可见的，在代码中gpu\[0]指的就是这块儿GPU

`CUDA_VISIBLE_DEVICES=0,2,3`

只有编号为0,2,3的GPU对程序是可见的，在代码中gpu\[0]指的是第0块儿，gpu\[1]指的是第2块儿，gpu\[2]指的是第3块儿

`CUDA_VISIBLE_DEVICES=2,0,3`

只有编号为0,2,3的GPU对程序是可见的，但是在代码中gpu\[0]指的是第2块儿，gpu\[1]指的是第0块儿，gpu\[2]指的是第3块儿

