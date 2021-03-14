---
title: shell中if条件字符串数字比对[[ ]]和[ ]区别
tags: 
---

[toc]

转载自 : https://www.cnblogs.com/include/archive/2011/12/09/2307905.html

引用：

[](http://www.51testing.com/?uid-7701-action-viewspace-itemid-13731)[http://www.51testing.com/?uid-7701-action-viewspace-itemid-13731](http://www.51testing.com/?uid-7701-action-viewspace-itemid-13731)

[http://blog.csdn.net/sunboy_2050/article/details/6836382](http://blog.csdn.net/sunboy_2050/article/details/6836382)

[shell 括号](http://hi.baidu.com/masterfoo/blog/item/63f2c4f2f4be4dc87831aa30.html)  

学习 shell 的时候总是被 shell 里的条件判断方式搞得头疼，经常不知道改 用 [],[[]],(()) 还是 test,let，而很少有书把它们的关系讲解的很清楚(应该是我悟性差或是看书太少)，今天总结一下，基础的东西如它们 的使用方法不再赘述，重点说说它们的区别的使用时应该注意的地方。  
先说 [] 和 test，两者是一样的，在命令行里 test expr 和 [ expr] 的效果相同。test 的三个基本作用是判断文件、判断字符串、判断整数。支持使用与或非将表达式连接起来。要注意的有：  
1.test 中可用的比较运算符只有 == 和!=，两者都是用于字符串比较的，不可用于整数比较，整数比较只能使用 - eq, -gt 这种形式。无论是字符串比较还是整数比较都千万不要使用大于号小于号。当然，如果你实在想用也是可以的，对于字符串比较可以使用尖括号的转义形式， 如果比较 "ab" 和 "bc"：[ab \< bc]，结果为真，也就是返回状态为 0.  
然后是 [[]]，这是内置在 shell 中的一个命令，它就比刚才说的 test 强大的多了。支持字符串的模式匹配（使用 =~ 操作符时甚至支持 shell 的正则表达 式）。简直强大的令人发指！逻辑组合可以不使用 test 的 - a,-o 而使用 &&,|| 这样更亲切的形式 (针对 c、Java 程序员)。当 然，也不用想的太复杂，基本只要记住  
1. 字符串比较时可以把右边的作为一个模式（这是右边的字符串不加双引号的情况下。如果右边的字符串加了双引号，则认为是一个文本字符串。），而不仅仅是一个字符串，比如 [[hello == hell?]]，结果为真。

另外要注意的是，使用 [] 和[[]]的时候不要吝啬空格，每一项两边都要有空格，[[ 1 == 2 ]]的结果为 “假”，但[[ 1==2 ]] 的结果为“真”！后一种显然是错的

  
3. 最后就是 let 和 (())，两者也是一样的(或者说基本上是一样的，双括号比 let 稍弱一些)。主要进行算术运算(上面的两个都不行)，也比较适合进 行整数比较，可以直接使用熟悉的<,> 等比较运算符。可以直接使用变量名如 var 而不需要 $var 这样的形式。支持分号隔开的多个表达式

####################################################################################################################################  

1. 首先，尽管很相似，但是从概念上讲，二者是不同层次的东西。  
"[["，是关键字，许多 shell(如 ash bsh)并不支持这种方式。ksh, bash(据说从 2.02 起引入对 [[的支持) 等支持。  
"[" 是一条命令， 与 test 等价，大多数 shell 都支持。在现代的大多数 sh 实现中，"[" 与 "test" 是内部 (builtin) 命令，换句话说执行 "test"/"[" 时不会调用 / some/path/to/test 这样的外部命令(如果有这样的命令的话)。

  
2.[[]]结构比 Bash 版本的 [] 更通用。在 [[和]] 之间的所有的字符都不会被文件扩展或是标记分割，但是会有参数引用和命令替换。

用 [[...]] **测试**结构比用 [...] 更能防止脚本里的许多逻辑错误。比如说，&&,||,<和>操作符能在一个 [[]] 测试里通过，但在 [] 结构会发生错误。

3.(())结构扩展并计算一个算术表达式的值。如果表达式值为 0，会返回 1 或假作为退出状态码。一个非零值的表达式返回一个 0 或真作为退出状态码。这个结构和先前 test 命令及 [] 结构的讨论刚好相反。

4.[...] 为 shell 命令，所以在其中的表达式应是它的命令行参数，所以串比较操作符 ">" 与 "<" 必须转义，否则就变成 IO 改向操作符了 (请参看上面 2 中的例子)。在 [[中 "<" 与 ">" 不需转义；  
由于 "[[" 是关键字，不会做命令行扩展，因而相对的语法就稍严格些。例如  
在 [...] 中可以用引号括起操作符，因为在做命令行扩展时会去掉这些引号，而在 [[ ... ]] 则不允许这样做。

5.[[...]]进行算术扩展，而 [ ... ] 不做

6.[[... && ... && ...]] 和 [ ... -a ... -a ...] 不一样，[[ ]] 是逻辑短路操作，而 [ ] 不会进行逻辑短路  

1）在 ksh 中的 test  
数字的运算可使用 let、(()) ，其中运算时不需要变量 $ 符号，运算符为 +、-、*、/、% ，不建议使用 expr  
数字的比较使用 (()) ，其运算符 >、>=、<、<=、==、!=  
可以使用算术扩展，如：((99+1 <= 101))  
字符表达式的比较使用 [[]] ，其运算符 =、!=、-n、-z  
文件表达式的测试使用 [[]] ，其运算符 -r、-l、-w、-x、-f、-d、-s、-nt、-ot  
逻辑表达式的测试使用 [[]] ，其运算符 !、&&、||  
数字比较、字符比较、逻辑测试可以组合，如 $ [["a" != "b" && 4 -gt 3]]  
支持 bash 中的通配符扩展，如：[[hest = h??t]] 、[ hest = h*t ]]  
使用 (()) 时，不需要空格分隔各值和运算符，使用 [[ ]] 时需要用空格分隔各值和运算符。

2）bash 与 ksh 中的 [[]] 不同  
在 redhat9 的 bash 中也可以使用 [[]] 符号。但是建议严格按照上面的原则使用。  
在 bash 中，数字的比较最好使用 (())，虽说可以使用 [[ ]]，但若在其内使用运算符 >、>=、<、<=、==、!= 时，其结果经常是错误的，不过若在 [[ ]] 中使用 [ ] 中的运算符 “-eq、-ne、-le、-lt、-gt、-ge” 等，还尚未发现有错。因此诸如 $ [[ "a" != “b” && 4 > 3 ]] 这类组合（见上）也不可以在 bash 中使用，其出错率很高。  
例：[["a" != "b" && 10> 2 ]] 判断结果就不正常。  
诸如 [2 \< 10]、[[ 2 < 10 ]] 都是不要使用。使用算术扩展最好用 (( 99+1 == 100 )) ，而不要使用 [[ 99+1 -eq 100 ]] 。  

[####################################################################################################################################![](http://www.51testing.com/attachments/2007/06/7701_200706181431421.gif)](http://www.51testing.com/batch.download.php?aid=4440 "点击查看大图片")  

####################################################################################################################################  

<table bgcolor="#eeeeee" border="0"><tbody><tr bgcolor="#0033c0"><td>运算符</td><td>描述</td><td>示例</td></tr><tr bgcolor="#888888"><td colspan="3">文件比较运算符</td></tr><tr><td>-e&nbsp;filename</td><td>如果&nbsp;filename&nbsp;存在，则为真</td><td>[-e /var/log/syslog]</td></tr><tr><td>-d&nbsp;filename</td><td>如果&nbsp;filename&nbsp;为目录，则为真</td><td>[-d /tmp/mydir]</td></tr><tr><td>-f&nbsp;filename</td><td>如果&nbsp;filename&nbsp;为常规文件，则为真</td><td>[-f /usr/bin/grep]</td></tr><tr><td>-L&nbsp;filename</td><td>如果&nbsp;filename&nbsp;为符号链接，则为真</td><td>[-L /usr/bin/grep]</td></tr><tr><td>-r&nbsp;filename</td><td>如果&nbsp;filename&nbsp;可读，则为真</td><td>[-r /var/log/syslog]</td></tr><tr><td>-w&nbsp;filename</td><td>如果&nbsp;filename&nbsp;可写，则为真</td><td>[-w /var/mytmp.txt]</td></tr><tr><td>-x&nbsp;filename</td><td>如果&nbsp;filename&nbsp;可执行，则为真</td><td>[-L /usr/bin/grep]</td></tr><tr><td>filename1&nbsp;-nt&nbsp;filename2</td><td>如果&nbsp;filename1&nbsp;比&nbsp;filename2&nbsp;新，则为真</td><td>[/tmp/install/etc/services -nt /etc/services]</td></tr><tr><td>filename1&nbsp;-ot&nbsp;filename2</td><td>如果&nbsp;filename1&nbsp;比&nbsp;filename2&nbsp;旧，则为真</td><td>[/boot/bzImage -ot arch/i386/boot/bzImage]</td></tr><tr bgcolor="#888888"><td colspan="3">字符串比较运算符&nbsp;（请注意引号的使用，这是防止空格扰乱代码的好方法）</td></tr><tr><td>-z&nbsp;string</td><td>如果&nbsp;string&nbsp;长度为零，则为真</td><td>[-z "$myvar"]</td></tr><tr><td>-n&nbsp;string</td><td>如果&nbsp;string&nbsp;长度非零，则为真</td><td>[-n "$myvar"]</td></tr><tr><td>string1&nbsp;=&nbsp;string2</td><td>如果&nbsp;string1&nbsp;与&nbsp;string2&nbsp;相同，则为真</td><td>["$myvar" = "one two three"]</td></tr><tr><td>string1&nbsp;!=&nbsp;string2</td><td>如果&nbsp;string1&nbsp;与&nbsp;string2&nbsp;不同，则为真</td><td>["$myvar" != "one two three"]</td></tr><tr bgcolor="#888888"><td colspan="3">算术比较运算符</td></tr><tr><td>num1&nbsp;-eq&nbsp;num2</td><td>等于</td><td>[3 -eq $mynum]</td></tr><tr><td>num1&nbsp;-ne&nbsp;num2</td><td>不等于</td><td>[3 -ne $mynum]</td></tr><tr><td>num1&nbsp;-lt&nbsp;num2</td><td>小于</td><td>[3 -lt $mynum]</td></tr><tr><td>num1&nbsp;-le&nbsp;num2</td><td>小于或等于</td><td>[3 -le $mynum]</td></tr><tr><td>num1&nbsp;-gt&nbsp;num2</td><td>大于</td><td>[3 -gt $mynum]</td></tr><tr><td>num1&nbsp;-ge&nbsp;num2</td><td>大于或等于</td><td>[3 -ge $mynum]<br></td></tr></tbody></table>

  

| 测试命令  
　　test 命令用于检查某个条件是否成立，它可以进行数值、字符和文件 3 个方面的测试，其测试符和相应的功能分别如下。  
　　（1）数值测试：  
　　-eq 等于则为真。  
　　-ne 不等于则为真。  
　　-gt 大于则为真。  
　　-ge 大于等于则为真。  
　　-lt 小于则为真。  
　　-le 小于等于则为真。  
　　（2）字串测试：  
　　= 等于则为真。  
　　!= 不相等则为真。  
　　-z 字串 字串长度伪则为真。  
　　-n 字串 字串长度不伪则为真。  
　　（3）文件测试：  
　　-e 文件名 如果文件存在则为真。  
　　-r 文件名 如果文件存在且可读则为真。  
　　-w 文件名 如果文件存在且可写则为真。  
　　-x 文件名 如果文件存在且可执行则为真。  
　　-s 文件名 如果文件存在且至少有一个字符则为真。  
　　-d 文件名 如果文件存在且为目录则为真。  
　　-f 文件名 如果文件存在且为普通文件则为真。  
　　-c 文件名 如果文件存在且为字符型特殊文件则为真。  
　　-b 文件名 如果文件存在且为块特殊文件则为真 |

  
条件变量替换:   
   Bash Shell 可以进行变量的条件替换, 既只有某种条件发生时才进行替换, 替换   
条件放在 {} 中.   
(1) ${value:-word}   

       当变量未定义或者值为空时, 返回值为 word 的内容, 否则返回变量的值. 

(2) ${value:=word} 

       与前者类似, 只是若变量未定义或者值为空时, 在返回 word 的值的同时将   

       word 赋值给 value 

(3) ${value:?message} 

       若变量以赋值的话, 正常替换. 否则将消息 message 送到标准错误输出 (若   

       此替换出现在 Shell 程序中, 那么该程序将终止运行) 

(4) ${value:+word}   

       若变量以赋值的话, 其值才用 word 替换, 否则不进行任何替换 

(5) ${value:offset}   
       ${value:offset:length}   
       从变量中提取子串, 这里 offset 和 length 可以是算术表达式.   

(6) ${#value} 

       变量的字符个数 

(7) ${value#pattern}   
       ${value##pattern}   
       去掉 value 中与 pattern 相匹配的部分, 条件是 value 的开头与 pattern 相匹配   
       #与 ## 的区别在于一个是最短匹配模式, 一个是最长匹配模式.   

(8) ${value%pattern} 

       ${value%%pattern}   
       于 (7) 类似, 只是是从 value 的尾部于 pattern 相匹配,% 与 %% 的区别与 #与## 一样   

(9) ${value/pattern/string} 

       ${value//pattern/string}   
       进行变量内容的替换, 把与 pattern 匹配的部分替换为 string 的内容,/ 与 // 的区别与上同   

注意: 上述条件变量替换中, 除 (2) 外, 其余均不影响变量本身的值 

#!/bin/bash

var1="1"  
var2="2"

下面是并且的运算符 - a，另外注意，用一个 test 命令就可以了，还有 if 条件后面的分号

if test $var1 = "1"-a $var2 = "2" ; then  
   echo "equal"  
fi

下面是或运算符 -o，有一个为真就可以

if test $var1 != "1" -o $var2 != "3" ; then  
   echo "not equal"  
fi

下面是非运算符 ！  
if 条件是为真的时候执行，如果使用！运算符，那么原表达式必须为 false

if ! test $var1 != "1"; then  
   echo "not 1"  
fi

  
以上三个 if 都为真，所以三个 echo 都会打印

在一个文档把这几个运算法说的一塌糊涂，于是自己动手实验了一下

------------------------------------------------------------------------------------------------------

shell 字符串比较、判断是否为数字

 

二元比较操作符, 比较变量或者比较数字. 注意数字与字符串的区别.  
整数比较  
-eq       等于, 如: if ["$a" -eq "$b"]  
-ne       不等于, 如: if ["$a" -ne "$b"]  
-gt       大于, 如: if ["$a" -gt "$b"]  
-ge       大于等于, 如: if ["$a" -ge "$b"]  
-lt       小于, 如: if ["$a" -lt "$b"]  
-le       小于等于, 如: if ["$a" -le "$b"]  
<小于 (需要双括号), 如:(("$a" < "$b"))  
<=       小于等于 (需要双括号), 如:(("$a" <= "$b"))  
>       大于 (需要双括号), 如:(("$a" > "$b"))  
>=       大于等于 (需要双括号), 如:(("$a" >= "$b"))  
字符串比较  
=       等于, 如: if ["$a" = "$b"]  
==       等于, 如: if ["$a" == "$b"], 与 = 等价  
       注意:== 的功能在 [[]] 和[]中的行为是不同的, 如下:  
       1 [[$a == z*]]    # 如果 $a 以 "z" 开头 (模式匹配) 那么将为 true  
       2 [[$a == "z*"]] # 如果 $a 等于 z*(字符匹配), 那么结果为 true  
       3  
       4 [$a == z*]      # File globbing 和 word splitting 将会发生  
       5 ["$a" == "z*"] # 如果 $a 等于 z*(字符匹配), 那么结果为 true  
       一点解释, 关于 File globbing 是一种关于文件的速记法, 比如 "*.c" 就是, 再如~ 也是.  
       但是 file globbing 并不是严格的正则表达式, 虽然绝大多数情况下结构比较像.  
!=       不等于, 如: if ["$a" != "$b"]  
       这个操作符将在 [[]] 结构中使用模式匹配.  
<       小于, 在 ASCII 字母顺序下. 如:  
       if [["$a" < "$b"]]  
       if ["$a" \< "$b"]  
       注意: 在 [] 结构中 "<" 需要被转义.  
>       大于, 在 ASCII 字母顺序下. 如:  
       if [["$a"> "$b" ]]  
       if ["$a" \> "$b" ]  
       注意: 在 [] 结构中 ">" 需要被转义.  
       具体参考 Example 26-11 来查看这个操作符应用的例子.  
-z       字符串为 "null". 就是长度为 0.  
-n       字符串不为 "null"  
       注意:  
       使用 - n 在 [] 结构中测试必须要用 ""把变量引起来. 使用一个未被"" 的字符串来使用! -z  
       或者就是未用 "" 引用的字符串本身, 放到 [] 结构中。虽然一般情况下可  
       以工作, 但这是不安全的. 习惯于使用 "" 来测试字符串是一种好习惯.