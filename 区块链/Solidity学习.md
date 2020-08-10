---
title: Solidity学习
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

需要注意的时本文有缺漏,翻译来源大多直接时google翻译,仅供参考,具体编码还是要搜索关键字才能完整使用

#### solidity源文件的布局

##### Pragma 版本

源文件可以（并且应该）使用所谓的版本编译指示进行注释，以拒绝随后可能引入不兼容更改的编译器版本进行编译。 我们尝试将这些更改保持在绝对最小值，尤其是在语义变化也需要更改语法的情况下引入更改，但这并不总是可能的。 因此，至少对于包含突破性更改的版本，读取更改日志总是一个好主意，这些版本将始终具有0.x.0或x.0.0格式的版本。

版本pragma使用如下：

`pragma solidity ^0.4.0;`

这样一个源文件不会使用比版本0.4.0之前的编译器编译，并且它也不会在从0.5.0版本开始的编译器（第二个条件通过使用^添加）起作用。 这个想法是，直到版本0.5.0才会有变化，所以我们可以随时确定我们的代码将按照我们打算的方式进行编译。 我们不会修复编译器的确切版本，因此修补程序版本仍然可能。
可以为编译器版本指定更复杂的规则，表达式遵循由npm使用的规则。

##### 导入其他源文件

Solidity支持与JavaScript中可用的导入语句（来自ES6）的引用语句，尽管Solidity不知道“default export”的概念。
在全局层面，您可以使用以下形式的导入语句：

`import "filename";`
此语句从“filename”（以及导入的符号）导入所有全局符号到当前全局范围（与ES6不同，但与Solidity相反）。

`import * as symbolName from "filename";`
创建一个新的全局符号symbolName，其成员都是来自“filename”的全局符号。

`import {symbol1 as alias, symbol2} from "filename";`
创建新的全局符号alias和symbol2，分别从“filename”引用symbol1和symbol2。

另一种语法不是ES6的一部分，但可能很便于：
`import "filename" as symbolName;`
相当于 ==import * as symbolName from "filename";==

##### 路径

在上文中，文件名始终被视为具有/作为目录分隔符的路径. .作为当前目录和..作为父目录。 当. 或..后跟一个字符，除了/，它不被认为是当前或父目录。 所有路径名称都被视为绝对路径，除非它们以当前的路径开头. 或父目录...

要从与当前文件相同的目录导入文件x，请使用导入“./x”作为x ;. 如果使用导入“x”作为x; 相反，可以引用不同的文件（在全局“包含目录”中）。

这取决于编译器（见下文）如何实际解析路径。 一般来说，目录层次结构不需要严格地映射到本地文件系统上，它也可以映射到通过例如文件发现的资源比如 ipfs，http或git。

##### 在实际编译器中使用

当调用编译器时，不仅可以指定如何发现路径的第一个元素，而且可以指定路径前缀重新映射， `github.com/ethereum/dapp-bin/library` 被重新映射到 `/usr/local/dapp-bin/library`，编译器将从那里读取文件。 如果可以应用多重重新映射，则首先尝试使用最长密钥。 这允许一个“回退-重新映射”与例如 “”映射到“ `/usr/local/ include/solidity` ”。 此外，这些重新映射可以依赖于上下文，它允许您配置包导入例如 不同版本的同名库。

##### 注释

```
// 单行注释.

/*
多行注释
*/
```

---------------------

#### 合约的结构体

Solidity的合约类似于面向对象语言的类。 每个合同都可以包含State Variables, Functions, Function Modifiers, Events, Structs Types 和 Enum Types的声明。 此外，合约可以继承其他合约。

##### 状态变量

状态变量是永久存储在合约存储中的值。

```
pragma solidity ^0.4.0;

contract SimpleStorage {
    uint storedData; // 状态变量
    // ...
}
```

> 请参阅有关状态变量类型的“类型”部分，“可见性”和“获取器”，以获取可见性的可能选择。

##### 函数 Functions

函数是一个代码合同中的可执行单元。

```
pragma solidity ^0.4.0;

contract SimpleAuction {
    function bid() payable { // 函数
        // ...
    }
}
```

> 函数调用可以内部或外部发生，均有不同程度的知名度对其他合同（可见性和getter）的。

