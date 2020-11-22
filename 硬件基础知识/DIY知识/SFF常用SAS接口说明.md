---
title: SFF常用SAS接口说明
tags: 
---

[toc]

许多连接器的解决方案都是作为SFF规范开发并记录在SFF委员会中的。随后，大多数文件都被EIA，ANSI和IEC等组织纳入标准或作为标准发布。

SFF规范主要包括串行连接SCSI，光纤通道，以太网802.3和InfiniBand 标准规范等,这里我们仅记录SAS常见接口的说明

- SAS 3.0 速率12Gbps,带宽4\*12Gbps
- SAS 2.1和SAS 2.0 速率6Gbps,带宽4\*6Gbps
- SAS 1.1和SAS 1.0 速率3Gbps,带宽4\*3Gbps

目前主要的接口和接头有如下,其中这些较新的SFF-8644和SFF-8643 HD SAS连接器接口基本上取代了旧的SFF-8088外部和SFF-8087内部SAS接口。

#### SFF-8643 : Internal Mini SAS HD 4i/8i

SAS 3.0 4通道 12Gbps

- SFF-8643是最新的HD MiniSAS连接器设计，用于实现HD SAS内部互连解决方案。
- SFF-8643是一款36针“高密度SAS”连接器，采用通常用于内部连接的塑料体。典型应用是SAS HBA与SAS驱动器之间的INTERNAL SAS链路。
- SFF-8643符合最新的SAS 3.0规范，并支持12Gb / s数据传输协议
- SFF-8643的HD MiniSAS外部对应产品是SFF-8644，它也兼容SAS 3.0，并且还支持12Gb / s SAS数据传输速度
- SFF-8643和SFF-8644都可以支持最多4端口（4通道）的SAS数据。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606045900905.png)

#### SFF-8644：External Mini SAS HD 4x / 8x

- SFF-8644是最新的HD MiniSAS连接器设计，用于实现HD SAS外部互连解决方案。
- SFF-8644是一款36针“高密度SAS”连接器，采用与屏蔽外部连接兼容的金属外壳。典型应用是SAS HBA与SAS驱动器子系统之间的SAS链路。
- SFF-8644符合最新的SAS 3.0规范，并支持12Gb / s数据传输协议
- SFF-8644的HD MiniSAS内部对应产品是SFF-8643，它也兼容SAS 3.0，并且还支持12Gb / s SAS数据传输速度。
- SFF-8644和SFF-8643都可以支持最多4端口（4通道）的SAS数据。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606045940933.png)

#### SFF-8087：Internal Mini SAS 4i

SAS 2.0 4通道 6Gbps

- SFF-8087 Mini-SAS连接器专为实现Mini SAS内部互连解决方案而设计。
- SFF-8087是一款36针“ Mini SAS ”连接器，采用兼容内部连接的塑料锁定接口。典型应用是SAS HBA与SAS驱动器子系统之间的SAS链路。
- SFF-8087符合最新的6Gb / s Mini-SAS 2.0规范，支持6Gb / s数据传输协议
- SFF-8087的Mini-SAS外部对应产品是SFF-8088，它也兼容Mini-SAS 2.0，并且还支持6Gb / s SAS数据传输速度。
- SFF-8087和SFF-8088均可支持最多4端口（4通道）的SAS数据。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606046024494.png)

#### SFF-8088：External Mini SAS 4x

- SFF-8088 Mini-SAS连接器专为实现Mini SAS外部互连解决方案而设计。
- SFF-8088是一款26针“ Mini SAS ”连接器，采用与屏蔽外部连接兼容的金属外壳。典型应用是SAS HBA与SAS驱动器子系统之间的SAS链路。
- SFF-8088符合最新的6Gb / s Mini-SAS 2.0规范，支持6Gb / s数据传输协议。
- SFF-8088的Mini-SAS内部对应产品是SFF-8087，它也兼容Mini-SAS 2.0，并且还支持6Gb / s SAS数据传输速度。
- SFF-8088和SFF-8087均可支持最多4端口（4通道）的SAS数据。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606046054561.png)

--------------------------------------------

#### SFF-8639（现称'U.2'）

U.2 12Gbps 支持NVMe 背板型号

- SFF-8639是最新的连接器设计，用于连接MultiLink SAS驱动器或PCIe驱动器（包括硬盘驱动器和SSD驱动器）。它最近被SSD小型工具组重新命名为“U.2”。
- SFF-8639是SFF-8680的修订版，它是一个29针2通道SAS驱动器接口。SFF-8639 U.2是一款68针驱动器接口连接器，具有更高的信号质量，可支持12Gb / s SAS和Gen 3 x4 PCIe或PCI Express NVMe。
- SFF-8639 / U.2连接器可以集成到多个驱动器的pcb“对接底板”上，也可以集成到单个驱动器“T-Card”适配器上。
- SFF-8639 U.2连接器共有6条高速信号路径，但SAS和PCIe规格在任何时候都只能使用多达4条通道。
- 它符合最新的12Gb / s SAS 3.0规范以及x4 Gen3 PCIe和SSD Form Factor V 1.0。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606046132648.png)

#### SFF-8680

SAS 3.0 12Gbps 背板型号

- SFF-8680是最新的连接器设计，用于连接SAS驱动器 - SAS硬盘和SAS SSD驱动器。
- SFF-8680是一个29针连接器，带有塑料主体，配置有15个引脚，支持驱动器的电源要求，以及（2）7组引脚，用于传输SAS数据信号。
- SFF-8680支持2个SAS端口（通道）与驱动器之间的连接。
- SFF-8680可以集成到用于多个驱动器的pcb“对接底板”上，也可以集成到单个驱动器“T-Card”适配器上。
- SFF-8680符合最新的SAS 3.0规范，并支持12Gb / s数据传输协议。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606046285562.png)

这种较新的SFF-8680驱动器接口连接器接口基本上取代了旧的SFF-8482驱动器接口连接器。

#### SFF-8482

- SFF-8482是一种连接器设计，用于连接SAS驱动器，SAS硬盘驱动器和SAS SSD驱动器的连接。
- SFF-8482是一个29针连接器，带有塑料主体，配置有15个引脚，可支持驱动器的电源要求;（2）7组引脚，用于传输SAS数据信号。
- SFF-8482支持2个SAS端口（通道）与驱动器之间的连接。
- SFF-8482可以集成到多个驱动器的pcb“对接”背板上，安装在单驱动器“T-Card”适配器上。

![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/SFF常用SAS接口说明/20201122/1606046374674.png)

----------------------------------------

本文部分内容采自 [猫先生的blog](https://www.mr-mao.cn/archives/mini-sas-introduction.html)