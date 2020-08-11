---
title: EOS
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

EOS主链的 chainid是
**chainid:aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906**

#### EOS客户端Cleos安装和使用
1. 必须使用git clone EOSIO/eos --recursive
2. 编译安装需要有7GB以上的内存
3. 智能合约编译工具在 $EOS_SOURCE/build目录下也需要进行安装
4. cleos创建的钱包目录在 ~/eosio-wallet/xxx
5. cleos可以使用fluent api参数 -u 指定主网节点

#### EOS节点应用nodeos
1. 节点数据一般在 ~/.local/share/eosio
2. 跳过签名 nodeos --skip-transaction-signatures

> 如果您的本地运行nodeos，作为开发人员在不处理密钥的情况下测试功能的简便方法，则可以运行nodeos以便不需要Transaction签名。
$ nodeos --skip-transaction-signatures
然后对于任何需要签名的操作，请使用-s选项
$ cleos ${command} ${subcommand} -s ${param}

#### EOS钱包管理keosd

==使用独立的钱包应用==

> 您可以使用可在program/keosd中找到的单独的钱包应用程序，而不是使用内置于nodeos的钱包功能。默认情况下，节点使用端口8888，因此请为钱包应用选择另一个端口。
$ keosd --http-server-endpoint 127.0.0.1:8887
然后，对于任何需要签名的操作，请使用-wallet-host和-wallet-port选项.
$ cleos —-wallet-url 127.0.0.1:8887 ${command} ${subcommand} ${param}

#### EOS账户的权限控制和多重签名账户

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/EOS/2020811/1597124084095.png)

上表中，除了权限（Permission）和秘钥（Keys）之外，还有两栏，一个是权重（Weight），另一个是域值（Threshold）.

这两个概念也至关重要，还是拿大家熟悉的转账来举个例子吧，按照上表的配置，如果你想转账给 vitalikoneos 这个账户，你需要将秘钥的权重相加，如果结果不小于域值，该笔交易才被认为是合法的，即 EOS7... 和 EOS8... 对应的私钥都得对该笔交易签名，它们的权重和才不小于域值 2 。

同样的道理，如果你想修改 @Active 的秘钥，你需要用 EOS6... 和 EOS5... 所对应的秘钥同时对这个操作进行签名。可以看到我用了 4 对秘钥对来管理我的账户，这个安全性已经非常高了。

当你创建一个账户时，你的账户默认包含两种权限：@owner 和 @active，
其中 @owner主要用来管理其他权限的变更，例如修改 @active 对应的 Keys，新建或删除一个 @publish 权限等；
而 @active 权限在创建之初主要用来执行转账等合约操作，即如果你要转出 EOS，你需要 @active 下的 Keys 对该笔交易签名。

#### EOS Cleos命令参考

| 操作 | 语法 |
| --- | --- |
| 获取所有命令 | `$ cleos` |
| 获取所有子命令 | `$ cleos ${command}` |
| 链接节点 | `$ cleos --url ${node}:${port}` |
| 查询区块链状态 | `$ cleos get info` |
| 通过transaction_id获取交易 | `$ cleos get transaction ${transaction_id}` |
| 通过帐户获取交易 | `$ cleos get transaction ${account}` |
| 转账EOS | `$ cleos transfer ${from_account} ${to_account} ${quantity}` |
| 钱包 - 创建钱包 | `$ cleos wallet create {-n} ${wallet_name}` |
| 钱包 - 钱包列表 | `$ cleos wallet list` |
| 钱包 - 导入密钥 | `$ cleos wallet import ${key}` |
| 钱包 - key列表 | `$ cleos wallet keys` |
| 钱包 - 锁 | `$ cleos wallet lock -n ${wallet_name}` |
| 钱包 - 解锁钱包 | `$ cleos wallet unlock -n ${wallet_name} --password ${password}` |
| 钱包 - 打开钱包 | `$ cleos wallet open` |
| 帐户 - 创建密钥 | `$ cleos create key` |
| 帐户 - 创建帐户 | `$ cleos create account ${control_account} ${account_name} ${owner_public_key} ${active_public_key}` |
| 帐户 - 查看子账户 | `$ cleos get servants ${account_name}` |
| 帐户 - 检查帐户余额 | `$ cleos get account ${account_name}` |
| 权限 - 创建或修改权限 | `$ cleos set account permission ${permission} ${account} ${permission_json} ${account_authority}` |
| 合约 - 部署 | `$ cleos set contract ../${contract}.wast ../${contract}.abi　or $cleos set contract ../${contract}` |
| 合约 - 查询ABI | `$ cleos get code -a ${contract}.abi ${contract}` |
| 合约 - 推送操作 | `$ cleos push action ${contract} ${action} ${param} -S ${scope_1} -S ${scope_2} -p ${account}@active` |
| 合约 - 查询表 | `$ cleos get table ${field} ${contract} ${table}` |

