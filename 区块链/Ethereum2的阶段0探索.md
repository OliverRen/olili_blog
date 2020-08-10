---
title: eth2的阶段0探索
tags: 小书匠语法,技术
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

#### eth2参与者的组织

- 验证者 staking validator 
需要质押32ETH 最低16ETH会被退出
区块的提议者 block proposer
见证者 attesters 
成为验证者需要在eth1网络进行抵押,使用deposit文件来创建对应关系,deposit文件是由本地通过一组命令创建的能建立关联并生成eth2私钥文件的程序来创建的.

- 委员会 committee
最少会有128个 staking validator组成,其中一个是 block proposer,其他的是attesters,最多可以有2048个staking validtor
当每个epoch开始前,所有验证者都已经均匀的分配到每个slot中,并先以最少每128位组成委员会,最对组成64个委员会后才开始平均的扩大每个委员会的人数规模.

- 时隙和时段 slot and epoch
一个epoch有32个slot,所以有384秒==6.4分钟
一个slot是12秒

#### 投票==发出见证消息

- 区块投票 LMD GHOST 
选出信标链的slot区块,只有分配到这个slot的委员会成员需要投票

- 检查点投票 Casper FFG 投票
选出上一个检查点,每个时段都需要所有人发起投票

- 见证消息 attestations
是一个validator在每个时段内发出的一个包含了一条 LMD GHOST投票和一条 Casper FFG投票的信息.

- 合理化 justified
一个时段结束的时候，如果其检查点得到了 2/3 的总余额支持（形成了多数票），那么该检查点就被合理化（justified）了。

- 最终化 finalized
如果一个检查点 B 已经得到合理化，其下一个时段的检查点也被合理化了，那么 B 就被敲定（finalized）了

- 签名聚合
委员会机制使得汇总所有的见证人签名、变成单个聚合签名在技术上的优化成为可能。如果同一委员会中的所有验证者都作了同样的 LMD GHOST 和 FFG 投票，则他们的签名可以聚合起来（成为单个签名）。

- 信标链验证者奖惩措施
1.  见证人奖励
2.  见证人惩罚
3.  对质押者来说典型的贬值风险
4.  罚没（slashing）及举报人奖励
5.  区块提议者奖励
6.  怠惰惩罚（inactivity penalty）
根据介绍文章介绍的,好的验证者赚到的和坏的验证者失去的是相等的,那么增发的eth到底去了哪里???

#### 总结

- 验证者干什么
1. 在每一个时段，验证者都被均匀分配到不同时隙中，并进一步划分成相同规模的委员会。验证者只有 1 个应召的时隙，也只会存在于 1 个委员会中。
2. 由阐述1可得,一个时段中的所有验证者，通过集体决策尝试敲定某个检查点；方法是 FFG 投票；
3. 各时隙中的所有验证者，通过集体决策尝试选出信标链的顶端区块：方法是 LMD GHOST 投票；
4 .一个委员会中的所有验证者，通过集体投票尝试将某个分片交联到信标链上。
委员会分为信标链委员会和分片链委员会,我们现在看的都是信标链委员会.
分片委员会即每个slot中每个委员会会尝试交联到一个shard分片上即成为了这个分片这个slot中的分片委员会.

- 验证者怎么分
随着staking validator的增多,启动信标链开始
1. 1->128组成一个最小的委员会
2. 然后委员会数量增多从 1->64 这对应着映射到的shard切片数目是64个,如果验证者数量不足,是会减少委员会的数量的
3. 随着staking validator继续增多,会扩大委员会内成员的规模 128->2048
4. 委员会的规模都是一样大的,所以每次增减都是64的倍数

- 每个epoch可以容纳的验证者数量
在一个时隙 slot =12秒内 会有64个委员会的需要,即信标链和每一个分片链上都需要一个委员会
在一个时段 epoch=32个slot
故一个epoch可以容纳的validator
`2048 staking validator * 64 committee * 32 slot`
相应的需要质押的eth有一亿多,已经超过了目前eth1上的发行总量

- 信标链启动门槛
128 * 2 * 64 需要 16384个staking validator,即128个验证者组成一个委员会,每个slot都需要最少64\*2个委员会
在达到这一初始门槛之前，信标链将不会发放质押奖励。之后每一个epoch结束后都能得到eth奖励.

- 信标链上的验证者们怎么干=>发出见证消息=>即怎么投票
1. 每个epoch开始前一小段时间,就已经把所有验证者们被均匀地分配到32个时隙中，然后进一步分配到同等规模的各委员会中。.这叫做schedual block,那么可以理解最多是有32个schedual block的
2. 所有验证者都要在自己所在的时隙出发出见证消息，指出信标链的顶端。每个委员会都要在自己所在的时隙尝试交联(映射)到特定的某个分片。混洗算法会增减委员会的数量，以保证每个委员会都至少有 128 名验证者。
3. 每个验证者在自己的时隙中可以对自己的顶端块和检查点进行见证,并发出见证消息投票
理想情况下,每个epoch下所有的验证者正好都会分配到了32个slot中,并且正好都在slot中分配到了委员会中,并且都在自己的slot时隙中收到了当前bp的所提议的块(收集了之前slot中委员会,验证者们所发出的见证消息提案),这样该slot中的所有委员会中的所有验证者就会发出相同的见证消息,见证消息被聚合,作为该委员会中的所有提案等待后面的slot中的bp进行收集和打包.
现实情况是,验证者被分配到了slot中组成委员会,有可能有的验证者并没有被加入到委员会中,或者说bp压根就没有在线提议了该块,slot中的验证者也不可能都提议相同的提案,更加不可能都会后续相同的slot尽心打包.所以就会在整个打包过程中出现了一个错综复杂的情况.

> 把validator都划分好之后,不是说他们一定在属于自己时隙的时间内把见证消息被打包,在包含属于自己的时隙和之后一共32个时隙内这个见证消息都有机会被打包,当然被就是后面的slot的bp进行打包了

> 所以虽然每个时段一个validator只有一次投票的权力,但是由于见证消息打包的时机不同,所以有可能一个validator在一个时段内是会有一个前面时段遗留下来的见证消息和本时段内投的见证消息,共2条见证消息被打包的.

> 由此衍生,如果网络很差,见证消息不能被及时的打包,比如选的bp好巧不巧都skip了.或者参与投票的人突然大面积的失联,参与度降低的化,就会导致在一个时段的边界时隙对本时段检查点不能justified合理化,于是前一个时段的检查点也不能被最终化 finalized.直到后面slot继续生成,才会合理化了一个时段,这就有可能会最终化两个时段之前的区块,而不是前一个.必须要求Casper FFG的投票超过2/3

