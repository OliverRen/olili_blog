---
title: 29_LotusMiner应用的故障处理
tags: 
---

[toc]

- Error: Can't acquire bellman.lock

`mining block failed: computing election proof: github.com/filecoin-project/lotus/miner.(*Miner).mineOne`

无法获取到锁,这是在 `TMPDIR` 下的文件

- Error: Failed to get api endpoint

`lotus-miner info WARN  main  lotus-storage-miner/main.go:73  failed to get api endpoint: (/Users/user/.lotusminer) %!w(*errors.errorString=&{API not running (no endpoint)}):`

这说明 `lotus daemon` 还没有准备好

- Error: Your computer may not be fast enough

`CAUTION: block production took longer than the block delay. Your computer may not be fast enough to keep up`

机器不够好

- Error: No space left on device

如果看到这种情况，则意味着扇区承诺写入了太多的数据，$TMPDIR这些数据默认是根分区（这在Linux安装程序中很常见）。通常，您的根分区不会获得最大的存储分区，因此您需要将环境变量更改为其他变量。

- 突然要修改 miner 的 config 文件,但不想重启 miner

手工修改 config 文件后,可以使用 `lotus-miner sectors set-seal-delay` 来使进程重新加载

- 紧急杀掉所有lotus进程

`ps -ef | grep lotus | awk '{print $2}' | xargs -L 1 kill`

- 自动备份lotus-miner文件

1. 需要source本地lotus-miner的环境变量
2. 需要在lotus-mienr_HOMEPATH/config中配置可以备份的路径前缀,如下面配置了 /data4/lotus-miner-metadata-backup

`/usr/local/bin/lotus-miner backup /data4/lotus-miner-metadata-backup/$(date +%Y%m%d)`

- 高级环境变量的设置,目前无法预估后果

`FIL_PROOFS_SDR_PARENTS_CACHE_SIZE=1073741824` 缓存的证明父级数目

`FIL_PROOFS_MAX_GPU_COLUMN_BATCH_SIZE=400000` 一次编译的列数,默认是40,0000.大了会耗尽GPU RAM,小了会降低性能.默认值是 2080TI的测试值

`FIL_PROOFS_COLUMN_WRITE_BATCH_SIZE` 从GPU返回的数数据并行写入缓冲区的大小,默认值是 262144

`FIL_PROOFS_MAX_GPU_TREE_BATCH_SIZE` 构建 tree_r_last,默认是70,0000个树节点

- 临时限制进程

```
# 获取lotus-miner的PID(如下所示，PID为2333)
$ ps -ef | grep lotus-miner
root       2333 6666 88 Nov31 ?        1-02:50:00 lotus-miner run
# 为lotus-miner设置ulimit
sudo prlimit --nofile=1048576 --nproc=unlimited --stack=1048576 --rtprio=99 --nice=-19 --pid 2333\
```

- 使用脚本简单的处理 sector 报错 

```
m=`lotus-miner info | grep 'Miner:' | awk -F ' ' '{print $2}'`
lotus state sectors $m > /tmp/s.txt
for i in `lotus-miner sectors list | grep -P '(Fatal|Fail|Recover)' | grep -v Remove | awk -F ' ' '{print $1}'`
do
  a=`cat /tmp/s.txt | grep -P "^$i:" | wc -l`
  if [ $a -eq 0 ]
  then
    echo $i $a Removing
    lotus-miner sectors update-state --really-do-it $i Removing
  else
    echo $i $a Proving
    lotus-miner sectors update-state --really-do-it $i Proving
  fi
done

lotus-miner sectors status --log 0
lotus-miner sectors update-state --really-do-it 0 Removing
当sector出现意料之外的错误，会进入如下两种状态。
FatalError。通常由于sector的链上信息不符合预期，此时需要手动排查问题。
Removing/RemoveFailed/Removed。当垃圾sector出现预料之外的错误，我们选择直接删除。
```