---
title: IPFS和FileCoin的FIL币
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

 ### FileCoin 初步理解

Filecoin作为去中心化存储网络的激励和验证机制,矿工是整个网络的主要参与者,也是网络运营和维护者.所有去中心化网络的前提假设都是节点是自私的,理性的,因为只有基于这样的假设设计的机制才能保证网络的稳定性.在这样的假设下Filecoin利用期望共识(Expectation Consensus)保证区块链网络的共识,利用复制证明(Proof of Replication)和时空证明(Proof of Spacetime)保证了自私矿工的理性决策是做诚实的节点,即只有诚实的行为才能保证收益的最大化.

1. FileCoin Quick View </br>
	- IPFS 是一个协议,现在的挖矿是指 FileCoin 上的挖FIL币
	- 矿机其实就是服务器, 硬件技术含量不高,主要是官方提高了硬件的性能指标
	- 从硬件要求上看,各个矿机供应商大同小异,但是硬件配置其实只占了挖矿收益影响因素约30%的比重,主要影响因素还是各厂家的软件与运维上.
	- 针对不同的角色所需求的硬件能力是不一样的,对于旨在存储数据作为仓储节点的话主要是需要硬盘和打包速度.如果还需要作为一个检索服务的节点的话,那么高性能的带宽传输能力也是必须的.

2. 挖矿密封数据的主要操作 </br>
	- P1 密封预交付阶段1 PoRep复制证明,此阶段受CPU限制,并且是单线程的,故需要强性能的CPU,SHA扩展的==AMD处理器==在很大程度上加快了此过程
	- P2 密封预交付阶段2 波塞冬(Poseidon)哈希算法执行Merkle树生成, 主要使用 GPU
	- C1 密封提交阶段1 执行生成证明所必需的准备工作的中间阶段 CPU运算
	- C2 该密封阶段涉及创建SNARK 将证明在广播之前进行压缩, 30分钟 GPU

