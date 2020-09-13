---
title: NuGet使用帮助
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

#### 概述

NuGet包 即扩展名为 .nupkg 的文件其实是一个 .zip包,可以修改后缀名后直接打开.这个包包含了编译后的代码 (dll文件),及与该代码相关的其他文件和描述性清单.使用 NuGet包可以用来共享代码.

文档中的关键名词的说明
- `nuget.exe` 指 nuget.exe的工具包软件,即工具的可执行文件
- `NuGet` 泛指 .nupkg 这种用来共享代码的方式
- `NuGet包` 打包后的软件包

==项目类型==
- .NET Standard
- .NET Core
- .NET Framework
- 迁移的 .NET项目

==项目格式==
> 确认项目是否是 SDK样式,请检查项目文件(.csproj)的 \<Project>节点是否包含 SDK属性即可.
- SDK样式
- 非 SDK样式

==NuGet包配置引用的格式==
- `packages.config`格式 
	NuGet 1.0+ ,已安装或已还原的包存储在 ==packages== 文件夹中。
- `PackageReference`格式 (项目文件中的包引用) 
	NuGet 4.0+ , 关联文件 ==obj/project.assets.json== 是动态生成的,PackageReference始终由 .NET Core 项目使用

==推荐工具==
- dotnet CLI 最推荐的工具
- nuget.exe CLI
- msbuild -t:pack 只用来打包

| 项目 | 项目格式 | CLI工具 | 说明 |
| ------ | ------------ | ----------- | ------ |
| .NET Standard | SDK | dotnet CLI | vs2017之前非SDK使用 nuget.exe |
| .NET Core | SDK | dotnet CLI |  vs2017之前非SDK使用 nuget.exe |
| .NET Framework | 非SDK | nuget.exe CLI | 若是SDK样式使用 dotnet CLI |
| 迁移NuGet格式的.NET项目 | 非SDK | 使用 msbuild -t:pack 创建包  | 创建包使用msbuild,否则使用dotnet CLI |

==针对项目来选择工具==
从 packages.config 迁移到 PackageReference 的项目比较特殊,只有创建包使用msbuild,其他时候使用dotnet CLI
当项目为非SDK样式时使用nuget.exe,若迁移至 PackageReference 则使用 dotnet CLI
当项目为SDK样式时都使用 dotnet CLI

当使用dotnet CLI时,一般都是直接使用项目文件(.csproj)中的属性
当使用nuget.exe CLI时,还原包依靠 packages.config 文件,而构建包需要单独的 .nuspec 文件.
当使用msbuild的时候,一般是 packages.config 格式迁移到PackageReference 的项目
> 这里已经不再考虑 .net core 过渡中产生的 使用project.json 文件来构建依赖关系的情况了
> 即你可以简单看如果有 packages.config  文件那么就是用 nuget.exe CLI来管理的,不然就应该使用 dotnet CLI.

