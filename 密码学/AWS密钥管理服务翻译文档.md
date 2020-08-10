---
title: AWS密钥管理服务翻译文档
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

> 由于公司的同事要实现一个内部的KMS系统,所以我对AWS的KMS管理服务的白皮书文档做了一个翻译,同时写了一点自己的理解,仅供参考

**我自己的理解**

系统分为两层
* AWS HSM 物理逻辑的硬件层,一些加密的服务器,用来存储加密密匙,密匙材料
* AWS KMS 软件层,用逻辑层来中存储的主密匙生成客户主密匙 CMK

HSM的硬件层可以是 AWS KMS默认使用的HSM集群,也可以是自定义的密匙存储HSM集群
这样的一个硬件+软件的环境可以被称为一个域,域中所有成员都贡献一个域密匙,这个域密匙的状态可以称为域状态

主密匙使用密匙材料来生成,密匙材料可以轮换
主密匙的授权和访问控制策略
IAM 策略和授权
添加标签
创建别名（引用了 CMK）
计划删除 CMK

主密匙在AWS KMS中创建 客户主密匙 CMK
CMK派生出来的密匙提供的是 加密密匙令牌 EKT
加密密匙令牌在调用加密时生成 数据密匙

使用信封加密
使用数据密匙加密明文
使用CMK加密数据密匙

密匙层的定义
您甚至可以使用其他加密密钥对数据加密密钥进行加密，并且在另一个加密密钥下加密该加密密钥。但是，最后，一个密钥必须以明文形式保留，以便您可以解密密钥和数据。此顶层明文密钥加密密钥称为主密钥。

加密可以传入上下文,授权和加密访问策略

**AWS密钥管理服务 加密细节 白皮书**

申明略
目录略

#### 摘要
AWS KMS是使用通过FIPS 140-2认证的硬件安全模块 (HSM) 提供密匙的存储和操作的云服务.
AWS KMS与大多数 AWS 服务可以无缝集成,您可以轻松地使用 KMS 主密钥控制您在这些服务内所存储数据的加密数据.本白皮书描述了你在使用AWS KMS执行加密操作的细节.

#### 介绍
AWS KMS提供了一个Web界面来生成和管理加密密钥 ; 对用于保护数据的加密服务也提供API操作。
AWS KMS提供与AWS服务集成，可以为通过集中管理和传统的审计密钥(自定义密匙存储)的服务提供一致的行为.
本白皮书提供AWS KMS的加密操作的详细说明，以帮助您评估这项服务提供的功能。

AWS KMS通过AWS管理控制台提供一个web交互界面,命令行接口, 和RESTful API操作 ,来对一个分布式通过FIPS 140-2认证的硬件安全模块 (HSM) 请求加密数据 .AWS KMS HSM是一个独立的多芯片的硬件加密设备,旨在提供专用的加密功能，以满足AWS KMS的安全性和可扩展性的要求。你可以使用客户主密匙(CMKs)来建立基于HSM完成自己的加密层.这些密匙只会在硬件安全模块中根据所需来处理你的加密请求.你可以创建多个CMKs,,每个都由密匙ID来标识.您可以定义谁可以管理和/或通过创建相应的密匙策略去使用CMKs以达成访问控制。这允许您为您的钥匙,每个API操作,定义指定的客户端调用使用。

