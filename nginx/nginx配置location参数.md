---
title: nginx配置location参数
tags: 
renderNumberedHeading: true
grammar_cjkRuby: true
---

[toc]

## 注意点

 1. 匹配的顺序是先匹配普通字符串，然后再匹配正则表达式。另外普通字符串匹配顺序是根据配置中字符长度从长到短，也就是说使用普通字符串配置的location顺序是无关紧要的，反正最后nginx会根据配置的长短来进行匹配，但是需要注意的是正则表达式按照配置文件里的顺序测试。找到第一个比配的正则表达式将停止搜索。
 2. 一般情况下，匹配成功了普通字符串location后还会进行正则表达式location匹配。有两种方法改变这种行为，其一就是使用“=”前缀，这时执行的是严格匹配，并且匹配成功后立即停止其他匹配，同时处理这个请求；另外一种就是使用“^~”前缀，如果把这个前缀用于一个常规字符串那么告诉nginx 如果路径匹配那么不测试正则表达式。

## location模块配置
根据匹配特性大概可以分为以下几个部分 按照优先级顺序
>最高优先级(=) 第二优先级(^~) 第三优先级(按照顺序匹配~,~*) 第四优先级(/)

 1. **匹配即停止**
=：表示精确匹配，要么就匹配上，要么就不会被匹配。如果匹配上了，就进入该location块，其他都不看。
^~：表示优先匹配，如果按从上往下的顺序匹配到了该^~后面的URL，那么就进入该location块，其他都不看。
 2. **按顺序匹配**
~：表示区分大小写的正则匹配，如果依照自上而下的顺序匹配上URL了，那就不会再继续寻找，即使用这个location块。
~*：表示不区分大小写的正则匹配，如果依照自上而下的顺序匹配上URL了，那就不会再继续寻找，即使用这个location块。
 3. **通用匹配**
 /：表示任何请求都会被匹配到。
 

## location使用举例
>输入http://ip+port/images/1.p
>此时显示的是'= /images/1.p'，因为=匹配优先级最高

``` nginxconf?linenums
location = /images/1.p {
    default_type 'text/plain';
    echo '= /images/1.p';
}
location ^~ /images/1.p {
    default_type 'text/plain';
    echo ' /images/1.p';
}
```
>输入http://ip+port/images/1.p
>此时显示到的是'^~ /images/1.p'，因为^~只要匹配到了就会停止匹配，哪怕后续的长度更长
``` nginxconf?linenums
location ^~ /images/ {
    default_type 'text/plain';
    echo '^~ /images/1.p';
}
location ~ /images/1.p {
    default_type 'text/plain';
    echo '~ /images/1.p';
}
```
>输入http://ip+port/images/1.pxyzxyz
>此时显示到的是'~ /images/'，因为这是按照顺序匹配的，匹配到了后面的就不再匹配了
``` nginxconf?linenums
location ~ /images/ {
    default_type 'text/plain';
    echo '~ /images/';
}
location ~ /images/1 {
    default_type 'text/plain';
    echo '~ /images/1';
}
```
>输入http://ip+port/images/  显示'/'，因为没有匹配到后面的URL，使用默认的/规则
>输入http://ip+port/images/1xyzxyz  显示'~ /images/1'，因为匹配到了后面的正则
``` nginxconf?linenums
location / {
    default_type 'text/plain';
    echo '/';
}
location ~ /images/1 {
    default_type 'text/plain';
    echo '~ /images/1';
}
```
>输入http://ip+port/images/ 显示'/images/'
>输入http://ip+port/images/1/ab 显示'/images/'
>输入http://ip+port/images/1/abc 显示'/images/1/abc'  匹配上第一个location后，会继续向下匹配寻找，如果有更加完整的匹配，则会有下面的。如果没有，则使用当前的。
``` nginxconf?linenums
location /images/ {
    default_type 'text/plain';
    echo '/images/';
}
location /images/1/abc {
    default_type 'text/plain';
    echo '/images/1/abc';
}
```
>在使用“=”的时候会有意外情况，比方说下面这个例子。当输入'http://ip+port/'时，发现返回的状态码是304&404
>原因在于Nginx发现请求的是个目录时，会重定向去请求'http://ip+port/index.html'，此时返回码是304
>而后Nginx收到了'http://ip+port/index.html'这个请求，发现没有location能够匹配，就返回404了
``` nginxconf?linenums
location = / {
    default_type 'text/plain';
    index index.html index.htm;
    root /web/;
}
```