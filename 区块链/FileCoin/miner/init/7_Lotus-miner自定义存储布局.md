---
title: 7_Lotus-miner自定义存储布局
tags: 
---

**矿工自定义存储布局**

首先要在矿工初始化时,使用 `--no-local-storage`,然后可以指定用于

- seal密封 (建议在ssd上)
- 长期存储的磁盘位置.

你可以在 `$LOTUS_MINER_PATH/storage.json` 中设定,其默认值为 `~/.lotusminer/storage.json`.

使用自定义命令行需要lotus-miner运行,设置后需要重启miner

自定义密封位置: `lotus-miner storage attach --init --seal <PATH_FOR_SEALING_STORAGE>`

自定义存储位置: `lotus-miner storage attach --init --store <PATH_FOR_LONG_TERM_STORAGE>`

列出所有存储位置 : `lotus-miner storage list`

需要注意的是在`lotusminer`目录下的`storage.json`只记录了有多少路径可以被用来进行存储,具体存储目录是否可以seal,是否可以store,以及存储的使用率都是在对应目录下的`sectorstore.json`中描述的