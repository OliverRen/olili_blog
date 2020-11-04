---
title: IPFS简介
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

#### IPFS 协议

IPFS的英文全称是 InterPlanetary File System，中文名叫星际文件系统。

IPFS是一个 p2p 协议 , P2P协议节点越多, 下载速度越快

IPFS是一个点对点的分布式文件系统

IPFS是一个分布式的网络，点对点的超媒体协议 。超媒体建立的是文本、图片、视频之间的链接。

就像btc网络一样，ipfs协议也没有发明什么，大多数工作是在前人已有的基础进行的，ipfs集成了如下已有的系统:

- DHT (distributed hash tables）：分布式哈希表
- Git : 内含版本管理
- BitTorrent：类似的数据交换协议
- SFS（self-certified filesystems）：自认证文件系统

#### IPFS 设计

1. 节点身份

	每一个ipfs节点都有一个独一无二的身份id

2. 网络

	ipfs节点要和网络里面成百上千的其它节点通讯，现实中的网络结构如此复杂，ipfs使用 ICE NAT穿透技术来保障网络的连通性。

3. 路由
	
	ipfs网络的路由使用的是DHT，借鉴了S/Kademlia，使得一个节点可以快速的查找到其它节点。

4. 数据交换协议

	ipfs借鉴BitTorrent协议，使用了叫做BitSwap的数据交换协议，该协议使用两个列表，想要的数据块（want_list）和我有的数据块（have_list）与其它节点进行数据交换。

5. 对象存储
	
	ipfs存储数据使用的是 Merkle DAG结构，这赋予了ipfs内容寻址，防篡改，去重功能。

6. 版本控制系统	
	
	ipfs在 Merkle DAG上面添加了Git版本控制功能，这使得ipfs文件拥有了时光机功能

7. 自认证命名系统

	ipfs使用了SFS自认证系统给文件命名，同时提供了ipns解决传播问题，而且还兼容了现有的域名系统
	
#### IPFS 的内容

- IPLD : 将数据 import 到 ipfs 中组织的协议族
- Bitswap : 拉取和传输数据区块的协议
- DHT : A Distributed Hash Table (DHT) 分布式的key-value存储.
- Gateway : ipfs网络在 http 上的代理接入点
- multicodec : multihash中被hash的数据是通过multicodec组织的数据
- multihash : 是一个自描述hash算法后的数据

#### IPFS 的工作流程

1. 将文件加入到ipfs
	
	首先会对要加入的文件内容进行 chunk 分块,并组成dag的形式,然后从叶子节点开始一层一层往上计算cid直到最终的根节点,可以使用这个工具进行分析 [dag.ipfs.io](https://dag.ipfs.io/)

	chunk 可以有 `平均分割法`和`smart变长分割法(rabin方式)`, rabin方式会使用16byte的滑动窗口来计算,使得块大小分布在一个平均值形成正太分布,这样可以使得内容的修改仅仅知会影响修改的块
	
2. CID

	在IPFS系统上传文件后，IPFS系统会为上传的文件进行加密，加密后会得到一个哈希值。这个哈希值就是 CID (一串64位、由数字和字母构成的数值)
	
	CID 有两种版本,可以使用这个工具进行分析 [cid.ipfs.io](https://cid.ipfs.io)
	
	- CID v0 : 使用Qm开头的cid,其内容只包含了 multihash,且只会使用base58编码,其内容看起来大概是这样的 `<0><dag-pb><multihash>`
	- CID v1 : 包含了前缀标识可以向后兼容的cid version,其通过第一个字符来标识编码,`b`表示base32,`z`表示base58,`f`表示base16,这个base字符叫做 multibase table [multibase](https://github.com/multiformats/multibase).其内容看起来像这样 </br>
		Binary : `<cid-version><ipld-format><multihash>` </br>
		String : `<base>base(<cid-version><ipld-format><multihash>)`

3. 客户端
	
	使用 go-ipfs 的cli或者是 ipfs-desktop 的 windows客户端都可以,使用 ipfs-update进行更新,或者在更新了程序后使用 `ipfs daemon`进行数据升级迁移.
	
	ipfs最终作为一个应用,更加推荐使用官方文档的 how to 开始实践 .[ipfs.io how to doc](https://docs.ipfs.io/how-to/)
	
4. IPNS和DNSLink
	
	IPNS 是使用 `ipfs name pushlish CID`来创建一个对特定内容 ipfs-path 的指向
	
	IPNS 可以理解为有版本管理的指向
	
	DNSLink是直接使用dns的txt记录来实现的.即将对一个域名的访问,改为 dnslink=/ipfs/Cid 的访问
	
	`my-dns-tool set --type=TXT --ttl=60 --domain=libp2p.io --name=_dnslink --value="dnslink=/ipfs/Qmc2o4ZNtbinEmRF9UGouBYTuiHbtCSShMFRbBY5ZiZDmU"`

#### IPFS 与 家族其他成员的关系

`IPFS`可以说是`Protocol Labs`下第一个真正的应用,它把 `Multiformats`,`IPLD`,`Libp2p`糅合在了一起.

- Multiformats 用来定义
- IPLD 用来描述数据,将数据 import 到 ipfs 中组织的协议族
- Libp2p 用来传输数据

IPFS 是依赖 IPLD 的,是一个数据存储的具体实现.
