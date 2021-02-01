---
title: 实用的NVIDIA-SMI查询示例
tags: 
---

[toc]

#### > 简单查询

`nvidia-smi -L | --list-gpus` : 显示系统可识别的显卡，输出示例：

`nvidia-smi -f | --filename` : 将查询结果存入文件而不是输出到终端<br />`nvidia-smi -q | --query` : 查看GPU或Unit信息，可结合以下几个参量同时使用达到特定目的：

*   `-i | --id=` : 仅针对指定设备ID的GPU查询，e.g. `nvidia-smi -q -i 0` 查看设备ID为0的GPU信息
*   `-u | --unit` : 查询Unit属性，不使用该参量默认查询GPU属性
*   `-f | --filename=` : 将查询结果保存到文件，屏蔽终端输出
*   `-x | --xml-format` : 生成xml格式的结果
*   `-d | --display=` : 有选择性地查询某些字段，支持的字段包括：memory, utilization, ecc, temperature, power, clock, compute, pids, performance, supported_clocks, page_retirement, accounting, encoder stats
*   `-l | --loop=` : 持续查询除非在指定秒间隔内检测到Ctrl+C中断
*   `-lms | --loop-ms=` ：持续查询除非在指定的毫秒间隔内检测到Ctrl+C中断

#### > 自定义查询

`nvidia-smi --query-gpu=` : 按自定字段查询GPU信息，支持 `-i | --id=` , `-f | --filename` , `-l | --loop=` & `-lms | --loop-ms` 附加参量。可通过 `--format=` 指定查询信息以哪个格式输出，支持的格式类型有：

*   `csv` : comma separated values
*   `noheader` : skip the first line with column headers or field names
*   `nounits` : don't print units for numerical values

支持的GPU字段包括：

*   `timestamp` : 查询时间，以"YYYY/MM/DD HH:MM:SS.msec"格式给出
*   `driver_version` : 以字符串格式给出当前安装的Nvidia显卡驱动版本
*   `count` : 显卡个数
*   `name` 或 `gpu_name` : 官方给定的显卡名称
*   `serial` 或 `gpu_serial` : 产品序列号，应与板载序列识别号一致，全球唯一
*   `uuid` 或 `gpu_uuid` : 全球唯一设备编号，与板载识别号无关
*   `pci.bus_id` 或 `gpu_bus_id` ： 十六进制PCI总线编号 “domain:bus:device.function”
*   `pci.domain` ： 十六进制PCI域（domain number）
*   `pci.bus` ：十六进制PCI总线 （bus number）
*   `pci.device` ： 十六进制PCI设备 （device number）
*   `pci.device_id` : PCI vendor device id, in hex
*   `pci.sub_device_id` : PCI Sub System id, in hex
*   `pcie.link.gen.current` : the current pcie link generation, may be reduced when the GPU is not in use
*   `pcie.link.gen.max` : the maxium pcie link generation possible with this GPU and system configuration
*   `pcie.link.width.current` : the current pcie link width, may be reduced when the gpu is not in use
*   `pcie.link.width.max` : the ma pcie link width possible with this GPU and system configuration
*   `index` : GPU索引值，其实编号为0
*   `display_mode` ：显卡是否连接显示器指示位，Enabled 表示有外接显示设备，其他情况 Disabled
*   `display_active` : 显示器是否经由GPU处理显示内容指示位，Enabled 表示GPU正负责某显示任务，Disabled表示其他情况。注意：即使显卡没有外接物理显示设备，该指示位依然可能是Enabled
*   `persistence_mode` : 是否出于persistence mode 指示位，Enabled 表示开启，Disabled 表示关闭。开启该模式后显卡驱动将常驻显存，降低显卡响应延时，仅Linux平台有效。
*   `accounting.mode` : 统计模式是否开启标识位，Enabled 或 Disabled。开启统计模式，占用显卡进程的信息将被统计便于进程执行期间查询或进程结束后查询。进程的总执行时间在进程结束之前保持为0，进程结束后更新为进程实际占用GPU时间。
*   `accounting.buffer_size` : 进程循环缓冲区大小，表示被统计进程的最大数量。缓存区中保持着当前被统计的进程，缓冲区满后新进程会覆盖旧进程。
*   `driver_mode.current` ： 当前使用的驱动模式，在linux平台上该值为 N/A。 Windows平台支持TCC和WDDM两种模式，可通过 `-dm` 或 `-fdm` 指定显卡驱动模式。TCC模式专为高性能计算优化，WDDM模式专为图形应用优化，高性能运算不建议使用WDDM模式。
*   `driver_mode.pending` : 预设驱动模式，下次设备重启后应用。linux平台总是为N/A
*   `vbios_version` : 板载BIOS版本
*   `inforom.img` 或 `inforom.image` : Global version of the infoROM image. Image version just like VBIOS version uniquely describes the exact version of the infoROM flashed on the board in contrast to infoROM object version which is only an indicator of supported features.
*   `inforom.oem` : Version for the OEM configuration data.
*   `inforom.ecc` : Version for the ECC recording data.
*   `inforom.pwr` : Version for the power management data.
*   `gom.current` 或 `gpu_operation_mode.current` : 当前使用GOM。GOM支持通过禁用部分显卡特性来省电和提高吞吐量，可通过 `--gom` 进行模式切换，支持的模式包括：
    *   `All On` ：显卡功能全开，全速运行
    *   `Compute` : 仅作为高性能运算，不支持图形操作
    *   `Low Double Precision` ：仅针对不需要高带宽、双精度计算的图形图像操作
