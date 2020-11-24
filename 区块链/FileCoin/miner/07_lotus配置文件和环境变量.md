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

* `LOTUS_FD_MAX` : 进程的文件描述符的限制
* `LOTUS_JAEGER` : Jaeger URL来发送追踪
* `LOTUS_DEV` : 任何非空字段都可以用来输出更多的日志,开发者较多使用
* `GOLOG_OUTPUT` : go日志的输出格式,可以是 stdout, stderr, file ,多个可以使用 `+` 连接
* `GOLOG_FILE` : go日志输出的文件路径
* `GOLOG_LOG_FMT` : go输出日志的格式 ,可以使用 json,nocolor

以下是专门针对 `lotus daemon` 来进行设置的

* `LOTUS_PATH` : lotus同步链文件的位置 (默认在 `~/.lotus`).
* `LOTUS_SKIP_GENESIS_CHECK=_yes_` : 当你运行一个不同创世块的filecoin网络的时候才需要
* `LOTUS_CHAIN_TIPSET_CACHE` : 设置链存储的tipset缓存的数目,注意一个epoch是有多个tipset的,默认是8192.如果需要缓存更多的查询,可以增加
* `LOTUS_CHAIN_INDEX_CACHE` : 设置epoch索引的缓存大小,默认是32768.如果要向前查很远的区块高度,就需要加高
* `LOTUS_BSYNC_MSG_WINDOW` : 设置区块同步初始化时从网络中获取消息的最大的窗口大小,如果带宽不大,可以设置为10-20.
* `FULLNODE_API_INFO="TOKEN:/ip4/<IP>/tcp/<PORT>/http"` 可以通过这种方式来提供给远程节点访问本机lotus节点rpc api的权限

**Hint**

需要注意的是软件默认的路径是跟执行用户有关系的,而且一般都需要root权限来执行相关文件的创建,如果直接使用 sudo 命令启动,则相关的路径文件默认时在 `/root/`下的.同时由于 sudo 命令由于安全性问题是会清除掉用户设置的环境变量的,这里可以考虑在 `sudoers` 文件中保留相关的环境变量,也可以使用 `sudo -E` 参数来附加当前的用户环境变量. 更建议直接通过 `su -`切换到root

不过最推荐的还是注册成 systemd 服务的方式来进行管理, systemd 加载的环境变量全局文件是 `/etc/systemd/system.conf` 和 `/etc/systemd/user.conf` 中,不过一般都会通过服务注册在 `/etc/systemd/system`下文件中的 `Environment` 来进行配置.如果担心更新lotus重新编译或者执行安装的时候覆盖掉了,可以使用 `systemctl edit service` 来创建 `conf.d/override.conf` 中进行配置