---
title: IPLD简介
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

本文会以从抽象到实现,从起源到发展,有可能开始的部分会比较难以理解,请继续往下看后回头即可理解.

IPLD不仅是IPFS项目的一部分，而是一个单独的项目。要理解它在分散世界中的重要性，我们必须理解语义网和关联数据的概念。

## web3.0中的语义网和关联数据

语义网或关联数据是Tim Berners Lee先生在2001年发表于“科学美国人”的一篇开创性文章中创造的一个术语。Berners Lee阐述了一个万维网数据的愿景，即机器可以独立于人类进行处理，改变我们日常生活的新服务。虽然文章中的大多数网页包含可由软件代理分析和采取行动的结构化数据的愿景尚未实现，但语义网已经成为一个越来越重要的平台，通过不断发展的社区使用国际语义Web标准，实现数据共享关联数据。

目前有许多使用语义Web技术和关联数据的例子，以便在整个网络上以灵活和可扩展的方式共享有价值的结构化信息。语义Web技术被广泛用于生命科学中，通过在多个数据集中找到路径来促进药物发现，这些数据集通过与每个数据相关联的基因显示药物和副作用之间的关联。

“纽约时报”发表了150多年来作为关联数据开发的大约10,000个主题标题的词汇，并将覆盖范围扩大到大约30,000个主题标签; 他们鼓励开发使用这些词汇表的服务，并将它们与其他在线资源相关联。

在英国广播公司使用关联数据使搜索引擎更容易找到内容，并通过社交媒体更多地链接; 从音乐或体育等领域的补充资源中添加其他上下文，并将链接和编辑注释传播到其原始条目目标之外，以便在其他上下文中提供相关信息。

美国data.gov网站的主页声明：“随着链接文档网络的发展，包括链接数据网络，我们正致力于最大限度地发挥语义Web技术的潜力，实现链接开放政府数据的承诺”，并且所有社交媒体网站都使用关联数据来创建人员网络，以使他们的平台尽可能具有吸引力。

更多的内容可以参阅扩展阅读的 语义网和关联数据 一文.

Tips:个人理解,说点简单直白的,我们平日接触的社交网络,抖音,PDD都通过拉好友,通讯录,linkin通过职场关联建立起了人员网络,这才使得他们的平台更加具有竞争力,或者说其内容才有了可看性.再比如说我需要去北京,正常我都是搜一下飞机票或者火车票,但现在我只需要一个目的地,剩下的会通过网络中的关联数据,我的各种旅游应用授权,搜索对应的航空,铁路,轮船等行程信息,根据我需要的时效和价格来反映出来最优的选择.语义的应用不应该仅仅是用相同属性的数据进行简单的关联,而是更多的数据进行深层的关联解析后给出优化的选择结果.我们使用关联数据也不仅仅是可以描述一类名词或是相似的物品,而是可以在不同的系统中相互定义来互通数据.

## IPLD概念

IPLD:InterPlanetary Linked Data 星际关联数据.

IPLD是内容可寻址的网络的`数据模型`

IPLD是一个独立的生态系统，它可以适用于所有以哈希值为寻址手段的协议。

IPLD是一套标准，它定义了如何创建去中心化的数据结构，使这些数据结构可以被寻址和关联。IPLD定义的数据结构对数据的重要性就相当于URL对HTML网页和链接的重要性。

它使我们能够将所有散列链接的数据结构视为统一信息空间的子集，从而将所有将具有散列数据的链接的数据结构统一为IPLD实例。

换句话说，IPLD是用于创建可普遍寻址和链接的分散式数据结构的一组标准和实现。这些结构使我们可以对HTML网页的URL和链接进行数据处理。

有非常多可以用于 IPLD 的库,甚至我们自己就可以定义创建一些库来描述自己的数据.

Tips:个人理解,也是说的简单直白一点,目前使用hash来对内容进行寻址已经是分布式系统中的一种普遍做法,于是就通过 `multihash` 来hash数据,通过 CID对 `multihash`的扩展我们就可以用一个简单的字符串描述了一个通过何种解析通过特定的hash算法表示的某个数据