##### 函数修饰符 Function Modifiers

函数修饰符可用于以声明方式修改函数的语义.

```
pragma solidity ^0.4.11;

contract Purchase {
    address public seller;

    modifier onlySeller() { // Modifier
        require(msg.sender == seller);
        _;
    }

    function abort() onlySeller { // 调用Modifier
        // ...
    }
}
```

##### 事件

事件是与EVM日志工具便捷接口。

```
pragma solidity ^0.4.0;

contract SimpleAuction {
    event HighestBidIncreased(address bidder, uint amount); // 事件

    function bid() payable {
        // ...
        HighestBidIncreased(msg.sender, msg.value); // 触发事件
    }
}
```

##### 结构类型

Structs是可以分组几个变量的自定义类型

```
pragma solidity ^0.4.0;

contract Ballot {
    struct Voter { // 结构体
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
}
```

##### 枚举类型

枚举可用于创建具有有限值集的自定义类型

```
pragma solidity ^0.4.0;

contract Purchase {
    enum State { Created, Locked, Inactive } // 枚举
}
```

-----------------------

#### 类型

Solidity是一种静态类型的语言
类型可以在含有运算符的表达式与彼此交互。

##### 值类型

以下类型也称为值类型，因为这些类型的变量将始终按值传递，即当它们用作函数参数或分配时，它们始终被复制。

布尔
整型
地址 Address
固定大小的字节数组
动态大小的字节数组
固定点数 Fixed Point Numbers
地址文字 Address Literals
理性和整数文字 Rational and Integer Literals
字符串文字 String Literals
十六进制文字 Hexadecimal Literals
枚举

##### 函数类型 Function Types

函数类型是函数的类型。 函数类型的变量可以从函数分配，函数类型的函数参数可以用于将函数传递给函数并从函数调用返回函数。 功能类型有两种功能 - 内部和外部功能.
1. 内部函数只能在当前合约内部更详细地调用（更具体地说是在当前代码单元内部，也包括内部函数库和继承函数），因为它们不能在当前契约的上下文之外执行。 调用内部函数是通过跳转到其入口标签来实现的，就像在内部调用当前合同的函数一样。
2. 外部功能由一个地址和一个函数签名，他们可以通过传递和外部函数调用返回。

功能类型记为如下：
`function (<parameter types>) {internal|external} [pure|constant|view|payable] [returns (<return types>)]`
`function (<参数类型>) {internal|external} [pure|constant|view|payable] [returns (<返回类型>)]`

与参数类型相反，返回类型不能为空 - 如果函数类型不返回任何东西，则returns (\<return types>)部分必须被省略。
缺省情况下，函数类型为internal，内部关键字可以省略。 与此相反，合同函数本身默认为公用，只能作为类型的名称中使用时，默认为内部。

在当前合约中有两种访问函数的方法：直接以其名称，f或使用this.f. 前者将导致内部功能，后者在外部功能中。

如果函数类型变量未初始化，则调用它将导致异常。 如果在使用delete之后调用函数也会发生这种情况。

如果在Solidity的上下文中使用外部函数类型，则将它们视为函数类型，它以单个字节24类型将该地址后跟功能标识符编码在一起。
请注意，现行合约的公共函数既可以作为内部函数也可以用作外部函数。 要使用f作为内部函数，只需使用f，如果要使用其外部形式，请使用this.f.

##### 引用类型

复杂类型，即不总是适合256位的类型，必须比我们已经看到的值类型更仔细地处理。 由于复制它们可能相当昂贵，我们必须考虑我们是否希望将它们存储在内存中（不是持久存储的）或存储（保存状态变量的位置）。

数据位置 Data location
数组
分配内存数组 Allocating Memory Array
数组文字/内联数组 Array Literals / Inline Arrays
成员
结构体 Structs
映射 Mappings
操作者涉及LValues Operators Involving LValues
delete

##### 基本类型转换

###### 隐性转换

如果运算符应用于不同类型，编译器将尝试将其中一个操作数隐式转换为其他类型（对于赋值也是如此）。 一般来说，值类型之间的隐式转换是有可能的，如果它在语义上有意义且没有信息丢失：uint8可以转换为uint16和int128到int256，但int8不能转换为uint256（因为uint256不能保持为-1）。 此外，无符号整数可以转换为相同或更大尺寸的字节，但反之亦然。 任何可以转换为uint160的类型也可以转换为地址。

