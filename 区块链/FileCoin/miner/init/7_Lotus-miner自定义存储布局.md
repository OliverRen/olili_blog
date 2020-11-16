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

**更改存储的位置**

这一部分内容其实和自定义配置存储位置其实差不多,但一般更改存储位置都是在已经上线存续运行的时候,需要在线的更新.

通过命令 `lotus-miner storage list` 可以查询到当前 lotus-miner 所使用的存储位置,如果你需要对其进行修改,你需要执行以下步骤: 

- 执行命令拒绝所有存储和检索加入
- 将原数据复制到新的位置,这涉及到大量的数据迁移,所以在下一步停止miner之后,有可能需要再次同步一下数据,防止文件的状态不一致.
- 停止miner
- 编辑 storage.json 文件,这里无法使用命令来进行修改了.直接修改该文件,内容是一个简单的json文件指定了miner可以使用的存储位置,至于存储位置的权重和是否可以seal及storage是在指定位置下有单独的 sectorstorage.json 来进行配置的.
- 启动miner,如果一切正常的话,原来位置的数据就可以进行删除了

当然如果你只是简单的想要增加可用的存储空间以增加存力,那么简单的使用在线命令 `lotus-miner storage attach`就可以实现了.可以不用停止 miner.