---
title: 4_Lotus的配置文件和环境变量
tags: 
---

**Lotus的配置文件和环境变量**

Lotus的配置文件在 `$LOTUS_PATH/config.toml` ,主要是关于api和libp2p的网络配置,其中api设置的是lotus daemon本身监听的端口,而libp2p则是用在与 Filecoin 网络中的其他节点进行交互的设置,其中ListenAddress和AnnounceAddresses可以显示的配置为自己的固定ip和port,当然需要使用multiaddress的格式.

Filecoin相关目录环境变量, 整个本地数据由这些相关目录 和 wallet 及 chain文件组成

* `~/.lotus ($LOTUS_PATH)`
* `~./lotusminer ($LOTUS_MINER_PATH)`
* `~./lotusworker ($LOTUS_WORKER_PATH)`

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