###### 显式转换

如果编译器不允许隐式转换，但是你知道你正在做什么，那么有时可以使用显式类型转换。 请注意，这可能会给您一些意想不到的行为，所以一定要测试，以确保结果是你想要的！ 以下示例将负的int8转换为uint：
```
int8 y = -3;
uint x = uint(y);
```
在这段代码片段末尾，x将具有0xfffff..fd（64个十六进制字符）的值，在256位的二进制补码表示中为-3。
如果一个类型被明确转换为较小的类型，则高阶位被切断：
```
uint32 a = 0x12345678;
uint16 b = uint16(a); // b will be 0x5678 now
```

###### 类型推导

为方便起见，并不总是需要明确指定变量的类型，编译器会根据分配给该变量的第一个表达式的类型自动推断：
```
uint24 x = 0x123;
var y = x;
```
这里，y的类型将是uint24。 对于函数参数或返回参数，不能使用var。

该类型仅从第一个赋值中推导出来，所以以下代码段中的循环是无限的，因为我i将具有类型uint8，并且此类型的任何值都小于2000.对于 `for (var i = 0; i < 2000; i++) { ... }`

------------------------

#### 单位和全局变量

##### ether单位
wei
finney
szabo
ether

##### 时间单位

可以使用文字数字后的秒，分，小时，天，周和年份进行后缀转换，其中以秒为单位，以下列方式使用
```
1 == 1 seconds
1 minutes == 60 seconds
1 hours == 60 minutes
1 days == 24 hours
1 weeks == 7 days
1 years == 365 days
```

> 如果您使用这些单位执行日历计算，请小心，因为不是每年等于365天，甚至每天都没有24小时，因为闰秒。


##### 特殊变量和函数

有一些特殊的变量和函数总是存在于全局命名空间中，主要用于提供关于块链的信息。

###### 块和事务属性

*   block.blockhash(uint blockNumber) returns (bytes32) 给定块的哈希 - 仅适用于256个不包括当前最新块
*   block.coinbase (address) 当前块矿工地址
*   block.difficulty (uint) 当前块难度
*   block.gaslimit (uint) 当前块gaslimit
*   block.number (uint) 当前数据块号
*   block.timestamp (uint) 当前块时间戳从unix纪元开始为秒
*   msg.data (bytes) 完整的calldata
*   msg.gas (uint) 剩余gas
*   msg.sender (address) 该消息（当前呼叫）的发送者
*   msg.sig (bytes4) 呼叫数据的前四个字节（即功能标识符）
*   msg.value (uint) 发送的消息的数量
*   now (uint) 当前块时间戳（block.timestamp的别名）
*   tx.gasprice (uint) gas价格的交易
*   tx.origin (address) 交易的发送者（全调用链）

msg的所有成员的值（包括msg.sender和msg.value）可以针对每个外部函数调用进行更改。 这包括对库函数的调用。如果要使用msg.sender在库函数中实现访问限制，则必须手动提供msg.sender的值作为参数。

###### 错误处理

`assert(bool condition): `
如果条件不满足，则抛出 - 用于内部错误。 

`require(bool condition): `
如果条件不满足，则抛出 - 用于输入或外部组件中的错误。 

`revert(): `
中止执行并恢复状态更改

###### 数学和加密功能

`addmod(uint x, uint y, uint k) returns (uint) `
计算（x + y）％k，其中以任意精度执行加法，并且不在2 ** 256处围绕

`mulmod(uint x, uint y, uint k) returns (uint) `
计算（x * y）％k，其中乘法以任意精度执行，并且不会在2 ** 256处循环。

`keccak256(...) returns (bytes32) `
计算的（紧凑）参数的Ethereum-SHA-3（Keccak-256）的散列

`sha256(...) returns (bytes32) `
计算（紧密包装）参数的SHA-256散列

`sha3(...) returns (bytes32) `
keccak256的别名

`ripemd160(...) returns (bytes20) `
计算（紧密包装）参数的RIPEMD-160哈希值

`ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address) `
从椭圆曲线签名中恢复与公钥相关的地址，或者在错误时返回零（示例使用）

在上面，“紧密包装”意味着参数是无连接的连接。 这意味着以下内容完全相同：
`keccak256("ab", "c")`
`keccak256("abc")`
`keccak256(0x616263)`
`keccak256(6382179)`
`keccak256(97, 98, 99)`

如果需要填充，可以使用显式类型转换：`keccak256("\x00\x12")` 与 `keccak256(uint16(0x12))`相同。
请注意，常量将使用存储它们所需的最少字节数来打包。 
这意味着，例如`keccak256(0) == keccak256(uint8(0))`和`keccak256(0x12345678) == keccak256(uint32(0x12345678))`

##### 地址相关

`<address>.balance (uint256) `
平衡地址在Wei

`<address>.transfer(uint256 amount) `
发送一定量wei向地址，抛出失败

`<address>.send(uint256 amount) returns (bool) `
发送一定量wei向地址，失败时返回false

`<address>.call(...) returns (bool) `
发出低级CALL，失败返回false

`<address>.callcode(...) returns (bool) `
发出低级CALLCODE，失败时返回false

`<address>.delegatecall(...) returns (bool) `
发出低级DELEGATECALL，失败返回false

##### 合约相关

`this `
当前合约，明确转换为地址

`selfdestruct(address recipient) `
摧毁目前的合同，将资金送到给定的地址

`suicide(address recipient) `
selfdestruct的别名

-----------------------

#### 表达式和控制结构

##### 输入参数 

输入参数的声明方式与变量相同。 作为例外，未使用的参数可以省略变量名称。 例如，假设我们希望我们的合约接受一种具有两个整数的外部调用，我们会写下如下：
```
pragma solidity ^0.4.0;

contract Simple {
    function taker(uint _a, uint _b) {
        // do something with _a and _b.
    }
}
```

##### 输出参数

输出参数可以在返回关键字之后以相同的语法声明。 例如，假设我们希望返回两个结果：两个给定整数的总和和乘积，那么我们将写：

```
pragma solidity ^0.4.0;

contract Simple {
    function arithmetics(uint _a, uint _b) returns (uint o_sum, uint o_product) {
        o_sum = _a + _b;
        o_product = _a * _b;
    }
}
```

可以省略输出参数的名称。 也可以使用return语句指定输出值。 返回语句还能够返回多个值，请参阅返回多个值。 返回参数初始化为零; 如果没有明确设置，它们将保持为零。

输入参数和输出参数可以用作函数体中的表达式。 在那里，他们也可以在任务的左边使用。

##### 控制结构

Solidity可以使用来自javascript的大多数控制结构,除了 switch和goto.
所以有如下
 `if, else, while, do, for, break, continue, return, ?:`

圆括号不能被省略为条件，但卷边可以在单个语句体上省略。
请注意，因为在C和JavaScript中没有类型转换从非布尔类型到布尔类型，所以Solidity中 `if (1) { ... }`是无效的。

##### 返回多个值

当一个函数有多个输出参数时
return (v0, v1, ..., vn) 
可以返回多个值。 组件的数量必须与输出参数的数量相同。

##### 函数调用

函数调用分为 ==内部函数调用== 和 ==外部函数调用==

###### 内部函数调用

当前合约的功能可以直接调用（“internally”），也可以递归地调用，如这个无意义的例子所示：

```
pragma solidity ^0.4.0;

contract C {
    function g(uint a) returns (uint ret) { return f(); }
    function f() returns (uint ret) { return g(7) + f(); }
}
```

> 这些函数调用被转换为EVM内部的简单跳转。 这具有当前存储器不被清除的效果，即将存储器引用传递到内部称为功能是非常有效的。 只能在内部调用相同合同的功能。

###### 外部函数调用

```
pragma solidity ^0.4.0;

contract InfoFeed {
    function info() payable returns (uint ret) { return 42; }
}

contract Consumer {
    InfoFeed feed;
    function setFeed(address addr) { feed = InfoFeed(addr); }
    function callFeed() { feed.info.value(10).gas(800)(); }
}
```

注意info的payable，如果没有的话，.value() 方法将不可用。

##### 命令调用和匿名功能参数

