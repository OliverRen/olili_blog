---
title: hash计算
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