> cleos包含所有命令的文档。有关cleos已知的所有命令的列表，只需简单地运行它，不带任何参数,同样的,要获得所有特定子命令得帮助,也请使用无参数运行它.

#### 链接节点
指明使用本地节点或者指定得其他公共节点,可以使用 -u和-p参数
```
$ cleos -u localhost:8889 <subcommand>
$ cleos -H test1.eos.io -p 80 <subcommand>
```
由于你需要在每一次使用cleos都加上这些参数,所以可以使用alias定义快捷别名就好

#### 查询区块链状态
```
$ cleos get info
{
  "server_version": "7451e092",
  "head_block_num": 6980,
  "last_irreversible_block_num": 6963,
  "head_block_id": "00001b4490e32b84861230871bb1c25fb8ee777153f4f82c5f3e4ca2b9877712",
  "head_block_time": "2017-12-07T09:18:48",
  "head_block_producer": "initp",
  "recent_slots": "1111111111111111111111111111111111111111111111111111111111111111",
  "participation_rate": "1.00000000000000000"
}
```

#### 通过transaction_id获取交易
如果是本地nodeos节点,需要开启 account_history_api_plugin得插件才行
```
$ cleos get transaction eb4b94b72718a369af09eb2e7885b3f494dd1d8a20278a6634611d5edd76b703
{
  "transaction_id": "eb4b94b72718a369af09eb2e7885b3f494dd1d8a20278a6634611d5edd76b703",
  "processed": {
    "refBlockNum": 2206,
    "refBlockPrefix": 221394282,
    "expiration": "2017-09-05T08:03:58",
    "scope": [
      "inita",
      "tester"
    ],
    "signatures": [
      "1f22e64240e1e479eee6ccbbd79a29f1a6eb6020384b4cca1a958e7c708d3e562009ae6e60afac96f9a3b89d729a50cd5a7b5a7a647540ba1678831bf970e83312"
    ],
    "messages": [{
        "code": "eos",
        "type": "transfer",
        "authorization": [{
            "account": "inita",
            "permission": "active"
          }
        ],
        "data": {
          "from": "inita",
          "to": "tester",
          "amount": 1000,
          "memo": ""
        },
        "hex_data": "000000008040934b00000000c84267a1e80300000000000000"
      }
    ],
    "output": [{
        "notify": [{
            "name": "tester",
            "output": {
              "notify": [],
              "sync_transactions": [],
              "async_transactions": []
            }
          },{
            "name": "inita",
            "output": {
              "notify": [],
              "sync_transactions": [],
              "async_transactions": []
            }
          }
        ],
        "sync_transactions": [],
        "async_transactions": []
      }
    ]
  }
}
```

#### 通过账户获取交易id
```
$ cleos get transactions inita
[
  {
    "transaction_id": "eb4b94b72718a369af09eb2e7885b3f494dd1d8a20278a6634611d5edd76b703",
    ...
  },
  {
    "transaction_id": "6acd2ece68c4b86c1fa209c3989235063384020781f2c67bbb80bc8d540ca120",
    ...
  },
  ...
]
```

#### 转账EOS
cleos transfer \[ 转出账户名 ]  \[ 转入账户名 ]  '0.01 EOS' 'memo'

```
$ cleos transfer inita tester 1000
```

#### 创建钱包

创建钱包时不指定名称，钱包将使用名称'default'
您可以在命令中添加-n ${wallet_name}命名钱包

```
$ cleos wallet create
Creating wallet: default
Save password to use in the future to unlock this wallet.
Without password imported keys will not be retrievable.
"PW5JD9cw9YY288AXPvnbwUk5JK4Cy6YyZ83wzHcshu8F2akU9rRWE"

$ cleos wallet create -n second-wallet
Creating wallet: second-wallet
Save password to use in the future to unlock this wallet.
Without password imported keys will not be retrievable.
"PW5Ji6JUrLjhKAVn68nmacLxwhvtqUAV18J7iycZppsPKeoGGgBEw"
```

#### 钱包列表

列表钱包命令将列出每个钱包状态的所有钱包，\*符号表示钱包当前已解锁。
```
$ cleos wallet list
Wallets:
[
  "default *",
  "second-wallet *"
]
```

#### 导入密钥
```
$ cleos wallet import 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
imported private key for: EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
```

#### 创建密钥
注意：cleos不保存生成的私钥。
```
$ cleos create key
public: EOS4toFS3YXEQCkuuw1aqDLrtHim86Gz9u3hBdcBw5KNPZcursVHq
private: 5JKbLfCXgcafDQVwHMm3shHt6iRWgrr9adcmt6vX3FNjAEtJGaT
```

#### 列出钱包密钥
```
$ cleos wallet keys
[[
    "EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV",
    "5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
  ]
]
```

#### 锁定钱包
注意锁定的钱包在列表中没有\*符号

```
$ cleos wallet lock -n second-wallet
Locked: 'second-wallet'
```

