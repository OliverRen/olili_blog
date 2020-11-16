---
title: 15_使用lotus-miner开始封装
tags: 
---

**Lotus mine 抵押扇区 及开始封装算力**

抵押扇区是增加有效存力的唯一方式,同时需要根据一个扇区的密封的时间\*1.5来更新配置中的`ExpectedSealDuration`字段.

抵押一个扇区即承诺自己提供一个扇区的容量给网络可用,使用命令 `lotus-miner sectors pledge` , 需要注意的是这会完整的走完整个过程,即肯定是要写入数据的.通过以下命令来进行检查

``` shell
# 查看密封中的工作,这一般会在 $TMPDIR/unsealed 中创建文件
lotus-miner sealing jobs
# 查看密封进度,密封完成时 pSet: NO将变为pSet: YES
lotus-miner sectors list
# 查看密封使用的资源
lotus-miner sealing workers
# 通过log来查看一个扇区密封所需的时间
lotus-miner sectors status --log 0
```