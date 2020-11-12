---
title: IP和数字互转
---

###### IP和数字互转

``` csharp?linenums
// ip转为数字
public static long IpToLong(string ip)
{
    char[] separator = {'.'};
    var items = ip.Split(separator);
    return long.Parse(items[0]) << 24
	   | long.Parse(items[1]) << 16
	   | long.Parse(items[2]) << 8
	   | long.Parse(items[3]);
}

// 数字转ip
public static string LongToIp(long ipInt)
{
    var sb = new StringBuilder();
    sb.Append((ipInt >> 24) & 0xFF).Append(".");
    sb.Append((ipInt >> 16) & 0xFF).Append(".");
    sb.Append((ipInt >> 8) & 0xFF).Append(".");
    sb.Append(ipInt & 0xFF);
    return sb.ToString();
}
```