---
title: 15_P1阶段的CPU绑定
tags: 
---

P1阶段时可以通过设置环境变量 `$FIL_PROOFS_USE_MULTICORE_SDR=1`对 worker 启用多核心加快 SDR 的效率 .

然后通过 `taskset -C` 或 systemd 的中的 cpu亲和度参数来绑定相邻边界的4个核心

启动参数:
`lotus-worker run --listen 0.0.0.0:X --addpiece=false --precommit1=true --unseal=true --precommit2=false --commit=false`

通过 taskset:
```
# Restrict to single core number 0
taskset -c 0 <worker_pid | command>
# Restrict to a single core complex (example)
# Check your CPU model documentation to verify how many
# core complexes it has and how many cores in each:
taskset -c 0,1,2,3 <worker_pid | command>
```

通过systemd:
```
# workerN.service
...
CPUAffinity=C1,C2... # Specify the core number that this worker will use.
...
```