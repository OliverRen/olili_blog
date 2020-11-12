---
title: ByteArray与数值互转
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