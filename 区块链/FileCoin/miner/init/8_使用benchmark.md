---
title: 8_使用benchmark
tags: 
---

**跑`benchmark`来得知机器封装一个块的时间**

在lotus目录编译 `make lotus-bench`. 运行help可以查看到帮助.大体上命令是这样的

`./lotus-bench sealing --storage-dir /data/bench --sector-size 32GiB --num-sectors 1 --parallel 1 --json-out `

``` json
lotus benchmark result
{
  "SectorSize": 34359738368,
  "SealingResults": [
	{
	  "AddPiece": 870097300267,
	  "PreCommit1": 19675090466708,
	  "PreCommit2": 2160057571490,
	  "Commit1": 44283547951,
	  "Commit2": 5573822383169,
	  "Verify": 28487520,
	  "Unseal": 19463753783027
	}
  ],
  "PostGenerateCandidates": 155197,
  "PostWinningProofCold": 8356540927,
  "PostWinningProofHot": 4285092397,
  "VerifyWinningPostCold": 57527449,
  "VerifyWinningPostHot": 20039908,
  "PostWindowProofCold": 1077144420908,
  "PostWindowProofHot": 973861248741,
  "VerifyWindowPostCold": 6744654407,
  "VerifyWindowPostHot": 63166446
}
```

单位 unit 应该是 tick = 1\/3600000000000 H,这里是自己测试机的结果

| 时间 | 操作 | 换算 |
| --- | --- | --- |
| 封装 | 封装 | 封装 |
| 870097300267 | add | 0.2417H = 14M 30S |
| 19675090466708 | p1 | 5.4653H = 5H 28M |
| 2160057571490 | p2 | 0.6000H = 36M |
| 44283547951 | c1 | 0.0123H = 44S |
| 5573822383169 | c2 | 1.5483H = 1H 32M 53S |
| 校验 | 校验 | 校验 |
| 28487520 | verify | 0.03S |
| 19463753783027 | unseal | 5.4065H = 5H 24M 24S |
| 出块 | 出块 | 出块 |
| 155197 | candidate | 几乎为0 |
| 4285092397 | winning proof hot | 4.28S |
| 8356540927 | winning proof cold | 8.35S |
| 20039908 | winning post hot | 0.02S |
| 57527449 | winning post cold | 0.05S |
| 时空证明 | 时空证明 | 时空证明 |
| 973861248741 | window proof hot | 0.2705H	= 16M 14S |
| 1077144420908 | window proof cold | 0.2992H = 18M |
| 63166446 | window post hot | 0.06S |
| 6744654407 | window post cold | 6.74S |

