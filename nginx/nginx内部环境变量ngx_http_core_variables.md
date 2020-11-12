---
title: nginx内部环境变量
---

| 名称  | 说明              |
| ------- | ----------------- |
$args  | 请求中的参数
$binary_remote_addr | 远程地址的二进制表示
$body_bytes_sent | 已发送的消息体字节数
$content_length | http请求信息头里面的 Content-Length
$content_type | 请求信息头里的 Content-Type
$document_root | 针对当前请求的根路径设置值
$document_uri | 与$uri相同
$host | 请求信息中的 Host,如果请求中没有host行,则等于设置的服务器名
$hostname | 主机名
$http_cookie | cookie信息
$http_post | -
$http_referer | 引用地址
$http_user_agent | 客户端代理信息
$http_via | 最后一个访问服务器的ip地址
$http_x_forwarded_for | 相当于网络访问路径
$is_args | -
$limit_rate | 对连接速率的限制
$nginx_version |
$pid | -
$query_string | 与$args相同
$realpath_root | -
$remote_addr | 客户端地址
$remote_port | 客户端端口号
$remote_user | 客户端用户名 认证
$request | 用户请求
$request_body | -
$request_body_file | 发往后端的本地文件名称
$request_completion | -
$request_filename | 当前请求的文件路径名
$request_method | 请求方法名
$request_uri | 请求的uri带参数
$scheme | 所用的协议，比如 http,https,rewrite
$sent_http_cache_control | -
$sent_http_connection | -
$sent_http_content_length | -
$sent_http_content_type | -
$sent_http_keep_alive | -
$sent_http_last_modified | -
$sent_http_location | -
$sent_http_transfer_encoding | -
$server_addr | 服务器地址，如果没有listen指明则发起系统调用获得地址
$server_name | 请求达到的服务器名
$server_port | 请求到达的服务器端口号
$server_protocol | 请求的协议版本 http/1.0 http/1.1
$uri | 请求的uri 有可能和最初的值不同，比如经过重定向
[ngx_http_core_variables]