#### 解锁钱包
要解锁它，请指定创建钱包时获得的密码
```
$ cleos wallet unlock -n second-wallet --password PW5Ji6JUrLjhKAVn68nmacLxwhvtqUAV18J7iycZppsPKeoGGgBEw
Unlocked: 'second-wallet'

$ cleos wallet unlock
password:
```

#### 打开钱包
```
$ cleos wallet open
Wallets: [
  "default"
]
$ cleos wallet open -n second-wallet
Wallets: [
  "default",
  "second-wallet"
]
```

#### 查询账户名
`cleos get accounts [ 账户公钥 ]`

#### 创建帐号
您将需要您的EOS密钥才能创建帐户,现在一般都是父账户创建子账户了
账户名要求必须是12位字符，其中的可用字符为：\[1-5] 和 \[a-z] 。
购买带宽和cpu可以为0,但是内存最少为3kb
第一个账号为支付账号
第二个为要生成的账号
第三个为对应生成账号的公匙

```
cleos system newaccount 
--stake-net '0.0 EOS' 
--stake-cpu '0.0 EOS' 
--buy-ram-kbytes 3 
vfrwffsesdfk  
xx34xx2xx5xx 
EOS59vJPCZ4Qv1fVCDeCckSb2xnZmNkbdppdk3QVRnsxzX5bydBuM
```

#### 查询本账户创建的子账户
```
$ cleos get servants inita
{
  "controlled_accounts": [
    "tester"
  ]
}
```

#### 查询账户信息
```
$ cleos get table eosio [账户名] userres

$ cleos get account tester
```

#### 创建或需改权限
创建权限
```
$ cleos set account permission test active '{"threshold" : 1, "keys" : [{"permission":{"key":"EOS8X7Mp7apQWtL6T2sfSZzBcQNUqZB7tARFEm9gA9Tn9nbMdsvBB","permission":"active"},"weight":1}], "accounts" : [{"permission":{"actor":"acc2","permission":"active"},"weight":50}]}' owner
```

修改权限
```
$ cleos set account permission test active '{"threshold" : 1, "keys" : [], "accounts" : [{"permission":{"actor":"sandwich","permission":"active"},"weight":1},{"permission":{"actor":"acc1","permission":"active"},"weight":50}]}' owner

变更active
cleos set account permission <转让账户名> active '{"threshold":1,"keys":[{"key":"<对方公钥>","weight":1}]}' owner -p <转让账户名>@owner

变更owner
cleos set account permission <转让账户名> owner '{"threshold":1,"keys":[{"key":"<对方公钥>","weight":1}]}' -p <转让账户名>@owner
```

设置multisig
```
$ cleos set account permission test active '{"threshold" : 100, "keys" : [{"permission":{"key":"EOS8X7Mp7apQWtL6T2sfSZzBcQNUqZB7tARFEm9gA9Tn9nbMdsvBB","permission":"active"},"weight":25}], "accounts" : [{"permission":{"actor":"@sandwich","permission":"active"},"weight":75}]}' owner


$ cleos set account permission vitalikoneos owner '{
    "keys": [{
        "key": "EOS7bePjtecDvVwRj937B3aaaXyph1vGdAkgu5jibYJ1vfWNaCUWk",
        "weight": 1
    },
    {
        "key": "EOS4z4VM5QH4NWAGf2BpYKhHxhqM7Dti2Ssmk6XXk1v7U1kjaVPgS",
        "weight": 1
    }],
    "threshold": 2
}' -p vitalikoneos@owner

$ cleos set account permission vitalikoneos active '{
    "keys": [{
        "key": "EOS7bePjtecDvVwRj937B3aaaXyph1vGdAkgu5jibYJ1vfWNaCUWk",
        "weight": 1
    },
    {
        "key": "EOS4z4VM5QH4NWAGf2BpYKhHxhqM7Dti2Ssmk6XXk1v7U1kjaVPgS",
        "weight": 1
    }],
    "threshold": 2
}' owner -p vitalikoneos@owner
```

#### 查看账户余额
```
cleos get currency balance eosio.token [ 账户名 ]
cleos get table eosio.token [ 账户名 ]  accounts
```

#### 内存
```
1.购买内存
cleos [-u ] system buyram
2.卖出内存
cleos [-u ] system sellram
```

#### 查看账户抵押信息
```
cleos system listbw [ 账户名 ]
cleos get table eosio [ 账户名 ]  delband

可追加抵押增加票数（抵押EOS可分别获得相应网络、CPU资源，票数为两项之和） 
eos system delegatebw <本人账户名>  <本人账户名>  '0.001 EOS' '0.02 EOS'

撤销抵押（同时撤销相应的票数。三天后到账）
eos system undelegatebw <本人账户名>  <本人账户名>  '0.001 EOS' '0.02 EOS'
```

#### 投票
查看节点清单 `eos system listproducers`
```
好了，现在您可以开始为喜欢的节点投票了。比如想要投给eoscannonchn，您只需要输入：
./cleos.sh system voteproducer prods YOUR_ACCOUNT eoscannonchn -p YOUR_ACCOUNT
```