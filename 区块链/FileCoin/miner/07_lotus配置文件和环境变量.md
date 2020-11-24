---
title: 07_lotus配置文件和环境变量
tags: 
---

#### Lotus的配置文件

Lotus的配置文件在 `$LOTUS_PATH/config.toml` 

- API : lotus daemon本身监听的端口
- Libp2p : 与 Filecoin 网络中的其他节点进行交互的设置

```
# lotus rpc api
[API]
  # lotus rpc api绑定
  ListenAddress = "/ip4/127.0.0.1/tcp/1234/http"
  # lotus daemon不需要进行设置
  RemoteListenAddress = ""
  # 通用的网络超时
  Timeout = "30s"

# 在filecoin网络中与其他node节点的连接
[Libp2p]
  # libp2p的监听,使用端口0意味着随机端口
  ListenAddresses = ["/ip4/0.0.0.0/tcp/0", "/ip6/::/tcp/0"]
  # 显示的指定自己可以被公开访问到的地址,如果指定了那么上面肯定是需要使用固定的端口的,然后路由需要端口转发
  AnnounceAddresses = []
  # 避免被访问到的地址
  NoAnnounceAddresses = []
  # 连接管理器的设置
  ConnMgrLow = 150
  ConnMgrHigh = 180
  ConnMgrGrace = "20s"

# pubsub是用来向网络广播信息的
[Pubsub]
  Bootstrapper = false
  RemoteTracer = "/dns4/pubsub-tracer.filecoin.io/tcp/4001/p2p/QmTd6UvR47vUidRNZ1ZKXHrAFhqTJAD27rKL9XYghEKgKX"

# 是否使用本地的ipfs节点
[Client]
  UseIpfs = false
  IpfsMAddr = ""
  IpfsUseForRetrieval = false

# 标准配置
[Metrics]
  Nickname = ""
  HeadNotifs = false

# 钱包配置
[Wallet]
  EnableLedger = false
```

#### Lotus的环境变量

Filecoin相关目录环境变量, 整个本地数据由这些相关目录 和 wallet 及 chain文件组成

* `~/.lotus ($LOTUS_PATH)`
* `~./lotusminer ($LOTUS_MINER_PATH)`
* `~./lotusworker ($LOTUS_WORKER_PATH)`

以下环境变量对大多数的 Lotus 二进制文件都是有效的





* `LOTUS_FD_MAX` : Sets the file descriptor limit for the process
* `LOTUS_JAEGER` : Sets the Jaeger URL to send traces. See more on docs.
* `LOTUS_DEV` : Any non-empty value will enable more verbose logging, useful only for developers.

Variables specific to the _Lotus daemon_ 

* `LOTUS_PATH` : Location to store Lotus data (defaults to `~/.lotus`).
* `LOTUS_SKIP_GENESIS_CHECK=_yes_` : Set only if you wish to run a lotus network with a different genesis block.
* `LOTUS_CHAIN_TIPSET_CACHE` : Sets the size for the chainstore tipset cache. Defaults to `8192`. Increase if you perform frequent arbitrary tipset lookups.
* `LOTUS_CHAIN_INDEX_CACHE` : Sets the size for the epoch index cache. Defaults to `32768`. Increase if you perform frequent deep chain lookups for block heights far from the latest height.
* `LOTUS_BSYNC_MSG_WINDOW` : Sets the initial maximum window size for message fetching blocksync request. Set to 10-20 if you have an internet connection with low bandwidth.
* `FULLNODE_API_INFO="TOKEN : /ip4/<IP>/tcp/<PORT>/http"` 可以设置本地的lotus读取远程的 lotus daemon

**Hint**

需要注意的是软件默认的路径是跟执行用户有关系的,而且一般都需要root权限来执行相关文件的创建,如果直接使用 sudo 命令启动,则相关的路径文件默认时在 `/root/`下的.同时由于 sudo 命令由于安全性问题是会清除掉用户设置的环境变量的,这里可以考虑在 `sudoers` 文件中保留相关的环境变量,也可以使用 `sudo -E` 参数来附加当前的用户环境变量. 更建议直接通过 `su -`切换到root

不过最推荐的还是注册成 systemd 服务的方式来进行管理, systemd 加载的环境变量全局文件是 `/etc/systemd/system.conf` 和 `/etc/systemd/user.conf` 中,不过一般都会通过服务注册在 `/etc/systemd/system`下文件中的 `Environment` 来进行配置.如果担心更新lotus重新编译或者执行安装的时候覆盖掉了,可以使用 `systemctl edit service` 来创建 `conf.d/override.conf` 中进行配置