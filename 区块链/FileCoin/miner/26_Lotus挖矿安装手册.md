---
title: Lotus挖矿安装手册
---

[toc]

* [准备工作](#%E5%87%86%E5%A4%87%E5%B7%A5%E4%BD%9C)
* [编译安装lotus挖矿软件](#%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85lotus%E6%8C%96%E7%9F%BF%E8%BD%AF%E4%BB%B6)
* [Lotus的配置文件和环境变量](#lotus%E7%9A%84%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%92%8C%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F)
* [Lotus\-miner 官方工具挖矿](#lotus-miner-%E5%AE%98%E6%96%B9%E5%B7%A5%E5%85%B7%E6%8C%96%E7%9F%BF)
* [Lotus\-miner 官方工具挖矿进阶设置](#lotus-miner-%E5%AE%98%E6%96%B9%E5%B7%A5%E5%85%B7%E6%8C%96%E7%9F%BF%E8%BF%9B%E9%98%B6%E8%AE%BE%E7%BD%AE)
  * [防火墙有可能要开启](#%E9%98%B2%E7%81%AB%E5%A2%99%E6%9C%89%E5%8F%AF%E8%83%BD%E8%A6%81%E5%BC%80%E5%90%AF)
  * [矿工自定义存储布局](#%E7%9F%BF%E5%B7%A5%E8%87%AA%E5%AE%9A%E4%B9%89%E5%AD%98%E5%82%A8%E5%B8%83%E5%B1%80)
  * [跑 benchmark 来得知机器封装一个块的时间](#%E8%B7%91-benchmark-%E6%9D%A5%E5%BE%97%E7%9F%A5%E6%9C%BA%E5%99%A8%E5%B0%81%E8%A3%85%E4%B8%80%E4%B8%AA%E5%9D%97%E7%9A%84%E6%97%B6%E9%97%B4)
  * [矿工钱包,分开 owner 地址和 worker 地址,为 windowPoSt设置单独的 control 地址\.](#%E7%9F%BF%E5%B7%A5%E9%92%B1%E5%8C%85%E5%88%86%E5%BC%80-owner-%E5%9C%B0%E5%9D%80%E5%92%8C-worker-%E5%9C%B0%E5%9D%80%E4%B8%BA-windowpost%E8%AE%BE%E7%BD%AE%E5%8D%95%E7%8B%AC%E7%9A%84-control-%E5%9C%B0%E5%9D%80)
  * [Lotus Miner 配置参考](#lotus-miner-%E9%85%8D%E7%BD%AE%E5%8F%82%E8%80%83)
  * [Lotus套件升级](#lotus%E5%A5%97%E4%BB%B6%E5%8D%87%E7%BA%A7)
  * [安全的升级和重启miner](#%E5%AE%89%E5%85%A8%E7%9A%84%E5%8D%87%E7%BA%A7%E5%92%8C%E9%87%8D%E5%90%AFminer)
  * [重启 worker](#%E9%87%8D%E5%90%AF-worker)
  * [更改存储的位置](#%E6%9B%B4%E6%94%B9%E5%AD%98%E5%82%A8%E7%9A%84%E4%BD%8D%E7%BD%AE)
  * [更改worker的存储位置](#%E6%9B%B4%E6%94%B9worker%E7%9A%84%E5%AD%98%E5%82%A8%E4%BD%8D%E7%BD%AE)
* [Lotus mine 抵押扇区 及开始封装算力](#lotus-mine-%E6%8A%B5%E6%8A%BC%E6%89%87%E5%8C%BA-%E5%8F%8A%E5%BC%80%E5%A7%8B%E5%B0%81%E8%A3%85%E7%AE%97%E5%8A%9B)
* [Lotus miner seal worker](#lotus-miner-seal-worker)
* [同时运行 miner 和 worker的CPU分配](#%E5%90%8C%E6%97%B6%E8%BF%90%E8%A1%8C-miner-%E5%92%8C-worker%E7%9A%84cpu%E5%88%86%E9%85%8D)
* [Lotus miner 故障排除](#lotus-miner-%E6%95%85%E9%9A%9C%E6%8E%92%E9%99%A4)
* [Lotus miner 管理交易](#lotus-miner-%E7%AE%A1%E7%90%86%E4%BA%A4%E6%98%93)










--------------------

