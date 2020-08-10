---
title: 优雅的关闭console程序
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

不同于Windows Service,我们的 service继承自 `System.ServiceProcess.ServiceBase` 然后实现了OnStop和OnShutdown就可以很好的借助与 服务管理器的调用来合理的关闭后台线程和一些其他资源.使用 Console作为宿主在用户关闭窗口时是显得猝不及防的.

我们可以使用 ManualResetEvent 或 ManualResetEventSlim 的wait来代替 Console.ReadLine 阻塞主线程,这样就可能有额外的监听进程退出,然后销毁应当销毁的资源的机会了.

``` csharp
class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");

            // 使用轻量级手动事件复位
            ManualResetEventSlim exit = new ManualResetEventSlim(false);
            // 注册事件以拦截 ctrl+C,ctrl+Break 的关闭窗口
            Console.CancelKeyPress += (sender, e) =>
             {
                 var key = e.SpecialKey;
                 e.Cancel = false;
                 exit.Set();
             };
            // 注册事件以在appdomain关闭的时候回调
            // 这里操作系统等待的事件并不长,依然又可能来不及关闭所有的资源,但是给了一个机会去运行在wait后的代码
            AppDomain.CurrentDomain.ProcessExit += (sender, e) =>
            {
                exit.Set();
            };

            // do a lot back thread job
            // add some threads
            // open some resources
            // start listen sockets

            // 主线程等待
            exit.Wait();

            // 手动重置后程序结束

            // close back thread
            // close resources
            // close net listen

            Console.WriteLine("Bye Bye");
        }
    }
```