*   `gom.pending` : 预设的GOM模式，设备下次重启时应用
*   `fan.speed` : 该值指示风扇应以多大功率运行并不是实际检测量，0表示不运行，100%表示全功率运行。如果风扇损坏或不能控制，则实际运行功率与该值可能不匹配。
*   `pstate` : 当前显卡性能状态等级，P0表示满级状态，P12表示最差等级状态
*   `memory.total` : 显卡总共可用内存
*   `memory.used` :显卡已消耗内存
*   `memory.free` :显卡闲置内存
*   `compute_mode` :The compute mode flag indicates whether individual or multiple compute applications may run on the GPU.
    *   `Default` : means multiple contexts are allowed per device.
    *   `Exclusive_Process` : means only one context is allowed per device, usable from multiple threads at a time.
    *   `Prohibited` : means no contexts are allowed per device (no compute apps).
*   `utilization.gpu` : 指示在上一个采样间隔中GPU的繁忙程度，占用比。采样间隔根据产品不同，有的是1s，有的是1/6s
*   `utilization.memory` : 指示在上一个采样间隔中GPU繁忙程度，读写时间占比。
*   `temperature.gpu` : GPU核心温度

#### > 快捷查询

##### - 显卡时钟查询

查看GPU支持的时钟频率，我们可以使用 `nvidia-smi --query-supported-clocks=` 命令，该命令将遍历所有Memory Clock 和 Graphic Clock可能的组合，仅这里列举的时钟组合可以传递给 `--applications-clocks` 作为 参数。`--query-support-clocks=` 接受 `timestamp` , `gpu_name` , `gpu_bus_id` , `gpu_serial` , `gpu_uuid` , `memory` 和 `graphics` 等五个字段的组合。

*   `timestamps` : 查询时间，按照标准时间格式输出，见上文
*   `gpu_name` : 设备的官方名称
*   `gpu_bus_id` : 设备PCI 总线ID，格式见上文
*   `gpu_serial` :设备序列识别号，应与机身标定设备唯一序列识别号一致
*   `gpu_uuid` :设备唯一识别ID，与机身标识无关
*   `memory` 或 `mem` : 支持的Memory Clock
*   `graphics` 或 `gr` : 支持的Graphics Clock

详细说明查看 `nvidia-smi --help-query-supported-clocks` 输出。

##### - 活跃进程查询

查看使用GPU设备的进程，我们可以使用 `nvidia-smi --query-compute-apps=` 命令。`--query-compute-apps=` 接受 `timestamp` , `gpu_name` , `gpu_bus_id` , `gpu_serial` , `gpu_uuid` , pid , `used_gpu_memory` 和 `process_name` 等字段的组合。

*   `timestamps` : 查询时间，按照标准时间格式输出，见上文
*   `gpu_name` : 设备的官方名称
*   `gpu_bus_id` : 设备PCI 总线ID，格式见上文
*   `gpu_serial` :设备序列识别号，应与机身标定设备唯一序列识别号一致
*   `gpu_uuid` :设备唯一识别ID，与机身标识无关
*   `pid` : 进程ID
*   progress_name 或 `name` : 进程名称
*   `used_gpu_memory` 或 `used_memory` : 进程占用的内存，在windows平台上当设备运行在WDDM模式下时该值不可用，因为显存由Windows KMD接管而非Nvidia驱动程序

详细说明查看 `nvidia-smi --help-query-compute-apps` 输出。

##### - 进程统计查询

查看被设备统计的进程，即在统计循环缓冲区中的进程，使用 `nvidia-smi --query-accounted-apps=` 命令。`--query-accounted-apps=` 接受`timestamp` , `gpu_name` , `gpu_bus_id` , `gpu_serial` , `gpu_uuid` , `pid` , `gpu_utilization` , `mem_utilization` , `max_memory_usage` 和 `time` 等字段的组合。

*   `timestamps` : 查询时间，按照标准时间格式输出，见上文
*   `gpu_name` : 设备的官方名称
*   `gpu_bus_id` : 设备PCI 总线ID，格式见上文
*   `gpu_serial` :设备序列识别号，应与机身标定设备唯一序列识别号一致
*   `gpu_uuid` :设备唯一识别ID，与机身标识无关
*   `pid` : 进程ID
*   `gpu_utilization` or `gpu_util` :GPU使用
*   `mem_utilization` or `mem_util` :进程显存使用占比
*   `max_memory_usage` :进程最大内存占用量
*   `time` :进程活动时常，单位ms

详细说明查看 `nvidia-smi --help-query-accounted-apps` 输出。

作者：肆不肆傻
链接：https://www.jianshu.com/p/f55b86a9cc72
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。