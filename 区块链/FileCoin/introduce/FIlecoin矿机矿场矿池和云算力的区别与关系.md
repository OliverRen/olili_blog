---
title: FIlecoin矿机矿场矿池和云算力的区别与关系
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

#### 什么是矿机

Filecoin矿机实际上就是一台专业的存储服务器，它主要由机箱、主板、电源、风扇、处理器（CPU）、内存（RAM）、显卡（GPU）、硬盘等部件组成。除了一些辅助部件外，大家最关心的还是CPU、GPU、内存和硬盘等核心部件。随着Filecoin测试网的上线，官方也公布了适用于Filecoin挖矿的基础硬件配置参数，并根据测试的情况多次调整了硬件配置要求。

本质上来说 FIlecoin矿机 依然是一台通用的服务器,如果它不被用来挖矿,依然是可以用来担任其他任务的.

在 Filecoin目录下的 mining-hardware-config 也有官方公布的推荐配置,当然随着测试和参数的调整,其实官方的配置也一直在进行修改,对广大矿工其实也只有参考意义,具体到矿工有可能采用比官方更好的配件,也有可能是轻量级的配件,最终依然是矿工的系统集群和算法优化整体能力的较量.

1. 首先说下硬盘

衡量硬盘的性能指标包括硬盘容量、硬盘速度、硬盘转速、接口、缓存、硬盘单碟容量等。因为Filecoin挖矿的本质还是做存储，从数据安全角度出发所以目前绝大多数矿机厂商采用的都是8T容量的企业级SATA机械硬盘，也有少部分矿机厂商选用的是10T或者12T的，大家基本上都是选择希捷、西部数据或东芝等几个主流品牌。 

也有部分从POC挖矿转型过来挖Filecoin的矿工从成本的角度出发会采用二手硬盘，由于Filecoin挖矿提交时空证明需要的频繁读取硬盘数据，从挖矿的安全性和稳定性上来说，使用二手硬盘存在极大的风险，如果硬盘出现坏盘或者读取速度慢的情况下，很难保障挖矿收益甚至会出现触发惩罚的情况，得不偿失。 

另外，也有部分朋友问为什么不采用固态硬盘而是机械硬盘挖矿，这主要从硬盘容量、成本以及数据安全等方面考虑。1、目前主流固态硬盘容量最大的就是500G或者1T，而机械盘的容量都在10T左右；2、固态硬盘的单T成本是机械硬盘的数倍，从挖矿的投资收益角度来说，选固态硬盘肯定是不划算的；3、由于固态硬盘是芯片级存储，如果硬盘损坏数据丢失，数据将难以恢复。如果数据丢失，会造成难以估量的损失，这也体现了机械硬盘的最大优势。 

2. CPU

高性能的CPU使矿工可以更快地处理数据并更快地生成复制证明，从而在网络上获得更多的有效存储（算力）。目前官方要求最低的CPU配置为8核。同时 AMD 7002 Eypc系列的处理器由于带有 SHA指令集比起 Intel的CPU有巨大的性能优势.

3. GPU

自从2019年11月27日,Filecoin官方技术人员 Why 宣布矿机需要GPU之后,目前主流使用的矿卡都是 2080TI 11G.新推出的 3080在CUDA上有20%的性能优势,但是在散热和外观尺寸上很难塞进传统服务器,(大多数非公版3080都是2.5slot甚至3slot的).

只有当矿工在给定的时间段内赢得块奖励的选举票时，才会在时空的选举证明（“winningPoSt”）期间运行SNARK（零知识证明）。winningPoSt 的时间要求很高，一般的CPU配置难以完成，因此，配置GPU的目的是为了压缩生成 SNARK的时间和空间。每当矿工赢得记账权时，GPU会被用来准确计算出每个周期内的PoStSNARK。生成时空证明所需的GPU算力大小在很大程度上取决于矿工在网络中的有效存储占比。

4. RAM

Filecoin挖矿在复制证明（PoRep）和时空证明（PoSt）的零知识证明（SNARK）生成过程中需要消耗大量RAM（内存），以实现高效的链上提交。目前测试网最低要求封装扇区是32G，内存要求配置是128G以上。一般来说，内存够大可保证足够的读取速度。 

#### 什么是矿场

我们所说的矿场，其实就是将几十、几百甚至几千台矿机（服务器）进行集中运维管理的一个物理空间集合。Filecoin 挖矿由于特有的抵押和惩罚机制，对于挖矿环境要求很高，原则上不允许出现断网断电的情况，否则可能触发惩罚机制，罚扣你所质押的代币，矿工得不偿失。一般自建机房的条件很难达到Filecoin挖矿的要求，所以绝大部分矿工在选择矿场上都会优先考虑IDC机房。 

主要考虑以下几点:

- 双路UPS
- 无尘恒温
- 双上联冗余网络结构
- 用电实施监控
- 消防
- 7\*24\*365
