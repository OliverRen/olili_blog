---
title: PCIe带宽
---

[toc]

直接上图再说明

![PCIe不同版本的编码方式和传输速率](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/PCIE带宽/20201015/1602746800303.png)

PCIe 吞吐量（可用带宽）计算方法：

`吞吐量 = 传输速率 *  编码方案`

例如：PCI-e2.0 协议支持 5.0 GT/s，即每一条Lane 上支持每秒钟内传输 5G个Bit；但这并不意味着 PCIe 2.0协议的每一条Lane支持 5Gbps 的速率。

为什么这么说呢？因为PCIe 2.0 的物理层协议中使用的是 8b/10b 的编码方案。 即每传输8个Bit，需要发送10个Bit；这多出的2个Bit并不是对上层有意义的信息。

那么，PCIe 2.0协议的每一条Lane支持 5 * 8 / 10 = 4 Gbps = 500 MB/s 的速率。

以一个PCIe 2.0 x8的通道为例，x8的可用带宽为 4 * 8 = 32 Gbps = 4 GB/s。

 同理，PCI-e3.0 协议支持 8.0 GT/s, 即每一条Lane 上支持每秒钟内传输 8G个Bit。

而PCIe 3.0 的物理层协议中使用的是 128b/130b 的编码方案。 即每传输128个Bit，需要发送130个Bit。

那么， PCIe 3.0协议的每一条Lane支持 8 * 128 / 130 = 7.877 Gbps = 984.6 MB/s 的速率。

一个PCIe 3.0 x16的通道，x16 的可用带宽为 7.877 * 16 = 126.031 Gbps = 15.754 GB/s。

顺便提一句,目前最强劲的SSD走PCIe的话需要 PCIe 4.0\*4 才不会由瓶颈.可以参看Intel的服务器SSD和三星的服务器SSD

![Intel D7-P5500](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/PCIe带宽/20201015/1602747101093.png)

[来源 www.intel.cn](https://www.intel.cn/content/www/cn/zh/products/memory-storage/solid-state-drives/data-center-ssds/d7-series/d7-p5500-series/d7-p5500-7-68tb-2-5in-3d3.html) 

![三星980](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/PCIe带宽/20201015/1602747230522.png)

[来源 www.samsungeshop.com.cn](https://www.samsungeshop.com.cn/item/MZ-V8/1314.htm)

