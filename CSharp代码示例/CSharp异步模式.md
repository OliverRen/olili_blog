---
title: CSharp异步模式
---

[toc]

#### APM

==Asynchronous Programming Model==
需要开始方法名和结束方法名,并需要遵循 BeginXXX 和 EndXXX 的规范.

``` csharp
public class MyClass
 {
    public IAsyncResult BeginRead(byte[] buffer, int offset, int count,AsyncCallback callback, object state);
    public int EndRead(IAsyncResult asyncResult);
}
```

#### EAP

==Event based Asynchronous Pattern==
要求方法以Async为后缀,并且大多是void的,同时要有一个或多个事件,事件句柄委托类型和派生自Event参数的类型.

``` csharp
public class MyClass
{
    public void ReadAsync(byte[] buffer, int offset, int count);
    public event ReadCompletedEventHandler ReadCompleted;
}
public delegate void ReadCompletedEventHandler(object sender, ReadCompletedEventArgs eventArgs);
public class ReadCompletedEventArgs: AsyncCompletedEventArgs
{
    public int Result {
        get;
    }
}
```

#### TAP

==Task based Asynchronous Pattern==
异步操作通过一个单独的方法来表现,异步方法的后缀使用Async命名,TAP中异步方法返回一个Task类型或Task\<TResult\>类型.

``` csharp
public class MyClass
{
    public Task<int> ReadAsync(byte [] buffer, int offset, int count);
}
```

一个基本的TAP方法的参数应该和同步方法的参数相同，且顺序相同。然而，“out”和“ref”参数不遵从这个规则，并且应该避免使用它们。通过out或者ref返回的任何数据可以作为返回的Task<TResult>结果的一部分，可以利用一个元组或者一个自定义数据结构容纳多个值。