---
title: IP和数字互转
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