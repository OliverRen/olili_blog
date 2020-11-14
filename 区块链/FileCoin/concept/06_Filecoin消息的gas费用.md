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

**BaseFee**

单位为 attoFIL / gas ,指定了单位gas消耗的 FIL 数量.故每个消息消耗的代币为 BaseFee * GasUsed. 

该值根据网络阻塞参数即块大小来自动更新,可以通过命令 `lotus chain head | xargs lotus chain getblock | jq -r .ParentBaseFee` 获取.

消息的发送方还有如下可以设置的参数

**GasLimit**

gas的数量,指定可以消耗的gas量的上限,如果gas被消耗完,消息将失败,所有操作状态会还原.而矿工的奖励以 GasLimit * GasPremium 计

**GasPremium**

以 attoFIL / gas 为单位,表示矿工通过包含该消息可以获得报酬,一般是 GasLimit * GasPremium , 不是 GasUsed 而是 GasLimit, 所以预估准gaslimit也很重要,否则就会有 over estimation burn的预估超出的额外手续费燃烧. 这受 GasFeeCap 的限制，BaseFee 具有更高的优先级。

**GasUsage**

一条消息的执行实际消耗的气体量。当前协议不知道消息在执行之前将确切消耗多少气体。这以 GasUnit 为单位。

**GasFeeCap**

以 attoFIL / gas 为单位,是发送方对消息设置一个花费的天花板.一条消息的总花费为 GasPremium + BaseFee.由于给矿工的赏金 GasPremium 是发送方自己设置的,所以 GasFeeCap本质上用来防止意外的高额 BaseFee

------------------

如果BaseFee + GasPremium大于消息的GasFeeCap，则矿工的奖励为GasLimit \*（GasFeeCap-BaseFee）。请注意，如果消息的GasFeeCap低于BaseFee，则矿工出作为罚款.

如果你的交易一直没有矿工进行打包,他就会卡在mpool中,一般是当网络的BaseFee很高时GasFeeCap太低造成的,当然如果网络很拥堵,也可能是GasPremium太低造成的.

你可以使用命令查看本地消息 `lotus mpool pending --local`.

替换 mpool 中的消息,你可以通过推送一个相同 nonce,但是 GasPremium比原始消息大 25%以上的消息.简单的来说,可以使用命令 `lotus mpool replace --auto <from> <nonce>` 达成. 或通过各个参数自行选择 `lotus mpool replace --gas-feecap <feecap> --gas-premuim <premium> --gas-limit <limit> <from> <nonce>` .当然你也可以使用已经本地签名过的消息直接通过 MpoolPush 发送.