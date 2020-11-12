---
title: ByteArray与HexString互转
---

###### ByteArray 与 HexString 互转

``` csharp?linenums
// hex字符串转为byte array
public static byte[] HexToByteArrayViaShiftByte(string hex)
{
    int GetHexVal(char c)
    {
	// char强制转换为int
	int val = c;
	return val - (val < 58 ? 48 : (val < 97 ? 55 : 87));
    }

    if (hex.Length % 2 == 1)
	throw new Exception("The binary key cannot have an odd number of digits");
    var arr = new byte[hex.Length >> 1];
    for (var i = 0; i < hex.Length >> 1; ++i)
    {
	arr[i] = (byte) ((GetHexVal(hex[i << 1]) << 4) + (GetHexVal(hex[(i << 1) + 1])));
    }
    return arr;
}

// byte shift lookup table,length=256
private static uint[] _Lookup32 = Enumerable.Range(0, 256).Select(i =>
{
    var s = i.ToString("X2");
    return ((uint) s[0]) + ((uint) s[1] << 16);
}).ToArray();
// byte array 转为 hex字符串
public static string ByteArrayToHexViaLookupPerByte(byte[] bytes)
{
    var result = new char[bytes.Length * 2];
    for (var i = 0; i < bytes.Length; i++)
    {
	var val = _Lookup32[bytes[i]];
	result[2 * i] = (char) val;
	result[2 * i + 1] = (char) (val >> 16);
    }
    return new string(result);
}
```