![](http://qiniu.imolili.com/小书匠/1592301125155.png)
图片 1: AWS KMS 架构

AWS KMS是分层服务，包括面向网络的KMS主机和一个有多个HSM组成的服务层。这些分层主机的组合形成的AWS
KMS硬件栈。到AWS KMS的所有请求都必须通过传输层安全协议（TLS）进行。AWS KMS主机只允许拥有完整向前安全的加密组件的TLS版本。 在AWS KMS主机中,本白皮书中定义的协议和程序通过使用HSM来执行这些请求。AWS KMS的验证,授权使用相同的凭证,和访问策略机制可用于所有其他AWS API操作，包括AWS身份和访问管理（IAM）.

#### 设计目标
AWS KMS的设计满足以下要求。
可用性:....
基于群组的访问：??? 指亚马逊员工也许出于行政行为需要直接操作HSMs,但不会导出CMKs的明文.WTF (译者注:??? 这里特别需要指出,客户自己去请求都用的是请求 Request,而他这里指定内部的调用或者操作用的都是会话 Session)
访问控制:....
低延迟和高吞吐量： AWS KMS的延迟和吞吐量水平,适合在AWS其他服务中使用提供加密操作。
区域的独立性： AWS提供的客户数据区域的独立性。主要使用的是AWS地区内隔离。
安全随机： 强大的加密取决于确实无法预测的随机数生成，而AWS提供了高品质的随机数的来源。
审计:....

#### 背景
本节包含了密码原语的描述以及他们被使用的地方. 此外，还介绍了AWS KMS的基本要素。

##### 密码学原语 
AWS KMS采用可配置的加密算法，使系统可以快速地从一个算法或模式迁移到另一个。初始默认设置的加密算法已经根据联邦信息处理标准（FIPS）要求的安全性能和使用性能进行选择.

- 熵和随机数生成 
AWS KMS的密钥生成是在HSM中进行。该硬件安全模块实现混合随机数发生器 NIST SP800-90A确定性 随机位发生器（DRBG）CTR_DRBG AES-256 [3] 。它使用一个非确定性的 384位的随机数作为种子发生器,可以在每次调用加密数据时进行更新.

- 加密 
硬件安全模块内生成的所有对称密钥都是符合 高级加密 标准 AES）[4] 在 伽罗瓦计数器模式（GCM） [5]  256位密钥。类似的解密调用使用其反函数。
 AES-GCM是一种经过验证的加密方案。除了加密明文以产生密文, 它也可以被用在签名数据使用,该签名标签，有助于确保该数据从签名的原文到所述密文没有被修改.
 
- 密钥推导函数
密钥推导函数是用来从一个初始密钥导出附加密钥的。AWS使用KMS密钥导出函数（KDF）在CMK下推导出每个请求的加密密匙。所有KDF调用都在计数器模式[7] 使用HMAC [FIPS197] [8] 与SHA256 [FIPS180] [9]来执行。 该 256位推导密匙是使用 AES-GCM算法 来加密或解密 客户数据和密钥的. 

- 数字签名 
所有的服务主体都有一个椭圆曲线数字签名算法（ECDSA）密钥对。(..... 略引用文本)
AWS KMS内调用命令,认证,和通讯信息都是通过数字签名来进行校验的

- 密钥建立
AWS KMS使用两种不同的密钥建立方法。
第一被定义为C（1，2，ECC DH)  ......
第二个密匙建立方法是 C（2，2，ECC DH)......

- 信封加密 
许多密码系统中使用的基本结构是信封加密。信封加密使用两个或多个加密密钥来加密消息。一般来说,一个密钥是从一个较长期的静态密钥 K 导出的，另一个则是每个消息一个密钥的msgKey,是生成被用来对消息进行加密的。信封包数据是加密的消息的形式,密文=Encrypt（msgKey,message），然后使用长期静态密匙对msgKey进行加密，encKey =Encrypt（K，msgKey），然后把两个值（encKey，密文）打包成单一结构进行发送.
 接收者是有K的权限的，首先可以通过解密信封加密密钥，然后解密该信封中的加密密文。
 
##### 基本概念
本节介绍了一些在本白皮书阐述了一些基本概念。