函数调用参数也可以通过名称，以任何顺序给出，如果它们被包含在{}中，可以在下面的例子中看到。 参数列表必须与名称和函数声明中的参数列表重合，但可以按任意顺序排列。

```
pragma solidity ^0.4.0;

contract C {
    function f(uint key, uint value) {
        // ...
    }

    function g() {
        // named arguments
        f({value: 2, key: 3});
    }
}
```

##### 省略函数参数名

可以省略未使用参数的名称（特别是返回参数）。 这些名字仍然存在于堆栈中，但是它们是无法访问的。

```
pragma solidity ^0.4.0;

contract C {
    // 省略参数名称
    function func(uint k, uint) returns(uint) {
        return k;
    }
}
```

##### 创建新合约

合同可以使用关键字 ==new== 创建新合同。 正在创建的合同的完整代码必须提前知道，因此递归创建依赖是不可能的。

```
pragma solidity ^0.4.0;

contract D {
    uint x;
    function D(uint a) payable {
        x = a;
    }
}

contract C {
    D d = new D(4); // 将作为C构造函数的一部分执行

    function createD(uint arg) {
        D newD = new D(arg);
    }

    function createAndEndowD(uint arg, uint amount) {
        // 创建的时候发送ether
        D newD = (new D).value(amount)(arg);
    }
}
```

##### 错误处理: Assert, Require, Revert and Exceptions

Solidity使用状态恢复异常来处理错误。 这种异常将撤消在当前调用（及其所有子调用）状态的所有变化，也标志的错误给调用者。 方便函数assert和require可以用于检查条件，如果条件不满足则抛出异常。 `assert`函数只能用于测试内部错误，并检查不变量。 应该使用require函数来确保满足输入或合同状态变量的有效条件，或者验证从外部合同的调用返回值。 如果正确使用，分析工具可以评估您的合同，以识别将达到失败断言的条件和函数调用。 正常运行的代码不应该达到失败的断言声明; 如果发生这种情况，您的合同中会出现一个您应该修复的错误。

还有另外两种方法可以触发异常：`revert`函数可用于标记错误并恢复当前的调用。 将来可能还可以包括有关恢复调用中的错误的详细信息。 `throw`关键字也可以用作revert()的替代方法。从0.4.13版本，throw关键字已被弃用，将来会被淘汰。

在以下情况下会生成assert样式异常：
1. 如果您以太大或负数索引访问数组(比如x[i] 在 i >= x.length or i < 0) 
2. 如果您以太大或负数索引访问固定长度的bytesN。 
3. 如果您划分或模数为零（例如5/0或23％0）。 
4. 如果通过负移动量。 
5. 如果转换过大或负进枚举类型的值。 
6. 如果调用内部函数类型的零初始化变量。 
7. 如果您使用一个评估为false的参数调用assert。

在以下情况下会生成require-style异常：
1. 调用throw 
2. 调用require并且条件为false 
3. 如果您通过消息调用调用函数，但是它没有正确完成（即，用尽了气体，没有匹配的功能，或者引发异常本身），除非使用低级别的操作call，send，delegatecall或callcode。 低级别的操作不会抛出异常，而是通过返回false来指示失败。 
4. 如果您使用new关键字，但合同创建未正常完成创建合同（见上文的“无法正常完成”的定义）。 
5. 如果您执行一个定向不包含代码的合同的外部函数调用。 
6. 如果您的合约通过无功能修改器（包括构造函数和后备功能）通过公共函数接收Ether。 
7. 如果你的合约通过一个公共的getter函数接收Ether。 
8. 如果.transfer（）失败。

在内部，Solidity对require-style异常执行一个还原操作（0xfd指令），并执行一个无效操作（指令0xfe）来抛出一个assert-style异常。 在这两种情况下，这将导致EVM恢复对状态所做的所有更改。 恢复原因是没有安全的方式来继续执行，因为没有发生预期的效果。 因为我们要保留交易的原子性，所以最安全的做法是恢复所有的变化，并使整个事务（或至少调用）无效。 请注意，断言风格的异常消耗调用中可用的所有gas，而需求风格的异常将不会消耗从大都会版本开始的任何gas。

--------------

#### 合约

