---
title: FileCoin的区块结构tipsets
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

与以太坊一样,该系统通过确保不浪费任何工作量来激励协作并从总体来提高链上的吞吐量.此外,由于tipset要求严格,所有的块都必须来自相同的父块,并且在相同的高度被开采,因此在分叉的情况下,该链可以实现**快速收敛**.

最终, Filecoin 会赋予提供更多存储算力的区块以权重,因为它的核心是存储网络.随着时间的流逝,矿工会聚集在权重最大的链上来创造价值,而权重小的链将成为孤块.		