---
title: 使用及扩展log4net
---

[toc]

#### 简介

几乎所有的大型应用都会有自己的用于跟踪调试的API。因为一旦程序被部署以后，就不太可能再利用专门的调试工具了。然而一个管理员可能需要有一套强大的日志系统来诊断和修复配置上的问题。

经验表明，日志记录往往是软件开发周期中的重要组成部分。它具有以下几个优点：它可以提供应用程序运行时的精确环境，可供开发人员尽快找到应用程序中的Bug；一旦在程序中加入了Log 输出代码，程序运行过程中就能生成并输出日志信息而无需人工干预。另外，日志信息可以输出到不同的地方（控制台，文件等）以备以后研究之用。

在.net环境中用的比较多的一个是 NLog ,另外一个就是 apache的log4net,我们开发团队选型原来都会考虑java和.net环境的共通性,由于log4net在java环境中有个姐妹组件 log4j.所以我们选择了使用 log4net. 就是这么简单的理由,lol.

> 这里说的日志系统,仅仅是从程序中记录,提取的一个方式,完整的日志系统可以参考 ELK.

log4net 有四种主要的组件，分别是
- Repository 管理日志库
- Logger 产生日志
- Appender 输出方式
- Layout 输出格式

#### Repository

Repository主要用于负责日志对象组织结构的维护。在log4net的以前版本中，框架仅支持分等级的组织结构(hierarchical organization)。这种等级结构本质上是库的一个实现，并且定义在`log4net.Repository.Hierarchy` 名字空间中。

要实现一个Repository，需要实现`log4net.Repository.ILoggerRepository` 接口。但是通常并不是直接实现该接口，而是以`log4net.Repository.LoggerRepositorySkeleton`为基类继承。体系库(hierarchical repository )则由`log4net.Repository.Hierarchy.Hierarchy`类实现。

如果你是个log4net框架的使用者，而非扩展者，那么你几乎不会在你的代码里用到Repository的类。而是需要用到LogManager类来自动管理库和日志对象。

#### Logger

Logger是直接和应用程序交互的组件。Logger只是产生日志，然后由它引用的Appender记录到指定的媒介，并由Layout控制输出格式。

Logger提供了多种方式来记录一个日志消息，也可以有多个Logger同时存在。每个实例化的Logger对象对被log4net作为命名实体（Named Entity）来维护。

Log4net框架定义了一个叫做LogManager的类，用来管理所有的logger对象。通常来说，我们会以类（class）的类型（type）为参数来调用GetLogger()，以便跟踪我们正在进行日志记录的类。传递的类(class)的类型(type)可以用typeof(Classname)方法来获得.

下面说一下日志的等级，它们由高到底分别为：
==OFF > FATAL > ERROR > WARN > INFO > DEBUG  > ALL==
其中OFF表示停用所以日志记录，ALL表示所有日志都可以记录。

#### Appender

一个好的日志框架应该能够产生多目的地的输出。比如说输出到控制台或保存到一个日志文件。log4net 能够很好的满足这些要求。它使用一个叫做Appender的组件来定义输出介质。正如名字所示，这些组件把它们附加到Logger日志组件上并将输出传递到输出流中。你可以把多个Appender组件附加到一个日志对象上。Log4net框架提供了几个Appender组件。关于log4net提供的Appender组件的完整列表可以在log4net框架的帮助手册中找到。有了这些现成的Appender组件，一般来说你没有必要再自己编写了。但是如果你愿意，可以从`log4net.Appender.AppenderSkeleton`类继承。

**Appenders**

1.  AdoNetAppender 将日志记录到数据库中。可以采用SQL和存储过程两种方式。
2.  AnsiColorTerminalAppender 将日志高亮输出到ANSI终端。
3.  AspNetTraceAppender  能用asp.net中Trace的方式查看记录的日志。
4.  BufferingForwardingAppender 在输出到子Appenders之前先缓存日志事件。
5.  ConsoleAppender 将日志输出到应用程序控制台。
6.  EventLogAppender 将日志写到Windows Event Log。
7.  FileAppender 将日志输出到文件。
8.  ForwardingAppender 发送日志事件到子Appenders。
9.  LocalSyslogAppender 将日志写到local syslog service (仅用于UNIX环境下)。
10.  MemoryAppender 将日志存到内存缓冲区。
11.  NetSendAppender 将日志输出到Windows Messenger service.这些日志信息将在用户终端的对话框中显示。
12.  OutputDebugStringAppender 将日志输出到Debuger，如果程序没有Debuger，就输出到系统Debuger。如果系统Debuger也不可用，将忽略消息。
13.  RemoteSyslogAppender 通过UDP网络协议将日志写到Remote syslog service。
14.  RemotingAppender 通过.NET Remoting将日志写到远程接收端。
15.  RollingFileAppender 将日志以回滚文件的形式写到文件中。
16.  SmtpAppender 将日志写到邮件中。
17.  SmtpPickupDirAppender 将消息以文件的方式放入一个目录中，像IIS SMTP agent这样的SMTP代理就可以阅读或发送它们。
18.  TelnetAppender 客户端通过Telnet来接受日志事件。
19.  TraceAppender 将日志写到.NET trace 系统。
20.  UdpAppender 将日志以无连接UDP数据报的形式送到远程宿主或用UdpClient的形式广播。