合约可以从合约中呗创建,创建时,其构造函数会被执行一次
构造函数时可选的,但只允许一个构造函数,也就意味着不支持重载

##### 可见性和Getters

由于Solidity知道两种函数调用（内部函数调用不会创建实际的EVM调用（也称为“消息调用”）和外部函数调用），因此函数和状态变量有四种可见性类型。

函数可以被指定为外部的，公共的，内部的或私有的，默认是公共的。 对于状态变量，外部是不可能的，默认是内部的。

- external: 
		外部功能是合约接口的一部分，这意味着它们可以通过其他合约和交易进行调用。 外部函数f不能在内部调用（即f()不起作用，但this.f()可以正常工作

- public: 
		公共功能是合同接口的一部分，可以在内部或通过消息进行调用。 对于公共状态变量，生成自动Getters函数（见下文）。

- internal: 
		这些功能和状态变量只能在内部进行访问（即从当前合约或从其中获得的合约），而不使用这些变量。

- private: 
		私有函数和状态变量只对其中定义的合约而不是衍生合约可见。

一切，这是一个合同里面是所有外部观察者可见。 使某些私有化只能阻止其他合约访问和修改信息，但仍然可以在整个世界之外的块链可见。


##### getter函数

编译器会自动为所有公共状态变量创建getter函数。 对于下面给出的合约，编译器将生成一个名为data的函数，它不接受任何参数，并返回一个uint，即状态变量数据的值。 状态变量的初始化可以在声明中完成。

##### 功能修饰符

修饰符可用于轻松更改功能的行为。 例如，它们可以在执行功能之前自动检查条件。 修饰符是合同的可继承属性，可能会被派生合同覆盖。

```
pragma solidity ^0.4.11;

contract owned {
    function owned() { owner = msg.sender; }
    address owner;

    // 此合约仅定义修饰符，但不使用它 - 它将用于派生合约。
    // 函数体插入其中，特殊符号“_”; 在修饰符的定义出现。
    // 这意味着如果所有者调用此函数，则执行该函数，否则抛出异常。
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract mortal is owned {
    // 这个合同从“拥有”继承“onlyOwner” - “变体”，并将其应用于“关闭”功能，这导致“关闭”的调用只有由存储的所有者进行生效。
    function close() onlyOwner {
        selfdestruct(owner);
    }
}


contract priced {
    // 修饰符可以接收参数：
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}


contract Register is priced, owned {
    mapping (address => bool) registeredAddresses;
    uint price;

    function Register(uint initialPrice) { price = initialPrice; }

    // 在此处也提供“payable”关键字很重要，否则功能将自动拒绝发送给它的所有以太网。
    function register() payable costs(price) {
        registeredAddresses[msg.sender] = true;
    }

    function changePrice(uint _price) onlyOwner {
        price = _price;
    }
}

contract Mutex {
    bool locked;
    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    /// 此函数受互斥体保护，这意味着来自msg.sender.call中的重入调用不能再次调用f。
    /// “return 7”语句将7分配给返回值，但仍然在修改器中执行“locked = false”语句。
    function f() noReentrancy returns (uint) {
        require(msg.sender.call());
        return 7;
    }
}
```

##### 常数变量

状态变量可以声明为常数。 在这种情况下，它们必须从编译时的常量表达式分配。 不允许任何访问存储，块链数据（例如现在，this.balance或block.number）或执行数据（msg.gas）或调用外部契约的表达式。 可能会对内存分配造成副作用的表达式，但可能对其他内存对象有副作用的表达式不是。 允许内置函数keccak256，sha256，ripemd160，ecrecover，addmod和mulmod（尽管它们调用外部契约）。

允许内存分配器副作用的原因在于可以构建复杂的对象，例如。 查找表。 此功能尚未完全使用。

编译器不保留这些变量的存储空间，并且每次出现都会被相应的常量表达式替换（可能由优化程序计算为单个值）。

不是所有类型的常量都是在这个时候实现的。 唯一支持的类型是值类型和字符串。

```
pragma solidity ^0.4.0;

contract C {
    uint constant x = 32**22 + 8;
    string constant text = "abc";
    bytes32 constant myHash = keccak256("abc");
}
```

##### 查看功能

