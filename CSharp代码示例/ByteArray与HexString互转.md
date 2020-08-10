---
title: ByteArray与HexString互转
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