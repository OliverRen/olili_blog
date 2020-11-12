---
title: BigInteger转换为int,long
---

###### BigInteger转换为int

``` csharp?linenums
public static int SafeInt(this BigInteger i)
{
    if (i > int.MaxValue)
	throw new InvalidCastException("over int max value");
    return (int) i;
}

public static long SafeLong(this BigInteger i)
{
    if (i > long.MaxValue)
	throw new InvalidCastException("over long max value");
    return (long) i;
}
```