---
title: Filecoin消息的gas费用
tags: 小书匠语法
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

#### 基本定义

Filecoin中发送消息的费用由以下三部分组成

- BaseFee的燃烧部分
- GasPremium的矿工奖励部分
- GasLimit高估后额外的OverEstimationBurn高估燃烧部分

即 `GasUsage * BaseFee FIL` + `GasLimit * Gas Premium FIL` + `OverEstimationBurn * BaseFee`

下面将详细阐述这里几个参数的含义

`GasLimit` GasUnit一个数量

发送消息方指定的消耗Gas的最大上限,如果Gas被消耗完,消息将失败

发送方设置

`GasUsage` GasUnit一个数量

一条消息的执行实际消耗的气体量。当前协议在消息确切执行之前不知道会消耗多少气体

网络执行后确定

`BaseFee` 一个GasUnit消耗的Fil数量,是一个单价单位 attoFIL/Gas

该值根据网络阻塞参数即块大小来自动更新,可以通过命令 `lotus chain head | xargs lotus chain getblock | jq -r .ParentBaseFee` 获取

网络自动调整

`GasPremium` 一个GasUnit消耗的Fil数量,是一个单价单位 attoFIL/Gas

表示发送方愿意为打包该消息支付给矿工的最高报酬

具体来说 如果`BaseFee + GasPremium`大于消息的`GasFeeCap`，则矿工的奖励为`GasLimit *（GasFeeCap-BaseFee）`。

请注意，如果消息的GasFeeCap低于BaseFee，则矿工出作为罚款.矿工时不可能打包这样的消息的.

发送方设置

`GasFeeCap` 一个GasUnit消耗的Fil数量,是一个单价单位 attoFIL/Gas

这个参数是对单位GasUnit设置天花板,因为从公式可以看出,单位GasUnit消耗就是 `BaseFee`+ `GasPremium`,同时由于GasPremium 是发送方自己设置的,所以 GasFeeCap本质上用来防止意外的高额 BaseFee

发送方设置

`OverEstimationBurn` GasUnit一个数量

当 `GasLimit` 和 `GasUsage` 之间差距过大的时候,会造成高估的额外gas燃烧.这是一个数量单位,单价是 `BaseFee`

#### 具体运算规则

总结就是发送方设置的都是最大值,最大的gas消耗数量,给矿工的最大奖励价格,与`BaseFee`结合后的单价上限.具体最后清算都是由网络来清算的.网络会有限保证`BaseFee`一定会被燃烧,然后有多的再保证矿工的奖励,如果你gas数量估算高了,还要发送方额外的燃烧高估费用.