函数可以被声明为view，在这种情况下，它们置为不修改状态。以下语句被认为是修改状态：
1. 写入状态变量。 
2. 发射事件.. 
3. 创建其他合约。 
4. 使用selfdestruct 
5. 通过调用发送Ether 
6. 调用其他函数不被标记view或者pure 
7. 使用低等级调用 
8. 使用包含某些操作码的内联汇编。

```
pragma solidity ^0.4.16;

contract C {
    function f(uint a, uint b) view returns (uint) {
        return a * (b + 42) + now;
    }
}
```

`constant`是view的别名.
Getter方法被标记为view。
编译器并没有强制执行view方法不修改状态。

##### 纯函数

函数可以声明为pure，在这种情况下，它们承诺不会从该状态中读取或修改该状态。
除了上述状态修改语句的列表外，以下是从状态读取的：
1. 从状态变量读取。 
2. 访问this.balance或\<address>.balance。 
3. 访问block，tx，msg的任何成员（除了msg.sig和msg.data）。 
4. 调用任何未标记为pure的功能。 
5. 使用包含某些操作码的内联汇编。

```
pragma solidity ^0.4.16;

contract C {
    function f(uint a, uint b) pure returns (uint) {
        return a * (b + 42);
    }
}
```

##### fallback函数

如果合约想要接受ether,就必须实现一个 fallback函数

这个函数不能有参数，不能返回任何东西。 
只要合约收到普通的Ether（无数据），就执行此函数. 在这种情况下，函数调用通常只有很少的gas（精确的是2300个gas），所以重要的是使fallback函数调用尽可能的便宜。

特别是，以下操作将比提供给fallback功能的津贴消耗更多的气体：
- 写入存储
- 创建合约
- 称为消耗大量gas的外部功能
- 发送Ether

==绝对不能使用哦==,请确保您彻底测试您的fallback函数，以确保执行成本低于2300gas，然后再部署合同。

##### 事件

event
```
pragma solidity ^0.4.0;

contract ClientReceipt {
    event Deposit(
        address indexed _from,
        bytes32 indexed _id,
        uint _value
    );

    function deposit(bytes32 _id) payable {
        // 任何调用这个函数（甚至是深嵌套的）都可以从JavaScript API中通过过滤`Deposit`来调用。
        Deposit(msg.sender, _id, msg.value);
    }
}
```

##### 低层次的接口日志

还可以通过函数log0，log1，log2，log3和log4访问记录机制的低级接口。 

```
log3(
    msg.value,
    0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20,
    msg.sender,
    _id
)
```

##### 继承

Solidity通过复制代码（包括多态）来支持多重继承。
所有函数调用都是虚拟的，这意味着调用最多的派生函数，除非明确地给出了合同名称。
当合同从多个合同继承时，在块链上只创建一个合同，并将所有基础合同的代码复制到创建的合同中。
一般继承系统与Python非常相似，特别是关于多重继承。

##### 基础构造函数的参数

派生合约需要提供基础构造函数所需的所有参数。 这可以通过两种方式完成：

```
pragma solidity ^0.4.0;

contract Base {
    uint x;
    function Base(uint _x) { x = _x; }
}


contract Derived is Base(7) {
    function Derived(uint _y) Base(_y * _y) {
    }
}
```

##### 抽象合约

合约的函数可以缺少一个实现
这种合同无法编译（即使它们包含已实现的功能以及未实现的功能），但可以作为基础合同使用：

如下面的例子:

```
pragma solidity ^0.4.0;

contract Feline {
    function utterance() returns (bytes32);
}

contract Cat is Feline {
    function utterance() returns (bytes32) { return "miaow"; }
}
```

##### 接口

接口类似于抽象合同，但它们不能实现任何功能。 还有进一步的限制：
- 无法继承其他合同或接口。 
- 无法定义构造函数。 
- 无法定义变量。 
- 无法定义结构体。 
- 无法定义枚举。 

其中一些限制可能会在未来取消。
接口基本上限于合同ABI可以表示的内容，ABI和接口之间的转换应该是可能的，没有任何信息丢失。

合约可以继承接口，因为他们将继承其他合约。

接口用自己的关键词表示：

```
pragma solidity ^0.4.11;

interface Token {
    function transfer(address recipient, uint amount);
}
```

