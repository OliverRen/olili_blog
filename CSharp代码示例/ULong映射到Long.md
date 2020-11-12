---
title: ULong映射到Long
---

###### Map ULong to Long

``` csharp?linenums
public static long MapUlongToLong(this ulong ulongValue)
{
    return unchecked((long) ulongValue + long.MinValue);
}

public static ulong MapLongToUlong(this long longValue)
{
    return unchecked((ulong) (longValue - long.MinValue));
}
```