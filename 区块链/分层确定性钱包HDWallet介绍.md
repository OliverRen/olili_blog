---
title: 分层确定性钱包HDWallet介绍
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

#### 分层确定性钱包 HD Wallet的描述

HD Wallet : Hierarchical Deterministic Wallets

分层确定性的概念早在 BIP32 提案提出。
根据比特币核心开发者 Gregory Maxwell 的原始描述和讨论，Pieter Wuille 在2012 年 02月 11日整理完善提交 BIP32 。直到 2016年 6月 15 日 才被合并到 Bitcoin Core，目前几乎所有的钱包服务商都整合了该协议。BIP32 是 HD 钱包的核心提案，通过种子来生成主私钥，然后派生海量的子私钥和地址

但是种子是一串很长的随机数，不利于记录.所以我们用算法将种子转化为一串助记词 （Mnemonic），方便保存记录，这就是 BIP39，它扩展了 HD 钱包种子的生成算法。

BIP43 对 BIP32 树结构增加了子索引标识 purpose 的扩展 m/purpose'/ \*。 

BIP44 是在 BIP43 和 BIP32 的基础上增加多币种，通过 HD 钱包派生多个地址，可以同时管理主网和测试网的比特币，BIP44 提出了5层的路径建议，如下：`m/purpse'/coin_type'/account'/change/address_index`，BIP44的规则使得 HD 钱包非常强大，用户只需要保存一个种子，就能控制所有币种，所有账户的钱包。

#### HD Wallet的原理简介
1. 生成HD Wallets钱包的时候除了会生成主私钥（master private key）和主公钥（master public key），还会生成一个chain code。
2. 利用master private key + chain code可以得到指定的子私钥（sub private key）；
3. 利用 master public key + chain code可以得到指定的子公钥（sub-public key）；
4. 为了方便起见，HD Wallets引入了extended的概念，以方便使用。即： 扩展型私钥extended private key包含了private key和chain code 扩展型公钥extended public key包含了public key 和 chain code
5. 每个private/public key可以派生出2^32个sub-private/public key,编号用index表示。而所有派生出来的sub-private/public keyy可以继续派生2^32个sub-sub private/public key，一直持续下去…… 这就有了层级（dept）的概念。
6. 编号（index）和层级（dept）就构成了路径（PATH），就像我们的文件夹路径，不过这里的节点名都是数字。m(根节点)的派生出来的子节点的路径是m/0到m/2^32-1，而m/0派生出来的子节点是m/0/0到m/0/2^32-1 。
7. 从上面几点很容易理解，假设要得到m/0/0的公钥，只需要m/0的公钥即可，而非一定需要m的公钥（即主公钥），私钥同理。

#### BIP32 Hierarchical Deterministic Wallets， 就是我们所说的HD钱包

钱包也是一个私钥的容器，按照上面的方法，我们可以生成一堆私钥（一个人也有很多账号的需求，可以更好保护隐私），而每个私钥都需要备份就特别麻烦的。最早期的比特币钱包就是就是这样，还有一个昵称：“Just a Bunch Of Keys(一堆私钥)“为了解决这种麻烦，就有了BIP32 提议： 根据一个随机数种子通过分层确定性推导的方式得到n个私钥，这样保存的时候，只需要保存一个种子就可以，私钥可以推导出来，如图：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/分层确定性钱包HDWallet介绍/2020811/1597114872616.png)

来分析下这个分层推导的过程，第一步推导主秘钥的过程：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/分层确定性钱包HDWallet介绍/2020811/1597114872656.png)

根种子输入到HMAC-SHA512算法中就可以得到一个可用来创造主私钥(m) 和 一个主链编码（ a master chain code)这一步生成的秘钥（由私钥或公钥）及主链编码再加上一个索引号，将作为HMAC-SHA512算法的输入继续衍生出下一层的私钥及链编码，如下图：
![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/分层确定性钱包HDWallet介绍/2020811/1597114872657.png)

衍生推导的方案其实有两个：一个用父私钥推导（称为强化衍生方程），一个用父公钥推导。同时为了区分这两种不同的衍生，在索引号也进行了区分，索引号小于2^31用于常规衍生，而2^31到2^32-1之间用于强化衍生，为了方便表示索引号i’，表示2^31+i。因此增加索引（水平扩展）及 通过子秘钥向下一层（深度扩展）可以无限生成私钥。注意， 这个推导过程是确定（相同的输入，总是有相同的输出）也是单向的，子密钥不能推导出同层级的兄弟密钥，也不能推出父密钥。如果没有子链码也不能推导出孙密钥。现在我们已经对分层推导有了认识。一句话概括下BIP32就是：为了避免管理一堆私钥的麻烦提出的分层推导方案。

#### 扩展密钥

CKD 推导子密钥的三个元素中，其中父密钥和链码结合统称为扩展密钥 (Extended keys)。
包含私钥的扩展密钥用以推导子私钥，从子私钥又可推导对应的公钥和比特币地址；
包含公钥的扩展密钥用以推导子公钥；
扩展密钥使用 Base58Check编码时会加上特定的前缀编码：
包含私钥的前缀为 xprv
包含公钥的扩展密钥前缀为 xpub
相比比特币的公私钥，扩展密钥编码之后得到的长度为 512 或 513 位。

#### 增强扩展密钥