更多详细的内容请参看 [.NET Core的 csproj 格式的新增内容](https://docs.microsoft.com/zh-cn/dotnet/core/tools/csproj#additions)

--------------------

#### NuGet工具本身的配置文件

*这里只描述NuGet 4.0的默认位置*

 **计算机全局配置**
设置虽然适用于计算机上的所有操作，但会被任何用户级或项目级设置覆盖。
Windows：%ProgramFiles(x86)%\NuGet\Config
Mac/Linux：$XDG_DATA_HOME。 如果 $XDG_DATA_HOME 的值是 null 或为空，将使用 ~/.local/share 或 /usr/local/share（因 OS 版本而异）

**用户级别配置**
设置应用于所有操作，但可被任何项目级的设置替代。
Windows：%appdata%\NuGet\NuGet.Config
Mac/Linux：~/.config/NuGet/NuGet.Config 或 ~/.nuget/NuGet/NuGet.Config（因 OS 版本而异）

**解决方案级别配置**
当前文件夹（又称解决方案文件夹）或上至驱动器根目录的任何文件夹。
切记是 solution.sln 所在的层级,设置应用于子文件夹种的所有项目,如果配置文件位于项目文件夹种,则不会有任何影响.

> 在vs中一般编辑的是用户级别的配置
> 配置文件的优先级一般是 解决方案级别配置 > 用户级别配置 > 计算机全局配置

--------------------

#### NuGet全局包和缓存文件夹

*这里一般情况都指 NuGet 4.0+,使用 PackageReference 风格所使用的配置*

NuGet 在操作的时候有如下4种可以用来表示目标的名称
- http-cache
- global-packages
- temp
- plugins-cache

**http-cache**
nuget.exe CLI和dotnet CLI工具存在的下载包的副本(另存为 .dat文件),这些副本被组织到每个包源的子文件夹中,且有30分钟的过期时间

配置默认目录
- Windows：%localappdata%\NuGet\v3-cache
- Mac/Linux：~/.local/share/NuGet/v3-cache
- 使用 NUGET_HTTP_CACHE_PATH 环境变量替代。

> NuGet 3.5和早期版本使用 %localappdata%\NuGet\Cache中 ==packages-cache== 而不是 http-cache

**global-packages**
global-packages 文件夹是 NuGet 安装任何下载包的位置。 每个包完全展开到匹配包标识符和版本号的子文件夹。 使用 PackageReference 格式的项目始终直接从该文件夹中使用包。 使用 packages.config 时，包将安装到 global-packages 文件夹，然后复制到项目的 ==packages== 文件夹。

> 这可以通过vs中的清除包缓存来进行清理,这会删除packages文件夹

配置默认目录:
- Windows：%userprofile%\.nuget\packages
- Mac/Linux：~/.nuget/packages
- 可以使用 NUGET_PACKAGES 环境变量
- 可以在 dotnet cli使用参数 globalPackagesFolder 
- 可以在 nuget.exe cli使用参数 repositoryPath
- 可以在 msbuild使用参数 RestorePackagesPath

**temp**
NuGet 在各种操作期间存储的临时文件

配置默认目录
- Windows: $temp$\NuGetScratch
- Mac/Linux: /tmp/NuGetScratch

**plugins-cache** (4.8+)
NuGet 用来存储来自操作生命请求的结果的文件夹

配置默认目录
- Windows：%localappdata%\NuGet\plugins-cache
- Mac/Linux：~/.local/share/NuGet/plugins-cache
- 使用 NUGET_PLUGINS_CACHE_PATH 环境变量替代。

对于NuGet配置的相关命令可以使用以下命令来查看
这里使用all可以显示所有的配置目标
`dotnet nuget locals all --list`
`nuget locals all -list`

---------------------

#### NuGet包引用格式及其内容

- `packages.config` 
	NuGet 1.0+ ,已安装或已还原的包存储在 ==packages== 文件夹中。
- `PackageReference` (项目文件中的包引用) 
	NuGet 4.0+ , 关联文件 ==obj/project.assets.json== 是动态生成的,PackageReference始终由 .NET Core 项目使用

默认情况下:
更新的 PackageReference格式可以用于 .NET Core 项目 , .NET Standard 项目.
面向 .NET Framework 的项目也支持 PackageReference(c++项目和ASP.NET项目除外),但当前默认是使用 packages.config.

PackageReference的引用格式应当使用 dotnet cli 来管理和使用
packages.config 应当使用nuget.exe cli 来管理和使用

##### 使用 PackageReference的引用格式

==引用或还原NuGet包的相关属性==

1. 包还原风格
对于项目文件中没有 PackageReference,项目文件夹中也没有 packages.config 文件的时候,即不确定项目到底使用什么 NuGet包引用风格的时候,可以通过 ==RestoreProjectStyle== 来控制包还原成 PackageReference风格
``` xml
<PropertyGroup>
    <!--- ... -->
    <RestoreProjectStyle>PackageReference</RestoreProjectStyle>
    <!--- ... -->
</PropertyGroup>
```

2. PackageReferences风格引用NuGet包
``` xml
<ItemGroup>
    <!-- ... -->
	<!-->=版本-->
    <PackageReference Include="Contoso.Utility.UsefulStuff" Version="3.6.0" />
	<!--可变版本-->
	<PackageReference Include="Contoso.Utility.UsefulStuff" Version="3.6.*" />
    <!-- ... -->
</ItemGroup>
```

3. 添加 PackageReference 的条件
可以在单个PackageReference上增加 Condition来控制包的引用
``` xml
<ItemGroup>
    <!-- ... -->
    <PackageReference Include="Newtonsoft.Json" Version="9.0.1" Condition="'$(TargetFramework)' == 'net452'" />
    <!-- ... -->
</ItemGroup>
```
也可以在ItemGroup级别应用所有子级的PackageReference元素
``` xml
<ItemGroup Condition = "'$(TargetFramework)' == 'net452'">
    <!-- ... -->
    <PackageReference Include="Newtonsoft.Json" Version="9.0.1" />
    <PackageReference Include="Contoso.Utility.UsefulStuff" Version="3.6.0" />
    <!-- ... -->
</ItemGroup>
```

4. 锁定依赖项
使用锁定文件来保留包依赖项的完整闭包
锁定依赖项将会使NuGet选择最佳匹配项

有两种方式可以启用锁定文件
第一种使用 RestorePackagesWithLockFile 属性
``` xml
<PropertyGroup>
    <!--- ... -->
    <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
    <!--- ... -->
</PropertyGroup>
```
第二种是在根目录中创建 ==packages.lock.json== 文件

##### 使用 packages.config  引用风格

packages.config文件时一个以 \<packages> 为根节点的xml文件

子节点的属性有
- id 必选 包的标识符，如 Newtonsoft.json 或 Microsoft.AspNet.Mvc。
- version 必选 要安装的包的确切版本
- targetFramework 可选 安装包时应用的目标框架名字对象
- allowedVersions 可选 在包更新期间允许对此包应用的一系列版本
- developmentDependency 如果使用项目本身创建 NuGet 包，针对依赖项将其设置为 true，可防止在创建使用包时添加该包

示例
以下 packages.config 指的是九个包，但由于 Microsoft.Net.Compilers 属性，生成使用包时不会包括 developmentDependency。 对 Newtonsoft.Json 的引用还将更新限制为仅 8.x 和 9.x 版本。
``` xml
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="Microsoft.CodeDom.Providers.DotNetCompilerPlatform" version="1.0.0" targetFramework="net46" />
  <package id="Microsoft.Net.Compilers" version="1.0.0" targetFramework="net46" developmentDependency="true" />
  <package id="Microsoft.Web.Infrastructure" version="1.0.0.0" targetFramework="net46" />
  <package id="Microsoft.Web.Xdt" version="2.1.1" targetFramework="net46" />
  <package id="Newtonsoft.Json" version="8.0.3" allowedVersions="[8,10)" targetFramework="net46" />
  <package id="NuGet.Core" version="2.11.1" targetFramework="net46" />
  <package id="NuGet.Server" version="2.11.2" targetFramework="net46" />
  <package id="RouteMagic" version="1.3" targetFramework="net46" />
  <package id="WebActivatorEx" version="2.1.0" targetFramework="net46" />
</packages>
```

##### 从 packages.config 迁移到 PackageReference
结合微软文档,我自己总结了以下使用PackageReference 的几个好处
1. 在一个统一的位置管理所有项目依赖项,即在 .csproj 文件中,对引用包和项目引用统一进行管理,而不需要再使用单独的 packages.config 文件.
2. 使用PackageReference时,NuGet包时保留在 global-packages 文件夹中而不是解决方案的 packages 文件夹中,所以占用的空间更少,而且可以减少下载量速度更快.
3. 顶级依赖项的有序视图,即仅需要列出那些直接安装再项目中的NuGet包,而不需要将低级依赖项混在一起.即依赖的条目会得到极大的精简. 这被叫做动态解析依赖项,课传递的包依赖项.
4. 当项目出现包引用异常的时候,使用 PackageReference风格可以很容易的使用 dotnet cli命令 restore,build,run进行包还原,而传统方式需要手动的删除引用删除包的记录后重新添加和还原
5. 官方显示 PackageReference 处于积极开发维护的阶段,而 packages.config 已经不再继续新的开发了.

如何回滚到 packages.config
无论说的怎么好,一些包由于兼容性问题,或是不知道什么原因导致不得不回滚的话你可以这么操作.
1.  关闭已迁移的项目。
2.  将项目文件和 `packages.config` 从备份（通常为 `<solution_root>\MigrationBackup\<unique_guid>\<project_name>\`）复制到项目文件夹。 如果项目根目录中存在 obj 文件夹，则删除该文件夹。
3.  打开项目。
4.  使用“工具”>“NuGet 包管理器”>“包管理器控制台”菜单命令打开包管理器控制台 。
5.  在控制台中运行以下命令：`update-package -reinstall`  

--------------------

#### 创建 NuGet包

##### 使用dotnet CLI创建NuGet包

在项目文件中 (☞ .csproj 文件) 中的 \<PropertyGroup> 标记内至少添加以下元数据属性

*   `PackageId`，包标识符，在托管包的库中必须是唯一的。 如果未指定，默认值为 `AssemblyName`。
*   `Version`，窗体 Major.Minor.Patch[-Suffix] 中特定的版本号，其中 -Suffix 标识[预发布版本](https://docs.microsoft.com/zh-cn/nuget/create-packages/prerelease-packages)。 如果未指定，默认值为 1.0.0。
*   包标题应出现在主机上（例如 nuget.org）
*   `Authors`，作者和所有者信息。 如果未指定，默认值为 `AssemblyName`。
*   `Company`，公司名称。 如果未指定，默认值为 `AssemblyName`。

在Visual Studio的属性,包中可以设置,或直接在项目文件 (.csproj) 中设置这些属性,示例:
``` xml
<PropertyGroup>
	<TargetFramework>netstandard2.0</TargetFramework>
	<PackageId>AppLogger</PackageId>
	<Version>1.0.0</Version>
	<Authors>your_name</Authors>
	<Company>your_company</Company>
</PropertyGroup>
```

常用的可选属性,控制属性如下:
* `IsPackable`, 一个指定能否打包项目的布尔值。 默认值为 true。
* `PackageVersion`,指定生成的包所具有的版本。 接受所有形式的 NuGet 版本字符串。 默认为值 $(Version)，即项目中 Version 属性的值。
* `Title`, 明了易用的包标题，通常用在 UI 显示中，如 nuget.org 上和 Visual Studio 中包管理器上的那样。 如果未指定，则改为使用包 ID。
* `PackageDescription`, 用于 UI 显示的包的详细说明。
* `Copyright`, 包的版权详细信息。
* `PackageIconUrl`,64x64 透明背景图像的 URL，用作 UI 显示中包的图标。
* `PackageTags`,标记的分号分隔列表，这些标记用于指定包。这些标记可帮助其他人查找包并了解其用途。
* `PackageOutputPath`,确定用于已打包的包的输出路径。 默认值为 $(OutputPath)。
* `IncludeSymbols`, 此布尔值指示在打包项目时，包是否应创建一个附加的符号包。 符号包的格式由 SymbolPackageFormat 属性控制。

完整的属性列表可以参考 [.NET Core的 csproj 格式的新增内容 > NuGet元数据属性](https://docs.microsoft.com/zh-cn/dotnet/core/tools/csproj#nuget-metadata-properties)

##### 使用nuget.exe CLI创建包

根据需要打包的文件,创建 .nuspec 的清单文件.
一般有以下几种途径来创建该文件
- 基于工作目录,即在一个特定的包含了创建包的工作目录下运行 `nuget spec`
- 来自程序集dll,运行 `nuget spec <assembly>.dll`
- 根据 Visual Studio 项目,即在项目目录下运行 `nuget spec` 或 `nuget spec project.csproj`
- 直接创建一个新的模板文件 `nuget spec package-name`

所必须的属性和常见可选属性基本和 dotnet CLI所需要的一致.
详细的列表可以参看 [.nuspec文件说明](https://docs.microsoft.com/zh-cn/nuget/reference/nuspec)

nuget.exe CLI打包以生成 .nupkg 文件
在程序集和工作目录下,可以使用以下命令创建
`nuget pack <project>.nuspec`
当使用Visual Studio项目时,可以对项目文件运行命令
`nuget pack <project>.csproj`

##### 使用MSBuild创建包
当项目从 packages.config格式迁移到 PackageReference后需要打包的时候,需要将 ==NuGet.Build.Tasks.Pack== 包添加到项目依赖项中才可以在使用的时候良好的被解析,所以需要使用 MSBuild来创建包.

所必须的属性和常见可选属性基本和 dotnet CLI所需要的一致.因为这时也是在 .csproj文件中进行指定的.
但是需要手动的添加 ==NuGet.Build.Tasks.Pack==包
``` xml
<ItemGroup>
  <!-- ... -->
  <PackageReference Include="NuGet.Build.Tasks.Pack" Version="5.2.0"/>
  <!-- ... -->
</ItemGroup>
```

然后再命令行中输入
``` cmd
# 还原包
msbuild -t:restore
# 打包
msbuild -t:pack
```

##### 使用 PackageReference风格的高版本 NuGet的额外说明

**构建多个目标框架的NuGet包**
1. 修改 TargetFramework -> TargetFrameworks.例如: `<TargetFrameworks>netstandard2.0;net45</TargetFrameworks>`
2. 在代码中可以使用编译标签来区分与目标框架相关的代码,例如:
``` csharp
public string Platform {
   get {
#if NET45
      return ".NET Framework"
#elif NETSTANDARD2_0
      return ".NET Standard"
#else
#error This code block does not match csproj TargetFrameworks list
#endif
   }
}
```

> 原来在 packages.config 风格中也可以创建针对多个 framework版本的NuGet包,但那都是使用包的结构来进行区分的,而现在也全部可以在项目文件一个地方完成了

**符号包**

良好的调试体验依赖于调试符号的存在，因为它们提供了一些关键信息，例如已编译的代码与源代码之间的关联、局部变量的名称、堆栈跟踪等。 你可以使用符号包 (.snupkg) 来分发这些符号，并改善 NuGet 包的调试体验。

> 不应当在lib中将pdb的符号文件与dll捆绑在一起,而是应该创建单独的符号包

在创建包的可选属性中我们已经提到了关于符号包的两个属性:
``` xml
<PropertyGroup>
    <IncludeSymbols>true</IncludeSymbols>
    <SymbolPackageFormat>snupkg</SymbolPackageFormat>
</PropertyGroup>
```
这样在使用 pack 命令时会同时生成 snupkg的符号包
然后可以使用 push 命令推送 snupkg符号包,或在推送主包的时候同时推送符号包.

##### 创建NuGet包的最佳实践

针对包标识符  PackageId 的最佳做法:

*   **唯一性**：标识符必须在 nuget.org 或托管包的任意库中是唯一的。 确定标识符之前，请搜索适用库以检查该名称是否已使用。 为了避免冲突，最好使用公司名作为标识符的第一部分（例如 `Contoso.`）。
*   **类似于命名空间的名称**：遵循类似于 .NET 中命名空间的模式，使用点表示法（而不是连字符）。 例如，使用 `Contoso.Utility.UsefulStuff` 而不是 `Contoso-Utility-UsefulStuff` 或 `Contoso_Utility_UsefulStuff`。 当包标识符与代码中使用的命名空间相匹配时，这个方法也很有用。
*   **示例包**：如果生成展示如何使用另一个包的示例代码包，请附加 `.Sample` 作为标识符的后缀，就像 `Contoso.Utility.UsefulStuff.Sample` 中一样。 （当然，示例包会在其他包上有依赖项。）创建示例包时，请在 `<IncludeAssets>` 中使用 `contentFiles` 值。 在 `content` 文件夹中，在名为 `\Samples\<identifier>` 的文件夹中排列示例代码，与 `\Samples\Contoso.Utility.UsefulStuff.Sample` 中相似。

针对包版本的最佳做法:
创建包时对包版本的考量主要是出于使用者的便利和准确性.所以这部分内容放到 包安装时的版本控制与依赖项解析的部分阐述.

##### 包版本

特定版本号的格式为 Major.Minor.Patch\[-Suffix] ，其中的组件具有以下含义：

*   _Major_：重大更改
*   _Minor_：新增功能，但可向后兼容
*   _Patch_：仅可向后兼容的 bug 修复
*   _-Suffix_（可选）：连字符后跟字符串，表示预发布版本（遵循[语义化版本控制或 SemVer 1.0 约定](https://semver.org/spec/v1.0.0.html)）。

示例:
- 1.0.1
- 6.11.1231
- 4.3.1-rc
- 2.2.44-beta1

**版本范围**

引用包依赖项时，NuGet 支持使用间隔表示法来指定版本范围，汇总如下：

| Notation | 应用的规则 | 描述 |
| --- | --- | --- |
| 1.0 | x ≥ 1.0 | 最低版本（包含） |
| (1.0,) | x > 1.0 | 最低版本（独占） |
| \[1.0] | x == 1.0 | 精确的版本匹配 |
| (,1.0] | x ≤ 1.0 | 最高版本（包含） |
| (,1.0) | x < 1.0 | 最高版本（独占） |
| \[1.0,2.0] | 1.0 ≤ x ≤ 2.0 | 精确范围（包含） |
| (1.0,2.0) | 1.0 < x < 2.0 | 精确范围（独占） |
| \[1.0,2.0) | 1.0 ≤ x < 2.0 | 混合了最低版本（包含）和最高版本（独占） |
| (1.0) | 无效 | 无效 |

使用 PackageReference 格式时，NuGet 还支持使用浮点表示法 * 来表示版本号的主要、次要、修补程序和预发布后缀部分。 `packages.config` 格式不支持可变版本。

==项目文件中的引用 (PackageReference) 示例==
``` xml
<!-- Accepts any version 6.1 and above. -->
<PackageReference Include="ExamplePackage" Version="6.1" />

<!-- Accepts any 6.x.y version. -->
<PackageReference Include="ExamplePackage" Version="6.*" />
<PackageReference Include="ExamplePackage" Version="[6,7)" />

<!-- Accepts any version above, but not including 4.1.3. Could be
     used to guarantee a dependency with a specific bug fix. -->
<PackageReference Include="ExamplePackage" Version="(4.1.3,)" />

<!-- Accepts any version up below 5.x, which might be used to prevent pulling in a later
     version of a dependency that changed its interface. However, this form is not
     recommended because it can be difficult to determine the lowest version. -->
<PackageReference Include="ExamplePackage" Version="(,5.0)" />

<!-- Accepts any 1.x or 2.x version, but not 0.x or 3.x and higher. -->
<PackageReference Include="ExamplePackage" Version="[1,3)" />

<!-- Accepts 1.3.2 up to 1.4.x, but not 1.5 and higher. -->
<PackageReference Include="ExamplePackage" Version="[1.3.2,1.5)" />
```

==packages.config文件示例==
`allowedVersion`属性仅在更新操作的时候约束可以更新到的版本的范围.

``` xml
<!-- Install/restore version 6.1.0, accept any version 6.1.0 and above on update. -->
<package id="ExamplePackage" version="6.1.0" allowedVersions="6.1.0" />

<!-- Install/restore version 6.1.0, and do not change during update. -->
<package id="ExamplePackage" version="6.1.0" allowedVersions="[6.1.0]" />

<!-- Install/restore version 6.1.0, accept any 6.x version during update. -->
<package id="ExamplePackage" version="6.1.0" allowedVersions="[6,7)" />

<!-- Install/restore version 4.1.4, accept any version above, but not including, 4.1.3.
     Could be used to guarantee a dependency with a specific bug fix. -->
<package id="ExamplePackage" version="4.1.4" allowedVersions="(4.1.3,)" />

<!-- Install/restore version 3.1.2, accept any version up below 5.x on update, which might be
     used to prevent pulling in a later version of a dependency that changed its interface.
     However, this form is not recommended because it can be difficult to determine the lowest version. -->
<package id="ExamplePackage" version="3.1.2" allowedVersions="(,5.0)" />

<!-- Install/restore version 1.1.4, accept any 1.x or 2.x version on update, but not
     0.x or 3.x and higher. -->
<package id="ExamplePackage" version="1.1.4" allowedVersions="[1,3)" />

<!-- Install/restore version 1.3.5, accepts 1.3.2 up to 1.4.x on update, but not 1.5 and higher. -->
<package id="ExamplePackage" version="1.3.5" allowedVersions="[1.3.2,1.5)" />
```

==使用nuget.exe CLI创建的nuget清单文件 .nuspec==
``` xml
<!-- Accepts any version 6.1 and above. -->
<dependency id="ExamplePackage" version="6.1" />

<!-- Accepts any version above, but not including 4.1.3. Could be
     used to guarantee a dependency with a specific bug fix. -->
<dependency id="ExamplePackage" version="(4.1.3,)" />

<!-- Accepts any version up below 5.x, which might be used to prevent pulling in a later
     version of a dependency that changed its interface. However, this form is not
     recommended because it can be difficult to determine the lowest version. -->
<dependency id="ExamplePackage" version="(,5.0)" />

<!-- Accepts any 1.x or 2.x version, but not 0.x or 3.x and higher. -->
<dependency id="ExamplePackage" version="[1,3)" />

<!-- Accepts 1.3.2 up to 1.4.x, but not 1.5 and higher. -->
<dependency id="ExamplePackage" version="[1.3.2,1.5)" />
```

##### NuGet执行包依赖项的解析

###### PackageReference格式项目解析依赖项

PackageReference格式使用的是 .csproj 文件来组织 NuGet包依赖项,而且只记录了项目直接依赖的顶级Get会对添加的包关系图的引用进行提前解决冲突,这被称作 ==传递还原==.

重新安装或者还原包指的即是在下载这个包关系图中所有包的过程.当NuGet还原进程在生成之前,它会首先解析内存中的依赖项,然后将其生存的包关系图写入 `project.assets.json` 文件,如果启用了锁定文件功能,它还会将已经解析的依赖项写入 `packages.lock.json` . 这些资产文件位于`MSBuildProjectExtensionPath`,它默认是项目的obj文件夹.

传递还原应用,选择依赖项包版本的4条主要规则:
1. 最低适用版本.不适用与适用 `*` 声明的可变版本. (单一包版本的规则)
2. 可变版本.此版本规则表示,使用与版本模式匹配的最高版本. (单一包版本的规则)
3. 选择最近项,在下面的示例中，应用程序直接依赖于版本约束为 >=2.0 的包 B。 应用程序还依赖于版本约束为 >=1.0 的包 A，此包依赖于包 B。 在关系图中，由于包 B 2.0 上的依赖项更接近应用程序，因此将使用该版本: (多个包版本的规则)
![使用“选择最近项”规则的应用程序](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/NuGet使用帮助/2020811/1597125342130.png)

> 这里是指路径更加接近,而跟依赖包的版本没有关系,上图中如果 Package B > 1.0版本的依赖如果还有子依赖的话,也是会被NuGet忽略的,即忽略了关系图中远的包的所有分支.
> 选择最近项规则可能导致包版本降级,可以破坏关系图中的其他依赖项,此时用户会得到警告提醒
4. 等距依赖项:当关系图中引用的不同包版本与应用程序具有相同距离时,NuGet将使用满足所有版本要求的最低版本,当无法找到的时候会直接报错 (多个包版本的规则).此时应用程序应当自己直接引用该依赖项的合适版本,以便NuGet使用最近原则.

###### packages.config 文件解析依赖项

当使用 packages.config 文件解析依赖项的时候,项目会将包依赖项 ==及其子依赖项== 以列表的形式写入 packages.config 文件,安装包的同时,NuGet还可能会修改 .csproj , app.config, web.config 等其他单独的文件.

利用 packages.config，NuGet 可尝试解决在安装每个单独包期间出现的依赖项冲突。 也就是说，如果正在安装包 A 并且其依赖于包 B，同时包 B 已作为其他项的依赖项在 packages.config 中列出，则 NuGet 将比较所请求的包 B 版本，并尝试找到满足所有版本约束的版本。 具体而言，NuGet 将选择可满足依赖项的较低 major.minor 版本 。

-----------------------

#### 使用 NuGet包

##### NuGet 客户端工具

- dotnet.exe
- nuget.exe
- Visual Studio (特定的PowerShell环境)
- VsCode
- MSbuild (生成服务器,持续集成 CI中使用,而不是一个通用性工具,即他不能用在编码中,只是最后可以生成NuGet包)

##### 使用dotnet cli

dotnet cli适用与 .Net Core和.Net Standard项目
dotnet cli对于nuget的管理也同样适用与 .Net Framework 的SDK样式项目.
一般迁移到 PackageReference格式的项目都应该使用dotnet cli,否则应该使用nuget cli.
一般安装完 .Net Core SDK 后会自动将dotnet目录加入到path环境变量中,这样可以方便的在任意目录使用dotnet命令

添加NuGet源
`dotnet nuget add [Source]`
删除nuget源
`dotnet nuget remove [Source] `
更新nuget源
`dotnet nuget update [Source]`
禁用nuget源
`dotnet nuget disable [Source]`
启用nuget源
`dotnet nuget enable [Source]`
查看nuget配置
`dotnet nuget locals all --list`
对nuget本地文件夹进行清除
`dotnet nuget locals all --clear`

对于包命令可以使用 -Version 指定版本号,可以使用 -Source 来指定NuGet源
添加包引用
`dotnet add package [Name] [-v Version]`
删除包引用
`dotnet remove pakcage [Name]`
列出引用的包
`dotnet list package`
对当前项目进行打包
`dotnet pack`
还原包(PackageReference格式)
> 对于 dotnet cli,不需要==重新安装包==这个过程,直接使用还原包即可恢复引用.
`dotnet restore`
推送包
`dotnet nuget push [xxx.nupkg] -k [apikey] -s https://api.nuget.org/v3/index.json`
`dotnet nuget push [xxx.nupkg] -k 123456 -s http://192.168.10.221:82/nuget/test`

##### nuget.exe的使用 

nuget.exe CLI 提供了完整的 nuget 功能, 可用于安装、创建、发布和管理包, 而==无需对项目文件进行任何更改==。
nuget.exe cli 适用于 .Net Framework项目
nuget.exe cli 也适用于非 SDK 样式的项目,例如面向 .Net Standard库的非 SDK样式项目
如果你已经迁移到了PackageReference格式,则需要改用 dotnet cli.
nuget.exe cli 需要 packages.config 文件来进行包引用的管理.

> 在大多数情况下,建议将使用 packages.config的非 SDK 样式项目迁移到 PackageReference,然后可以使用dotnet cli 而不是 nuget.exe cli.到目前为止 ,c++和 ASP.NET 项目无法进行迁移.

查看nuget的配置
`nuget locals all -list`
对nuget本地文件夹进行清除
`nuget locals all -clear`

将包安装到当前项目中, 但不修改项目或引用文件。
> 切记使用它nuget.exe的cli命令时,仅仅只是把NuGet包下载到了本地目录,并不会执行添加引用,所以也就没有删除引用等操作,或者说想要删除就直接删除文件目录即可.
`nuget install Newtonsoft.Json  [-OutputDirectory packages] [-Version version]`  
将项目中的包更新为最新版本,仅限 package.config 的 v1格式
`nuget update`
查询源上的包
`nuget list -Source [Source]`
还原包
`nuget restore [solution.sln]`
对项目生成NuGet清单
> 需要注意的时,需要对生成的 nuspec 文件中的属性内容进行填充,否则待会是无法进行打包的
> 当然如果使用了VS从创建的项目,应该可以通过项目的属性界面进行填写,使用 `nuget spec` 命令会自动使用填写的属性
`nuget spec`
对项目进行打包
`nuget pack`
对nuget包进行推送
`nuget push [Name] apikey -Source [Source]`

##### 在Visual Studio中使用 NuGet包管理器

> 建议勾选 选项 - NuGet包管理器 - 中的允许安装第一个包时选择格式

通过在项目上右键点击 Manage Nuget Packages...即可打开NuGet包管理器
然后就是 UI 上面点点鼠标就可以搞定搜索,安装,删除,更新,包还原操作了

通过在解决方案上右键点击 Manage NuGet Packages for Solution...可以同时处理多个项目的NuGet包管理
UI会让你选择受操作影响的项目

> 合并选项卡:可以方便的让你查看解决方案中不同项目使用的具有不同版本号的相同包

> 对于 .net core 或 .net standard 类库项目, Visual Studio的解决方案资源管理器中项目属性上有包属性可以直接进行配置
> 然后对项目执行 pack命令即打包命令即可

> 如果针对的是 .net framework ,可以使用PackageReference方法,需要直接在项目文件中进行包属性配置
> 或者在项目 属性 程序集名称中,提供项目的包属性字段,这些文件保存在 `Properties/AssemblyInfo.cs`中.
> 然后需要单独下载nuget.exe工具使用 spec 创建清单,编辑后,使用 pack 命令创建NuGet包.

##### 在Visual Studio中使用包管理器控制台(PowerShell)
通过 工具 > NuGet包管理器 > 包管理器控制台 名利可以打开控制台

> 虽然 `get-help NuGet` 显示的命令都是有大小写的,但其实并不区分

对于包命令可以使用 -Version 指定版本号,可以使用 -Source 来指定NuGet源,可以使用-ProjectName 来指定项目
添加包引用
`install-package [Name]`
删除包引用
`uninstall-package [Name] [-RemoveDependencies] [-Force]`
更新包引用
`update-package [Name]`
重新安装包,用来解决虽然包引用已经添加但是却没有包的文件
`update-package -reinstall`
更新solution中的所有包
`update-package`
列出引用的包
`get-package`
列出引用的包是否有更新的需要
`get-package -updates`
查询包
`find-package [Name]`

----------------

#### 包还原及其过程和包的重新安装 

##### 还原包的说明

使用以下命令可以根据项目的依赖项还原包
- `dotnet build`
- `dotnet run`
- `dotnet restore`
- `nuget restore`

> 如果尚未安装包,NuGet首先尝试从缓存中检索它,如果包不在缓存中,NuGet将尝试从 Visual Studio 的工具 > 选项 > NuGet 包管理器 > 包源 下的列表中所有已启用的源下载包,在还原期间,NuGet会忽略包源的顺序,而使用最先响应请求的源返回的包.

还原包根据 项目文件 (.csproj) 或 packages.config
前者是 packages.config 格式的非 SDK项目格式
后者是使用 PackageReference 格式的项目

对于 PackageReference格式的项目,还原后, global-packages 文件夹会显示此包,并且会创建 obj/project.assets.json 文件
对于 packages.config格式的项目,项目的packages文件下应会显示该程序包.

默认情况下,NuGet还原操作会使用 global-packages 和 http-cache 文件夹中的包
若要避免使用 global-packages 文件夹，请执行下列操作之一：

*   使用 `nuget locals global-packages -clear` 或 `dotnet nuget locals global-packages --clear` 清除文件夹。
*   在进行还原操作之前，使用下列方法之一暂时更改 global-packages 的位置 ：
    *   将 NUGET_PACKAGES 环境变量设置为其他文件夹。
    *   创建 `NuGet.Config` 文件，将 `globalPackagesFolder`（如果使用 PackageReference）或 `repositoryPath`（如果使用 `packages.config`）设置为其他文件夹。 有关详细信息，请参阅[配置设置](https://docs.microsoft.com/zh-cn/nuget/reference/nuget-config-file#config-section)。
    *   仅限 MSBuild：指定具有 `RestorePackagesPath` 属性的其他文件夹。

若要避免将缓存用于 HTTP 源，请执行下列操作之一：

*   将 `-NoCache` 选项与 `nuget restore` 结合使用，或者将 `--no-cache` 选项与 `dotnet restore` 结合使用。 这些选项不会影响通过 Visual Studio 包管理器或控制台执行的还原操作。
*   使用 `nuget locals http-cache -clear` 或 `dotnet nuget locals http-cache --clear` 清除缓存。
*   暂时将 NUGET_HTTP_CACHE_PATH 环境变量设置为其他文件夹。

##### 安装包的时候流程说明

不同的NuGet工具使用不同的NuGet格式,通常会对项目文件或 packages.config 中的包创建引用,然后执行包还原,然后执行包还原,从而有效的安装包,除了 nuget install,它仅仅是下载并展开包到 packages 文件夹,而不会修改其他任何文件.

一般流程如下:
1. 除nuget.exe以外的工具会将包标识符和版本记录到项目文件或packages.config中
2. 获取包
	- 在 global-packages文件夹中查找
	- 从配置文件指定的 NuGet源 中查找,如果是在线的源,尝试从http-cache中查找(没有标记 nocache命令)
	- 尝试下载包
	- 如果无法下载 则报错	
3. 保存包的副本和http-cache
4. 将包安装到用户的 global-packages 文件夹中
5. NuGet安装所需要的包依赖项
6. 更新项目中的其他文件和文件夹
	- 对于 PackageReference 项目,需要更新的保存在 ==obj/project.assets.json== 中的包依赖关系图.包本身的内容不会复制到项目中,因为包文件实际都存储在 global-packages 中.
	- 对于packages.config格式的项目,如果包使用了 配置文件相关的命令,则会更新 app.config或web.config
7. 仅在 visual studio 中,如果可用则展示NuGet包的自述文件.

##### 重新安装包的说明

使用以下方式可以显式的重新安装指定的包
在包管理器控制台中使用 `update-package -reinstall`
在包管理器UI中删除后重新安装

何时需要重新安装包
1. 包还原后的引用损坏
2. 项目因为删除了文件导致的损坏
3. 包更新导致项目损坏
4. 项目升级后

---------------------------

> 本文内容基本上都来源于 [docs.microsfot.com文档](https://docs.microsoft.com/zh-cn/nuget/what-is-nuget) ,本人只是出于学习的目的根据自己的习惯进行整理和总结.