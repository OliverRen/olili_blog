---
title: ULong映射到Long
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