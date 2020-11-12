---
title: 使用代码管理IIS
---

###### 使用代码管理IIS

关于Microsoft.Web.Administration相关操作参数详见如下代码：
==需要引入Microsoft.Web.Administration.dll==

``` csharp
Microsoft.Web.Administration.ServerManager sm = new Microsoft.Web.Administration.ServerManager();

            System.Console.WriteLine("应用程序池默认设置：");
            System.Console.WriteLine("\t常规：");
            System.Console.WriteLine("\t\t.NET Framework 版本：{0}", sm.ApplicationPoolDefaults.ManagedRuntimeVersion);
            System.Console.WriteLine("\t\t队列长度：{0}", sm.ApplicationPoolDefaults.QueueLength);
            System.Console.WriteLine("\t\t托管管道模式：{0}", sm.ApplicationPoolDefaults.ManagedPipelineMode.ToString());
            System.Console.WriteLine("\t\t自动启动：{0}", sm.ApplicationPoolDefaults.AutoStart);

            System.Console.WriteLine("\tCPU：");
            System.Console.WriteLine("\t\t处理器关联掩码：{0}", sm.ApplicationPoolDefaults.Cpu.SmpProcessorAffinityMask);
            System.Console.WriteLine("\t\t限制：{0}", sm.ApplicationPoolDefaults.Cpu.Limit);
            System.Console.WriteLine("\t\t限制操作：{0}", sm.ApplicationPoolDefaults.Cpu.Action.ToString());
            System.Console.WriteLine("\t\t限制间隔（分钟）：{0}", sm.ApplicationPoolDefaults.Cpu.ResetInterval.TotalMinutes);
            System.Console.WriteLine("\t\t已启用处理器关联：{0}", sm.ApplicationPoolDefaults.Cpu.SmpAffinitized);

            System.Console.WriteLine("\t回收：");
            System.Console.WriteLine("\t\t发生配置更改时禁止回收：{0}", sm.ApplicationPoolDefaults.Recycling.DisallowRotationOnConfigChange);
            System.Console.WriteLine("\t\t固定时间间隔（分钟）：{0}", sm.ApplicationPoolDefaults.Recycling.PeriodicRestart.Time.TotalMinutes);
            System.Console.WriteLine("\t\t禁用重叠回收：{0}", sm.ApplicationPoolDefaults.Recycling.DisallowOverlappingRotation);
            System.Console.WriteLine("\t\t请求限制：{0}", sm.ApplicationPoolDefaults.Recycling.PeriodicRestart.Requests);
            System.Console.WriteLine("\t\t虚拟内存限制（KB）：{0}", sm.ApplicationPoolDefaults.Recycling.PeriodicRestart.Memory);
            System.Console.WriteLine("\t\t专用内存限制（KB）：{0}", sm.ApplicationPoolDefaults.Recycling.PeriodicRestart.PrivateMemory);
            System.Console.WriteLine("\t\t特定时间：{0}", sm.ApplicationPoolDefaults.Recycling.PeriodicRestart.Schedule.ToString());
            System.Console.WriteLine("\t\t生成回收事件日志条目：{0}", sm.ApplicationPoolDefaults.Recycling.LogEventOnRecycle.ToString());

            System.Console.WriteLine("\t进程孤立：");
            System.Console.WriteLine("\t\t可执行文件：{0}", sm.ApplicationPoolDefaults.Failure.OrphanActionExe);
            System.Console.WriteLine("\t\t可执行文件参数：{0}", sm.ApplicationPoolDefaults.Failure.OrphanActionParams);
            System.Console.WriteLine("\t\t已启用：{0}", sm.ApplicationPoolDefaults.Failure.OrphanWorkerProcess);

            System.Console.WriteLine("\t进程模型：");
            System.Console.WriteLine("\t\tPing 间隔（秒）：{0}", sm.ApplicationPoolDefaults.ProcessModel.PingInterval.TotalSeconds);
            System.Console.WriteLine("\t\tPing 最大响应时间（秒）：{0}", sm.ApplicationPoolDefaults.ProcessModel.PingResponseTime.TotalSeconds);
            System.Console.WriteLine("\t\t标识：{0}", sm.ApplicationPoolDefaults.ProcessModel.IdentityType);
            System.Console.WriteLine("\t\t用户名：{0}", sm.ApplicationPoolDefaults.ProcessModel.UserName);
            System.Console.WriteLine("\t\t密码：{0}", sm.ApplicationPoolDefaults.ProcessModel.Password);
            System.Console.WriteLine("\t\t关闭时间限制（秒）：{0}", sm.ApplicationPoolDefaults.ProcessModel.ShutdownTimeLimit.TotalSeconds);
            System.Console.WriteLine("\t\t加载用户配置文件：{0}", sm.ApplicationPoolDefaults.ProcessModel.LoadUserProfile);
            System.Console.WriteLine("\t\t启动时间限制（秒）：{0}", sm.ApplicationPoolDefaults.ProcessModel.StartupTimeLimit.TotalSeconds);
            System.Console.WriteLine("\t\t允许 Ping：{0}", sm.ApplicationPoolDefaults.ProcessModel.PingingEnabled);
            System.Console.WriteLine("\t\t闲置超时（分钟）：{0}", sm.ApplicationPoolDefaults.ProcessModel.IdleTimeout.TotalMinutes);
            System.Console.WriteLine("\t\t最大工作进程数：{0}", sm.ApplicationPoolDefaults.ProcessModel.MaxProcesses);

            System.Console.WriteLine("\t快速故障防护：");
            System.Console.WriteLine("\t\t“服务不可用”响应类型：{0}", sm.ApplicationPoolDefaults.Failure.LoadBalancerCapabilities.ToString());
            System.Console.WriteLine("\t\t故障间隔（分钟）：{0}", sm.ApplicationPoolDefaults.Failure.RapidFailProtectionInterval.TotalMinutes);
            System.Console.WriteLine("\t\t关闭可执行文件：{0}", sm.ApplicationPoolDefaults.Failure.AutoShutdownExe);
            System.Console.WriteLine("\t\t关闭可执行文件参数：{0}", sm.ApplicationPoolDefaults.Failure.AutoShutdownParams);
            System.Console.WriteLine("\t\t已启用：{0}", sm.ApplicationPoolDefaults.Failure.RapidFailProtection);
            System.Console.WriteLine("\t\t最大故障数：{0}", sm.ApplicationPoolDefaults.Failure.RapidFailProtectionMaxCrashes);
            System.Console.WriteLine("\t\t允许32位应用程序运行在64位 Windows 上：{0}", sm.ApplicationPoolDefaults.Enable32BitAppOnWin64);

            System.Console.WriteLine();
            System.Console.WriteLine("网站默认设置：");
            System.Console.WriteLine("\t常规：");
            System.Console.WriteLine("\t\t物理路径凭据：UserName={0}, Password={1}", sm.VirtualDirectoryDefaults.UserName, sm.VirtualDirectoryDefaults.Password);
            System.Console.WriteLine("\t\t物理路径凭据登录类型：{0}", sm.VirtualDirectoryDefaults.LogonMethod.ToString());
            System.Console.WriteLine("\t\t应用程序池：{0}", sm.ApplicationDefaults.ApplicationPoolName);
            System.Console.WriteLine("\t\t自动启动：{0}", sm.SiteDefaults.ServerAutoStart);
            System.Console.WriteLine("\t行为：");
            System.Console.WriteLine("\t\t连接限制：");
            System.Console.WriteLine("\t\t\t连接超时（秒）：{0}", sm.SiteDefaults.Limits.ConnectionTimeout.TotalSeconds);
            System.Console.WriteLine("\t\t\t最大并发连接数：{0}", sm.SiteDefaults.Limits.MaxConnections);
            System.Console.WriteLine("\t\t\t最大带宽（字节/秒）：{0}", sm.SiteDefaults.Limits.MaxBandwidth);
            System.Console.WriteLine("\t\t失败请求跟踪：");
            System.Console.WriteLine("\t\t\t跟踪文件的最大数量：{0}", sm.SiteDefaults.TraceFailedRequestsLogging.MaxLogFiles);
            System.Console.WriteLine("\t\t\t目录：{0}", sm.SiteDefaults.TraceFailedRequestsLogging.Directory);
            System.Console.WriteLine("\t\t\t已启用：{0}", sm.SiteDefaults.TraceFailedRequestsLogging.Enabled);
            System.Console.WriteLine("\t\t已启用的协议：{0}", sm.ApplicationDefaults.EnabledProtocols);

            foreach (var s in sm.Sites)//遍历网站
            {
                System.Console.WriteLine();
                System.Console.WriteLine("模式名：{0}", s.Schema.Name);
                System.Console.WriteLine("编号：{0}", s.Id);
                System.Console.WriteLine("网站名称：{0}", s.Name);
                System.Console.WriteLine("物理路径：{0}", s.Applications["/"].VirtualDirectories["/"].PhysicalPath);
                System.Console.WriteLine("物理路径凭据：{0}", s.Methods.ToString());
                System.Console.WriteLine("应用程序池：{0}", s.Applications["/"].ApplicationPoolName);
                System.Console.WriteLine("已启用的协议：{0}", s.Applications["/"].EnabledProtocols);
                System.Console.WriteLine("自动启动：{0}", s.ServerAutoStart);
                System.Console.WriteLine("运行状态：{0}", s.State.ToString());

                System.Console.WriteLine("网站绑定：");
                foreach (var tmp in s.Bindings)
                {
                    System.Console.WriteLine("\t类型：{0}", tmp.Protocol);
                    System.Console.WriteLine("\tIP 地址：{0}", tmp.EndPoint.Address.ToString());
                    System.Console.WriteLine("\t端口：{0}", tmp.EndPoint.Port.ToString());
                    System.Console.WriteLine("\t主机名：{0}", tmp.Host);
                    //System.Console.WriteLine(tmp.BindingInformation);
                    //System.Console.WriteLine(tmp.CertificateStoreName);
                    //System.Console.WriteLine(tmp.IsIPPortHostBinding);
                    //System.Console.WriteLine(tmp.IsLocallyStored);
                    //System.Console.WriteLine(tmp.UseDsMapper);
                }

                System.Console.WriteLine("连接限制：");
                System.Console.WriteLine("\t连接超时（秒）：{0}", s.Limits.ConnectionTimeout.TotalSeconds);
                System.Console.WriteLine("\t最大并发连接数：{0}", s.Limits.MaxConnections);
                System.Console.WriteLine("\t最大带宽（字节/秒）：{0}", s.Limits.MaxBandwidth);

                System.Console.WriteLine("失败请求跟踪：");
                System.Console.WriteLine("\t跟踪文件的最大数量：{0}", s.TraceFailedRequestsLogging.MaxLogFiles);
                System.Console.WriteLine("\t目录：{0}", s.TraceFailedRequestsLogging.Directory);
                System.Console.WriteLine("\t已启用：{0}", s.TraceFailedRequestsLogging.Enabled);

                System.Console.WriteLine("日志：");
                //System.Console.WriteLine("\t启用日志服务：{0}", s.LogFile.Enabled);
                System.Console.WriteLine("\t格式：{0}", s.LogFile.LogFormat.ToString());
                System.Console.WriteLine("\t目录：{0}", s.LogFile.Directory);
                System.Console.WriteLine("\t文件包含字段：{0}", s.LogFile.LogExtFileFlags.ToString());
                System.Console.WriteLine("\t计划：{0}", s.LogFile.Period.ToString());
                System.Console.WriteLine("\t最大文件大小（字节）：{0}", s.LogFile.TruncateSize);
                System.Console.WriteLine("\t使用本地时间进行文件命名和滚动更新：{0}", s.LogFile.LocalTimeRollover);

                System.Console.WriteLine("----应用程序的默认应用程序池：{0}", s.ApplicationDefaults.ApplicationPoolName);
                System.Console.WriteLine("----应用程序的默认已启用的协议：{0}", s.ApplicationDefaults.EnabledProtocols);
                //System.Console.WriteLine("----应用程序的默认物理路径凭据：{0}", s.ApplicationDefaults.Methods.ToString());
                //System.Console.WriteLine("----虚拟目录的默认物理路径凭据：{0}", s.VirtualDirectoryDefaults.Methods.ToString());
                System.Console.WriteLine("----虚拟目录的默认物理路径凭据登录类型：{0}", s.VirtualDirectoryDefaults.LogonMethod.ToString());
                System.Console.WriteLine("----虚拟目录的默认用户名：{0}", s.VirtualDirectoryDefaults.UserName);
                System.Console.WriteLine("----虚拟目录的默认用户密码：{0}", s.VirtualDirectoryDefaults.Password);
                System.Console.WriteLine("应用程序 列表：");
                foreach (var tmp in s.Applications)
                {
                    if (tmp.Path != "/")
                    {
                        System.Console.WriteLine("\t模式名：{0}", tmp.Schema.Name);
                        System.Console.WriteLine("\t虚拟路径：{0}", tmp.Path);
                        System.Console.WriteLine("\t物理路径：{0}", tmp.VirtualDirectories["/"].PhysicalPath);
                        //System.Console.WriteLine("\t物理路径凭据：{0}", tmp.Methods.ToString());
                        System.Console.WriteLine("\t应用程序池：{0}", tmp.ApplicationPoolName);
                        System.Console.WriteLine("\t已启用的协议：{0}", tmp.EnabledProtocols);
                    }
                    System.Console.WriteLine("\t虚拟目录 列表：");
                    foreach (var tmp2 in tmp.VirtualDirectories)
                    {
                        if (tmp2.Path != "/")
                        {
                            System.Console.WriteLine("\t\t模式名：{0}", tmp2.Schema.Name);
                            System.Console.WriteLine("\t\t虚拟路径：{0}", tmp2.Path);
                            System.Console.WriteLine("\t\t物理路径：{0}", tmp2.PhysicalPath);
                            //System.Console.WriteLine("\t\t物理路径凭据：{0}", tmp2.Methods.ToString());
                            System.Console.WriteLine("\t\t物理路径凭据登录类型：{0}", tmp2.LogonMethod.ToString());
                        }
                    }
                }
            }
```