**Appender Filters**
一个Appender 对象缺省地将所有的日志事件传递到输出流。Appender的过滤器(Appender Filters) 可以按照不同的标准过滤日志事件。在log4net.Filter的名字空间下已经有几个预定义的过滤器。使用这些过滤器，你可以按照==日志级别==范围过滤日志事件，或者按照某个==特殊的字符串==进行过滤。你可以在API的帮助文件中发现更多关于过滤器的信息。

1.  DenyAllFilter 阻止所有的日志事件被记录
2.  LevelMatchFilter 只有指定等级的日志事件才被记录
3.  LevelRangeFilter 日志等级在指定范围内的事件才被记录
4.  LoggerMatchFilter Logger名称匹配，才记录
5.  PropertyFilter 消息匹配指定的属性值时才被记录
6.  StringMathFilter 消息匹配指定的字符串才被记录

#### Layout

Layout 组件用于向用户显示最后经过格式化的输出信息。输出信息可以以多种格式显示，主要依赖于我们采用的Layout组件类型。一般是一个xml的配置文件。Layout组件和一个Appender组件一起工作。一个Appender只能有一个Layout。

API帮助手册中有关于不同Layout组件的列表。一个Appender对象，只能对应一个Layout对象。要实现你自己的Layout类，你需要从`log4net.Layout.LayoutSkeleton`类继承，它实现了ILayout接口。

最常用的Layout应该是用户自定义格式的`PatternLayout`，其次是SimpleLayout和ExceptionLayout。这里罗列一下 PatterLayout 的格式化字符串:

| Conversion Pattern Name | Effect |
| --- | --- |
| a | 等价于appdomain |
| appdomain | 引发日志事件的应用程序域的友好名称。（我在使用中一般是可执行文件的名字。） |
| c | 等价于 logger |
| C | 等价于 type |
| class | 等价于 type |
| d | 等价于 date |
| date | 发生日志事件的本地时间。 使用 %utcdate 输出UTC时间。date后面还可以跟一个日期格式，用大括号括起来。例如：%date{HH:mm:ss,fff}或者%date{dd MMM yyyy HH:mm:ss,fff}。如果date后面什么也不跟，将使用ISO8601 格式 。日期格式和.Net中DateTime类的ToString方法中使用的格式是一样。另外log4net还有3个自己的格式Formatter。 它们是 "ABSOLUTE", "DATE"和"ISO8601"分别代表 AbsoluteTimeDateFormatter, DateTimeDateFormatter和Iso8601DateFormatter。例如： %date{ISO8601}或%date{ABSOLUTE}。它们的性能要好于ToString。 |
| exception | 异常信息日志事件中必须存了一个异常对象，如果日志事件不包含没有异常对象，将什么也不输出。异常输出完毕后会跟一个换行。一般会在输出异常前加一个换行，并将异常放在最后。 |
| F | 等价于 file |
| file | 发生日志请求的源代码文件的名字。警告：只在调试的时候有效。调用本地信息会影响性能。 |
| identity | 当前活动用户的名字(`Principal.Identity.Name`).警告：会影响性能。（我测试的时候%identity返回都是空的。） |
| l | 等价于 location |
| L | 等价于 line |
| location | 引发日志事件的方法（包括命名空间和类名），以及所在的源文件和行号。警告：会影响性能。没有pdb文件的话，只有方法名，没有源文件名和行号。 |
| level | 日志事件等级 |
| line | 引发日志事件的行号警告：会影响性能。 |
| logger | 记录日志事件的Logger对象的名字。可以使用精度说明符控制Logger的名字的输出层级，默认输出全名。注意，精度符的控制是从右开始的。例如：logger 名为 "a.b.c"， 输出模型为 %logger{2} ，将输出"b.c"。 |
| m | 等价于 message |
| M | 等价于 method |
| message | 由应用程序提供给日志事件的消息。 |
| mdc | MDC (旧为：ThreadContext.Properties) 现在是事件属性的一部分。 保留它是为了兼容性，它等价于 property。 |
| method | 发生日志请求的方法名（只有方法名而已）。警告：会影响性能。 |
| n | 等价于 newline |
| newline | 换行符 |
| ndc | NDC (nested diagnostic context) |
| p | 等价于 level |
| P | 等价于 property |
| properties | 等价于 property |
| property | 输出事件的特殊属性。例如： %property{user} 输出user属性。属性是由loggers或appenders添加到时间中的。 有一个默认的属性"log4net:HostName"总是会有。%property将输出所以的属性 。（我除了知道可以用它获得主机名外，还不知道怎么用。） |
| r | 等价于 timestamp |
| t | 等价于 thread |
| timestamp | 从程序启动到事件发生所经过的毫秒数。 |
| thread | 引发日志事件的线程，如果没有线程名就使用线程号。 |
| type | 引发日志请求的类的全名。.可以使用精度控制符。例如： 类名是 "log4net.Layout.PatternLayout", 格式模型是 %type{1} 将输出"PatternLayout"。（也是从右开始的。）警告：会影响性能。 |
| u | 等价于 identity |
| username | 当前用户的WindowsIdentity。（类似：HostName/Username）警告：会影响性能。 |
| utcdate | 发生日志事件的UTC时间。后面还可以跟一个日期格式，用大括号括起来。例如：%utcdate{HH:mm:ss,fff}或者%utcdate{dd MMM yyyy HH:mm:ss,fff}。如果utcdate后面什么也不跟，将使用ISO8601 格式 。日期格式和.Net中DateTime类的ToString方法中使用的格式是一样。另外log4net还有3个自己的格式Formatter。 它们是 "ABSOLUTE", "DATE"和"ISO8601"分别代表 AbsoluteTimeDateFormatter, DateTimeDateFormatter和Iso8601DateFormatter。例如： %date{ISO8601}或%date{ABSOLUTE}。它们的性能要好于ToString。 |
| w | 等价于 username |
| x | 等价于 ndc |
| X | 等价于 mdc |
| % | %%输出一个百分号 |