通过 `multiformats` 可以对具体的数据进行描述(这包含了multihash,multicodecs,multiaddrs,不过IPLD只与数据有关,而跟网络无关,所以只有multihash和multicodecs与IPLD有关)

即有了数据本身之后,我们还需要组织数据的数据结构,IPLD就是干这个的.通过IPLD使用的数据连接(cid)和数据模型(扩展json)就可以跨协议遍历链接，无论底层协议如何，都可以探索数据。

更加直白一点,IPLD就是对一堆任意给出数据给创建一个能自描述其中关联的CID的功能的一整个生态系统.

### 数据连接 CID

CID是 multihash 的一个扩展,即加上了 multihash 描述数据的格式 ( JSON,CBOR,Bitcoin,Ethereum,etc) 这样我们通过一个 CID字符就可以知道如何 decodec 后面的multihash来获取二进制数据了.

### 数据模型 JSON base

考虑到很多语言都有json库,并且json可读性很好, IPLD的数据模型和json很类似但添加了更多的类型.

比如增加了 CID的链接类型.还添加了一个二进制类型等等,这些都是通过增加编解码器来的

通过维护的一个 链接类型,包含内容的hash地址,hash算法 的codec编解码器,我们就可以将这种数据模型用于不同系统中的数据解析和获取

比如比特币区块肯定不是IPLD结构的,但我们可以有一个比特币的编解码器,通过它可以将比特币的block解释成一个 IPLD的数据模型.

举例:一个 CID类型数据 有可能包含以下内容
- hash地址:btc block hash
- hash算法:double-SHA256
- codec编解码器:bitcoin-block 或 bitcoin-tx

这样通过一个cid数据,你就知道该hash算法和通过何种codec来编解码读取数据了.

这样的IPLD结构就实现了不同的格式,不同的数据结构,不同的系统中随意的读取可寻址数据的能力.你也可以用你自己的 IPLD数据结构,通过你自己选择的 codec编解码器,连接任意其他的 IPLD数据,比如任意的 bitcoin区块,git提交和任意的内容寻址内容.


## 数据结构编址

也许看了上面的东西,关于 某一个数据结构,使用什么编解码器,和最终得到的 CID之间的关系还是很模糊,我们使用实际的代码来演示以更加明确其中的关系.

首先定义我们的数据结构,数据结构的意义在于把值分配给了具体的属性,这个person就可以被称为一个节点,而这个person包含的属性也是属性节点.

```
const person = {
  name: 'Mikeal Rogers',
  github: 'mikeal',
  twitter: '@mikeal'
}
```

如果有很多个不同的person,他们之间的相互关联起来的结构也可以组成一个数据结构

```
const earth = []
const pluto = []

const index = (person, planet) => {
  planet.push(person)
}

index({ name: 'Mikeal Rogers' }, earth)
index({ name: 'Eric Myhre' }, earth)
index({ name: 'Volker Mische' }, earth)
index({ name: 'Emory' }, pluto)
index({ name: 'Oglethorpe'}, pluto)

const galaxy = { earth, pluto }
```

这里的 galaxy 包含了 earth和pluto两个属性,要查看谁在earth,只需要查看 earth属性就可以了.获取具体的 mikeal 这个信息非常重要,但是从 galaxy.earth 这个途径去获取到这个属性同样重要甚至更加重要.这就需要对数据进行编址.

我们可以使用指针来理解这个编址的概念.Url就像web内容的指针一样,你可以通过不同的url访问同一个内容不是吗.

在IPLD中我们使用的CID就是用来将数据连接在一起的,CID就是这个指针的作用.我们继续使用代码来逐行的阐述.

```
import Block from '@ipld/block/defaults.js'

const example = async () => {
// 定义了一个自己的数据结构
  const person = {
    name: 'Mikeal Rogers',
    github: 'mikeal',
    twitter: '@mikeal'
  }
// 数据是json编解码的,它被序列化为二进制数据
  const block = Block.encoder(person, 'json')
// 创建cid,其中执行了特定算法的hash,从而分配了一个全局唯一的id
  const cid = await block.cid()
  console.log(cid.toString())
}
example()

// 输出 bagaaierakbgholyvqnp2kjpr5ep6yh6u4uhop7cv7wvabydbctksletsilkq
```