密钥需加强保管以免泄漏，泄漏私钥意味着对应的地址上的币可被转走、泄漏公钥意味着 HD 钱包的隐私被泄漏。增强密钥推导 (Hardened child key derivation) 解决下述两个问题：

1.  虽然泄漏公钥并不会导致丢币，但含有公钥的扩展密钥泄漏会导致以此为根节点推导出来的扩展公钥全部泄漏，一定程度上破坏了隐私性。
2.  如果泄漏扩展公钥（包含有链码）和子私钥，就可以被用来衍生所有的其他子私钥，因为可以通过遍历索引获得子链码。更糟糕的是，子私钥与母链码可以用来推断母私钥。

于此，BIP32 协议把 CKD 函数改为 HKD (hardened key derivation formula) 生成增强密钥推导函数。“打破”了父公钥以及子链码之间的关系。HKD几乎与一般的衍生的子私钥相同，不同的是父私钥被用作输入而不是父公钥。CKD 函数是从扩展密钥的序列号 ( 0x00 到 0x7fffffff)、父链码和父公钥生推导出子链码和子公钥，子私钥从父私钥推导；而 HKD 通过父私钥、父链码和增强扩展密钥的序列号 (0x80000000 到 0xffffffff) 推导增强子私钥和增强子链码。

#### 秘钥路径及BIP44

通过这种分层（树状结构）推导出来的秘钥，通常用路径来表示，每个级别之间用斜杠 / 来表示，由主私钥衍生出的私钥起始以“m”打头。因此，第一个母密钥生成的子私钥是m/0。第一个公共钥匙是M/0。第一个子密钥的子密钥就是m/0/1，以此类推。

BIP44则是为这个路径约定了一个规范的含义(也扩展了对多币种的支持)，BIP0044指定了包含5个预定义树状层级的结构：
`m / purpose' / coin' / account' / change / address_index`

m是固定的, Purpose也是固定的，值为44（或者 0x8000002C）

Coin type
这个代表的是币种，0代表比特币，1代表比特币测试链，60代表以太坊
完整的币种列表地址：https://github.com/satoshilabs/slips/blob/master/slip-0044.md

Account
代表这个币的账户索引，从0开始

Change
常量0用于外部链，常量1用于内部链（也称为更改地址）。外部链用于在钱包外可见的地址（例如，用于接收付款）。内部链用于在钱包外部不可见的地址，用于返回交易变更。 (所以一般使用0)

address_index
这就是地址索引，从0开始，代表生成第几个地址，官方建议，每个account下的address_index不要超过20

根据 EIP85提议的讨论以太坊钱包也遵循BIP44标准，确定路径是 `m/44'/60'/a'/0/n`

a 表示帐号，n 是第 n 生成的地址，60 是在 SLIP44 提案中确定的以太坊的编码。所以我们要开发以太坊钱包同样需要对比特币的钱包提案BIP32、BIP39有所了解。
一句话概括下BIP44就是：给BIP32的分层路径定义规范

#### BIP39 助记词

BIP32 提案可以让我们保存一个随机数种子（通常16进制数表示），而不是一堆秘钥，确实方便一些，不过用户使用起来(比如冷备份)也比较繁琐，这就出现了BIP39，它是使用助记词的方式，生成种子的，这样用户只需要记住12（或24）个单词，单词序列通过 PBKDF2 与 HMAC-SHA512 函数创建出随机种子作为 BIP32 的种子。
可以简单的做一个对比，下面那一种备份起来更友好：

// 随机数种子
090ABCB3A6e1400e9345bC60c78a8BE7  
// 助记词种子
candy maple cake sugar pudding cream honey rich smooth crumble sweet treat
使用助记词作为种子其实包含2个部分：助记词生成及助记词推导出随机种子，下面分析下这个过程。

**生成助记词**
助记词生成的过程是这样的：先生成一个128位随机数，再加上对随机数做的校验4位，得到132位的一个数，然后按每11位做切分，这样就有了12个二进制数，然后用每个数去查BIP39定义的单词表，这样就得到12个助记词，这个过程图示如下：

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/分层确定性钱包HDWallet介绍/2020811/1597114872617.png)

**助记词推导出种子**

这个过程使用密钥拉伸（Key stretching）函数，被用来增强弱密钥的安全性，PBKDF2是常用的密钥拉伸算法中的一种。
PBKDF2基本原理是通过一个为随机函数(例如 HMAC 函数)，把助记词明文和盐值作为输入参数，然后重复进行运算最终产生生成一个更长的（512 位）密钥种子。这个种子再构建一个确定性钱包并派生出它的密钥。

密钥拉伸函数需要两个参数：助记词和盐。盐可以提高暴力破解的难度。 盐由常量字符串 “mnemonic” 及一个可选的密码组成，注意使用不同密码，则拉伸函数在使用同一个助记词的情况下会产生一个不同的种子，这个过程图示图下:

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/分层确定性钱包HDWallet介绍/2020811/1597114872618.png)

校验和地址是EIP-55中定义的对大小写有要求的一种地址形式。

密码可以作为一个额外的安全因子来保护种子，即使助记词的备份被窃取，也可以保证钱包的安全（也要求密码拥有足够的复杂度和长度），不过另外一方面，如果我们忘记密码，那么将无法恢复我们的数字资产。

一句话概括下BIP39就是：通过定义助记词让种子的备份更友好