> 关于调用本地信息（caller location information）的说明：
> %type %file %line %method %location %class %C %F %L %l %M 都会调用本地信息。这样做会影响性能。本地信息使用`System.Diagnostics.StackTrace`得到。且程序目录下需要 pdb 文件.

#### log4net的配置文件
log4net的使用，主要在配置文件的设置上，以下是Log4net的一个配置示例及常用参数讲解。
``` xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <!--Log设定-->
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler,log4net-net-1.0" />
  </configSections>
  
    <log4net>
  
    <!--日志记录器logger，可以有多个-->    
	<logger name="fileLog">
      <level value="ALL" />
      <appender-ref ref="RollingLogFileAppender" />
      <appender-ref ref="ConsoleAppender" />
    </logger>
    
	<appender name="ConsoleAppender"  type="log4net.Appender.ConsoleAppender" >
      <layout type="log4net.Layout.PatternLayout">
        <param name="ConversionPattern"  value="[%d][%-4p] %m%n"/>
      </layout>
    </appender>
    
	<appender name="RollingLogFileAppender"  type="log4net.Appender.RollingFileAppender" >
      <!--log存放的路径-->
      <param name="File" value="log_" />
      <param name="AppendToFile" value="true" />
      <param name="StaticLogFileName" value="false"/>
      <param name="MaximumFileSize" value="10MB"/>
      <param name="Threshold" value="ALL"></param>
      <param name="DatePattern" value="yyyyMM&quot;\\log_&quot;yyyyMMdd&quot;.log&quot;"/>
      <param name="RollingStyle" value="Composite"/>
      <param name="CountDirection" value="1"/>
      <param name="AppendToFile" value="true"/>
      <layout type="log4net.Layout.PatternLayout">
        <param name="ConversionPattern"  value="[%d][%-4p] %m%n"  />
      </layout>
    </appender>
	
  </log4net>
</configuration>
```

#### 如何使用log4net的配置文件

log4net默认关联的是应用程序的配置文件(AppName.exe.config).
可以使用程序集自定义属性来进行设置。下面来介绍一下这个自定义属性：`log4net.Config.XmlConifguratorAttribute`

XmlConfiguratorAttribute有3个属性：
- ConfigFile 配置文件的名字，文件路径相对于应用程序目录(`AppDomain.CurrentDomain.BaseDirectory`)。ConfigFile属性不能和ConfigFileExtension属性一起使用。
- ConfigFileExtension 配置文件的扩展名，文件路径相对于应用程序的目录。ConfigFileExtension属性不能和ConfigFile属性一起使用。
- Watch 如果将Watch属性设置为true，就会监视配置文件。当配置文件发生变化的时候，就会重新加载。

你可以在程序启动时添加如下代码:
`log4net.Config.XmlConfigurator.Configure();`
或在AssemblyInfo中添加引用
` [assembly:log4net.Config.XmlConfigurator()]`