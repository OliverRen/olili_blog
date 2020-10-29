---
title: Multiformats简介
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

项目属于协议工作室的明星项目之一 [项目地址](https://multiformats.io/)

multiformats 是针对未来系统协议设计的自描述格式,这样可以实现互操作性,协议敏捷性

该项目的是一系列协议的集合，它在现有协议基础上对值（值：通常是具有某一项表达意义的）进行自我描述改造，即从值上就可以知道该值是如何产生的。

自描述协议的一些规定:
- 包含值的自描述,不能再带上下文
- 必须避免等待锁,(即从描述数据结构到获取数据值通过本身即可),具有可扩展性
- 它们必须紧凑并且具有二进制打包的表示形式。
- 它们必须具有人类可读的表示形式。

目前有如下 multiformats 协议存在:
*   [multihash](https://multiformats.io/multihash) - self-describing hashes 自描述的hash
*   [multiaddr](https://multiformats.io/multiaddr) 进行中 - self-describing network addresses 自描述的网络地址
*   [multibase](https://github.com/multiformats/multibase) 进行中 - self-describing base encodings 自描述的编码
*   [multicodec](https://github.com/multiformats/multicodec) - self-describing serialization 自描述的序列化
*   [multistream](https://github.com/multiformats/multistream) 弃用 - self-describing stream network protocols 自描述的流网络协议
*   [multigram](https://github.com/multiformats/multigram) 进行中 - self-describing packet network protocols 自描述的分组网络协议

目前 IPFS , libp2p , IPLD 等项目都使用了 multiformats

个人理解: `multiformats` 其实很容易理解,就相当于描述 100块钱,它不光有 100这个数值,同时会有一些附加的定义来帮助你获取关于这100块的额外属性,比如 `somebody wallet1 rmb 100`,即描述了某人的某钱包某币种和价值或数量.这只是内容的定义,接下来还有传输时的定义,使用 `multicodec` 这种自描述的序列化来阐述,比如 `{type:json,datas:somebody wallet1 rmb 100}`,再存储的时候通过 `multibase`来具体到存储时的内容.至于 `multihash`和`multiaddr`是类似于定义某些部分的实现协议,比如 `multihash`就表示了codec是hash,只是不同的hash函数也自描述,而`multiaddr`则是可寻址内容的基础,它主要固定的就是内容类型,即网络地址,实现寻址的这个功能.

我们以multihash为例子来说明什么是multiformats

```
multihash:

升级后的哈希值的结构为：

<hash-func-type><digest-length><digest-value>
<哈希函数类型><摘要长度><摘要值>

我们有一个使用sha2-256函数生成的哈希值（如下），其长度为32（16进制0x20）：
41dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8
规定sha2-256的代表数字为12(16进制)

于是我们得出来新的哈希值：
122041dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8
```