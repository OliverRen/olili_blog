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

项目属于协议工作室的明星项目之一,[项目地址](https://multiformats.io/)

multiformats 是针对未来系统协议的自描述格式,这样可以实现互操作性,协议敏捷性,并帮助我们避免被循环锁入.

自描述协议的一些规定:
- 包含值得自描述,不能再带上下文
- 必须避免等待锁并有可扩展性
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