- 客户主密钥（CMK）：CMK拥有一个Amazon资源名称（ARN），其包括一个唯一的密钥标识符(密钥ID)。
- 别名：一个用户友好的名称或别名，用来与CMK关联。别名可以在许多AWS KMS API代替密匙ID来使用。
- 权限：
- 授权：
- 数据密匙：HSMs中使用CMK派生的密匙作为实际加密数据的密匙.AWS KMS允许有获得授权的实体获得由CMK保护的数据密钥。他们可以同时返回明文（未加密）的密钥和加密过的密钥。
- 密文：
- 加密上下文：一个key-value键值对的附加信息 用来在AWS KMS中保护传输信息.

##### 用户主密匙 密匙层
你的分层密匙有一个最顶级的逻辑密匙,CMK. 一个CMK表示了一个密匙容器,被AWS ARN命名为一个唯一的标识定义.ARN会生成一个唯一标识,叫做 CMK key ID. CMK是通过用户AWS KMS初始化请求来创建的.在接受请求时,AWS KMS 会请求创建一个 HSM backing key(HBK)来放置到CMK容器中. 这些HSM中常驻的密匙都是用红色来进行标识的. 在HSM域中创建的HBK被设计成永远不能以明文进行导出的形式.取而代之的是在 HSM管理域的密匙加密下导出. 这些导出的 HBK密匙被称为导出的密匙令牌 EKTs.
密匙令牌被导出到一个高可用低延迟的存储中.你通过ARN连接到一个物理逻辑的CMK上,这可以表现成一个密匙层的最上层和一个加密服务的上下文.你可以在账户中创建多个CMK,并可以像其他的AWS命名资源一样设置策略.
在一个指定的CMK层中,HBK可以被视为一个CMK版本管理,当你想通过AWS KMS循环替换使用CMK的时候,一个新的HBK被创建并被分配和关联到CMK上作为活动的HBK.那个老的HBK们依然可以被用来解密和校验之前受保护的数据,但是只有活动的加密密匙才可以被用来保护新的数据信息.

