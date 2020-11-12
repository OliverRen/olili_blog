---
title: 手动使用CSC命令行编译器
---

[toc]

做为一名C#程序员，构建net应用程序的时候有许多IDE可以选择，相信大家用得最多的就是Visual Studio吧！
今天我们回归原始,看看如何使用C#命令编译器csc.exe来编写程序并编译运行

#### 安装 .net Framework

> 这篇文章是很早很早的时候了,那时根本就没有dotnet,一切都是以.net framework来阐述的

首先的工作是要先装.Net FrameWork,当然装过visual studio的同学就不需要了，安装这个ide的时候，微软就帮我们默认安装了这个SDK了

#### 编码 

使用随便什么文本编辑器,直接写代码咯,比如记事本啊,editplus之类的
这里我们把文件保存为 TestApp.cs

``` csharp
using System;
class TestApp
{
  static void Main()
  {
    Console.WriteLine("andy测试");
　　Console.Read();
  }
}
```

#### 编译

我们安装好 .net framework后就可以在 `C:\WINDOWS\Microsoft.NET\Framework\` 下对应不同版本有不同的文件夹,打开版本文件夹就可以找到我们的命令行编译工具 csc.exe 了
ok.我们使用命令行输入 `csc TestApp.cs`就可以得到编译好的 TestApp.exe 文件了.

#### 引用程序集
上面看上去好像已经完成了一个过程！但如果我们的程序需要引用外部的程序集，那应该怎么办呢？让我们修改TestApp应用程序，显示一个Windows的窗体消息框吧！请键入以下代码:

``` csharp
using System;
using System.Windows.Forms;   //千万记得要加上这一行
class TestApp
{
  static void Main()
  {
    Console.WriteLine("andy测试");
    MessageBox.Show("哈罗");　　//千万记得要加上这一行
　　Console.Read();
  }
}
```

由于引用了外部的程序集，所以我们在编译时，也应该在命令中引用外部的程序集(PS:msCorlib.dll是默认引用的)
编译和刚刚一样，只是命令稍微有些不同而以，请输入: `csc /r:System.Windows.Forms.dll c:\TestApp.cs`,这样就搞定了！
这时，可能又会有朋友问，那我想引用多个外部的程序集，又怎么办的！其实这个很简单，请看以下示例:`csc /r:System.Windows.Forms.dll;System.Drawing.dll` 文件名
如果还有的话，就像这样，继续用分号隔开。还有一点。C#命令行编译器是支持通配符的，比如输入`csc /r:System.Windows.Forms.dll *.cs` 这样就是编译目录下的所有cs文件。
也可以同时编译两个文件，比如文件Ａ使用到文件Ｂ的话，那就需要进行同时编译两个文件了！示例`csc /r:System.Windows.Forms.dll A.cs B.cs` 即可;
