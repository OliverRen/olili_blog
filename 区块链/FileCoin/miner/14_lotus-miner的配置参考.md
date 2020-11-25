---
title: 14_lotus-miner的配置参考
tags: 
---

**Lotus Miner 配置参考**

Lotus Miner配置是在初始化`init`步骤之后的,其位置是 `$LOTUS_MINER_PATH/config.toml`, 其默认值是 `~/.lotusminer/config.toml`. 必须重新启动矿机即miner服务才可以使配置生效.

- API部分 主要使为了worker来使用的,默认使绑定在本地环路接口,如果是多机器则需要配置到使用的网络接口
- Libp2p部分 这部分是配置miner嵌入的 Libp2p 节点的,需要配置成miner的公共ip和固定的端口
- PubSub部分用于在网络中分发消息
- Deal Making部分 用于控制存储和检索交易.注意 `ExpectedSealDuration` 应该等于 `(TIME_TO_SEAL_A_SECTOR + WaitDealsDelay) * 1.5`
- Sealing部分 即密封部分配置
- Storage部分 即存储部分,控制矿工是否可以执行某些密封行为
- Fees费用部分

#### API部分

```
[API]
  # 绑定监听的端口
  ListenAddress = "/ip4/127.0.0.1/tcp/2345/http"
  # 指示外部worker可见的地址,比如指定自己的网卡的一个IP 需要结合公开出去的信息一起修改
  # This should be set to the miner API address as seen externally
  RemoteListenAddress = "127.0.0.1:2345"
  # General network timeout value
  Timeout = "30s"
```

#### Libp2p部分

与外部libp2p通信部分的设置

```
# Binding address for the libp2p host. 0 means random port.
[Libp2p]
  # 本地监听的端口
  ListenAddresses = ["/ip4/0.0.0.0/tcp/0", "/ip6/::/tcp/0"]
  # 显示的指定外部网络中peer通过何种方式来与本机通信,否则他们只能猜测尝试判断
  AnnounceAddresses = []
  # 不想被探测访问的地址
  NoAnnounceAddresses = []
  # 连接管理器的设置
  ConnMgrLow = 150
  ConnMgrHigh = 180
  ConnMgrGrace = "20s"
```

#### Pubsub部分

pubsub是用来向网络广播信息的,一般miner不会进行pubsub信息的发布

```
[Pubsub]
  # Usually you will not run a pubsub bootstrapping node, so leave this as false
  Bootstrapper = false
  # FIXME
  RemoteTracer = ""
```

#### Dealmaking部分 存储交易

```
[Dealmaking]
  # 是否接受在线交易提议
  ConsiderOnlineStorageDeals = true
  # 是否接受线下交易提议
  ConsiderOfflineStorageDeals = true
  # 是否接受线上检索提议
  ConsiderOnlineRetrievalDeals = true
  # 是否接受线下检索提议
  ConsiderOfflineRetrievalDeals = true
  # 拒绝接受存储的内容CID
  PieceCidBlocklist = []
  # 密封过程大概需要的时间
  ExpectedSealDuration = "12h0m0s"

  # 存储交易评估的命令,是否接受这个存储交易
  Filter = "/absolute/path/to/storage_filter_program"

  # 检索交易评估的命令,是否接受这个检索交易
  RetrievalFilter = "/absolute/path/to/retrieval_filter_program"
```

ExpectedSealDuration表示了整个密封过程的大致时间,用来保证miner不会过早的提交这个sector

TIPS:这个值我们可以设置为9小时,该值评估为 `(封装sector时间+等待交易的延迟)*1.5`,甚至可以更短.`(P1+P2+0)*1.5=6`

Filter用来过滤存储交易

RetrievalFilter用来过滤检索交易

如果返回0则接受交易,非0则拒绝. `/bin/false` 会快速返回1来拒绝交易

这个perl脚本可以让矿工用来拒绝具体的客户,并且只接受相对较快的交易

``` perl
#!/usr/bin/perl

use warnings;
use strict;
use 5.014;

# Uncomment this to lock down the miner entirely
#exit 1

# A list of wallets you do not want to deal with
# For example this enty will prevent a shady ribasushi
# character from storing things on your miner
my $denylist = { map {( $_ => 1 )} qw(
  t3vxr6utzqjobnjnhi5gwn7pqoqstw7nrh4kchft6tzb2e7xorwvj5f3tg3du3kedadtkxvyp4jakf3zdd4iaa
)};

use JSON::PP 'decode_json';

my $deal = eval { decode_json(do{ local $/; <> }) };
if( ! defined $deal ) {
  print "Deal proposal JSON parsing failed: $@";
  exit 1;
}

# Artificially limit deal start time to work around https://github.com/filecoin-project/lotus/issues/3929
# 1598306400 is the unix-time of "block 0" in the network
my $max_days_before_start = 7;
if(
  1598306400 + $deal->{Proposal}{StartEpoch} * 30
    >
  time() + 60 * 60 * 24 * $max_days_before_start
) {
  print "Deal from client wallet $deal->{Proposal}{Client} begins more than $max_days_before_start days in the future, I do not like that";
  exit 1;
}

if( $denylist->{$deal->{Proposal}{Client}} ) {
  print "Deals from client wallet $deal->{Proposal}{Client} are not welcome";
  exit 1;
}

exit 0;
```

也可以使用一个第三方的内容审查的框架来过滤,比如 Murmuration实验室的 `bitscreen` [gtihub地址](https://github.com/Murmuration-Labs/bitscreen)

```
# grab filter program
go get -u -v github.com/Murmuration-Labs/bitscreen

# add it to both filters
Filter = "/path/to/go/bin/bitscreen"
RetrievalFilter = "/path/to/go/bin/bitscreen"
```

其主要工作方式也是将不能被存储的CID记录起来,拒绝存储和检索

#### Sealing 密封过程

```
[Sealing]
  # 同时可以接受交易提议的sector
  MaxWaitDealsSectors = 2
  # 同时封装的sector数目上限,包含pledge中的
  MaxSealingSectors = 0
  # 同上,但只对有交易相关的sector数目进行限制,pledge的不包含
  MaxSealingSectorsForDeals = 0
  # 当sector创建时等待多久时间来获取到在线存储交易
  WaitDealsDelay = "1h0m0s"
```

#### Storage 存储

```
[Storage]
  # 定义了网络中同一时间有多少sector可以被传输
  ParallelFetchLimit = 10
  # Miner角色本身也是一个worker,当然这里最好全部设置为false,让seal worker来干这些事情
  AllowPreCommit1 = true
  AllowPreCommit2 = true
  AllowCommit = true
  AllowUnseal = true
```

#### 修改miner的gas费率**

``` lotusminer/config.toml
[Fees]
  # 封装块是需要手续费的 平均需要 0.0001 FIL 以下,高费率是0.05
  MaxPreCommitGasFee = "0.05 FIL"
  # 提交块是需要手续费的 平均需要 0.001 FIL以下,高费率是0.1
  MaxCommitGasFee = "0.1 FIL"
  # 高费率在1FIL左右
  MaxWindowPoStGasFee = "1 FIL"
  # 保持默认就好
  MaxPublishDealsFee = "0.05 FIL"
  # 保持默认就好
  MaxMarketBalanceAddFee = "0.007 FIL"
```

