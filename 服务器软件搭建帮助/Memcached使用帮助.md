---
title: Memcached使用帮助
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

#### 协议说明

memcached所有的标准协议包含在对item执行命令过程中，一个item包含：
一个key
一个32位的标志值
以秒为单位的失效时间
一个64为的CAS值，这个是唯一的数据
CAS是可选的，可以使用“-C”禁止CAS。

___No Reply___
大多数ascii命令允许“noreply”。建议大家在ascii协议下别用“noreply”，因为那样不会报请求错误。“noreply”的目的是在执行交互命令（如：set、add）后，避免等待返回的包。
二进制协议将“noreply”定义为声明。如果你的客户端支持或者使用二进制协议，那么你将会用到它。

memcached的协议有文本协议和二进制协议两种
在Enyim的客户端中默认的配置是Binary的
使用text协议的 Commands API 说明
https://github.com/memcached/memcached/wiki/Commands

####  存储命令

客户端向服务器按照如下格式发送命令行

> (command name)  (key)  (flags)  (expire time)  (bytes data) (\r\n)

1. (command name) 可以是"set", "add", "replace"。
	- "set"表示按照相应的(key)存储该数据。
	- "add"表示按照相应的(key)添加该数据,但是如果该(key)已经存在则会操作失败。
	- "replace"表示按照相应的(key)替换数据,但是如果该(key)不存在则操作失败
2. (key)客户端需要保存数据的key
3. (flags) 是一个16位的无符号整数(十进制).该标志将和需要存储的数据一起存储,并在客户端get数据时返回。客户可以将此标志用做特殊用途，此标志对服务器来说是不透明的。
4. (expire time) 指定key过期时间.如果该数值为0表示存储的数据永远不过时(但是,该数据有可能被其他项所替换掉。因为服务器采用了LRU(最近最久没有使用)的算法替换)。如果非0(unix时间或者距离此时的秒数),当过期后,服务器可以保证用户得不到该数据(以服务器时间为标准)。
5. (bytes data) 需要存储的字节,也可以是空数据 0
6. \r\n 作为结束标志

服务端将返回应答.

1. "STORED\r\n" 表示存储成功
2. "NOT_STORED\r\n" 表示存储失败

__存储命令的行为__

- set
	set是保存数据命令。会覆盖已存在的数据，而新数据将在LRU顶端
	
- add
	只有在该数据不存在时才保存该数据。如果是新加入的item，那么将其直接放在LRU顶端；如果item已经存在导致add失败，那么将这个item从LRU链表上摘下再放到LRU顶端。

- replace
	替换已经存在的数据。 这个操作几乎用不到。
	
- append
	紧接着已经存在的item增加item。这个操作不允许增加原来的item限制，对管理链表很有用。
	
- prepend
	与append命令类似，这个命令是在已存在的数据前加入新数据。
	
- cas
	检查并存储(Check And Set)或者比较并更新(Compare And Swap)。如果从上次读取到现在没有更新，那么存入数据，处理更新竞争很有用。
	
------------------

#### 读取命令

客户端向服务端发送如下格式的数据

> get (key)* \r\n

服务器端将返回0个或者多个的数据项。
每个数据项都是由一个文本行和一个数据块组成。
当所有的数据项都接收完毕将收到"END\r\n"
每一项返回的数据结构

> VALUE  (key)  (flags)  (bytes data)\r\n

1.(key) 希望得到的key
2.(flags) 发送存储命令时设置的flags,原样返回
3.(bytes data) 存储的数据
4.\r\n 为这行数据结束的标志位

__读取命令__

- get
	读取命令， 更具一个或多个key查找数据，并返回所找到的数据。

- gets
	使用CAS的get命令，返回的item带有一个CAS标识符 (一个唯一的64位数)。使用cas命令返回数据。如果得到的item的cas值被更改了，这个数据将不会被保存。
	
--------------------

#### 删除命令

> delete (key) (time)\r\n

1.(key) 需要删除的key
2.希望将该数据删除的时间(unix时间戳,或从现在开始的秒数)
3.\r\n为命令结束的标志位

服务端将返回

1."DELETED\r\n" 删除成功
2."NOT_FOUND\r\n" 需要删除的key不存在

---------------------

#### incr/decr

如果key存储的value是64位整型的数据,则可以使用incr,decr来进行修改,如果数据不存在,那么将返回失败

命令格式
> incr/decr (key) (value)\r\n

服务端返回

1."NOT_FOUND\r\n" 服务端没有找到需要操作的项
2."(value)\r\n" 返回该数据剩余的有效时间

注意:

- 如果一个数据项的有效期被设置为0,这时使用decr命令是无法减少数据。
- 如果要执行 incr key -1 的操作不会有什么问题,结果和你希望的一样。但是,执行decr -1时的结果一定会让你觉得很意外,因为它的结果无论key的数据是什么结果的都是0.原因是:在这两个命令的执行过程中都是吧-1当做一个无符号的整形处理的。
- 执行decr命令时数据的长度不会随之而减小,而是在返回数据的后面填补空格。但是执行incr命令越界后会自动的增加数据的位数。