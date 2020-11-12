---
title: ELK技术帮助
---

[toc]

* [单例安装](#%E5%8D%95%E4%BE%8B%E5%AE%89%E8%A3%85)
    * [ELK全家桶](#elk%E5%85%A8%E5%AE%B6%E6%A1%B6)
    * [软件安装](#%E8%BD%AF%E4%BB%B6%E5%AE%89%E8%A3%85)
      * [软件依赖](#%E8%BD%AF%E4%BB%B6%E4%BE%9D%E8%B5%96)
      * [简易安装流程](#%E7%AE%80%E6%98%93%E5%AE%89%E8%A3%85%E6%B5%81%E7%A8%8B)
      * [elasticsearch\.yum配置详解](#elasticsearchyum%E9%85%8D%E7%BD%AE%E8%AF%A6%E8%A7%A3)
      * [logstash配置示例](#logstash%E9%85%8D%E7%BD%AE%E7%A4%BA%E4%BE%8B)
* [集群部署](#%E9%9B%86%E7%BE%A4%E9%83%A8%E7%BD%B2)
    * [elasticsearch集群的搭建](#elasticsearch%E9%9B%86%E7%BE%A4%E7%9A%84%E6%90%AD%E5%BB%BA)
    * [elasticsearch集群的特性](#elasticsearch%E9%9B%86%E7%BE%A4%E7%9A%84%E7%89%B9%E6%80%A7)
      * [cluster](#cluster)
      * [shards](#shards)
      * [replicas](#replicas)
      * [recovery](#recovery)
      * [river](#river)
      * [gateway](#gateway)
      * [discovery\.zen](#discoveryzen)
      * [Transport](#transport)
* [服务器优化](#%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%BC%98%E5%8C%96)
* [问题解决](#%E9%97%AE%E9%A2%98%E8%A7%A3%E5%86%B3)
    * [由于GC引起的节点脱离集群](#%E7%94%B1%E4%BA%8Egc%E5%BC%95%E8%B5%B7%E7%9A%84%E8%8A%82%E7%82%B9%E8%84%B1%E7%A6%BB%E9%9B%86%E7%BE%A4)
    * [out of memory错误](#out-of-memory%E9%94%99%E8%AF%AF)
    * [无法创建本地线程问题](#%E6%97%A0%E6%B3%95%E5%88%9B%E5%BB%BA%E6%9C%AC%E5%9C%B0%E7%BA%BF%E7%A8%8B%E9%97%AE%E9%A2%98)
    * [设置jvm锁住内存时启动警告](#%E8%AE%BE%E7%BD%AEjvm%E9%94%81%E4%BD%8F%E5%86%85%E5%AD%98%E6%97%B6%E5%90%AF%E5%8A%A8%E8%AD%A6%E5%91%8A)
    * [org\.elasticsearch\.transport\.RemoteTransportException: Failed to deserialize exception response from stream](#orgelasticsearchtransportremotetransportexception-failed-to-deserialize-exception-response-from-stream)
* [CRUD学习篇](#crud%E5%AD%A6%E4%B9%A0%E7%AF%87)
    * [对索引进行维护](#%E5%AF%B9%E7%B4%A2%E5%BC%95%E8%BF%9B%E8%A1%8C%E7%BB%B4%E6%8A%A4)
    * [查看mapping](#%E6%9F%A5%E7%9C%8Bmapping)
    * [CRUD](#crud)

#### 单例安装

##### ELK全家桶

1. Logstash : 作为log的收集,转换格式的工具,同时集成了各种日志的插件来对日志做格式化等操作,可以对日志的查询和分析的效率有很大的提升.
	* shipper : 成为日志的收集者,负责收集log
	* indexer : 从中转处读取日志数据并转发给elasticsearch进行存储
2. redis : 作为一个中转db
3. elasticsearch : 基于lucene的开源搜索殷勤,这里用来做日志最后的存储和索引.
4. kibana : 开源web的展现,作为日志数据的呈现客户端

大部分软件都可以直接在以下目录进行 [下载](http://www.elasticsearch.org/downloads/)

![ELK使用示例](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/ELK技术帮助/2020811/1597125422013.jpg)

##### 软件安装

必须说明的是 elk的技术栈更新相当快,虽然整体构成和用途没有太大的变更,但是使用细节和界面上的东西变化很大,故安装说明只记录了流程作为备忘.

> 需要注意的是 elk 的三大件 elasticsearch,logstash,kibana 是有版本对应的,必须安装文档说明下载对应的版本

###### 软件依赖

jdk : 运行java程序必须
redis : 中间日志队列db
ruby & ruby gems & bundler : kibana2必须,但kibana3之后就是html+css实现的就不需要了

###### 简易安装流程

1. 安装 java,配置环境变量
2. 安装redis,配置redis并启动
3. 安装elasticsearch,配置 ./config/elasticsearch.yum,主要修改bind,并作为daemon启动
4. 安装logstash,相对而言,logstash的配置是比较多的,下文给出了ship和index的示例
5. kibana,不同版本的客户端kibana方式不一,一般都是使用http服务托管即可

###### elasticsearch.yum配置详解

``` elasticsearch.yum
cluster.name: elasticsearch
配置es的集群名称，默认是elasticsearch，es会自动发现在同一网段下的es，如果在同一网段下有多个集群，就可以用这个属性来区分不同的集群。

node.name: "Franz Kafka"
节点名，默认随机指定一个name列表中名字，该列表在es的jar包中config文件夹里name.txt文件中，其中有很多作者添加的有趣名字。

node.master: true
指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。

node.data: true
指定该节点是否存储索引数据，默认为true。

index.number_of_shards: 5
设置默认索引分片个数，默认为5片。

index.number_of_replicas: 1
设置默认索引副本个数，默认为1个副本。

path.conf: /path/to/conf
设置配置文件的存储路径，默认是es根目录下的config文件夹。

path.data: /path/to/data
设置索引数据的存储路径，默认是es根目录下的data文件夹，可以设置多个存储路径，用逗号隔开，例：
path.data: /path/to/data1,/path/to/data2

path.work: /path/to/work
设置临时文件的存储路径，默认是es根目录下的work文件夹。

path.logs: /path/to/logs
设置日志文件的存储路径，默认是es根目录下的logs文件夹

path.plugins: /path/to/plugins
设置插件的存放路径，默认是es根目录下的plugins文件夹

bootstrap.mlockall: true
设置为true来锁住内存。因为当jvm开始swapping时es的效率 会降低，所以要保证它不swap，可以把ES_MIN_MEM和ES_MAX_MEM两个环境变量设置成同一个值，并且保证机器有足够的内存分配给es。 同时也要允许elasticsearch的进程可以锁住内存，linux下可以通过`ulimit -l unlimited`命令。

network.bind_host: 192.168.0.1
设置绑定的ip地址，可以是ipv4或ipv6的，默认为0.0.0.0。


network.publish_host: 192.168.0.1
设置其它节点和该节点交互的ip地址，如果不设置它会自动判断，值必须是个真实的ip地址。

network.host: 192.168.0.1
这个参数是用来同时设置bind_host和publish_host上面两个参数。

transport.tcp.port: 9300
设置节点间交互的tcp端口，默认是9300。

transport.tcp.compress: true
设置是否压缩tcp传输时的数据，默认为false，不压缩。

http.port: 9200
设置对外服务的http端口，默认为9200。

http.max_content_length: 100mb
设置内容的最大容量，默认100mb

http.enabled: false
是否使用http协议对外提供服务，默认为true，开启。

gateway.type: local
gateway的类型，默认为local即为本地文件系统，可以设置为本地文件系统，分布式文件系统，hadoop的HDFS，和amazon的s3服务器，其它文件系统的设置方法下次再详细说。

gateway.recover_after_nodes: 1
设置集群中N个节点启动时进行数据恢复，默认为1。

gateway.recover_after_time: 5m
设置初始化数据恢复进程的超时时间，默认是5分钟。

gateway.expected_nodes: 2
设置这个集群中节点的数量，默认为2，一旦这N个节点启动，就会立即进行数据恢复。

cluster.routing.allocation.node_initial_primaries_recoveries: 4
初始化数据恢复时，并发恢复线程的个数，默认为4。

cluster.routing.allocation.node_concurrent_recoveries: 2
添加删除节点或负载均衡时并发恢复线程的个数，默认为4。

indices.recovery.max_size_per_sec: 0
设置数据恢复时限制的带宽，如入100mb，默认为0，即无限制。

indices.recovery.concurrent_streams: 5
设置这个参数来限制从其它分片恢复数据时最大同时打开并发流的个数，默认为5。

discovery.zen.minimum_master_nodes: 1
设置这个参数来保证集群中的节点可以知道其它N个有master资格的节点。默认为1，对于大的集群来说，可以设置大一点的值（2-4）

discovery.zen.ping.timeout: 3s
设置集群中自动发现其它节点时ping连接超时时间，默认为3秒，对于比较差的网络环境可以高点的值来防止自动发现时出错。

discovery.zen.ping.multicast.enabled: false
设置是否打开多播发现节点，默认是true。

discovery.zen.ping.unicast.hosts: ["host1", "host2:port", "host3[portX-portY]"]
设置集群中master节点的初始列表，可以通过这些节点来自动发现新加入集群的节点。

下面是一些查询时的慢日志参数设置
index.search.slowlog.level: TRACE
index.search.slowlog.threshold.query.warn: 10s
index.search.slowlog.threshold.query.info: 5s
index.search.slowlog.threshold.query.debug: 2s
index.search.slowlog.threshold.query.trace: 500ms

index.search.slowlog.threshold.fetch.warn: 1s
index.search.slowlog.threshold.fetch.info: 800ms
index.search.slowlog.threshold.fetch.debug:500ms
index.search.slowlog.threshold.fetch.trace: 200ms
```

###### logstash配置示例

从终端读取,并输入给redis
``` logstash-ship.conf
input {
  stdin {
    type => "test"
  }
}
output {
  stdout { codec => rubydebug }
  redis { host => "127.0.0.1" data_type => "list" key => "logstash" }
}
```

从redis中读取,并输出给es
``` logstash-index.conf
input {
  redis {
    host => "127.0.0.1"
    type => "syslog"
    threads => 4
    # these settings should match the output of the agent
    data_type => "list"
    key => "logstash"
    # We use json_event here since the sender is a logstash agent
    format => "json_event"
    }
}
output {
  elasticsearch {
    host => "127.0.0.1"
  }
}
```

#### 集群部署

##### elasticsearch集群的搭建

搭建elasticsearch集群主要修改config下面的elasticsearch.yml文件来配置一个集群。

elasticsearch可以指定一个集群名，集群里可以配置一个Master和多个node节点，也可以手动配置选举产生Master节点,只要cluster.name设置一致，并且机器在同一网段下，启动的es会自动发现对方，组成集群。

下面的配置，是三台机器组成一个集群，不指定哪个台机器是Master，让他们选举产生Master。

``` cluster
cluster.name: "es_mongodb"
node.name: "es_mongodb0"
node.master: true
node.data: true

cluster.name: "es_mongodb"
node.name: "es_mongodb1"
node.master: true
node.data: true

cluster.name: "es_mongodb"
node.name: "es_mongodb2"
node.master: true
node.data: true
```

##### elasticsearch集群的特性

对于elasticsearch集群搭建，可以把索引进行分片存储，一个索引可以分成若干个片，分别存储到集群里面，而对于集群里面的负载均衡，副本分配，索引动态均衡（根据节点的增加或者减少）都是elasticsearch自己内部完成的，一有情况就会重新进行分配。

下面先是通过介绍几个关于elasticsearch的几个名词了解es集群特性

###### cluster

代表一个集群，集群中有多个节点，其中有一个为主节点，这个主节点是可以通过选举产生的，主从节点是对于集群内部来说的。es的一个概念就是去中心化，字面上理解就是无中心节点，这是对于集群外部来说的，因为从外部来看es集群，在逻辑上是个整体，你与任何一个节点的通信和与整个es集群通信是等价的。

###### shards

代表索引分片，es可以把一个完整的索引分成多个分片，这样的好处是可以把一个大的索引拆分成多个，分布到不同的节点上。构成分布式搜索。默认有5个分片，分片的数量只能在索引创建前指定，并且索引创建后不能更改。

###### replicas

代表索引副本，es可以设置多个索引的副本，副本的作用一是提高系统的容错性，当个某个节点某个分片损坏或丢失时可以从副本中恢复。二是提高es的查询效率，es会自动对搜索请求进行负载均衡。

###### recovery

代表数据恢复或叫数据重新分布，es在有节点加入或退出时会根据机器的负载对索引分片进行重新分配，挂掉的节点重新启动时也会进行数据恢复。

###### river

代表es的一个数据源，也是其它存储方式（如：数据库）同步数据到es的一个方法。它是以插件方式存在的一个es服务，通过读取river中的数据并把它索引到es中，官方的river有couchDB的，RabbitMQ的，Hadoop的，MongoDB的。

###### gateway

代表es索引的持久化存储方式，es默认是先把索引存放到内存中，当内存满了时再持久化到硬盘。当这个es集群关闭再重新启动时就会从gateway中读取索引数据。es支持多种类型的gateway，有本地文件系统（默认），分布式文件系统，Hadoop的HDFS和amazon的s3云存储服务。

###### discovery.zen

代表es的自动发现节点机制，es是一个基于p2p的系统，它先通过广播寻找存在的节点，再通过多播协议来进行节点之间的通信，同时也支持点对点的交互。

###### Transport

代表es内部节点或集群与客户端的交互方式，默认内部是使用tcp协议进行交互，同时它支持http协议（json格式）、thrift、servlet、memcached、zeroMQ等的传输协议（通过插件方式集成）。

#### 服务器优化

1. 中文分词对于es来说默认的smartcn并不是很好,可以选用  [ik分词](https://github.com/medcl/elasticsearch-analysis-ik), [pinyin分词](https://github.com/medcl/elasticsearch-analysis-pinyin), [简繁转换分析器](https://github.com/medcl/elasticsearch-analysis-stconvert)
2. 内存设定,可以使用一些控制JVM的参数,如 ES_MIN_MEM 和 ES_MAX_MEM .
3. 打开文件数,使用 ulimit -l unlimited 或者调整 /etc/security/limits.conf
4.  关闭文件的更新时间,修改 /etc/fstab 添加 `/dev/sda7 /data/elasticsearch ext4 noatime,nodiratime 0 0`
5.  强制使用物理内存 bootstrap.mlockall:true

#### 问题解决

##### 由于GC引起的节点脱离集群

因为gc时会使jvm停止工作，如果某个节点gc时间过长，master ping3次（zen discovery默认ping失败重试3次）不通后就会把该节点剔除出集群，从而导致索引进行重新分配。

解决方法：
1. 优化GC,减少GC时间
2. 调大zen.discovery的重试次数和超时时间

##### out of memory错误

因为默认情况下es对字段数据缓存（Field Data Cache）大小是无限制的，查询时会把字段值放到内存，特别是facet查询，对内存要求非常高，它会把结果都放在内存，然后进行排序等操作，一直使用内存，直到内存用完，当内存不够用时就有可能出现out of memory错误。

解决方法：
1. 设置es的缓存类型为Soft Reference，它的主要特点是据有较强的引用功能。只有当内存不够的时候，才进行回收这类内存，因此在内存足够的时候，它们通常不被回收。另外，这些引 用对象还能保证在Java抛出OutOfMemory 异常之前，被设置为null。它可以用于实现一些常用图片的缓存，实现Cache的功能，保证最大限度的使用内存而不引起OutOfMemory。在es的配置文件加上index.cache.field.type: soft即可。
2. 设置es最大缓存数据条数和缓存失效时间，通过设置index.cache.field.max_size: 50000来把缓存field的最大值设置为50000，设置index.cache.field.expire: 10m把过期时间设置成10分钟。

``` 配置修改
indices.cache.query.size: 2%
indices.cache.filter.size: 10%
indices.fielddata.cache.size: 50000
indices.fielddata.cache.expire: 5m
indices.cache.field.type: soft
```

##### 无法创建本地线程问题

es恢复时报错： `RecoverFilesRecoveryException[[index][3] Failed to transfer [215] files with total size of [9.4gb]]; nested: OutOfMemoryError[unable to create new native thread]; ]]`

刚开始以为是文件句柄数限制，但想到之前报的是too many open file这个错误，并且也把数据改大了。查资料得知一个进程的jvm进程的最大线程数为：虚拟内存/（堆栈大小*1024*1024），也就是说虚拟内存越大或堆栈越小，能创建的线程越多。重新设置后还是会报那这错，按理说可创建线程数完全够用了的，就想是不是系统的一些限制。后来在网上找到说是max user processes的问题，这个值默认是1024，这个参数单看名字是用户最大打开的进程数，但看官方说明，就是用户最多可创建线程数，因为一个进程最少有一个线程，所以间接影响到最大进程数。调大这个参数后就没有报这个错了。.

解决方法:
1. 增大jvm的heap内存或降低xss堆栈大小（默认的是512K）。
2. 打开/etc/security/limits.d/90-nproc.conf，把`soft    nproc     1024`这行的1024改大就行了。

##### 设置jvm锁住内存时启动警告

当设置bootstrap.mlockall: true时，启动es报警告Unknown mlockall error 0，因为linux系统默认能让进程锁住的内存为45k。

解决方法：
设置为无限制, `ulimit -l unlimited`

##### `org.elasticsearch.transport.RemoteTransportException: Failed to deserialize exception response from stream`

原因:es节点之间的JDK版本不一样

解决方法：
统一JDK环境

#### CRUD学习篇

##### 对索引进行维护

维护索引进行大量数据操作的时候,可以选择把索引的复制先删除,停止refresh,维护完成后再重建复制

``` 删除replicas
curl -XPUT http://127.0.0.1:9200/logstash-mweibo-2015.05.02/_settings -d '{
    "index": { "number_of_replicas" : 0 }
}'
```

``` refresh
curl -XPUT http://127.0.0.1:9200/logstash-2015.05.01 -d'
{
  "settings" : {
    "refresh_interval": "-1"
  }
}'
```

##### 查看mapping

`curl localhost:9200/vehicles/_mapping`
可以查看类似于solr的schema的对象 json格式
我们put进新的数据，es会自动添加到mapping中 我们不需要自己来维护mapping

##### CRUD

CRUD
URL的格式：
`http://localhost:9200/<index>/<type>/[<id>]`
其中index、type是必须提供的。
id是可选的，不提供es会自动生成。

Index => Database
Type  => Table
Document => Row
Field  =>  Column

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/ELK技术帮助/2020811/1597125422013.jpg)

create
``` http
curl -XPUT "http://localhost:9200/movies/movie/1" -d'
{
    "title": "The Godfather",
    "director": "Francis Ford Coppola",
    "year": 1972
}'
```

update
``` http
curl -XPUT "http://localhost:9200/movies/movie/1" -d'
{
    "title": "The Godfather",
    "director": "Francis Ford Coppola",
    "year": 1972,
    "genres": ["Crime", "Drama"]
}'
```

get by id
``` http
curl -XGET "http://localhost:9200/movies/movie/1" -d''
```

delete by id
``` http
curl -XDELETE "http://localhost:9200/movies/movie/1" -d''
```

search full-text
``` http
curl -XPOST "http://localhost:9200/_search" -d'
{
    "query": {
        "query_string": {
            "query": "kill"
        }
    }
}'
```

search by property
``` http
curl -XPOST "http://localhost:9200/_search" -d'
{
    "query": {
        "query_string": {
            "query": "ford",
            "fields": ["title"]
        }
    }
}'
```
