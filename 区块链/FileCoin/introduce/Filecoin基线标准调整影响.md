---
title: Filecoin基线标准调整影响
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

[toc]

* [Filecoin 基线铸造的重要性](#filecoin-%E5%9F%BA%E7%BA%BF%E9%93%B8%E9%80%A0%E7%9A%84%E9%87%8D%E8%A6%81%E6%80%A7)
* [主网上线的调整](#%E4%B8%BB%E7%BD%91%E4%B8%8A%E7%BA%BF%E7%9A%84%E8%B0%83%E6%95%B4)

#### Filecoin 基线铸造的重要性

Filecon 上的存储需求和供给匹配时，交易订单达成。

在交易前期，客户和矿工都要质押承诺在链上，质押后才能进行订单交易。客户和矿工之间的交易，在订单上链时就被锁定，付款是每个支付周期分批发给矿工。如果矿工在订单完成前终止链存储，那么就会惩罚矿工，将扇区终止费和交易质押都被销毁，剩余的交易付款退回给用户。

已验证用户是指存储了真实有效的数据，为网络作出贡献。

官方鼓励存储真实有效数据，如果矿工自我交易填补存储空间并获得区块奖励，不给予大量的补贴。

许多区块链基于简单的指数衰减模型铸造代币。在这种模式下，一开始区块奖励是最高的，而矿工的参与度通常是最低，因此，在网络生命周期早期进行挖矿就会产生许多币，之后迅速下降。

Filecoin 不能就使用简单的指数衰减模型，这会导致早期矿工为了抢夺代币过度投资硬件，获得区块奖励后迅速退出网络，这会导致用户数据丢失，无法提供长期的存储服务。

基准线是替代了时间的推移来铸造代币，而是随着网络上总存储算力的增加而提高区块奖励。这样既可以保留原始指数衰减模型的结构，又可以在网络启动的最初时段改善它。一旦网络达到基准线，则发出与简单的指数衰减模型相同的累积区块链，但是如果网络未达到预先建立的伐值，则会延迟一部分奖励。

简单来说铸造代币 30% 是使用了简单的指数衰减模型，70% 是使用基线铸造。

#### 主网上线的调整

2020年10月15日晚10点45分 Filecoin 主网随着区块高度148888的到来正式上线.那么为什么最近的区块奖励减少了呢,从区块链浏览器上来看,在2020年10月12日中午时分,区块每份奖励从15FIL下降到10.55FIL,可以认为每天减少了4-5万FIL.主要原因就是 Filcoin 的 baseline 进行了调整,从原来的 1EB(每年200%速率增长) 调整为 2.5EB(100%增长). 这里主要影响的是基线产币部分,30%的简单产币并没有改变.

Filecoin 可由存储矿工挖出的奖励从 14亿Fil 调整为 11亿FIL.首先总体上 Filecoin 和比特币一样,也是限定总量,然后设定周期进行产量减半的. BTC每4年区块奖励减半,Filecoin是每6年减半.不过 Filecoin这里把产币又分成了简单产币和基线产币两种,即我们所说的混合铸造.

1. 流通量

2020年10月31日.从目前的数据来看,矿工每日出产的币占到整体流通性释放的不足1/4左右.当前24小时流通性释放大概是66万左右.也就是说主网上线以来半个月的主要抛压依然是早期投资人.

2. 简单产币

简单供应是为了保证矿工在全网算力未到基线网络标准时，矿工可得到基础的奖励。这部分固定为按照原6年减半衰减的30%

根据释放模型和6年减半的函数,可以计算出首年区块奖励为12184万,每日为33.38万,即每日10万左右的奖励是属于简单产币供应的.

我们都可知tipset是30秒一个,每个tipset中blocks数或者就说奖励份数平均数是4.即当天发放的奖励份数是 `2*60*24*4==11520`.即每份奖励中大约8.68属于简单产币供应.

3. 基线产币

根据释放模型和6年减半的函数计算后剩下的70%的供应量就是基线供应.基线供应部分的释放函数根据定义,可以简单的描述为每天先增加达到基线标准,然后再递减,也就是说在首年算力没有达到baseline的时候,基线释放部分是随着算力增长对基线的比例来释放供应的.

4. 衍生举例

以当前700PB总存量来算 `700/2.5/1024*33.38*0.7=6.389`,结合上面的简单产币可以看出.存储矿工部分也就是16万,就算根据FIP-0004,有25%立即释放,剩下的180day线性释放以一半记,相比流动性释放来说比例不大,尚且不计除头部矿工外,尚需购币进行前置质押.我们可以继续计算.按照当前的32GB sector质押量,1T大约需要6FIL.按照每日10P的算力增长.每天的质押量是大于释放量的.所以就算有 FIP-0004 的提案落实,从存储矿工来计,目前整体依然处于购币时间段.市场博弈是在参与了SR获得大量免费质押的头部矿工和早期投资者之间展开.

5. 下面以具体的图表来演示,图表来源 [ipfs.cn](https://ipfs.cn/news/info-101285.html)

![总供应释放6年减半曲线和简单供应曲线](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604112724886.png)

![基线供应量理论](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604112773917.png)

![基线增长预期](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604112794600.png)

![实际算力增长](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604112808553.png)

极限增长曲线对实际算力增长的约束其实很简单,这里会计算出来一个调整后的T时算力

- 当实际算力在t时刻小于基线算力,取实际算力
- 当实际算力在t时刻大于等于基线算力,取基线算力

![阴影部分会调整后算力](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604112927447.png)

然后需要把调整后算力,计算成 基线网络标准的累计算力,也很简单,我们把这个成为在 t时刻的实际累计算力

![实际累计算力](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604113026251.png)

然后需要将实际累计算力进行基线增长曲线填充,这样的话,就可以简单认为,在整体算力到达2.5EB之前,整个收益由于填充宽度追不上填充速率会得到增加.这里我们会计算出来一个基于 基线标准下的有效时间 `T'` 有效网络时间

![有效基线网络时间](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604113140051.png)

然后把有效网络时间作为参数,代入回一开始的总供应曲线中的基线供应部分,就可以求出真实 t时刻算力对应 基线调整后 T'有效网络时间时的基线供应量了.

![基线供应](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/1604113217072.png)

6. 以下是官方解读基线供应的公式：

- 基线挖矿定义

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/13110310291-d6feb983-9601-4b86-9a93-f663d8ef5b68.jpg)

- 基线挖矿

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/13110310380-6f981339-bd7d-447a-8d85-76d2b75871c2.jpg)

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/13110310455-af66451f-8fd9-4dfa-ae7e-444e7d7c7dfa.jpg)

- 基线网络下块的奖励的计算

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/Filecoin基线标准调整影响/20201031/13110310528-7623c5cd-1246-4d49-b0e3-2c9cbb9aa609.jpg)
