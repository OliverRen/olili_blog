---
title: elkStack日志分析平台 
tags: 
renderNumberedHeading: false
grammar_cjkRuby: true
---

[toc]

 ### 概念介绍

ELK Stack 是 Elasticsearch、Logstash、Kibana 三个开源软件的组合。在实时数据检索和分析场合，三者通常是配合共用，而且又都先后归于 Elastic.co 公司名下，故有此简称。

为什么需要一个日志的分析平台
* 开发人员不能登录线上服务器查看详细日志，经过运维周转费时费力
* 日志数据分散在多个系统，难以查找
* 日志数据量大，查询速度慢
* 一个调用会涉及多个系统，难以在这些系统的日志中快速定位数据
* 无法实时监控

日志的分析和监控在系统开发中有很重要的地位,常见的需求有:
* 根据关键字查询日志
* 监控系统运行情况
* 统计分析，比如接口的调用次数、执行时间、成功率等
* 异常数据自动触发消息通知
* 基于日志的数据挖掘

对于日志来说,收集,查询,显示是一个基本流程,正对应了logstash,elasticsearch,kibana的功能
由于ELK的迭代很快,早期的很多内容已经不适应最新的版本,所以只写一些最基础的实际我使用过的一些介绍了

![理论拓扑](http://qiniu.imolili.com/小书匠/1581146882250.png)

---

#### ElasticSearch
ElasticSearch是一个基于Lucene的开源分布式搜索服务器。它的特点有：分布式，零配置，自动发现，索引自动分片，索引副本机制，restful风格接口，多数据源，自动搜索负载等。它提供了一个分布式多用户能力的全文搜索引擎，基于RESTful web接口。Elasticsearch是用Java开发的，并作为Apache许可条款下的开放源码发布，是第二流行的企业搜索引擎。设计用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。
在elasticsearch中，所有节点的数据是均等的。

#### Logstash
Logstash是一个完全开源的工具，它可以对你的日志进行收集、过滤、分析，支持大量的数据获取方法，并将其存储供以后使用（如搜索）。说到搜索，logstash带有一个web界面，搜索和展示所有日志。一般工作方式为c/s架构，client端安装在需要收集日志的主机上，server端负责将收到的各节点日志进行过滤、修改等操作在一并发往elasticsearch上去。

#### Kibana
Kibana 是一个基于浏览器页面的Elasticsearch前端展示工具，也是一个开源和免费的工具，Kibana可以为 Logstash 和 ElasticSearch 提供的日志分析友好的 Web 界面，可以帮助您汇总、分析和搜索重要数据日志。

---

### 配置部署
老版本的ELK还需要自行安装 kopf,head 等插件来方便使用,新版本更新后确切的说应该是kibana 3之后,已经是一个功能性很完整的套件了.

很明显可以看出,ElasticSearch作为一个搜索服务器主要是用来保存数据,而Kibana是用来检索和分析日志数据的,所以前期的工作主要就是Logstash节点的配置和部署

#### Logstash工作原理：
Logstash事件处理有三个阶段：inputs → filters → outputs。是一个接收，处理，转发日志的工具。支持系统日志，webserver日志，错误日志，应用日志，总之包括所有可以抛出来的日志类型。
![enter description here](http://qiniu.imolili.com/小书匠/1581148875621.png)

==一些常用的输入 [input] 为： #3F51B5==
file：从文件系统的文件中读取，类似于tial -f命令
syslog：在514端口上监听系统日志消息，并根据RFC3164标准进行解析
redis：从redis service中读取
beats：从filebeat中读取
Filters：数据中间处理，对数据进行操作。

==一些常用的过滤器 [filter] 为: #3F51B5==
grok：解析任意文本数据，Grok 是 Logstash 最重要的插件。它的主要作用就是将文本格式的字符串，转换成为具体的结构化的数据，配合正则表达式使用。内置120多个解析语法。
mutate：对字段进行转换。例如对字段进行删除、替换、修改、重命名等。
drop：丢弃一部分events不进行处理。
clone：拷贝 event，这个过程中也可以添加或移除字段。
geoip：添加地理信息(为前台kibana图形化展示使用)
Outputs：outputs是logstash处理管道的最末端组件。一个event可以在处理过程中经过多重输出，但是一旦所有的outputs都执行结束，这个event也就完成生命周期。

==一些常见的输出 [output] 为: #3F51B5==
elasticsearch：可以高效的保存数据，并且能够方便和简单的进行查询。
file：将event数据保存到文件中。
graphite：将event数据发送到图形化组件中，一个很流行的开源存储图形化展示的组件。
Codecs：codecs 是基于数据流的过滤器，它可以作为input，output的一部分配置。Codecs可以帮助你轻松的分割发送过来已经被序列化的数据。

==一些常见的Codecs #3F51B5==
json：使用json格式对数据进行编码/解码。
multiline：将汇多个事件中数据汇总为一个单一的行。比如：java异常信息和堆栈信息。

#### ELK整体方案
1.在每台生成日志文件的机器上，部署Logstash，作为Shipper的角色，负责从日志文件中提取数据，但是不做任何处理，直接将数据输出到Redis队列(list)中；
2.需要一台机器部署Logstash，作为Indexer的角色，负责从Redis中取出数据，对数据进行格式化和相关处理后，输出到Elasticsearch中存储；
3.部署Elasticsearch集群，当然取决于你的数据量了，数据量小的话可以使用单台服务，如果做集群的话，最好是有3个以上节点，同时还需要部署相关的监控插件；
4.部署Kibana服务，提供Web服务。

采用这样的架构部署，有三点优势：==第一 #F44336==，降低对日志所在机器的影响，这些机器上一般都部署着反向代理或应用服务，本身负载就很重了，所以尽可能的在这些机器上少做事；==第二 #F44336==，如果有很多台机器需要做日志收集，那么让每台机器都向Elasticsearch持续写入数据，必然会对Elasticsearch造成压力，因此需要对数据进行缓冲，同时，这样的缓冲也可以一定程度的保护数据不丢失；==第三 #F44336==，将日志数据的格式化与处理放到Indexer中统一做，可以在一处修改代码、部署，避免需要到多台机器上去修改配置。 

![enter description here](http://qiniu.imolili.com/小书匠/1581149253053.png)

#### 收集nginx日志记录
Logstash的配置文件使用Yaml

1.配置nginx日志格式
``` nginxconf?linenums
log_format main '$remote_addr "$time_iso8601" "$request" $status $body_bytes_sent "$http_user_agent" "$http_referer" "$http_x_forwarded_for" "$request_time" "$upstream_response_time" "$http_cookie" "$http_Authorization" "$http_token"';
access_log  /var/log/nginx/example.access.log  main;
```

2.nginx日志–>>Logstash–>>消息队列
logstash读取文件使用的是file插件,如果是应用日志有可能直接写入消息队列即可 毕竟消息队列性能比业务机要强多了
``` yaml?linenums
input {
    file {
        type => "example_nginx_access"
        path => ["/var/log/nginx/example.access.log"]
 
        start_position => "beginning"
        sincedb_path => "/dev/null"
    }
}
```
output部分，将数据输出到消息队列，以redis为例，需要指定redis server和list key名称。另外，在测试阶段，可以使用stdout来查看输出信息。
``` yaml?linenums
output {
    if [type] == "example_nginx_access" {
        redis {
            host => "127.0.0.1"
            port => "6379"
            data_type => "list"
            key => "logstash:example_nginx_access"
        }
      #  stdout {codec => rubydebug}
    }
}
```

3.消息队列–>>Logstash–>>Elasticsearch
``` yaml?linenums
input {
    redis {
            host => "127.0.0.1"
            port => "6379"
            data_type => "list"
            key => "logstash:example_nginx_access"
    }
}
 
output {
    elasticsearch {
        index => "logstash-example-nginx-%{+YYYY.MM}"
        hosts => ["127.0.0.1:9200"]
    }
}
```

---