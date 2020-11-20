---
title: 批量杀掉lotus进程xargs
tags: 
---

`ps -ef | grep lotus | awk '{print $2}' | xargs -L 1 kill`