1. 一条消息如果要被打包,燃烧的`GasUsage * BaseFee FIL`是最优先的,所以如果 `GasFeeCap`< `BaseFee`,那么意味着打包的矿工还要贴钱,也就是说这样的消息是绝对不可能被矿工打包的.`BaseFee` 部分通俗的讲就是你发送交易都要给整个网络的运行付钱,这是进入燃烧地址的,会造成整个网络中代币的紧缩,这个是网络自动调整的.
2. 矿工在执行消息的时候能获得的奖励是以 `GasLimit` 来计算的,就算是消息执行的 `GasUsage`已经达到 `GasLimit`,消息没有执行完,失败了所有状态会还原,矿工也依然会获得`GasLimit * Gas Premium FIL`的部分.
3. 发送消息的人支付了`BaseFee`燃烧和`GasPremium`的矿工打包费用后,还有一个`GasLimit`高估的燃烧费用,所以预估准gaslimit也很重要,意思就是你不是高估了么,就要额外罚款.

 `OverEstimationBurn`高估费用可以从 [源码](https://github.com/filecoin-project/lotus/blob/v0.10.0/chain/vm/burn.go#L38) 处可以了解到

``` golang
func ComputeGasOverestimationBurn(GasUsage, gasLimit int64) (int64, int64) {
	if GasUsage == 0 {
		return 0, gasLimit
	}

	// over = gasLimit/GasUsage - 1 - 0.1
	// over = min(over, 1)
	// gasToBurn = (gasLimit - GasUsage) * over

	// so to factor out division from `over`
	// over*GasUsage = min(gasLimit - (11*GasUsage)/10, GasUsage)
	// gasToBurn = ((gasLimit - GasUsage)*over*GasUsage) / GasUsage
	over := gasLimit - (gasOveruseNum*GasUsage)/gasOveruseDenom
	if over < 0 {
		return gasLimit - GasUsage, 0
	}

	// if we want sharper scaling it goes here:
	// over *= 2

	if over > GasUsage {
		over = GasUsage
	}

	// needs bigint, as it overflows in pathological case gasLimit > 2^32 GasUsage = gasLimit / 2
	gasToBurn := big.NewInt(gasLimit - GasUsage)
	gasToBurn = big.Mul(gasToBurn, big.NewInt(over))
	gasToBurn = big.Div(gasToBurn, big.NewInt(GasUsage))

	return gasLimit - GasUsage - gasToBurn.Int64(), gasToBurn.Int64()
}
```

这里有两个系数 `gasOveruseNum=11` 和 `gasOveruseDenom=10` 前者是分子,后者是分母.

如果使用的gas为0,应该是非法的,所以将`GasLimit`作为罚款燃烧

如果 `GasLimit` 预估没有超过 `GasUsage`的 10%,则不会造成款燃烧.

如果 `GasLimit` 超过 `GasUsag`e 的 10% - 110% 燃烧部分差不多是超出的 `overgas(overgas/GasUsage-1/10)`作为罚款燃烧,即`overgas`乘以超出的比例扣掉10%.

如果 `GasLimit` 超过 `GasUsage` 的110% 则是 `overgas`作为罚款燃烧

总结,你超出了`GasUsage`再10%没事,再多就全部交出来作为高估罚款

```
GasLimit=120,GasUsage=100 试算燃烧数量
over=120-100*11/10=10
gasToBurn=120-100=20=>20*10=200=>200/100=2

GasLimit=200,GasUsage=100 试算燃烧数量
over=200-(11*100)/10=90
gasToBurn=200-100=100=>100*90=9000=>9000/100=90

GasLimit=210,GasUsage=100 试算燃烧数量
over=210-(11*100)/10=100
gasToBurn=210-100=110=>110*100=11000=>11000/100=110

GasLimit=220,GasUsage=100 试算燃烧数量
over=220-(11*100)/10=110=>100
gasToBurn=220-100=120=>120*100=12000=>12000/100=120

GasLimit=500,GasUsage=100
over=500-100*11/10=390=>100
gasToBurn=500-100=400=>400*100=40000=>40000/100=400
```

#### TIPS

如果你的交易一直没有矿工进行打包,他就会卡在mpool中,一般是当网络的BaseFee很高时GasFeeCap太低造成的

当然如果网络很拥堵,也可能是GasPremium太低造成的.

你可以使用命令查看本地消息 `lotus mpool pending --local`.

替换 mpool 中的消息,你可以通过推送一个相同 nonce,但是 GasPremium比原始消息大 25%以上的消息.

简单的来说,可以使用命令 `lotus mpool replace --auto <from> <nonce>` 达成. 

或通过各个参数自行选择 `lotus mpool replace --gas-feecap <feecap> --gas-premuim <premium> --gas-limit <limit> <from> <nonce>` .

当然你也可以使用已经本地签名过的消息直接通过 MpoolPush 发送.

#### 手续费估算

1. 整体情况

本计算数据为当前已经发生的最极端的恶劣情况,目前属于上限,但不排除会有更加高的basefee

以 2020年12月3日 13点为准

basefee为 4 nanoFil

总算力为 1215PB 日增 14PB

由于单扇区最多2349个 sector,所以建议计算单位为 32G\*2349 即 73T以上,我们以 1PB来计算

计算周期为 360 天

2. 收益部分

32G sector 预估360天收益为 1.927 Fil

- 其中360天可以解锁的为 1.275 Fil
- 锁定部分为 0.652 Fil

则 1PB为 32768 个sector,预估360天收益为 63144 Fil

- 其中360天可以解锁的为 41779 Fil
- 锁定部分为 21365 Fil

3. 质押部分

由于存力存在时质押不变,认为时账面价值,目前质押 32G sector 质押为 0.234 Fil

则 1PB 为 32768 个sector,总质押为 7668 Fil

4. 手续费纯支出部分

手续费主要包含两部分

- 上链的2个质押消息 (preCommit , proveCommit),质押消息每个 sector 各发一个
- 每日时空证明 (winPoSt) ,每天都需要做

- 其中 preCommit 平均为 0.0567 Fil
- 其中 proveCommit 平均为 0.1419 FIL	
- 其中 winPoSt 平均为 1.0778 FIL

计算如下:

上链消息消耗部分为 `32768*(0.0567+0.1419)` =6507 Fil

每日时空证明消耗部分为 `(32768/2349)*1.0778*360`= 5413 Fil

5. 存储订单部分

由于目前官方对 CC sector (垃圾数据块) 和有存储订单的块 gas消耗上不一样,前者大概时后者的3倍,但目前来说接受存储订单的块依然时亏本的,除非提高非常多的订单要价.

6. 总结

以当前迅速封装1PB,然后保持360天的情况来看

投入为:

质押的 7668 + 手续费燃烧的 6507 + 5413 

收益为: 

41779 释放 + 21365 锁定

故一年后应该是 

- 完全燃烧的 6507 + 5413 = 11920 已覆盖
- 到手净收入  41779 -11920 = 29859 Fil
- 账面剩余锁定中的 21365 + 7668 = 29033 Fil