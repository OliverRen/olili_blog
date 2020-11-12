---
title: hash计算
---

###### hash计算

``` csharp?linenums
public static uint FNV32Hash(this byte[] array)
{
    var hash = 2166136261;
    for (int i = 0, l = array.Length; i < l; i++)
    {
	hash = (hash * 16777619) ^ array[i];
    }
    return hash;
}
public static string HmacHashStr(string data, string key)
{
    using (var hash = new HMACSHA256(Encoding.UTF8.GetBytes(key)))
    {
	var bytes = hash.ComputeHash(Encoding.UTF8.GetBytes(data));
	return string.Join(string.Empty, bytes.Select(c => c.ToString("X2")));
    }
}
public static string Md5HashStr(string str)
{
    using (var md5 = MD5.Create())
    {
	var bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(str));
	return string.Join(string.Empty, bytes.Select(c => c.ToString("X2")));
    }
}
```