![](http://qiniu.imolili.com/小书匠/1592301115704.png)
图片2 CMK密匙层

你可以通过AWS KMS,使用你自己的CMKs来直接保护你的信息,或者请求一个由HSM在你CMK下生成的密匙来进行.这些密匙被称为用户数据密匙,CDKs. CDK是可以返回成加密密文,明文,或两者同时返回.所有通过CMK加密过的数据(无论是用户自己定义的还是HSM生成的密匙)都必须通过调用AWS KMS HSM来进行解密.
返回的密文,或者已经解密的数据是永远不会在AWS KMS上被存储的.结果通过你调用AWS KMS的TLS连接进行返回.
 
我们总结了密钥层次和下表中的特定关键属性。
![](http://qiniu.imolili.com/小书匠/1592301119924.png)

1.域密钥
256位AES-GCM密匙,仅存在于 HSM 的内存中, 用来加密 CMKs的历史版本版本密匙 (HSM backing keys), 
每天变更

2.HSM backing key
256位对称密钥,仅在HSM的内存中存储,用来保护用户的数据和主密匙,使用domain key加密存储.
每年变更

3.数据加密密匙
256位AES-GCM密匙,只在HSM内存中存储,用来加密用户的数据和密匙,从 HBK中派生出来.
每次加密换一个,解密会重新生成

4.用户自定义数据密匙
用户自定义,从HSM中以明文或密文导出的密匙. 通过 HBK来加密并通过TLS通道返回给授权用户
应用中变更和使用

#### 客户主密匙

一个 CMK 指向一个逻辑密匙,但却可以关联一个或多个 HBKs. 这是通过一个 CreateKey API调用而生成的
调用语法:
{
 "Description": "string",
 "KeyUsage": "string",
 “Origin”: “string”;
 "Policy": "string"
}
参数说明:
可选的描述:密匙的描述,我们建议您填写描述，这能帮助你决定的该密匙是否适合.
可选的密匙使用用途:指定密匙的用途,目前这个默认值为 "加密/解密"
可选的来源:CMK的来源,默认时"AWS_CMS". 值 "EXTERNAL" 可以在需要从你现有的密匙管理系统中导入 Key Material.可以参看导入主密匙一节
可选的策略:密匙的策略。如果省略该参数，会使用默认的策略.这回开启拥有AWS KMS权限的IAM用户,root账户也可以管理这个密匙.

调用返回一个包含keyId的ARN描述
arn:aws:kms:\<region>:\<owningAWSAccountId>:key/\<keyId>

如果请求参数来源是 AWS_KMS ,在ARN被创建后,一个请求创建 HBK的请求通过授权的回话请求到 HSM.
HBK 是一个与 CMK keyId相关联的 256位的密匙, 它只能在HSM中被创建,并被设计成永远不能以明文形式脱离出HSM范围. 在 HSM中,通过当前的domain key DK0 生成了一个 HBK. 这些加密的 HBKs 就被称为 EKTs .虽然 HSM可以被配置成为使用各种不同的 密匙包装方法,但当前的实现是 AES-256 GCM. 由于其部分认证加密模式,一些明文导出的密匙令牌元数据也可以被保护.

这用文本可以被标识为 EKT = Encrypt (DK0,HBK).

你的 CMKs和随后的 HBKs有两种基本的保护形式: 你的 CMKs上的授权策略, 相关联的HBKs的加密保护,章节的剩下部分描述了这种加密保护 和 AWS KMS中的管理功能的安全性.
 
除了 ARN,可以为 CMK 创建一个用户友好的别名.一旦一个CMK关联的一个别名,这个别名就可以取代 ARN使用了.

CMKs的使用有多层的授权环绕.AWS KMS可以在加密内容和CMK之间启用单独分离的授权策略.举例来说一个AWS KMS信封加密亚马逊简单存储服务（Amazon S3的）对象继承了亚马逊S3桶的政策。然而，获得必要的加密密钥是由CMK访问策略来确定的.

##### 导入主密钥

AWS KMS提供了一种导入加密材料用来生成HBK的机制. 就像上面 客户主密匙 章节描述的那样, 当 CreateKey 命令使用 EXTERNAL作为 Origin参数值,一个 逻辑 CMK就不会创建基础的 HBK. 其加密材料必须通过 ImportKeyMaterial API调用来进行导入. 此功能允许你控制密码材料的 密匙创建和其使用时长.

==GetParametersForImport== 
在通过导入密匙材料创建主密匙之前,你必须获取导入密匙的必要参数.
以下是 GetParametersForImport 请求语法。
 {
"KeyId": "string",
"WrappingAlgorithm": "string", 
“WrappingKeySpec” : “string”
}
参数说明
KeyId:一个CMK的唯一密钥标识符。该值可以是全局唯一标识符ARN，或别名。
WrappingAlgorithm:用来加密你的密匙材料的算法。有效值为“RSAES_OAEP_SHA256", “RSAES_OAEP_SHA1” 或“RSAES_PKCS1_V1_5” 。AWS KMS建议您使用 RSAES_OAEP_SHA256。您可能需要根据您的密钥管理基础设施支持什么l来选择使用另一个密钥包装算法.
WrappingKeySpec:包装过的密匙(公钥)返回的类型.只有RSA 2048位公共密钥,即唯一有效的值是“RSA_2048” .

这个调用会发起一个从AWS KMS主机到HSM去生成一个新的RSA 2048的密匙对,这个密匙对会被用来在指定CMK keyid导入HBK. 私钥是受保护,并且只能被 HSM部件内部访问.

一个成功的调用会导致以下返回值。
{ "ImportToken": blob, "KeyId": "string", "PublicKey": blob, "ValidTo": number}
返回参数说明:
ImportToken:一个包含元数据(用来保证你的密匙材料已经被正确导入)的token.存储这个值,并将其发送到接下来的 ImportKeyMaterial 请求.
KeyId: 在你随后导入密钥材料时,在请求中使用这是CMK标识.
PublicKey:公钥用来加密你的密匙材料.公钥时通过 PKCS 编码的,一个 ASN DER编码的 RSA 公钥.
ValidTo:导入的token和公钥的过期时间.这些对象的过期时间是24小时. 如果你不在接下来的24小时内使用这些对象请求 ImportKeyMaterial, 你就必须重新请求一个新的.导入的token和公钥必须被同时使用.

==ImportKeyMaterial==
该 ImportKeyMaterial 请求导入必要的加密材料来创建 HBK。加密材料必须是256位对称密钥。它必须采用WrappingAlgorithm中指定的算法,并使用GetParametersForImport返回的公钥进行加密.
ImportKeyMaterial 采用下列参数。
{
 "EncryptedKey": blob,
 "ExpirationModel": "string",
 "ImportToken": blob,
 "KeyId": "string",
 "ValidTo": number
}
参数说明:
EncryptdKey:加密的密钥材料。通过你在GetParametersForImport请求中指定的加密算法和请求返回的公钥来加密你的密匙材料.
ExpirationModel:指定密钥材料是否到期。当该值是KEY_MATERIAL_EXPIRES,ValidTo参数就必须包含一个过期日期。当该值是KEY_MATERIAL_DOES_NOT_EXPIRE时,不要包含ValidTo参数。
ImportToken:GetParametersForImport返回的值
KeyId:密匙材料导入到的CMK标识,CMK的Origin必定是 EXTERNAL.
可选的ValidTo:导入的密匙材料的过期时间.当密匙材料过期后,AWS KMS会删除该密匙材料.CMK会变成无法使用.如果 ExpirationModel 被设置为 KEY_MATERIAL_DOES_NOT_EXPIRE.是你必须取消这个参数,否则就是必须的.

如果成功，CMK就可用了直到 AWS KMS标记其为过期.一旦导入的CMK过期,EKT就会从服务器存储层中删除

##### 启用和禁用密匙
启用和禁用CMK是与密匙的生命周期分开的.这不会改变密匙的真实状态,而是停止使用这个 CMK 层中所有 HBKs的能力.
这些都是简单的命令,执行需要一个 CMK keyId

![](http://qiniu.imolili.com/小书匠/1592301224138.png)


##### 密钥删除
您可以删除CMK和所有相关 HBKs。这是一个破坏性操作，从KMS删除密匙时，您应该谨慎行事。AWS KMS删除CMKs时强制执行的最少七天的等待时间。在等待期间的密匙被置于禁用状态等待删除。所有使用这么密匙的加解密操作都会失败.

对于EXTERNAL CMK,其生命周期是不通的。它多了一个等待导入的状态,而且不支持密匙轮换,未来, EKT 加密密匙令牌可以不再有等待时间,直接调用 DeleteImportedKeyMaterial来移除

使用 ScheduleKeyDeletion API可以删除 CMKs.它会需要下列参数:
{ "KeyId": “string”, "PendingWindowInDays": number}
参数说明:
KeyId:独特的CMK标识符用来被删除
可选的 PendingWindowInDays:等待期，以天数指明。等待期结束后，AWS KMS删除CMK和所有相关HBKs。此值是可选的。如果你有一个价值，它必须是7到30之间（含）。如果不包括值，则默认为30。

##### 轮换客户主密钥
你可以使你的CMK进行轮换,当前系统允许你为你的CMK选择年度轮换计划.当一个CMK被设置为轮换时,一个新的HBK被创建并标记活动的密匙为新的请求来保护信息。之前的活动密匙被移动到不活跃状态，但仍然可以被使用来解密之前版本所加密的任何密文值。AWS KMS不存储下CMK加密的密文。作为一个直接后果，这些密文值需要不活动的HBK来解密。这些旧的密文可以被重新加密通过调用 ReEncrypt 使用新的 HBK 重新加密。

您可以使用一个简单的API调用或AWS管理控制台设置密钥轮换。

#### 客户数据操作
你已经建立了CMK之后，它可以被用来执行加密操作。当数据被CMK加密后，所得到的就是一个客户端密文。密文包含两个部分：一个未加密报头（或明文），被认证的加密方案作为附加认证的数据保护，另一个是加密的部分。明文部分包括HBK标识符（HBKID）。这两个不可改变的字段确保AWS KMS可以在未来对对象进行解密。

##### 生成数据密匙
通过 GenerateDataKey API可以创建一个指定类型的数据密匙,或一个随机长度的密匙.下面是一个例子,你可以通过链接查看全API
https://docs.aws.amazon.com/kms/latest/APIReference/Welcome.html
以下是 GenerateDataKey 请求语法。
{"EncryptionContext": {"string" : "string"},"GrantTokens": ["string"],"KeyId": "string","KeySpec": "string","NumberOfBytes": "number"}
请求接受JSON格式的数据。
参数说明:
可选的 EncryptionContext:使用键值对作为包含额外的数据来在加密和解密使对密匙进行验证.
可选的GrantTokens: 一个授权token列表,表示其可以使用这个密匙,查看更多信息. https://docs.aws.amazon.com/kms/latest/developerguide/control-access.html 。 
可选的KeySpec: 标识加密算法和密钥大小的值。目前，要么 AES_128 要么 AES_256 。
可选的NumberOfBytes:一个包含产生字节数量的整数。

AWS KMS在认证了调用命令后,会获取当前活动的CMK的EKT. EKT会和你的请求,与加密上下文一起被传送到 HSM
该HSM将执行以下操作：
1. 生成所请求的机密材料，并保持在易失性存储器。
2. 把请求中定义的keyid对应的CMK中的EKT进行解密. HBK= Decrypt(DKi,EKT)
3. 产生一个随机数N.
4. 通过 HBK 和 N 派生一个256位 AES GCM加密密匙 K.
5. 加密秘密材料 密文=Encrypt(K,context,secret).
密文不会在AWS框架中保留,直接返回给你. 没有密文,加密上下文,CMK的使用授权,是不能解密的.
 
GenerateDataKey 返回明文的秘密材料,然后通过AWS KMS主机与HSM之间的安全通道传输,AWS KMS然后通过TLS会话将其发送给您。
 
以下是响应的语法。
{
"CiphertextBlob": "blob",
"KeyId": "string",
"Plaintext": "blob"
}
数据密钥的管理是留给应用程序开发人员的。他们可以在任何频率轮换这些密匙。此外，数据密钥本身可以 被不同的CMK或一个轮换CMK通过 ReEncrypt 重新加密全部细节可以在这里找到：https://docs.aws.amazon.com/kms/latest/APIReference/Welcome.html 。

##### 加密
AWS KMS的一个基本功能使在CMK下加密一个对象.AWS KMS经过设计可以在HSMs下提供一个低延迟的加密操作.每次直接调用的明文有4kb大小的限制.KMS加密SDK可以被用来加密较大的消息. AWS KMS在认证了调用命令后,会获取当前活动的 CMK的 EKT. 然后通过 EKT,你的明文,加密上下文 请求到该地区的任意可用的 HSM上.

该HSM会执行以下操作
1. 通过解密EKT获得 HBK = Decrypt（ DKi ， EKT)
2. 产生一个随机数N.
3. 从 HBK 上派生一个随机数N的 256位 AES-GCM的数据加密密匙 K.
4. 加密明文的 密文= Encrypt( K ,上下文 ,明文)
密文不会在AWS框架中保留,直接返回给你. 没有密文,加密上下文,CMK的使用授权,是不能解密的.

##### 解密
AWS KMS请求解密一个对象需要一个加密值和加密的上下文.AWS KMS使用 AWS signature version 4 signed requests 验证授权这个请求,并从加密值的 包裹key中提取出 HBKID. HBKID被用来获取解密用的 EKT, 密匙id和密匙id的策略.请求会被密匙策略进行验证并获得授权,然后任何与 密匙ID 相关的 IAM 策略也会生效.解密功能类似于加密功能.

以下是 解码 请求语法。
{"CiphertextBlob": "blob","EncryptionContext": { "string" : "string" }"GrantTokens": ["string"]}
参数说明:
CiphertextBlob:密文，包括元数据。
可选的EncryptionContext:加密上下文。如果在加密时有指定上下文,则解密时也需要指定。欲了解更多信息，请参阅https://docs.aws.amazon.com/kms/latest/developerguide/encrypt-context.html 。
可选的 GrantTokens:一个授权令牌的列表,用来提供解密权限.

密文和EKT时和加密上下文一起通过一个经过授权的会话发送到HSM进行解密的

该HSM执行：
1. 解密EKT获得 HBK = Decrypt (DKi, EKT);
2. 从密文数据结构中提取随机数 N.
3. 使用HBK和随机数N重新生成一个 256位的 AES-GCM 数据加密密匙 K
4. 解密密文以获得明文 = Decrypt(K,上下文,密文)

生成的密钥ID和明文通过安全会话返回给AWS KMS主机，然后通过TLS连接回调用客户应用程序。
以下是响应的语法。
 {
 "KeyId": "string",
 "Plaintext": blob
}
如果调用应用程序要确保明文的真实性，它必须验证返回的密钥ID是预期中一样的值。

##### 重新加密对象
通过一个CMK加密的现存的密文可以通过一个重新加密命令来加密到另一个CMK下.重新加密数据时在服务端通过新的CMK执行的,不需要客户端调用密匙解密出明文就可以进行.数据会先被解密然后再次加密.

以下是该请求的语法。
{
"CiphertextBlob": "blob",
"DestinationEncryptionContext": { "string" : "string" },
"DestinationKeyId": "string",
"GrantTokens": ["string"],
"SourceEncryptionContext": { "string" : "string"}
}
请求接受JSON格式的以下数据。
参数说明:
CiphertextBlob:需要重新加密的密文
可选的DestinationEncryptionContext:重新加密时需要的加密上下文
DestinationKeyId:用来重新加密数据的密匙Id
可选的GrantTokens:授予令牌来提供权限
可选的SourceEncryptionContext: 加密和解密 CiphertextBlob的加密上下文

这个过程集合了前文所述的解密和加密两个操作
密文会在初始的HBK下解密然后使用当前的指定的CMK下的HBK进行加密,如果两个命令的CMK时相同的,调用会将密文从旧的HBK解密使用当前最后版本的HBK加密
 
以下是响应的语法。
{
 "CiphertextBlob": blob,
 "KeyId": "string",
 "SourceKeyId": "string"
}
如果调用应用程序要确保基础明文的真实性，它必须验证 SourceKeyId 返回是于其中的值。

#### 域和域的状态
在AWS一个地区中,企业内部的AWS KMS实体相互协作的集合称为域.域包括一组可信的实体，一组规则，以及一组密钥，称为域密钥。域密钥属于域的成员的HSM之间共享。域状态包括以下字段。

![](http://qiniu.imolili.com/小书匠/1592301133340.png)

名称:一个域名来标识这个域
成员:HSM的是域的成员，包括他们的公共签名密钥和公共列表和公共协议密匙
操作者:一个实体的列表.公共签名密匙和操作服务的一个角色 (KMS操作员或服务器host)
规则:调用HSM执行命令的一系列合法的规则
域密匙:在域中当前使用的一系列对称域密匙

完整的域状态旨在HSM上有效,HSM域成员直接同步后得出的一个域令牌

##### 域密钥
域中的所有HSMs共享一个域密匙集合 {DKr} .这些密匙通过 域状态常规导出 进行共享. 导出的域状态可以在该域中任意一个成员 HSM 上导入. 通过 管理域状态 一节 可以了解这是如何实现的.

这组域密匙 {DKr}, 包含一个活动的域密匙和其他若干不活跃的域密匙. 域密匙每天都轮换来保证 我们 在 Recommendation for Key Management Part1中所述的特性. 在 域密匙轮换的时候, 所有在将停用的域密匙下加密的 CMK 会通过新的活动域密匙重新加密. 活动域密匙被用来加密任何新的 EKTs.过期的 域密匙依然可以被用来解密之前加密的 EKTs.

##### 导出域的令牌
域参与制之间的同步时一个经常性的需求.这是通过在域变更的时候导出 域状态来实现的.域状态导出成一个域令牌

![](http://qiniu.imolili.com/小书匠/1592301129568.png)

名称:一个域名来标识这个域
成员:HSM的是域的成员，包括他们的公共签名密钥和公共列表和公共协议密匙
操作者:一个实体的列表.公共签名密匙和操作服务的一个角色 (KMS操作员或服务器host)
规则:调用HSM执行命令的一系列合法的规则
-- 译者注:上面的内容和域状态中一致,下面两个字段是令牌特有的
加密过的域密匙:通过信封加密的域密钥。域名是通过上面列出的成员的公共协议密匙信封加密
签名:HSM生成一个域状态的签名

导出的域令牌是域中各个实体操作信任的根本源泉.

#### 管理域状态
略:这里主要是用来管理HSM集群的

#### 内部通信安全
略:这里主要是阐述AWS KMS和HSM及其他服务机器主机之间通信的安全方式

引用文档略
感谢名单略
文档版本略

#### 附录 - 缩写和密匙类型
==缩略语==
AES:高级加密标准
AES 高级加密标准
CDK 客户数据密匙
CMK 客户主密钥
CMKID 客户主密钥标识符
DK 域密钥
ECDH 椭圆曲线的Diffie-Hellman
ECDSA 椭圆曲线数字签名算法
EKT 导出密钥令牌
ESK 加密的会话密钥
GCM 伽罗瓦计数器模式
HBK HSM预备密匙
HBKID HSM预备密匙标识符
HSM 硬件安全模块
SHA256 长度256位安全的散列算法摘要
==密匙类型== 
HBK:HSM预备密匙,都是 256位的主密匙,从其中派生出特定的可以使用的密匙
DK:域密匙,256位AES-GCM密匙,(最大的密匙)他在域中所有成员之间共享.被用来保护 HSM预备密匙材料和HSM服务主机的会话密匙.
DKEK:域密匙的加密密匙是从一个主机上生成的AES-256GCM密匙,被用来加密当前一组域密匙,在HSM主机之间同步域状态
dHAK,QHAK:HSM协议密匙对,没有HSM启动时在本地都会通过曲线secp384r1上生成一个 ECDH协议密匙对.
dE,QE:临时协议密匙对.HSM和服务主机生成临时的协议密匙对.
dHSK,QHSK. HSM签名密匙对
dOS,QOS:操作签名密匙对
K:数据加密密匙
SK:会话密匙

> 译者注:整个系统大致是这个样子的
硬件有一组 HSM , 主要是用来存储密匙的,称为 密匙存储, 默认AWS KMS使用的是内置的 HSM ,也可以通过自定义密匙存储使用自己的 HSM集群.
这样一组 HSM + 前端对应的所有生成的密匙被称为一个域.
这个域中所有成员都有一个共享的域密匙,域密匙用来加密 HSM的 后背密匙材料和HSM 服务主机的会话密匙
域密匙也有自己的加密密匙,用来导出域状态,域状态可以在域中所有的HSM主机之间同步配置和数据

> 默认的HSM存储可以导入密匙材料,可以轮换密匙材料,而自定义的密匙存储HSM则不行