3. FileCoin的经济模型 </br>
	20200924 update </br>
	1. 代币释放模型 [资料来源](https://ipfs.io/ipfs/Qmdsip9Kcoyj3J3Fyvjw3wjPCuewkZiGVWpN8rYF3dJKqg/vesting.html) </br>
		* Filecoin 代币总量为 20 亿枚
		* 5％分配给 Filecoin 基金会
		* 10% 用于融资
		* 15% 分配给协议实验室
		* 70% 分配给矿工.其中代币总量的 15%, 3亿枚,将被用作为挖矿储备金,以在未来激励检索矿工和其他类型的矿工,具体使用方式以后由社区通过 Filecoin 改进提案(FIP)共同决定
		* 59.5% 存储矿工能挖到的币,一天释放的币认为是在40万左右

		种种这些措施都能看出,项目方对项目的代币释放计划是经过精心设计的.	这样的设计首先从制度上约束了项目方不能不劳而获在项目没完成之前就得到大量奖励.由于代币是分批释放的,因此项目方必须把项目做好,刺激代币价格上涨,这样自己后续拿到代币时收益才能尽量高.	另外这样的释放计划也尽量防止代币在上线初期像其它很多项目那样被投资者套现抛售而导致价格承受巨大的抛压.	在这个项目中,上线初期没有任何一方手中握有大量筹码,因此市场上的代币货源稀少.

		总的说来,这个项目从代币释放的机制来看项目方可谓是"用心良苦",尽量约束和平衡各方的利益,促使各方一起为项目的长远发展和生态建设努力.
	
	2. 质押 </br>
	为了减轻矿工的负担至最低来满足对质押的多种需求,Filecoin有三种不同的质押机制
		* 存储质押 : 7天的扇区故障费和1个扇区故障检测费(和区块奖励大小挂钩)
		* 共识质押 : 为了实现30%的网络流通量都要被锁定在初始共识质押中. 所以需根据扇区加权字节算力(QAP), 在网络中所占的比例分配给该扇区一小部分质押份额, 初始质押应随时间的减少而减少
		* 区块奖励质押 : 挖到币后先锁仓20天,后180天线性释放.意思就是20天后就能每天平均地拿到挖到的币,180天拿完.因为矿工是一致在挖币的, 所以只需要等待第一个20天, 后面每天都会受到奖励.(update有调整 取消20天锁定)

		其中1+2目前是一个扇区1个FIL.只是极限值,未来只少不多.当然这只是 space race 时的测试值,主网正式上线的时候肯定时会调整的.否则中小矿工或新增矿工很难加入进来.
	
	3. 产币 </br>
		* 简单产币 : 6年减半的那种.这部分占每天释放币的30%.
		* 基准产币 : 总网络达到某一个算力基准时, 才释放币.这个基准一开始为1EB(相当于1000PB),然后每年增加200%,之后5年分别是 : 3EB,9EB, 27EB, 81EB,243EB...全网算力一旦到了这个基准线,就继续释放剩余的奖励币, 这部分占70%

		1. 第一阶段 : 收入以“简单产币”为主,因为全网还没到1EB, 所以30%的币是一挖就有,另外70%得到了基准线后才有.
		2. 第二阶段 : 到了网络基准线了, 这时候整个网络容量很大,可以存很多有用的数据, 我们也能挖到那额外的70%的“基准产币”了,除此之外还会有一部分的存储订单交易收入.
		3. 第三阶段 : 挖币的人越来越多, 区块奖励越来越少,“简单产币”基本上没了, 这就和比特币一样,那么主要收入来源于提供高质量存储和检索服务和交易手续费了

	4. 消减 </br>
		 1. 存储故障消减 storage fault slashing 
		 2. 共识故障消减 consensus fault slashing

		目前讨论的主要还是第一种 存储故障的消减,一般不会有共识故障的消减
		
		1. Fault fees(FF)(故障费用):sector离线的故障费用 区块3.51天的期望收益每天扣除
		2. Sector penalties(SP-FF)(故障检出费用):sector错误的链检出惩罚 你没有declare fault的话会被链上其他矿工出块举报检出,他有奖金你有罚金.
		3. Termination fees(区块中止费用):最终terminate的费用


		WindowPoSt每半小时为一个窗口，一天有48个窗口；同一窗口每天在相同时段都要做WindowPoSt，即周期性执行的任务。

		扇区分为三类，其一称为nonfaulty：从未故障的扇区；其二称为DeclareFault：矿工声明故障的扇区准备修复但尚未修复；其三称为Skipped扇区：网络检查出来的故障扇区且仍处于故障。

		分区的定义：一个分区有2349个扇区，扇区故障会影响整个分区的惩罚。
		
		不会产生费用：如果某一个窗口期内没有查到故障扇区，这个窗口期即使WindowPoSt未按时提交也不会产生任何罚款费用（前提是首次未按时提交）。
		产生费用：在某些分区存在故障扇区时，如果窗口期未提交成功WindowPoSt，这些故障扇区会产生扇区故障费。
		费用统计区间：在每个窗口期，从检测到故障扇区后的第一个deadline开始，将产生扇区故障费。
		
		对于每个通过时空证明的被恢复扇区：目前恢复矿工算力，但扣除扇区故障费罚款；建议恢复算力的同时不收取任何罚款。

对于每个声明为skipped的扇区：当前设计为删除矿工算力，同时网络将该扇区标记为有故障，扣除矿工的扇区故障检测费（SP）+扇区故障费（FF），该窗口期后开始计算扇区故障费；建议删除矿工算力并标记扇区故障，但不收取任何罚款，该窗口期后开始计算扇区故障费。

对于未提交时空证明的分区：当前版本对所有故障扇区进行扇区故障费的惩罚、惩罚分区中每个扇区的扇区故障检测费，并删除分区中所有扇区的算力；建议改为删除分区中所有扇区的算力、惩罚每个故障和正在恢复故障的扇区的扇区故障费，但不会对从未有过故障的扇区做故障费相关惩罚。
		
		
		
		Lotus 0.8.0 实装 FIP-0002 epoch 94000 减少对错过windowPoSt的诚实矿工的处罚
		Lotus 1.1.0 实装 FIP-0004 epoch 170000 出块奖励的25%直接到账不需要锁定 剩下的还是180天线性释放
		
		
		
		
		Filecoin每6年减半并不意味着到第六年才开始递减，而是每一个区块释放的奖励代币都在递减。下面这个是Filecoin区块奖励释放的公式。
		
		
		http://ipfs-file.oss-cn-shenzhen.aliyuncs.com/0/2020-03/09135328337-5161abae-88d7-4064-9f8c-34193fb3634a.jpg
		
		我们可以看到，第一个区块奖励是153.68654133573枚FIL，第二个区块奖励的是153.686524445924枚FIL，每个区块递减为0.00001689枚FIL。到第七年的第一个区块奖励为76.843270667866枚FIL，与第一个区块的数量刚好完成减半。
		
		http://ipfs-file.oss-cn-shenzhen.aliyuncs.com/0/2020-03/09135328369-a4d55f97-e271-4b25-b752-0c09b8f143eb.jpg
		
		按这个公式计算，主网上线后第一天产币量约为44万枚FIL，最后一天产币量约为39万枚FIL，第一年区块奖励总释放量约为1.52亿枚FIL，第一年平均每天产币量约为41.6万枚FIL。

 

Filecoin的区块奖励总共是14亿枚，第一个六年释放7亿枚，第二个六年释放3.5亿枚，第三个六年释放1.75亿枚，预计到第七个六年也就是42年释放完99%的FIL。
		
		
		
		
		
		
		
		
		
		


		同时 FIP-0002对错过 windowPoSt的惩罚进行了减轻,初次错过不会有惩罚,即检出后的第一个deadline才会有故障费用.处理故障sector而不会针对整个partition.
		
		具体的变更如下:
		- DeclareFaultsRecovered 故障恢复后 SubmitWindowedPoSt 原来也需要支付故障费用,现在不需要了
		- 对申明为skipped跳过的活动区块,比如已经active活动的即需要proving的区块进行了removed.原来会扣除算力,标记故障后执行故障检出费用处罚.并会在proving的dealing时发生故障费用.现在的话会扣除算力,标记故障,但不会执行故障检出费用的处罚,当然故障费用还是会扣的
		- 在proving dealine即需要提交windowPoSt是对于没有提交的分区,即检测到有故障了,原来会对所有的故障sector做故障费用处罚,然后不管是错误扇区还是恢复中还是无错误的sector都会有故障检出费用(ps:因为你的确没有提交windowPoSt么),移除partition分区中所有扇区的算力,现在的话,对故障和恢复中的扇区做故障费用处罚,不会再做故障检出费用的处罚了,当然存力依然会被移除
		- 把故障费用,即声明了故障的周期,即每日扣除费用从原来的2.14天期望收益改为3.51天期望收益.为了具有更循序渐进的惩罚结构，官方评估了一个Markov Decision模型，此模型表达了矿工需要为存储合约提供的稳定时长至少要达到60％的存储服务要求时长，只有正常运行时间大于60％时才会产生正的收益期望。基于这一点，扇区故障费常数系数最低需要设置为3.51。



		- 如果区块能恢复,尽快declare fault,然后恢复区块,数据恢复完成,miner可以自动的declare recover然后提交了windowPoSt即可
		- 如果区块真的不能恢复,比如手贱remove了.或者磁盘的确损坏无法恢复,尽快执行terminate,一次性支付区块中止费用,可以少扣很多天的故障费用
		






		* 只要未能提交PoSt证明就会有故障费用的消减 br(3.51 FIP-0002从2.14调整为3.51)
		* 扇区故障费用的消减每天都会扣除直到钱包账户归零或矿工将sector从网络中移除,同时会受到一个扇区终止费的消减
		* 当矿工在WindowPoSt检查发生之前自我声明之后就不会收到后续的一次性的故障检出惩罚
		* 如果矿工自我声明,但是声明的太晚了,则依然会被做对于这个sector的消减惩罚 br(3.5) (update 数值有可能会变更)
		* 如果矿工没有自我声明,然后被区块网络检查错误,则会对整个 partition 都执行消减惩罚 br(3.5) (update数值有可能会变更)
		* 如果矿工的sector被删除的话会收到一个中止费用的消减.
	
	5. 矿工的奖励 </br>
		- Storage fees 存储费用是在达成交易后,作为为客户存储好数据而定期获得被支付的费用,这些奖励会随着时间的推移会自动存入矿工的提款钱包,并在收到后短暂的锁定.
		- Block rewards 区块奖励是给矿工的,这是相当于网络增发出来的FIL币.通过 WInningPoSt来赢得出新块的权力,这个几率和矿工对网络贡献的存储量成正比.在FileCoin网络中,时间被离散成一系列的epoch,每一个epoch开始都有一些矿工被选举出来能挖矿,这些新块组合成了tipset,数量是基于λ= 5泊松分布的随机变量.矿工应该使用策略来决定需要在他们的块中包含什么信息来最大程度的减少重叠,因为每个消息只有第一次执行才会被收取费用.
		- 经过验证的客户,他们得到了一个特殊的存力乘数,即普通密封乘数为1,已经执行过update的为1.1,而经过验证的客户的数据乘数为10.
		- 检索费用

		矿工应在以下3方面努力来挖到更多币
		
		* 性能更高的复制证明算法 : 链上数据更少,验证时间更快,硬件成本更低,不同的安全性假设,从而使扇区生命周期更长,并且无需重新封装即可进行扇区升级.
		* 更具可扩展性的共识算法,可以提供更大的吞吐量并以更短的时间内处理更多的消 息.
		* 更多可以使扇区持续更长的时间的交易订单功能.

		![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020831/1598861682918.png)
		
4. FileCoin矿工的经济效应 </br>
	20200924 add
	
	关于数量级的问题见下表
	
	| **倍数和分数** | **词头** | **符号** | **英文** |
	| --- | --- | --- | --- |
	| 10^24 | 尧（它） | Y | Yotta |
	| 10^21 | 泽（它） | Z | Zetta |
	| 10^18 | 艾（可萨） | E | Exa |
	| 10^15 | 拍（它） | P | Peta |
	| 10^12 | 太（拉） | T | Tera |
	| 10^9 | 吉（咖） | G | Giga |
	| 10^6 | 兆 | M | Mega |
	| 10^3 | 千 | k | kilo |
	| 10^2 | 百 | h | hecta |
	| 10^1 | 十 | da | deca |
	| 10^-1 | 分 | d | deci |
	| 10^-2 | 厘 | c | centi |
	| 10^-3 | 毫 | m | milli |
	| 10^-6 | 微 | μ | micro |
	| 10^-9 | 纳（诺） | n | nano |
	| 10^-12 | 皮（可） | p | pico |
	| 10^-15 | 飞（母托） | f | femto |
	| 10^-18 | 阿（托） | a | atto |
	| 10^-21 | 仄（普托） | z | zepto |
	| 10^-24 | 幺（科托） | y | yocto |

	统一以官方的  AMD Ryzen线程撕裂者3970x,128GB ram,使用 nvidia 2080TI显卡为基准当量, 
	这个配置每天大概可以封装setor的个数在 4-5 个左右 (32GB) , 差不多是140-150GB的总量, 
	如果使用以 AMD Epyc 7402 ,1TB  ram,8T\*2 ssd,使用 nvidia 2080TI或 nvidia 3080显卡, 
	这个配置可以提供基准当量的 12倍左右的并行运行. 可以视作每天可以有1.5-1.8TB的总密封量,

	由币的释放模型可知,存储矿工每天挖出的币总数大概是在 40万枚,基准产币未达到的情况下,只有30%的简单产币即12万枚, 虽然每个 tipsets 设置所有矿工预期赢得选票数的平均值设为 5,(泊松分布)(同时每个矿工的win count也由不同,这是可以有多份的),但目前实际都是偏小,大概在 3.5 左右(块由于网络原因丢了,或者是说孤块没有被网络接受) ,所以我们可以看到每个矿工出块的时候一个 win count的收益大概是12Fil,PS由于丢快和孤块的原因,所以你的绝对爆块率也肯定是小于你全网算力比例的.

	`(3.5 win counts) \* 2tipsets \* 60 minutes * 24hours * 12FIL ==> 120000 FIL`
	
	1. 需要特别注意的几个数据 </br>
		- 算力增长率 : 单位时间算力增长比率；
		- 爆块率 : 矿工获得出块权的比率；
		- 出块率 : 矿工获得出块权并成功出块的比率；
		- 挖矿效率 : 单位算力对应的FIL收益；

		对于一个矿工来说==算力增长率==与密封机器数量,单个扇区密封平均时间相关

		其中单个扇区密封时间与机器配置,代码效率和稳定性相关,这是由于目前官方支持单台机器多个数据密封任务的并行计算,经过证明的扇区空间需要不断的挑战验证,所以算力增长率是一个综合的衡量指标.

		爆块率 : 矿工通过有效算力获得出块权的==理论值==,只与矿工的有效算力成正比；

		出块率 : 矿工通过有效算力获得==出块权==,并成功提交算力证明(WinningPost),然后对消息进行打包才算是完成了一次出块,这个过程需要在一个区块时间(25秒)内完成.

		由于完成一次算力证明,需要数据读取与零知识证明过程(大量计算)需要保证程序的高效性和稳定性,并且要完成对链上消息的打包.这个过程需要完整准确的做完才能获得对应的收益.

		![每tipset执行出块的流程](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600923338207.png)

		![挖矿效率的本质](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600923418890.png)

		我们一直谈论的混杂了法币经济效益的数据 Fil/天\*万元 则是更加复杂的一个数据结合.它是综合了非常庞大的参数计算而成的.这不是简简单单的随口就能报出来的.需要不断的上线运行后才能总结得出.
	
	2. 期望共识的误区 </br>
		矿工通过密封数据形成有效算力,可以通过算力争夺出块权,这个过程类似于POW机制,具体的方式为 :  

		![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600922951377.png)

		其中,h(vrfout)是不可预测随机数,totalPower是全网算力,myPower是当前矿工密封数据的算力,e=5是每个tipset预期出块数量.每个Epoch时,每个矿工可以计算上面公式看是否成立,若满足则矿工获得出块权,成功出块以后可以得到对应的收益.

		 可以看出,当矿工的算力达到全网算力的20%时,矿工一定可以获得出块权；当矿工算力小于20%时,矿工获得出块权的比率与矿工算力占全网算力比率成正比.
		 
	3. 平均区块奖励 这是错误的思路,只是销售用来量化阐述的概念 </br>
		每区块奖励 只是和释放与win count数量有大的相关性.跟你挖了多少没啥大关联

		每TB的平均挖矿收益,这一定是会下降的,但是要反过来看,自己的存力一定是要从整网算力比例去看,而不是单纯看自己的算力总额,诚然只要自己增加了算力总额总是好事,但如果增长率的斜率还追不上整网存力增长速率,也就是自己的算力份额不能保持,有非常大的滑坡,那么自己的总收益就会下降,看平均收益率仅仅是用来计算自己当前期望挖取的Fil币数目,不能展示出来你的趋势,而趋势才是更重要的.
		
	4. 质押费 和 收益额 之间微妙的关系 </br>
		由于目前的FIL流通量严重不足,绝大部分的FIL都要倍用来增加算力进行前置质押,所以前置质押的速率也抑制了总存量的增长,反过来也延缓了单位存力收益额下降的趋势.可想而知,随着比例增长维持在整个网络中一个微妙的平衡时,这个数值也相对的会进行动态平衡.
		
	5. FileCoin大矿工的历史包袱问题 </br>
		从目前看,只要是有能力拿到达标奖励的159个矿工中头部的一些,他们获得的奖励FIL是非常丰厚的.结合 SR2 AMA上官方确定的 封装的算力和质押的Fil币会进行轨道转移映射到主网.他们只要不出太大的问题,在主网后6个月代币释放完成,就算根据目前期权价格做贴现远期也是早就收回了成本.故目前对大矿工来说,他们的急只是主网上线的急,一种托底的急,并不需要长远的去寻求额外的增长点了.

		小矿工方面,由于有100,500,1000的small miner reward存在,他们只要舍得开6个月的机器,也绝对是不会大亏的,特别需要指出的是小矿工一般都是在官方确定了机器配置之后采购的,一般不会有什么太大的前期试错成本.

		较为困难的是中型,什么都是一般般的矿工,技术一般般,机器一般般,封装量一般般.所以收益也是一般般,如果还有试错历史的话,有可能就需要更长的周期来平摊成本,他们一般就没法将成本大量的转移了.
		
5. FileCoin 的区块结构 tipsets </br>
	GHOST 协议让矿工记录过去所有被观察到的区块,以增加其区块链的权重. Filecoin 的共识机制建立在这些综合之上,叫做 tipsets . 如果比特币是靠最长和最有效的链的竞赛来运作,那么 Filecoin 的期望共识就是基于选举,在指定回合中可以选举多个矿工作为领导者.这就意味着可以在每个区块中创建多个有效的同级区块,在每个新的纪元(epoch),新一代的家谱发展出来,称之为 tipset ,这也是我们网络中独特的系统.

	Filecoin 中的区块按纪元(epoch)排序,每个新的区块都引用上一个纪元(epoch)中产生的至少一个块(父块).一个tipset 集是具有相同父块且在同一个纪元(epoch)中挖到的有效区块组成.

	下图,为了简化没有将存储算力考虑在内,用不同颜色表示的3个来自相同祖父块的tipsets.让我们来计算一下这些 tipsets 的权重.

	![在同一个Epoch中3个Tipsets的示例](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918330213.png)

	下面第一个图表中, “**祖块+父块+子块**” 给纪元2中的第一个 tipset 赋予总权重为5.

	![纪元2中的第一个tipset总权重为5](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918422870.png)

	下面第二个tipset拥有总权重为4(一个祖块,两个父块,一个子块).

	![纪元2中第二个tipset权重为4](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918442371.png)

	最后一个tipset(第三张表)拥有总权重为3(一个祖块,一个父块,一个子块)

	![纪元2中第三个tipset权重为3](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918457685.png)

	最后的表提供了该链的全面视角,在纪元2里第一个tipset赢了, 尽管到下一个纪元才会被确认.

	![来自同一纪元的所有tipsets.尽管还没有到下一个纪元被确认,目前权重最大的链是第一个权重为5的tipset](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/IPFS和FileCoin的FIL币/2020924/1600918479137.png)

	与以太坊一样,该系统通过确保不浪费任何工作量来激励协作并从总体来提高链上的吞吐量.此外,由于tipset要求严格,所有的块都必须来自相同的父块,并且在相同的高度被开采,因此在分叉的情况下,该链可以实现“*快速收敛*”.

	最终, Filecoin 会赋予提供更多存储算力的区块以权重,因为它的核心是存储网络.随着时间的流逝,矿工会聚集在权重最大的链上来创造价值,而权重小的链将成为孤块.

----------------
----------------

### Fileoin的基础术语

- **Block和Epoch** </br>
	FileCoin 区块链中的 epoch 是离散为25秒的一个时期,每个 epoch 中,都会选择存储矿工的一个子集,这个子集会通过 Winning-of-Spacetime 来向 Filecoin 添加一个block区块.这个选择被称为选举,一个矿工当选的可能性大致与他们贡献的网络总存储容量占整个 Filecoin 网络的份额成正比.这些矿工提交的区块 block 一起构成了一个 tipset .
- **客户** </br>
	客户付费存储和检索数据.他们可以从可用的存储服务商中进行选择.如果他们想存储私有数据,则需要在将其提交给存储服务商之前对其进行加密.
- **存储矿工** </br>
	存储矿工存储客户的数据以获得奖励.他们决定愿意保留多少空间来存储.在客户和存储矿工达成协议后,矿工有义务继续提供其存储数据的证据.每个人都可以查看证据,并确保存储矿工可信.
- **检索矿工** </br>
	检索矿工根据他们的要求提供客户的数据.他们可以从客户或存储矿工那里获取数据.检索矿工和客户支付很少的费用来交换数据,数据被分成几部分,客户每片段支付很少费用.检索矿工也可以充当存储矿工.
- **片段** </br>
	片段是客户端存储在分散存储网络中的数据的一部分.例如,可以将数据(可能是一个目录)有意地分为许多部分,并且每个部分可以由一组不同的存储矿工存储.这主要取决于矿工采矿采用的sector大小,如32GB或64GB
- **扇区(Sector)** </br>
	扇区是存储矿工提供给网络的一些磁盘空间(可以认为是与特定存储提供者的磁盘空间的特定部分相关联的唯一ID).矿工将客户的物品存放在其所在的区域,并为其服务赚取代币.为了存储片段,存储矿工必须向网络保证其扇区可用.目前sector的大小有32GB和64GB两种.
- **订单和订单簿** </br>
	订单是请求或提供服务的意图声明.客户向市场提交标的订单以请求服务(分别是用于存储数据的存储市场和用于获取数据的检索市场),而矿工则接受订单以提供服务.订单簿是订单的集合. Filecoin 为存储市场和检索市场维护独立的订单簿.
- **承诺aka质押** </br>
	承诺是向网络提供存储(特别是扇区)的承诺.存储矿工必须向 Filecoin 区块链提交质押才能开始在存储市场中接受订单.质押包括质押扇区的规模和存储矿工存放的抵押币.
- **消减(Slash)** </br>
	当某个扇区出现故障的时候,Filecoin 网络会大幅减少本应该存储这个 sector 的存储矿工.并且会减去该矿工的总算力.
- **密封(Seal)** </br>
	密封是 Filecoin 协议的基本构建块之一.这是在一个扇区上执行的计算密集型过程,导致该扇区的唯一表示.这种新表示的性质是基本验证的复制的和验证的时空过程.
- **存储挖矿** </br>
	存储矿工的作用是代表 Filecoin 网络保存文件.存储矿工必须以加密方式证明他们兑现了存储这些文件的承诺–这是通过复制证明(PoRep)和时空证明(PoSt)机制实现的.将存储抵押到 Filecoin 网络本身需要 Filecoin .这些被用作担保,以确保存储矿工履行其合同义务.
- **储存资料** </br>
	在 Filecoin 网络中,数据存储在固定大小的扇区中.通常,存储矿工用代表客户存储的数据填充这些部门,客户通过交易在特定时间段内与存储矿工服务签约.但是,存储矿工并没有被迫进行交易.如果存储矿工没有找到任何有吸引力的交易建议,他们可以选择做出容量承诺,用任意数据填充部门.这使他们可以证明他们正在代表网络保留空间.如果需要,以后可以“升级”为充当容量承诺而创建的部门,以便为将来的交易提供合同存储空间.
- **非交互性零知识证明(zk-SNARK)** </br>
	验证者和证明者之间不需要进行交互,而仅仅只需要持有相对应随机数不同的hash值即可判定证明者的确证明了对应的事物.这里就需要证明者自证即为 WindowsPost
- **存储证明Proof-of-Storage** </br>

	许多区块链网络都以参与者为区块链提供某种价值这一观念为基础-这种贡献很难伪造,但如果确实做出了,则可以进行微不足道的验证.通常认为基于这种方法的区块链需要“ X证明”,其中X是有价值的贡献.Filecoin区块链重视存储容量的贡献；它以新颖的存储证明构造为基础,将其与其他区块链区分开来,而其他区块链在大多数情况下需要贡献计算能力.

	术语,存储证明是指Filecoin协议的设计元素,它使一个人可以保证(达到很高的容忍度)声称声称贡献了给定存储量的参与者确实履行了这一承诺.实际上,Filecoin的存储证明结构提供了更为强大的主张,使人们可以有效地验证参与者是否正在存储特定的数据,而无需一个人自己拥有文件的副本.

	注意 : 这里的“证明”是非正式的用法-通常,这些证明采取概率论证的形式,而不是具体的证明；也就是说,从技术上讲,可以说服其他参与者,一个人没有做出贡献,但是这种可能性微乎其微,几乎不可能
	
	PS : 存储证明是一个泛化的概念,挖矿软件的实际工作是下面的复制证明和时空证明.
- **复制证明Proof-of-Replication(PoRep)** </br>
	一旦该扇区已被填充,PoRep看到存储矿工密封 扇区-密封是计算密集的过程的结果在所述数据的唯一表示(原始表示随后可以通过重构开封).一旦数据被密封,存储矿工 : 生成证明；对证明运行SNARK进行压缩；最后,将压缩结果提交给区块链,作为存储承诺的证明.通过此过程为网络保留的存储称为抵押存储.
- **时空证明Proof-of-Spacetime(PoSt)** </br>
	PoRep完成后,存储矿工必须不断证明他们仍在存储他们承诺存储的数据.这是通过PoSt完成的,PoSt是向存储矿工发出加密挑战的过程,只有直接咨询密封部门才能正确回答.存储矿工必须在严格的时间限制内应对这一挑战；密封的计算难度确保了存储矿工必须保持对密封部门的随时访问和完整性.
- **窗口时空证明(WindowPost)** </br>
	WindowPoSt是一种机制,可用来审核存储矿工的承诺.它看到每个24小时周期分解为一系列窗口.相应地,每个存储矿工的保证扇区集都被划分为子集,每个窗口一个子集.在给定的窗口内,每个存储矿工必须为其各自子集中的每个扇区提交PoSt.这要求可以立即访问每个面临挑战的部门,并将导致将SNARK压缩的证据作为消息以块形式发布到区块链.这样,在每个24小时内至少对一次保证存储的每个sector进行一次审核,并保留一个永久,可验证的公共记录,以证明每个存储矿工的持续承诺.Filecoin网络期望存储文件的持续可用性.未按规定提交WindowPoSt的Sector将导致故障,存储矿工提供的Sector将被削减 -也就是说,他们的抵押品的一部分将被没收,他们的总算力将看到一个减少.在被认为完全放弃存储承诺之前,存储矿工将有有限的时间从故障中恢复.如果需要,存储矿工也将具有先提交有过错的能力,这将减少处罚,但仍必须在合理的时间内解决.
- **赢得时空证明(WinningPost)** </br>
	WinningPoSt是一种机制,通过这种机制可以奖励存储矿工的贡献.在Filecoin网络中,时间离散化为一系列时期-区块链的高度对应于经过的时期数.在每个时间点开始处,存储的矿工的少数当选到矿井新块(Filecoin利用 tipsets,其允许多个块而在相同的高度被开采).每个成功创建区块的当选矿工都将获得Filecoin,并有机会向其他节点收取费用以在区块中包含消息.存储矿工的当选概率与其存储能力相对应.在与基础WindowPoSt相似的过程中,存储矿工的任务是在epoch结束之前提交指定扇区的压缩存储证明.未能在必要的窗口中完成WinningPoSt的存储矿工将丧失开采区块的机会,但不会因未能这样做而受到处罚.
- **存储能力** </br>
	Filecoin存储矿工的能力与选择存储矿工开采区块的可能性相对应,与他们代表网络密封的存储量大致成比例.为了通过简单的容量承诺进一步激励“有用”数据的存储,存储矿工有额外的机会竞争经过验证的客户提供的特殊交易.此类客户在提供涉及存储有意义数据的交易意图方面获得了认证,并且存储矿工为这些交易赚取的权力将通过乘数得到增强.考虑到该乘数后,给定存储矿工拥有的总电量称为质量调整后的 电量.
- **存储市场** </br>
	客户向存储订单簿提交一个投标订单(使用PUT协议,在下一节中说明).客户必须存放订单中指定的费用并指定他们要存储的副本数量.客户可以提交多个订单,也可以在订单中指定复制因子.更高的冗余度(更高的复制因子)导致对存储故障的更高容错率(如下所述).

	==Manage.PledgeSector==
	存储矿工通过通过==Manage.PledgeSector==在区块链中通过质押交易存入抵押品来保证其对网络的存储.抵押品(Fil)在提供服务的时间内存放,如果矿工为其承诺存储的数据生成存储凭证,则将其退还.如果某些存储证明丢失,则会损失一定比例的抵押品.一旦质押交易出现在区块链中,矿工就可以在存储市场中提供其存储服务 : 他们设置价格并将要价单添加到市场的订单簿中.

	==Put.AddOrders==
	一旦质押交易出现在区块链中(在AllocTable中),矿工便可以在存储市场中提供其存储服务 : 他们设置价格并通过==Put.AddOrders==将要价订单添加到市场的订单簿中.

	==Put.MatchOrders==
	当找到匹配的要价和买价单时(通过==Put.MatchOrders==),客户将片段(数据)发送给矿工.

	==Put.ReceivePiece==
	当接收到片段,矿工运行==Put.ReceivePiece==.接收到数据后,矿工和客户都签署了交易订单并将其提交到区块链(在存储市场订单中)

	==Manage.AssignOrders==
	存储矿工的存储分为多个扇区,每个扇区包含分配给矿工的部分.网络通过分配表跟踪每个存储矿工的扇区.此时(签署交易订单时),网络会将数据分配给矿工,并在分配表中记录下来.

	==Manage.SealSector==
	当存储矿工扇区被填充时,该扇区被密封.密封是一种缓慢的顺序操作,它将扇区中的数据转换为副本,该副本是与存储矿工公钥关联的数据唯一物理副本.在复制证明期间,密封是必要的操作.

	==Manage.ProveSector==
	当为存储矿工分配数据时,他们必须反复生成复制证明以确保他们正在存储数据,证明会发布在区块链上,网络会对其进行验证.

	==Δfault==
	如果缺少任何证据或证据无效,则网络会通过存储矿工的抵押币对他们进行惩罚.
	如果大量证据缺失或无效(由系统参数Δfault定义),则网络会认为存储矿工有故障,将订单结算为失败,然后相同新订单重新引入市场.
	如果每个存储该矿工的都无法存储该片段,则该片段将丢失,并且客户将获得退款.
- **检索市场** </br>

	这是一个脱链交换,客户和检索矿工以对等方式彼此发现.一旦客户和矿工就价格达成协议,他们便开始使用小额付款逐笔交换数据和币.

	Get.AddOrders
	检索矿工通过在网络上散播他们的要价单 : 他们设置价格并将要价单添加到市场的订单簿中.

	Get.MatchOrders
	客户向投标市场订单簿提交投标订单.检索矿工检查其订单是否与客户的相应投标订单相匹配.

	Put.SendPiece
	订单匹配后,检索矿工将件发送给客户(矿工发送部分数据,客户发送小额付款).收到件后,矿工和客户都签署了交易订单并将其提交给区块链.

-----------
-----------

### 矿机硬件问题

1. 虽然我们无法提供具体建议,但可以提供一些一般性指导.
	- CPU </br>
		根据经验,具有高时钟频率的多核CPU将加速密封过程,使存储矿工可以更快地将存储到网络上.Protocol Labs自己的测试表明,具有SHA扩展功能的现代AMD处理器具有 比其他处理器更大的优势.
	- GPU </br>
		必须有强大的GPU,才能在所需的时间限制内完成SNARK计算.Lotus当前被设计为支持NVIDIA制造的芯片.我们预计将来还会有其他制造商的支持卡.我们的 基准测试 可帮助您深入了解成功的芯片.
	- RAM </br>
		当前的Filecoin网络仅支持密封32GiB和64GiB扇区.在这些较大的扇区上执行必要的计算需要相应的更多RAM.建议采矿系统至少配备128GiB.
	- 存储 </br>
		选择合适的存储解决方案涉及很多考虑因素,也许最重要的是采矿作业所采用的特定收益模型.存储矿工目前需要保证原始存储量为1TiB(或质量调整后的等同量；对于主网,它将增加到100TiB),以便开采区块,但是超出此要求的因素还有很多,他们可能会觉得有用考虑.
		1. 首先,存储矿工应该牢记数据丢失的严厉处罚；即使翻转一位也可能导致严厉的处罚.结果,存储矿工可能希望考虑开销以实现数据冗余.
		2. 对于试图加入检索市场的存储矿工来说,考虑合并其他存储以准备提供密封数据的“热”副本也可能是明智的.尽管当然可以打开一个扇区以恢复原始数据,但是支持此用例的Filecoin实现将消除这种计算负担(这是Lotus当前正在开发的功能).
		3. 要考虑的另一个考虑因素是Filecoin网络对高可用性的期望.虽然理论上存储矿工应该能够与大多数商品的硬盘,固态硬盘,或其他合适的,非冷存储解决方案,不是所有的存储解决方案可依靠操作时执行最佳参加24 / 7.
		4. 当前,存储矿工还需要足够的空间来存储区块链本身.减少磁盘上区块链的占用空间是Lotus积极开发的一项功能.Filecoin的实现可能还需要额外的磁盘存储,以用于簿记,相当于已抵押存储的一小部分.
		5. 最后,协议实验室在测试中发现,将NVMe存储用作交换空间 可以在具有较少RAM(128GiB)数量的系统中用作补充.否则,存储矿工在某些操作期间可能会遇到内存不足的问题(尤其是密封需要大量工作内存).
	- 网络 </br>
		如果使用分布式Lotus Seal工作人员(请参阅 下面的“ 高级挖掘注意事项”),则建议使用高性能网络(建议使用10GbE +网卡和交换机).使用网络附加存储时,还建议使用高性能网络.

2. 先进的采矿注意事项

	如前所述, Filecoin 存储挖掘主要由与 PoRep 和 PoSt 机制相关的担忧所主导. PoRep 本身是由几个阶段和 Lotus 实施 Filecoin 的便于这些阶段不同的机器代表团使用效率最大化密封工人. Protocol Labs 开发了一个示例架构,旨在利用这些功能进行大规模挖掘.在这里,我们分解了设计类似系统时要考虑的不同瓶颈.
	- 密封预交付阶段1 </br>
		在此阶段,进行PoRep SDR编码.此阶段受CPU限制,并且是单线程的(根据设计,它不适合并行化).该阶段预计需要几个小时的时间,确切的时间取决于要密封的扇形的大小,当然还取决于进行密封的机器的规格.如前所述,Protocol Labs(及其他)发现,具有SHA扩展的AMD处理器在很大程度上加快了此过程.使用时钟频率更高的CPU也会提高性能.
	- 密封预交付阶段2 </br>
		在此阶段,使用波塞冬(Poseidon)哈希算法执行Merkle树生成.此过程主要是受GPU限制的-可以将CPU用作替代方案,但应该会慢得多.使用GPU时,此阶段预计需要45分钟到一个小时.
	- 密封提交阶段1 </br>
		这是执行生成证明所必需的准备工作的中间阶段.它受CPU限制,通常在数十秒内完成.
	- 密封提交阶段2 </br>
		最后,该密封阶段涉及创建SNARK,该SNARK用于在将必需的证明广播到区块链之前对其进行压缩.这是一个GPU密集型过程,预计需要20到30分钟才能完成.

	协议实验室发现将preCommit阶段2,提交阶段1和提交阶段2并置在同一台计算机上是有效的,利用高密度计算机进行preCommit阶段1.但是,preCommit阶段1之间存在大量文件传输以及交付前阶段2；在网络访问速度较慢或使用硬盘而不是固态驱动器的计算机上,这可能会超过其他方面的性能提升.在这种情况下,让所有阶段都出现在同一台机器上可能会更有效率.

	PoSt主要受GPU约束,但可以利用具有许多内核的CPU来加速过程.例如,WindowPoSt当前必须在30分钟的窗口内进行；24核CPU和8核CPU之间的差异可能是在以适当的余量清除该窗口与在狭窄的时间范围内进行清除之间的差异.WinningPoSt是一种强度较低的计算,必须在Filecoin时期的较小窗口(当前为25秒)内完成.

3. 挖矿服务器安装踩坑

	20200927 update
	
	- 服务器主板FPanel没有USB针,所以只有尾部的2个USB口,需要接hub
	- 引导U盘不能量产,所以是USB-ZIP模式,有可能主板比较新已经不支持了.只可以使用USB-HDD或者直接USB光驱引导
	- 设置SATA控制器为AHCI模式,再CSM兼容中关闭secure boot,设置所有板载设备为UEFI启动
	- 服务器的板载VGA如果选择safe graphic模式启动只能使用英文安装,否则后续步骤有按钮被遮挡无法控制选项
	- 创建了EFI分区后,需要手动在下方选择EFI分区来安装boot loader,他不会自动选择
	- Nvidia显卡在ubuntu中不能使用默认的开源驱动 nouveau ,需要手动禁用,否则会有looping登录界面的问题

-----------
-----------

### 显卡驱动和cuda加速

虽然在安装ubuntu的时候我已经勾选了专用软件和显卡驱动的选项,但是由于用到的是 NVIDIA RTX3080,不知道是不是因为太新了,所以并没有检测出来专用驱动,没办法只能自行安装了.

PS : 可以尝试添加PPA源使用apt的安装方式,当然要这个源有方案之后
``` shell
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
```
CUDA工具包其中其实也已经包含了显卡的驱动程序,但是cuda只是一个工具包,他是可以多个版本进行安装的.所以并不一定要安装cuda中的显卡驱动,具体可以看后面的安装过程,需要注意的是 cuda文件名上标记的版本号是支持的最低的显卡驱动的版本,所以如果自己安装显卡驱动的话,是一定需要在这个版本之上的.

- 准备工作 </br>
	建议都使用离线安装的方式,主要还是网络太蛋疼了,显卡驱动几百M,cuda工具包下载的时候有好几G.
	
	显卡驱动 : 从官方网站下载 [download](https://www.nvidia.cn/geforce/drivers/) , 我下载的版本是 NVIDIA-Linux-x86_64-455.23.04.run

	CUDA工具 : [download](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=runfilelocal)
- 禁用开源驱动 nouveau编辑文件 blacklist.conf </br>
	``` shell
	sudo gedit /etc/modprobe.d/blacklist.conf
	blacklist nouveau
	blacklist intel
		options nouveau modeset=0
	# 更新
	sudo update-initramfs -u
	# 重启
	sudo reboot
	# 验证
	lsmod | grep nouveau
	```
- 删除干净历史安装 </br>
	``` shell
	# 驱动如果是 runfile安装的
	sudo NVIDIA-*.run -uninstall
	# 驱动如果是使用apt安装的
	sudo apt remove nvidia*

	# 卸载CUDA,CUDA默认是安装在 /usr/local/cuda-*下的
	sudo uninstall_cuda_*.pl
	```
- 禁用 x window服务 </br>
	网上教程都安装,重启,并停止了 lightdm,其实ubuntu 20.04是使用了gdm的.直接停止后尝试安装,当然如果有用向日葵之类的软件进行远程控制的话,建议切换到lightdm,因为gdm压根就连不上会被中断
	``` shell
	# 更新 apt
	sudo apt update

	# 有可能的 lightdm 然后完成需要重启
	sudo apt install lightdm 
	# 如果安装了lightdm需要关闭
	sudo service lightdm stop
	sudo systemctl stop lightdm

	# 直接关闭gdm
	sudo systemctl stop gdm
	```
- 安装驱动文件 </br>
	进入runfile文件所在的目录,赋予权限,然后开始安装
	``` shell
	sudo chmod a+x NVIDIA*.run

	# NVIDIA*.run -h 可以输出帮助
	# NVIDIA*.run -A 可以输出扩展选项

	# 执行安装
	sudo ./NVIDIA-Linux-x86_64-396.18.run --no-x-check --no-nouveau-check --no-opengl-files 
	# 我们已经自己禁用了x-window
	# 我们已经手动禁用了nouveau
	# 由于ubuntu自己有opengl,所以我们不用安装opengl,否则会出现循环登录的情况
	
	# 安装过程
	大概说是NVIDIA驱动已经被Ubuntu集成安装,可以在软件更新器的附加驱动中找到,我就是因为3080显卡找不到才需要自己安装的,所以直接继续
	The distribution-provided pre-install script failed! Are you sure you want to continue?
	选择 yes 继续.
	Would you like to register the kernel module souces with DKMS? This will allow DKMS to automatically build a new module, if you install a different kernel later?
	选择 No 继续.
	是否安装 NVIDIA 32位兼容库
	选择NO继续
	Would you like to run the nvidia-xconfig utility to automatically update your x configuration so that the NVIDIA x driver will be used when you restart x? Any pre-existing x confile will be backed up.
	选择 Yes 继续
	
	# 安装完成
	# 挂载专用驱动 正常来说会自动挂载
	modprobe nvidia
	检查驱动是否成功
	nvidia-smi
	nvidia-settings 是ui界面的配置

	# 开启图形界面,之前如果安装了lightdm则启动之
	sudo systemctl start lightdm
	sudo systemctl start gdm

	sudo reboot

	# ps : 如重启后出现分辨率为800*600,且不可调的情况执行下面命令
	sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
	sudo touch /etc/X11/xorg.conf
	sudo reboot	
	```

- 安装CUDA </br>
	进入runfile文件目录,添加执行权限后执行安装

	``` shell
	sudo sh ./cuda_*.run --no-opengl-libs
	# 同驱动安装一样,这里也不需要安装opengl库
	
	# 安装过程
	Do you accept the previously read EULA?
	accept
	然后通过界面选择安装项,注意安装的东西
	
	# 安装完成,会输入大概如下的Summary
	===========
	= Summary =
	===========

	Driver : Not Selected
	Toolkit : Installed in /usr/local/cuda-11.1/
	Samples : Installed in /home/rxc/, but missing recommended libraries

	Please make sure that
	 -   PATH includes /usr/local/cuda-11.1/bin
	 -   LD_LIBRARY_PATH includes /usr/local/cuda-11.1/lib64, or, add /usr/local/cuda-11.1/lib64 to /etc/ld.so.conf and run ldconfig as root

	To uninstall the CUDA Toolkit, run cuda-uninstaller in /usr/local/cuda-11.1/bin
	***WARNING : Incomplete installation! This installation did not install the CUDA Driver. A driver of version at least .00 is required for CUDA 11.1 functionality to work.
	To install the driver using this installer, run the following command, replacing <CudaInstaller> with the name of this run file : 
		sudo <CudaInstaller>.run --silent --driver

	Logfile is /var/log/cuda-installer.log
	
	# 安装CUDA工具需要自行设置path,编辑 .bashrc 或者 /etc/profile全局文件
	gedit ~/.bashrc 
	export PATH=/usr/local/cuda-8.0/bin:$PATH
	export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH
	```
- 测试 </br>
	``` shell
	cd /usr/local/cuda-8.0/samples/1_Utilities/deviceQuery
	sudo make -j4
	# 这里-j4是因为是4核cpu,可以4个jobs一起跑
	./deviceQuery
	```

-----------
-----------

### FileCoin的技术学习记录

#### 推荐的学习路径文档列表

当然从头开始看是最完整的,不过我们可以分主次,有一些是越早了解完全越好的

1. FileCoin官方文档 [docs.Filecoin.io](https://docs.Filecoin.io/) ps官方的文档有可能一天都改动好多,看的时候多多刷新

2. [术语表](https://docs.Filecoin.io/reference/glossary)

3. FileCoin官方说明书 [spec.Filecoin.io](https://spec.Filecoin.io/)

4. Go-Filecoin的code review [github go-Filecoin code review](https://github.com/Filecoin-project/go-Filecoin/blob/master/CODEWALK.md)

5. 推荐的客户端工具Lotus [lotus.sh](https://lotu.sh/) , [lotus.github源码](https://github.com/Filecoin-project/lotus)

6. 石榴矿池 6block提供的开源挖矿软件 [6block.lotus-miner](https://github.com/shannon-6block/lotus-miner)

7. FileCoin api驱动的接入工具powergate [powergate](https://docs.textile.io/powergate/)

8. IPFS的集群化管理软件 [Fleek的space-daemon](https://docs.fleek.co/), [源码](https://github.com/FleekHQ/space-daemon)

9. 关于Filecoin的存储证明教学 [proto_school](https://proto.school/tutorials) ,[proto school-verifying storage on Filecoin](https://proto.school/verifying-storage-on-Filecoin/)

10. 仅作为参考的 开始挖矿系列 [Github awesome-Filecoin-mining](https://github.com/bobjiang/awesome-Filecoin-mining)

----------------------

20200921 begin update

#### 使用Lotus接入测试网络即同步数据

- 测试网络信息 [Network Info](https://network.Filecoin.io/#testnet)
- 测试网络的水龙地址 [testnet Filecoin faucet](https://spacerace.faucet.glif.io/)
- apt源选网易或者阿里
- 安装好git后需要设置本地代理	
	```
	git config --gloabl http.proxy=http://xxx:1080
	git config --global https.proxy=http://xxx:1080
	
	git config --global --unset http.proxy
	git config --global --unset https.proxy
	```
- ubuntu 的系统要求	
	`sudo apt update && sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl -y && sudo apt upgrade -y`
- lotus堆rust得依赖,需要 cargo 和 rustc 	
	`snap install rustup` or
	`rustup install stable` or
	`rustup default stable`
- cargo配置代理	
	
	cargo在编译时需要下载,在 `/home/.cargo`创建config文件,其实使用了sudo会在 /root下,cargo在编译的时候也需要下载,config文件中可以指定代理项,或者也可以直接使用国内镜像的方式
	``` cargo.config
	[http]
	proxy = "172.16.0.25:1081"
	[https]
	proxy = "172.16.0.25:1081"
	```	
- 或者对 cargo 配置国内镜像	
	``` shell
	# 安环境变量 设置环境变量 RUSTUP_DIST_SERVER(用于更新 toolchain)
	export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
	以及 RUSTUP_UPDATE_ROOT(用于更新 rustup)
	export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
	
	cargo镜像配置,在/home/.cargo下的config文件中配置如下内容
	[source.crates-io]
	registry = "https://github.com/rust-lang/crates.io-index"
	# 指定镜像 下面任选其一
	replace-with = 'sjtu'
	# 清华大学
	[source.tuna]
	registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
	# 中国科学技术大学
	[source.ustc]
	registry = "git://mirrors.ustc.edu.cn/crates.io-index"
	# 上海交通大学
	[source.sjtu]
	registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"
	# rustcc社区
	[source.rustcc]
	registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
	```	
- lotus 对 golang 得依赖,我们使用golang官网的下载解压方式,需要安装 go 1.14及以上的版本
- GO的代理	
	```	shell
	go env -w GO111MODULE=on
	go env -w GOPROXY=https://goproxy.io,direct
	
	# 设置不走 proxy 的私有仓库,多个用逗号相隔(可选)
	go env -w GOPRIVATE=*.corp.example.com

	# 设置不走 proxy 的私有组织(可选)
	go env -w GOPRIVATE=example.com/org_name
	```	
- 服务器需要安装clang,llvm	,否则在编译lotus的时候会出现 llvm-config 找不到文件的问题
	`sudo apt isntall clang`
	`sudo apt install llvm`
- lotus的中国ipfs代理 `IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"`,或者有良好的网络的时候,也可以使用本地的ipfs节点
- 使用git克隆lotus库
	`git clone https://github.com/Filecoin-project/lotus.git`
- 对支持 SHA 扩展指令的cpu使用环境变量标记 rust FFI [Native Filecoin FFI section](https://docs.Filecoin.io/get-started/lotus/installation/#native-Filecoin-ffi)
	`export RUSTFLAGS="-C target-cpu=native -g"`
	`export FFI_BUILD_FROM_SOURCE=1`
- 编译 lotus
	`sudo make clean deps all`
	`sudo make install`
- 查看可执行文件 ==lotus==	,==lotus-miner==	,==lotus-worker==	应该在 ==/usr/local/bin== 下
- 启动 lotus的守护进程  `lotus daemon`,或者通过命令创建 systemd service
	`sudo make install-daemon-service`
	`sudo make install-chainwatch-service`
	`sudo make install-miner-service` 
	其他有用的工具包括 `lotus-stats`,`lotus-pcr`,`lotus-health`
- 开始同步区块可以使用 `lotus sync status` ,  `lotus sync wait` 来查看同步情况


	[doc 通过lotus 同步区块链](https://docs.filecoin.io/get-started/lotus/chain/#syncing)

	\[Obsolete\ 这是spacerace时的快照,现在需要遵循下面的说明] 需要注意的是目前的区块同步依然是一个比较大的工程,大概实际运行的数据需要1/4的下载同步时间,所以强烈建议通过下载快照来进行同步,[快照地址](https://very-temporary-spacerace-chain-snapshot.s3-us-west-2.amazonaws.com/Spacerace_stateroots_snapshot_latest.car),请直接使用浏览器下载速度会快的多,这个快照每6小时都会进行更新.你可以使用 `lotus daemon --import-snapshot <snapshot>.car` 文件来进行同步数据的导入.
	
	如果不是区块链的浏览器,我们可以使用一个可信的状态快照来进行快速导入,这里不是全部数据
	\# The snapshot size is about 7GiB. This works for mainnet.
	lotus daemon --import-snapshot https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car
	\# An alternative is to download first and use the file
	lotus daemon --import-snapshot <filename.car>
	
	全节点 lotus daemon --import-chain https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/complete_chain_with_finality_stateroots_latest.car
	
	
- 区块数据的快照 snapshot
	`lotus chain export <file>` 导出区块链
	`lotus daemon --import-snapshot <file>` 无链校对导入区块链
	`lotus daemon --import-chain <filename>` 从链上校对导入区块链
	
	创建修剪过的快照可以如下方式创建
	lotus export --skip-old-msgs --recent-stateroots=900 <filename>


	缩减目前的lotus已经同步的链数据,其实就是停掉daemon后,把现在的数据全部删除.然后使用可信快照来进行快速导入
	
	```
	lotus daemon stop;
	rm -rf ~/.lotus/datastore/chain/*
	lotus daemon --import-snapshot https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car
	```
---------------------

#### Lotus的配置文件和环境变量

Lotus的配置文件在 ==$LOTUS_PATH/config.toml== ,主要是关于api和libp2p的网络配置,其中api设置的是lotus daemon本身监听的端口,而libp2p则是用在与网络中的其他节点进行交互的设置,其中ListenAddress和AnnounceAddresses可以显示的配置为自己的固定ip和port,当然需要使用multiaddress的格式.

Filecoin相关目录环境变量, 整个本地数据由这些相关目录 和 wallet 及 chain文件组成
* `~/.lotus ($LOTUS_PATH)`
* `~./lotusminer ($LOTUS_MINER_PATH)`
* `~./lotusworker ($LOTUS_WORKER_PATH)`

* `LOTUS_FD_MAX` : Sets the file descriptor limit for the process
* `LOTUS_JAEGER` : Sets the Jaeger URL to send traces. See TODO.
* `LOTUS_DEV` : Any non-empty value will enable more verbose logging, useful only for developers.

Variables specific to the _Lotus daemon_ 

* `LOTUS_PATH` : Location to store Lotus data (defaults to `~/.lotus`).
* `LOTUS_SKIP_GENESIS_CHECK=_yes_` : Set only if you wish to run a lotus network with a different genesis block.
* `LOTUS_CHAIN_TIPSET_CACHE` : Sets the size for the chainstore tipset cache. Defaults to `8192`. Increase if you perform frequent arbitrary tipset lookups.
* `LOTUS_CHAIN_INDEX_CACHE` : Sets the size for the epoch index cache. Defaults to `32768`. Increase if you perform frequent deep chain lookups for block heights far from the latest height.
* `LOTUS_BSYNC_MSG_WINDOW` : Sets the initial maximum window size for message fetching blocksync request. Set to 10-20 if you have an internet connection with low bandwidth.
* `FULLNODE_API_INFO="TOKEN : /ip4/<IP>/tcp/<PORT>/http"` 可以设置本地的lotus读取远程的 lotus daemon

需要注意的是软件默认的路径是跟执行用户有关系的,而且一般都需要root权限来执行相关文件的创建,如果直接使用 sudo 命令启动,则相关的路径文件默认时在 `/root/`下的.同时由于 sudo 命令由于安全性问题是会清除掉用户设置的环境变量的,这里可以考虑在 `sudoers` 文件中保留相关的环境变量,也可以使用 `sudo -E` 参数来附加当前的用户环境变量. 当然建议直接通过 `su -`切换到root

不过最推荐的还是注册成 systemd 服务的方式来进行管理, systemd 加载的环境变量全局文件是 `/etc/systemd/system.conf` 和 `/etc/systemd/user.conf` 中,不过一般都会通过服务注册在 `/etc/systemd/system`下文件中的 `Environment` 来进行配置.如果担心更新lotus重新编译或者执行安装的时候覆盖掉了,可以使用 `systemctl edit service` 来创建 `conf.d/override.conf` 中进行配置

---------------------

#### Lotus客户端的使用

1. 钱包管理 </br>
	- 查看钱包
		`lotus wallet list` 查看所有的钱包账户
		`lotus wallet default` 查看默认钱包
		`lotus wallet set-default <address>` 设置一个默认钱包
		`lotus wallt balance` 
	- 新建钱包
		`lotus wallet new [bls|secp256k1 (default secp256k1)]` 其中bls会生成 t3长地址(对multisig友好),secp256k1即btc的曲线参数会生成t1的短地址,新创建的钱包会在 ==$LOTUS_PATH/keystore==
	- 执行转账
		`lotus wallet send --from=<sender_address> <target_address> <amount>`
		`lotus wallet send <target_address> <amount>`
	- 导入导出钱包 (你也可以直接copy ~/.lotus/keystore)
		`lotus wallet export <address> > wallet.private`
		`lotus wallet import wallet.private` 

2. JsonRPC的Json Web Token </br>
	
	目前json-rpc接口没有文档,只能看源码

	- EndPoint
		* `http://[api:port]/rpc/v0` http json-rpc接口
		* `ws://[api:port]/rpc/v0` websocket json-rpc接口
		* `http://[api:port]/rest/v0/import` 只允许put请求,需要一个写权限来添加文件

	- 创建JWT
		```sh
		# Lotus Node
		lotus auth create-token --perm admin

		# Lotus Miner
		lotus-miner auth create-token --perm admin
		```

		其中有4种权限
		- `read` - 只能读取
		- `write` - 可以写入,包含 read
		- `sign` - 可以使用私钥签名,包含 read,write
		- `admin` - 管理节点的权限,包含 read,write,sign

	- 发起请求
		``` sh
		# 不需要权限
		curl -X POST \
		 -H "Content-Type:application/json" \
		 --data '{ "jsonrpc":"2.0", "method":"Filecoin.ChainHead", "params":[], "id":3 }' \
		 'http://127.0.0.1:1234/rpc/v0'

		 # 需要权限时,需要传入 JWT
		 curl -X POST \
		 -H "Content-Type:application/json" \
		 -H "Authorization:Bearer $(cat ~/.lotusminer/token)" \
		 --data '{ "jsonrpc":"2.0", "method":"Filecoin.ChainHead", "params":[], "id":3 }' \
		 'http://127.0.0.1:1234/rpc/v0'
		```

3. 使用Lotus存储数据

术语解释 CAR文件 : [Specification : Content Addressable aRchives](https://github.com/ipld/specs/blob/master/block-layer/content-addressable-archives.md)

- 数据必须打包到一个CAR文件中,这里可以使用以下命令 </br>
	`lotus client generate-car <input path> <output path>` </br>
	`lotus client import <file path>`
- 列出本地已经导入或者创建car的文件 </br>
	`lotus client local`
- 数据必须切割到指定的扇区大小,如果你自己创建了car文件,确保使用--czr标志来进行导入	
- 查询矿工,询问价格,开始存储交易(在线交易) </br>
	`lotus state list-miners` </br>
	`lotus client query-ask <miner>` </br>
	`lotus client deal` 
- 扇区文件可以存储的容量,首先计算使用的是1024而不是1000,同时对于每256位 bits,需要保留2位作为证明之需.即32GB的sector可以存储的容量是 2^30\*254\/256 字节
- 离线交易,生成car,然后生成对应所选矿工的piece块的CID,然后提出离线交易 </br>
	`lotus client generate-car <input path>	<output path>` </br>
	`client commP <inputCAR filepath> <miner>` </br>
	`lotus client deal --manual-piece-cid=CID --manual-piece-size=datasize <Data CID> <miner> <piece> <duration>` </br>
	`lotus-miner deals import-data <dealCID> <filepath>` </br>
- 从IPFS中导入数据,首先需要在lotus配置中打开 UseIpfs,然后可以直接将ipfs中的文件进行在线交易 </br>
	`lotus client deal QmSomeData t0100 0 100`
	
4. 使用Lotus检索交易

- 查询自己的数据被哪些矿工存储
	`lotus client find <Data CID>`
- 进行检索交易
	`lotus client retrieve <Data CID> <out file>`
	
--------------------

#### Lotus-miner 官方工具挖矿

20200930 update

1. 按照上述文档完整的安装了 Lotus 套件,并且使用 `lotus daemon` 完成 FileCoin 网络的同步,在中国必须要设置好 go的代理参数和 ipfs代理网关.

2. 设置性能参数环境变量,切记 systemd 服务要单独在服务配置文件中设置
	``` shell
	# See https://github.com/Filecoin-project/bellman
	export BELLMAN_CPU_UTILIZATION=0.875

	# See https://github.com/Filecoin-project/rust-fil-proofs/
	export FIL_PROOFS_MAXIMIZE_CACHING=1 # More speed at RAM cost (1x sector-size of RAM - 32 GB).使用更多的内存来加快预提交的速度
	export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 # precommit 2 GPU acceleration,加快GPU
	export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
	```

3. 设置 lotus node 节点 (当node和miner运行在不同的机器上的时候,详细参看上文的 如何使用 Lotus daemon 或 Lotus-miner监听提供的 json-rpc 接口 章节)
`export FULLNODE_API_INFO=<api_token>:/ip4/<lotus_daemon_ip>/tcp/<lotus_daemon_port>/http`

4. 如果内存过少,则需要添加swap分区,详细可以参看 linux使用文档中的添加swap
	``` shell
	sudo fallocate -l 256G /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	# show current swap spaces and take note of the current highest priority
	swapon --show
	# append the following line to /etc/fstab (ensure highest priority) and then reboot
	# /swapfile swap swap pri=50 0 0
	sudo reboot
	# check a 256GB swap file is automatically mounted and has the highest priority
	swapon --show
	```

5. 查看 lotus-miner显示支持的GPU和benchmark

	[权威列表](https://github.com/Filecoin-project/bellman#supported--tested-cards)

	[使用自定义的GPU](https://docs.Filecoin.io/mine/lotus/gpus/#enabling-a-custom-gpu)

	[bellperson](https://github.com/Filecoin-project/bellman#supported--tested-cards)

	添加环境变量
	`export BELLMAN_CUSTOM_GPU="GeForce RTX 3080:8704"`

	测试
	`./lotus-bench sealing --sector-size=2KiB`
	
	
	
	
	服务器中有多个GPU，选择特定的GPU运行程序可在程序运行命令前使用：CUDA_VISIBLE_DEVICES=0命令。0为服务器中的GPU编号，可以为0, 1, 2, 3等，表明对程序可见的GPU编号。
可以和CPU亲和一样,用逗号隔开
	
	
	
	
	

6. 执行挖矿必须要有 BLS 钱包,即 t3 开头的钱包,默认的创建的 spec256k1 是 t1开头的.

7. 下载 Filecoin矿工证明参数,32GB和64GB时不一样的,强烈建议通过环境变量来设置一个位置保存他们
	
	- filecoin-proof-parameters 默认路径 `/var/tmp/filecoin-proof-parameters/` , `export FIL_PROOFS_PARAMETER_CACHE=/path/to/folder/in/fast/disk`
	- filecoin-parents 默认路径 `/var/tmp/filecoin-parents/` , `export FIL_PROOFS_PARENT_CACHE=/path/to/folder/in/fast/disk2`
	- seal sector的tmp目录 `export TMPDIR=/disk3`

	``` shell
	# Use sectors supported by the Filecoin network that the miner will join and use.
	# lotus-miner fetch-params <sector-size>
	lotus-miner fetch-params 32GiB
	lotus-miner fetch-params 64GiB
	```
	
8. 设置环境变量,类似的如果通过systemctl来启动服务的,也需要再 lotus-miner.service.d 下的override文件进行配置

	``` shell
	export LOTUS_MINER_PATH=/path/to/miner/config/storage
	export LOTUS_PATH=/path/to/lotus/node/folder       # when using a local node
	export BELLMAN_CPU_UTILIZATION=0.875
	export FIL_PROOFS_MAXIMIZE_CACHING=1
	export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1        # when having GPU
	export FIL_PROOFS_USE_GPU_TREE_BUILDER=1         # when having GPU
	export FIL_PROOFS_PARAMETER_CACHE=/fast/disk/folder  # > 100GiB!
	export FIL_PROOFS_PARENT_CACHE=/fast/disk/folder2   # > 50GiB!
	export TMPDIR=/fast/disk/folder3               # Used when sealing.
	```
	
9. 矿工初始化,使用 --no-local-storage可以使得我们之后可以配置特定的存储位置而不是直接执行.配置文件一般是在 ~/.lotusminer/ 或 $LOTUS_MINER_PATH 下. 关于矿工的钱包账户之间的区别请参看 使用官方Lotus-miner执行挖矿的常见问题中的矿工钱包. 注意该命令需要owner发送消息需要代币
`lotus-miner init --owner=<bls address>  --worker=<other_address> --no-local-storage`
	
10. 需要一个公网ip来进行矿工设置.编辑 `$LOTUS_MINER_PATH/config.toml`, 其默认值是 `~/.lotusminer/config.toml`

	``` toml
	[libp2p]
	  ListenAddresses = ["/ip4/0.0.0.0/tcp/24001"] # choose a fixed port
	  AnnounceAddresses = ["/ip4/<YOUR_PUBLIC_IP_ADDRESS>/tcp/24001"] # important!
	```

11. 当的确可以访问该公网ip时,启动 lotus-miner
`lotus-miner run` 或 `systemctl start lotus-miner`

12. 公布矿工地址 `lotus-miner actor set-addrs /ip4/<YOUR_PUBLIC_IP_ADDRESS>/tcp/24001`

13. 其他步骤
	- 配置自定义存储的布局,这要求一开始使用 --no-local-storage
	- 编辑 lotus-miner 的配置
	- 了解什么是关机和重启矿机的好时机
	- 发现或者说通过运行基准测试来得到密封一个sector的时间 ExpectedSealDuration
	- 配置额外的worker来提高miner的密封sector的能力
	- 为 windowPost设置单独的账户地址.

--------------------

####  Lotus-miner 官方工具挖矿进阶设置

0. 防火墙有可能要开启

- 1234 lotus daemon api
- 2345 lotus-miner api
- 24001 lotus-miner work
- ssh

1. 矿工自定义存储布局

	首先要在矿工初始化时,使用 `--no-local-storage`.然后可以指定用于 seal密封 (建议在ssd上) 和长期存储的磁盘位置.你可以在 `$LOTUS_MINER_PATH/storage.json` 中设定,其默认值为 `~/.lotusminer/storage.json`.

	使用自定义命令行需要lotus-miner运行,设置后需要重启miner

	自定义密封位置: `lotus-miner storage attach --init --seal <PATH_FOR_SEALING_STORAGE>`

	自定义存储位置: `lotus-miner storage attach --init --store <PATH_FOR_LONG_TERM_STORAGE>`

	列出所有存储位置 : `lotus-miner storage list`

2. 跑 benchmark 来得知机器封装一个块的时间

	在lotus目录编译 `make lotus-bench`. 运行help可以查看到帮助.大体上命令是这样的

	`./lotus-bench sealing --storage-dir /data/bench --sector-size 32GiB --num-sectors 1 --parallel 1 --json-out `

	``` json
	lotus benchmark result
	{
	  "SectorSize": 34359738368,
	  "SealingResults": [
		{
		  "AddPiece": 870097300267,
		  "PreCommit1": 19675090466708,
		  "PreCommit2": 2160057571490,
		  "Commit1": 44283547951,
		  "Commit2": 5573822383169,
		  "Verify": 28487520,
		  "Unseal": 19463753783027
		}
	  ],
	  "PostGenerateCandidates": 155197,
	  "PostWinningProofCold": 8356540927,
	  "PostWinningProofHot": 4285092397,
	  "VerifyWinningPostCold": 57527449,
	  "VerifyWinningPostHot": 20039908,
	  "PostWindowProofCold": 1077144420908,
	  "PostWindowProofHot": 973861248741,
	  "VerifyWindowPostCold": 6744654407,
	  "VerifyWindowPostHot": 63166446
	}
	```

	单位 unit 应该是 tick = 1\/3600000000000 H,这里是自己测试机的结果

	| 时间 | 操作 | 换算 |
	| --- | --- | --- |
	| 封装 | 封装 | 封装 |
	| 870097300267 | add | 0.2417H = 14M 30S |
	| 19675090466708 | p1 | 5.4653H = 5H 28M |
	| 2160057571490 | p2 | 0.6000H = 36M |
	| 44283547951 | c1 | 0.0123H = 44S |
	| 5573822383169 | c2 | 1.5483H = 1H 32M 53S |
	| 校验 | 校验 | 校验 |
	| 28487520 | verify | 0.03S |
	| 19463753783027 | unseal | 5.4065H = 5H 24M 24S |
	| 出块 | 出块 | 出块 |
	| 155197 | candidate | 几乎为0 |
	| 4285092397 | winning proof hot | 4.28S |
	| 8356540927 | winning proof cold | 8.35S |
	| 20039908 | winning post hot | 0.02S |
	| 57527449 | winning post cold | 0.05S |
	| 时空证明 | 时空证明 | 时空证明 |
	| 973861248741 | window proof hot | 0.2705H	= 16M 14S |
	| 1077144420908 | window proof cold | 0.2992H = 18M |
	| 63166446 | window post hot | 0.06S |
	| 6744654407 | window post cold | 6.74S |

3. 矿工钱包,分开 owner 地址和 worker 地址,为 windowPoSt设置单独的 control 地址.

	矿工钱包可以配置为由几个账户组成,可以使用命令 `lotus-miner actor control list` 查看, 在矿工的init过程中,filecoin网络会给该矿工初始化一个 ==t0== 开头的表示账户id叫做 actor ,actor负责收集所有发送到矿工的币.
		- owner 地址,设计成尽可能离线冷钱包的形式.
		- worker 地址,生产环境中热钱包地址,强烈建议 owner地址和worker地址分开.
		- control 地址

	owner是在矿工初始化的时候设置的,只有如下几个场景需要用到owner地址
		- 改变矿工actor的worker地址.
		- 从矿工actor提取代币
		- 提交 WindowPoSt,如果设置了单独的control地址且有余额的情况下是会使用control地址的.

	worker地址是矿工每日的工作中使用的:
		- 初始化矿工
		- 修改矿工的peer id和multiaddresses
		- 与市场和支付渠道交互
		- 对新区块进行签名
		- 提交证明,声明错误,当control和owner都不能提交的时候也会用worker的余额来提交 WindowPoSt

	control地址是用来提交 WindowPoSt证明的,由于这些证明是提交的消息交易,所以是需要手续费的.但是这个消息比较特殊,因为消减的存在所以提交 WindowPoSt的消息是非常的高价值的.所以使用单独的Control地址来提交这些消息可以避免队首阻塞问题,因为这里也有nonce的概念.control地址可以设置多个.第一个有余额的地址就会被用来提交 WindowPoSt.

	`lotus-miner actor control set --really-do-it t3defg...`
	`lotus state wait-msg bafy2..`
	`lotus-miner actor control list`

	==管理余额==

	`lotus-miner info` 其中 miner 可用余额可以通过 `lotus-miner actor withdraw <amount>` 提取.

4. Lotus Miner 配置参考

	Lotus Miner配置是在初始化 init 步骤之后的,其位置是 `$LOTUS_MINER_PATH/config.toml`, 其默认值是 `~/.lotusminer/config.toml`. 必须重新启动矿机即miner服务才可以使配置生效.

	- API部分 主要使为了worker来使用的,默认使绑定在本地环路接口,如果是多机器则需要配置到使用的网络接口
	- Libp2p部分 这部分是配置miner嵌入的 Libp2p 节点的,需要配置成miner的公共ip和固定的端口
	- PubSub部分用于在网络中分发消息
	- Deal Making部分 用于控制存储和检索交易.注意 `ExpectedSealDuration` 应该等于 `(TIME_TO_SEAL_A_SECTOR + WaitDealsDelay) * 1.5`
	- Sealing部分 即密封部分配置
	- Storage部分 即存储部分,控制矿工是否可以执行某些密封行为
	- Fees费用部分

5. Lotus软件升级

	- 关闭所有的 seal miner 和 worker
	- 关闭 lotus daemon
	- git pull
	- 执行安装 
		``` shell
		export RUSTFLAGS="-C target-cpu=native -g"
		export FFI_BUILD_FROM_SOURCE=1
		git pull
		git checkout <tag_or_branch>
		git submodule update
		make clean deps all
		make install

		#安装服务 可以简单的 make install-all-services
		make install-daemon-service
		make install-chainwatch-service
		make install-miner-service
		# 其他有用的工具包括 `lotus-stats`,`lotus-pcr`,`lotus-health`,`lotus-shed`
		make lotus-stats lotus-pcr lotus-health lotus-shed
		
		make install install-all-services lotus-shed
		```
	- 启动 daemon `systemctl start lotus-daemon`	
	- 启动 miner `systemctl start lotus-miner`
	- 启动 worker `systemctl start lotus-worker`
	- 如果你需要重置所有本地数据,那么需要备份的包括 lotus钱包,node数据和miner配置,然后删除掉 $LOTUS_PATH , $LOTUS_MINER_PATH , $LOTUS_WORKER_PATH

6. 安全的升级和重启miner

	需要考虑的因素包括: 

	- 需要离线多久
	- proving时间期限的分布如何
	- 是否存在交易和检索
	- 是否有正在进行的密封操作

	1. 重启前,建议对lotus程序进行升级,同时下载更新挖矿参数到ssd上 $FIL_PROOFS_PARAMETER_CACHE
	2. 必须确认有时间窗口可以进行重启,使用命令 `lotus-miner proving info` 确认 deadline open有对 current epoch的时间窗口,也可以使用 `lotus-miner proving deadlines` 来确认将来24小时内的分布.
	3. 检查交易 `lotus-miner storage-deals list`, `lotus-miner retrieval-deals list` , `lotus-miner data-transfers list` . 并暂时禁用交易 `lotus-miner storage-deals selection reject --online --offline` , `lotus-miner retrieval-deals selection reject --online --offline`. 当miner 重启完成后,需要使用以下命令恢复交易 `lotus-miner storage-deals selection reset`, `lotus-miner retrieval-deals selection reset`.
	4. 检查当前正在进行的密封行为 `lotus-miner sectors list`

7. 重启 worker

	可以随时重新启动 Lotus Seal Worker,但是他们如果正在执行密封的某一个步骤的话,重新后需要从最后一个检查点重新开始.而且如果是在 C2阶段最多只有3次尝试的机会.

8. 更改存储的位置

	这一部分内容和小节1中的自定义配置存储位置其实差不多,但一般更改存储位置都是在已经上线存续运行的时候,需要在线的更新.

	通过命令 `lotus-miner storage list` 可以查询到当前 lotus-miner 所使用的存储位置,如果你需要对其进行修改,你需要执行以下步骤: 

	- 执行命令拒绝所有存储和检索加以
	- 将原数据复制到新的位置,这涉及到大量的数据迁移,所以在下一步停止miner之后,有可能需要再次同步一下数据,防止文件的状态不一致.
	- 停止miner
	- 编辑 storage.json 文件,这里无法使用命令来进行修改了.直接修改该文件,内容是一个简单的json文件指定了miner可以使用的存储位置,至于存储位置的权重和是否可以seal及storage是在指定位置下有单独的 sectorstorage.json 来进行配置的.
	- 启动miner,如果一切正常的话,原来位置的数据就可以进行删除了

	当然如果你只是简单的想要增加可用的存储空间以增加存力,那么简单的使用在线命令 `lotus-miner storage attach`就可以实现了.可以不用停止 miner.

9. 更改worker的存储位置

	- 停止 worker
	- 迁移数据
	- 对 $LOTUS_WORKER_PATH进行设置
	- 重新启动 worker

	需要注意的是不同线程的 worker 之间的数据是不支持转移和共享的.

--------------------

#### Lotus mine 抵押扇区

抵押扇区是增加有效存力的唯一方式,同时需要根据一个扇区的密封的时间\*1.5来更新配置中的`ExpectedSealDuration`字段.

抵押一个扇区即承诺自己提供一个扇区的容量给网络可用,使用命令 `lotus-miner sectors pledge` , 需要注意的是这会完整的走完整个过程,即肯定是要写入数据的.通过以下命令来进行检查

``` shell
# 查看密封中的工作,这一般会在 $TMPDIR/unsealed 中创建文件
lotus-miner sealing jobs
# 查看密封进度,密封完成时 pSet: NO将变为pSet: YES
lotus-miner sectors list
# 查看密封使用的资源
lotus-miner sealing workers
# 通过log来查看一个扇区密封所需的时间
lotus-miner sectors status --log 0
```

扇区状态 `lotus-miner sectors update-state --really-do-it number state` 

- ComputeProofFailed
- FinalizeFailed
- FaultReported
- FaultedFinal 我知道错了
- Removed 强制移除
- PreCommit1 重新来一次
- PreCommit2
- FinalizeSector
- WaitSeed
- PackingFailed
- RecoverDealIDs
- SealPreCommit1Failed
- PreCommitFailed
- CommitFailed
- Packing AddPiece状态
- PreCommitWait
- SubmitCommit
- Empty
- FailedUnrecoverable
- Faulty
- Committing 提交错误重新提交
- CommitWait
- Proving
- SealPreCommit2Failed
- Removing
- WaitDeals
- DealsExpired
- RemoveFailed
- PreCommitting

升级抵押的扇区以存储与交易相关的实际数据 `lotus-miner sectors mark-for-upgrade <sector number>`

--------------------

#### Lotus miner seal worker

lotus miner本身可以执行密封过程的所有阶段,但是 P1阶段的CPU的密集型任务会影响到后面的 winningPoSt 和 windowPoSt 的提交.所以我们可以创建管道让 worker来负责密封的部分阶段.这部分是关乎于压榨机器性能最重要的部分,涉及到了filecoin的证明系统 [SDR算法](https://github.com/filecoin-project/rust-fil-proofs/) .

一个 worker 最多运行两个任务,每个任务作为一个插槽成为一个 window 窗口. 最终数据取决于可用的cpu核心数和GPU的数量,比如 有多核CPU 和 一个 GPU的机器上:

*   2个_PreCommit1_任务（每个任务使用1个核心） 
*   1个_PreCommit2_任务（使用所有可用核心 只有1个GPU）
*   1个_提交_任务（使用所有可用的内核或使用GPU,C1很短,主要是C2只有1个GPU）
*   2个_解封_任务（每个使用1个核心）

当然实际测试中并不一定需要128GiB内存那么多,当然多总是好的. 使用命令 `lotus-worker run <flags>` 启动worker,需要注意的是不同的 worker 与 miner 要设置不同的 `$LOTUS_WORKER_PATH` 和 `$TMPDIR` 的环境变量,如果一台主机上运行多个 worker ,可以通过 `--listen`指定不同的监听端口,可选的 flags 参数如下

```
   --addpiece                    enable addpiece (default: true)
   --precommit1                  enable precommit1 (32G sectors: 1 core, 128GiB Memory) (default: true)
   --unseal                      enable unsealing (32G sectors: 1 core, 128GiB Memory) (default: true)
   --precommit2                  enable precommit2 (32G sectors: all cores, 96GiB Memory) (default: true)
   --commit                      enable commit (32G sectors: all cores or GPUs, 128GiB Memory + 64GiB swap) (default: true)
```

主miner只专注于执行 WindowPoSt 和 WinningPoSt

单独的CPU任务 P1和unseal分配worker
3个,最多6个p1,6个unseal

单独的GPU任务 P2 C分配worker
1个,最多1个p2,1个c

切记Lotus Miner 配置中的 `MaxSealingSectors`,`MaxSealingSectorsForDeals`控制了可以同时 seal 的 sector 数量. `Storage`配置中如果要将工作全部分配给worker,则需要将对应的设置为false

```
[Storage]
  AllowAddPiece = true
  AllowPreCommit1 = true
  AllowPreCommit2 = true
  AllowCommit = true
  AllowUnseal = true
```

#### 同时运行 miner 和 worker的CPU分配

这里可以对 worker 启用多核心加快 SDR 的效率 .通过设置环境变量 `$FIL_PROOFS_USE_MULTICORE_SDR=1`, 然后通过 `taskset -C` 或 systemd 的中的 cpu亲和度参数来绑定相邻边界的4个核心

启动参数:
`lotus-worker run --listen 0.0.0.0:X --addpiece=false --precommit1=true --unseal=true --precommit2=false --commit=false`

通过 taskset:
```
# Restrict to single core number 0
taskset -c 0 <worker_pid | command>
# Restrict to a single core complex (example)
# Check your CPU model documentation to verify how many
# core complexes it has and how many cores in each:
taskset -c 0,1,2,3 <worker_pid | command>
```

通过systemd:
```
# workerN.service
...
CPUAffinity=C1,C2... # Specify the core number that this worker will use.
...
```

--------------------

#### Lotus miner 故障排除

1. 连接问题

- 使用命令查看节点的nat状态 `lotus-miner net reachability`,这需要你连接到足够的peers才能正确反馈,正常的值是 Public
- 检查连接的对等点 peers ,使用命令 `lotus-miner net peers` , 如果过少,可以使用命令 `lotus-miner net connect <address1> <address2>...` 手动连接 [引导节点](https://github.com/filecoin-project/lotus/blob/master/build/bootstrap/bootstrappers.pi) 确保你们实在相同的网络分支中

--------------------

#### Lotus miner 管理交易

这里把交易的内容抽离出来的主要原因是在 filecoin 整个网络的初期特别是小矿工压根是不会牵扯到存储和检索的交易的,并且就算没有存储和检索的交易,单纯的对垃圾数据进行seal也可以增长有效存力,进行出块.

存储交易的几个主要的阶段分别是 1.数据传输 (transfer 用于在线交易) 或数据导入 (import 用于离线交易); 2.矿工对带有交易数据的sector进行密封; 3.矿工每24小时不间断的在订单时间内对 sector 进行时空证明

1. 启用和禁用存储交易

	miner对交易的启用和禁用可以有两种方法:
		- 配置法,修改 $LOTUS_MINER_PATH/config.toml 文件下的 `[DealMaking]`,然后重新启动 miner
		- 命令法,由于修改配置需要重启 miner,所以较为推荐使用命令法来进行修改,同时命令也会修改文件中的值,如果后续真的重新了矿机,其配置也是生效的

	要禁用存储交易 `lotus-miner storage-deals selection reject --online --offline`,要启用存储交易 `lotus-miner storage-deals selection reset`, 你可以使用命令 `lotus-miner storage-deals selection list
	` 来进行校验

2. 设定存储交易的要价

	达成存储交易一方面需要有需求,另外一方面就是矿工的价格和条件了.这是由矿工进行设置的,只要达成条件,那么矿工就可以自动的接受.这是由命令 `lotus-miner storage-deals set-ask` 来设置的. 举例如下:

	``` shell
	lotus-miner storage-deals set-ask \
	  --price 100000000000 \
	  --verified-price  100000000000 \
	  --min-piece-size 56KiB \
	  --max-piece-size 32GB
	```

	上述例子即矿工将交易价格设置为 每GiB每epoch的价格为 100000000000 attoFIL(即100 nanoFIL).所以如果客户需要存储 5GiB的数据一周,那么就需要支付 `5GiB * 100nanoFIL/GiB_Epoch * 20160 Epochs = 10080 microFIL`.

	矿工可以使用命令 `lotus-miner storage-deals get-ask` 查看自己的要价,使用命令 `lotus-miner storage-deals list -v` 来查看当前正在进行的交易 , 相对的客户可以使用 `lotus client query-ask <minerID>` 来查询指定矿工的要价.

3. 使用过滤器限制交易

	这主要是通过配置文件中 `[DealMaking]` 中的 `Filter` 来实现的,他可以通过一个外部程序或者脚本返回 true 来接受交易,否则就拒绝.

4. 封锁内容

	如果有一些内容不是很好,黄色啊之类的,那么可以通过cid进行阻止他们传入.下列命令接受一个文件,文件内容应该每行包括一个cid.

	`lotus-miner storage-deals set-blocklist blocklist-file.txt`

	可以使用命令 `lotus-miner storage-deals get-blocklist` 查看阻止列表 , 或使用命令 `lotus-miner storage-deals reset-blocklist` 来清除列表

5. 在sector中接受多个交易,操作效率就更高,这减少了密封和验证的操作.这主要是由配置中的 `[Sealing]` 的 `WaitDealsDelay` 来控制的,即等待多少时间.

6. 离线交易的数据导入,使用命令 `lotus-miner deals import-data <dealCid> <filePath>`

7. 检索交易的文档暂缺

--------------------

#### 交易的gas,fee,limit和cap

BaseFee:单位为 attoFIL / gas ,指定了单位gas消耗的 FIL 数量.故每个消息消耗的代币为 BaseFee * GasUsed. 该值根据网络阻塞参数即块大小来自动更新,可以通过命令 `lotus chain head | xargs lotus chain getblock | jq -r .ParentBaseFee` 获取.

消息的发送方还有如下可以设置的参数

GasLimit: gas的数量,指定可以消耗的gas量的上限,如果gas被消耗完,消息将失败,所有操作状态会还原.而矿工的奖励以 GasLimit * GasPremium 计

GasPremium : 以 attoFIL / gas 为单位,表示矿工通过包含该消息可以获得报酬,一般是 GasLimit * GasPremium , 不是 GasUsed 而是 GasLimit, 所以预估准gaslimit也很重要,否则就会有 over estimation burn的预估超出的额外手续费燃烧.

GasFeeCap : 以 attoFIL / gas 为单位,是发送方对消息设置一个花费的天花板.一条消息的总花费为 GasPremium + BaseFee.由于给矿工的赏金 GasPremium 是发送方自己设置的,所以 GasFeeCap本质上用来防止意外的高额 BaseFee

如果BaseFee + GasPremium大于消息的GasFeeCap，则矿工的奖励为GasLimit \*（GasFeeCap-BaseFee）。请注意，如果消息的GasFeeCap低于BaseFee，则矿工出作为罚款.

如果你的交易一直没有矿工进行打包,他就会卡在mpool中,一般是当网络的BaseFee很高时GasFeeCap太低造成的,当然如果网络很拥堵,也可能是GasPremium太低造成的.

你可以使用命令查看本地消息 `lotus mpool pending --local`.

替换 mpool 中的消息,你可以通过推送一个相同 nonce,但是 GasPremium比原始消息大 25%以上的消息.简单的来说,可以使用命令 `lotus mpool replace --auto <from> <nonce>` 达成. 或通过各个参数自行选择 `lotus mpool replace --gas-feecap <feecap> --gas-premuim <premium> --gas-limit <limit> <from> <nonce>` .当然你也可以使用已经本地签名过的消息直接通过 MpoolPush 发送.

--------------------

#### 使用官方Lotus-miner执行挖矿的当前热点问题

这部分内容有时效性,有可能指挥在 spacerace 阶段有效.

1. 在lotus中使用filter只与指定的bot进行deal

	``` toml

	~/.lotusminer/config.toml

	[Dealmaking]
	Filter = <shell command>

	## Reject all deals
	Filter = "false"

	## Accept all deals
	Filter = "true"

	## Only accept deals from the 4 competition dealbots (requires jq installed)
	Filter = "jq -e '.Proposal.Client == \"t1nslxql4pck5pq7hddlzym3orxlx35wkepzjkm3i\" or .Proposal.Client == \"t1stghxhdp2w53dym2nz2jtbpk6ccd4l2lxgmezlq\" or .Proposal.Client == \"t1mcr5xkgv4jdl3rnz77outn6xbmygb55vdejgbfi\" or .Proposal.Client == \"t1qiqdbbmrdalbntnuapriirduvxu5ltsc5mhy7si\" '"
	```

2. 修改miner的gas费率

	``` lotusminer/config.toml
	[Fees]
	MaxPreCommitGasFee = "0.05 FIL"
	MaxCommitGasFee = "0.05 FIL"
	MaxWindowPoStGasFee = "50 FIL"
	```

3. sector升级,再SR中,必须升级一个sector才判定会成功挖矿

	``` sh
	lotus-miner sectors list
	[sector number]: Proving sSet: YES active: YES tktH: XXXX seedH: YYYY deals: [0]

	lotus-miner sectors mark-for-upgrade [sector number]

	24小时内他将从 active: YES 变为 active: NO

	for s in $( seq $( lotus-miner sectors list | wc -l ) ) ; do lotus-miner sectors status --log $s | grep -Eo 'ReplaceCapacity":true' && echo $s; done`

	lotus-miner sectors status --on-chain-info $SECTOR_NUMBER | grep OnTime

	```