CID可以告诉我们,该数据是json编解码的,并且包含了数据的hash,使用这个CID就可以从任意位置获取该IPLD数据.

到这里为止,其实和我们普通的hash算法没什么两样,我们也可以使用一个sha256来创建普通的hash不是吗,顶多就是数据要自己约定好如何编码解码,那么继续讲CID的连接.

```
// 定义一个创建 persion数据块 的方法
const createPerson = name => Block.encoder({ name }, 'json')
// 创建了一个 galaxy的数据结构,其中包含了若干个人的 CID的关系
const createGalaxy = async () => {
  const mikeal = await createPerson('Mikeal Rogers').cid()
  const eric = await createPerson('Eric Myhre').cid()
  const volker = await createPerson('Volker Mische').cid()
  const elon = await createPerson('Elon Musk').cid()

  const galaxy = {
    americans: [ eric, mikeal, elon ],
    inAmerica: [ mikeal ],
    onEarth: [ mikeal, eric, volker ],
    onMars: [ elon ]
  }
// json中并没有CID数据类型,我们需要使用IPLD中的 dag-cbor 编码解码器,它是扩展的json
  const block = Block.encoder(galaxy, 'dag-cbor')
  const cid = await block.cid()
  console.log(cid.toString())
}
createGalaxy()
```

这里的 `dag-cbor` 编解码器是一种和 `json`等价的编解码器,同样的,可以有 `git`,`bitcoin`,`zcash`,`ethereum`等各种各样的编解码器.

这时我们查看生成的 galaxy 的CID可以看到什么,是这样的一个 dag 组织的数据.

```
{ americans: [ Hash(0003), Hash(0001), Hash(0004) ],
  inAmerica: [ Hash(0001) ],
  onEarth: [ Hash(0001), Hash(0002), Hash(0003) ],
  onMars: [ Hash(0004) ]
}
```

我们可以很快得知如下的关系,非常有限的索引非常有限的集合,但我们可以分析出很多关系
- 在美国有1个人，他是美国人。
- 有2个不在美国的美国人。
- 火星上的人是美国人。
- 我知道每个星球上有多少人被索引。
- 该索引中只有4个独特的人。

## IPLD术语

**Block**

块主要用来表示原始二进制数据和CID的配对,即 Binary:CID.大部分用户不直接使用原始的块数据,而是在 IPLD数据模型中进行编码和解码后使用.

**CID**

Content IDentifier, 这是一个自描述的数据结构标识符. 其中包含了一个 multihash和codec,即它是一个hash,并且自描述了是什么算法的hash,以及如何解码该hash标识对应的二进制数据.

**Codec**

编解码器,这包含了一种 multicodec 和限定为该格式的二进制数据执行的编码器和解码器.
例如 DAG-CBOR,DAG-JSON,bitcoin-block,bitcoin-tx,git 等.

**DAG-CBOR**

这是一种讲IPLD数据模型实现为 CBOR子集的编解码器,并且具有哈希一致性的附加约束.DAG-CBOR使用CBOR标记添加“链接”类型。

**DAG-JSON**

不建议用于生产环境的编解码器,这是使用JSON序列化实现IPLD数据模型的编解码器.DAG-JSON添加了“链接(CID)”和“二进制(Binary)”类型，以及用于哈希一致性表示的其他约束。

------------------------

由于本文只是 IPLD 的简介,只介绍 IPLD 的基础,并不打算设计如何进行编码,所以可以自行查看如果使用IPLD

- [js中使用IPLD](https://docs.ipld.io/getting-started/js.html)
- [go中使用IPLD](https://docs.ipld.io/getting-started/go.html)

更多进阶阅读
- [IPLD说明书spec](https://specs.ipld.io/)
- [完整的IPLD文档doc](https://docs.ipld.io/)
- [数据模型,数据布局和编码器](https://docs.ipld.io/docs/gtd/)
- [IPLD的目标](https://docs.ipld.io/docs/objectives.html#databases)
- [IPLD的架构](https://specs.ipld.io/schemas/)
- [高级IPLD数据布局](https://docs.ipld.io/docs/advanced-layouts.html)





