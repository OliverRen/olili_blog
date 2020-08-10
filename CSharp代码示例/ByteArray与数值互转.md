---
title: ByteArray与数值互转
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

###### ByteArray 与 数值互转

``` csharp?linenums
// BitConverter.IsLittleEndian=true
// Utils.NetworkBitConverter 又固定是false

public static byte[] ToBytes(uint value, bool littleEndian = true)
{
    if (littleEndian)
    {
	return new[]
	{
	    (byte) value,
	    (byte) (value >> 8),
	    (byte) (value >> 16),
	    (byte) (value >> 24)
	};
    }
    return new[]
    {
	(byte) (value >> 24),
	(byte) (value >> 16),
	(byte) (value >> 8),
	(byte) value
    };
}

public static byte[] ToBytes(ulong value, bool littleEndian)
{
    if (littleEndian)
    {
	return new[]
	{
	    (byte) value,
	    (byte) (value >> 8),
	    (byte) (value >> 16),
	    (byte) (value >> 24),
	    (byte) (value >> 32),
	    (byte) (value >> 40),
	    (byte) (value >> 48),
	    (byte) (value >> 56)
	};
    }
    return new[]
    {
	(byte) (value >> 56),
	(byte) (value >> 48),
	(byte) (value >> 40),
	(byte) (value >> 32),
	(byte) (value >> 24),
	(byte) (value >> 16),
	(byte) (value >> 8),
	(byte) value
    };
}

public static uint ToUInt32(byte[] value, int index, bool littleEndian)
{
    if (littleEndian)
    {
	return value[index]
	       + ((uint) value[index + 1] << 8)
	       + ((uint) value[index + 2] << 16)
	       + ((uint) value[index + 3] << 24);
    }
    return value[index + 3]
	   + ((uint) value[index + 2] << 8)
	   + ((uint) value[index + 1] << 16)
	   + ((uint) value[index + 0] << 24);
}

public static int ToInt32(byte[] value, int index, bool littleEndian)
{
    return unchecked((int) ToUInt32(value, index, littleEndian));
}
```