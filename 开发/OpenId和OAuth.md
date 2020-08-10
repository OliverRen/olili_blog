---
title: OpenId和OAuth
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

#### 我们先来看了解一些专业术语

==OpenId==
- RP:Relying Party 服务提供者,即当前用户在使用的站点或应用
- OP:OpenId Provider OpenId服务的提供者,负责对用户进行身份验证
- Claimed Identifier:终端的声明标识,即当前用户的id标识,可以是一个Uri,或是Xri,详见OpenId
- End User:终端用户 即当前的使用用户

--------------

#### OpenId

![](http://qiniu.imolili.com/小书匠/1.jpg)

##### OpenId的验证流程
1. 终端用户访问RP网站，在需要登录的时候选择了以OpenID的方式进行登录
2. RP站点将OpenID登录界面返回给终端用户
3. 终端用户在RP站点输入OpenID
4. RP网站需要对用户输入的OpenID进行解析，这个过程是非常重要的,uri和xri区别
5. RP发现OpenID后使用相应解析
6. RP连接OP建立安全通道
7. OP处理RP的关系请求
8. RP对OP发送对用户进行鉴证的请求
9. 终端用户在OP进行登录认证
10. 终端用户在OP进行登录认证
11. OP将见证结果返回给RP
12. RP对OP返回的结果进行分析
13. 如果成功则用户在RP登录成功

简化的描述就是
1. OpenId服务提供者分配给用户一个URL标识(也可以是多个)
2. 在用户登录的时候,选择一个URL进行登录(比如微博)
3. 跳转到微博OpenId登录页面
4. 用户在微博的渔民下输入微博的账号和密码
5. 微博验证成功这的确是自己的用户
6. 按照用户的选择,向用户登录的地址返回相关的信息.

> 当前的站点(依赖方)不需要做什么事情，只需要给url，让用户去登陆，返回需要的信息

-----------------

#### OAuth

![](http://qiniu.imolili.com/小书匠/2.jpg)

![](http://qiniu.imolili.com/小书匠/3.jpg)

##### OAuth授权的流程

1. 使用者（第三方软件）向OAUTH服务提供商请求未授权的Request Token。向Request Token URL发起请求，请求需要带上的参数见上图。
2 .OAUTH服务提供商同意使用者的请求，并向其颁发未经用户授权的oauth_token与对应的oauth_token_secret，并返回给使用者。
3. 使用者向OAUTH服务提供商请求用户授权的Request Token。向User Authorization URL发起请求，请求带上上步拿到的未授权的token与其密钥。
4. OAUTH服务提供商将引导用户授权。该过程可能会提示用户，你想将哪些受保护的资源授权给该应用。此步可能会返回授权的Request Token也可能不返回。如Yahoo OAUTH就不会返回任何信息给使用者。
5. Request Token 授权后，使用者将向Access Token URL发起请求，将上步授权的Request Token换取成Access Token。请求的参数见上图，这个比第一步A多了一个参数就是Request Token。
6. OAUTH服务提供商同意使用者的请求，并向其颁发Access Token与对应的密钥，并返回给使用者。
7. 使用者以后就可以使用上步返回的Access Token访问用户授权的资源。

简化的描述就是:
1. 用户在使用者页面上发起请求
2. 使用者组装需要授权的权限和自己的token到微博
3. 用户在微博授权页面输入微博的账号和密码
4. 微博验证成功之后返回 access_token
5. 然后使用者拿到 access_token 之后，再去请求微博的用户 API
6. 微博授权中心验证 access_token，如果验证通过，则返回用户 API 的请求数据给使用者。
7. 
后面当然对access_token还有refresh的过程 略

> 当前的使用者(依赖方)需要用户在跳转到OAuth登录后同意授权相应的权限,然后从OAuth服务商获取access_token后,就可以在不获取用户的微博账号密码的情况下使用通过授权的用户在微博的功能了.

##### OAuth授权一般以使用的交互模式分为:

1. 客户端模式
和用户无关，用于应用程序与API资源的直接交互场景

2. 密码模式
和用户有关，一般用于第三方登陆

3. 简化模式 with openId
仅限openid认证服务

4. 简化模式 with openid and oauth js客户端调用
包含 OpenID 认证服务和 OAuth 授权，但只针对 JS 调用（URL 参数获取），一般用于前端或无线端。

5. 混合模式
推荐使用，包含 OpenID 认证服务和 OAuth 授权，但针对的是后端服务调用。

--------------------

#### OpenId和OAuth的区别

OAuth关注的是authorization；而OpenID侧重的是authentication。
从表面上看，这两个英文单词很容易混淆，但实际上，它们的含义有本质的区别：

Oauth
authorization: n. 授权，认可；批准，委任

OpenId
authentication: n. 证明；鉴定；证实

OAuth关注的是授权，即：“用户能做什么”；而OpenID关注的是证明，即：“用户是谁”。

OpenID是关于证明、证实身份（Authentication）的，好比火车站进站的时候拿出身份证和车票来看，比对是否同一个人。这是在回答「我是谁？这就是我」，是为了证实「这不是一个匿名的不可查的信息源头」，因为匿名对象和信息对网络服务商来说不好统计管理，也不利于产生价值。

OAuth 是关于授权、许可（Authorization）的，好比坐飞机过安检的时候除了看身份证，还要求掏出兜里的东西，拿出包里的东西、手机等随身物品以便检查，这时就需要得到被检查人的许可才行，被检查人有权利扭头就走，但要想登机，必须给予许可、掏出物品。这是在回答「我同意让你对我进一步做些什么」，是为了在被授予权限的前提下，更多的获取除了账号密码以外的个人信息，例如：联系人通讯录，邮箱号，电话号，地址，照片，聊天记录，网络发言、活动记录，GPS 信息等等，来满足用户对服务的功能需要，或者「其他需要」。

我们通过下面这个例子来区别一下具体的区别:

##### OpenId

1.  用户希望访问其在example.com的账户
2.  example.com (在OpenID的黑话里面被称为“Relying Party”) 提示用户输入他/她/它的OpenID
3.  用户给出了他的OpenID，比如说 `http://user.myopenid.com`
4.  example.com 跳转到了用户的OpenID提供商“mypopenid.com”
5.  用户在”myopenid.com”(OpenID provider)提示的界面上输入用户名密码登录
6.  “myopenid.com” (OpenID provider) 问用户是否要登录到example.com
7.  用户同意后，”myopenid.com” (OpenID provider) 跳转回example.com
8.  example.com 允许用户访问其帐号

##### OAuth

1.  用户在使用example.com时希望从mycontacts.com导入他的联系人
2.  example.com (在OAuth的黑话里面叫“Consumer”)把用户送往mycontacts.com (黑话是“Service Provider”)
3.  用户在mycontacts.com 登录(可能也可能不用了他的OpenID)
4.  mycontacts.com问用户是不是希望授权example.com访问他在mycontact.com的联系人
5.  用户确定
6.  mycontacts.com 把用户送回example.com
7.  example.com 从mycontacts.com拿到联系人
8.  example.com 告诉用户导入成功


