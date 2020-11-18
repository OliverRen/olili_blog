---
title: 安装rust开发环境
tags: 
---

#### 安装rust

因为国内防火墙的原因，导致rust不能正常安装，如此有2个选择：

1. 搭墙，因为翻墙有风险而且速度也不佳，此处不推荐并省略。
2. 使用国内中国科技大学的代理
3. 使用了snap安装rustup,通过rustup安装

无论使用方法2还是方法3首先配置国内的镜像源

- Rust Toolchain 反向代理：https://mirrors.ustc.edu.cn/help/rust-static.html
- Rust Crates 源使用帮助：https://mirrors.ustc.edu.cn/help/crates.io-index.html
- Rust 官网：https://www.rust-lang.org/learn/get-started

```
# 写入环境变量设置代理
echo "export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static" >> /etc/profile
echo "export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup" >> /etc/profile
source /etc/profile
```

推荐使用方法2

```
# 使用官方推荐的脚本进行安装
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 安装完毕后刷新环境变量
source ~/.cargo/env
```

使用方法3

```
snap install rustup
rustup install stable
# 使用rustup可以方便的切换 stable,nightly,julia
rustup default stable

source ~/.cargo/env
```

#### 配置cargo

安装rust后,可以使用 `rustc -V` 和 `cargo -V`来查看是否输出正确,然后就可以配置cargo了

```
# 设置cargo代理
 cat >~/.cargo/config <<EOF
 [source.crates-io]
 replace-with = 'ustc'
 
 [source.ustc]
 registry = "git://mirrors.ustc.edu.cn/crates.io-index"
 EOF
 
 # 最后文件应该是这样的 
 [source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

# 指定镜像 下面任选其一,replace-with和选择的匹配即可
replace-with = 'sjtu'

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
# 中国科学技术大学
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"
# rustcc社区
[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
```

#### 使用 nightly 版本的rust

```
# 网上都说stable稳定版本不佳,推荐使用每日更新的nightly版本
rustup install nightly
rustup default nightly

# 安装RLS组建
 rustup component add rls --toolchain nightly
 rustup component add rust-analysis --toolchain nightly
rustup component add rust-src --toolchain nightly
 
# 安装racer 建议
cargo install racer
```

**window的tips**

windows的安装大致类似，最重要的一点是必须安装Microsoft Visual C++ Build Tools 2015 或以上的版本，安装占用至少5GB以上，所以还是linux好一点。

**IDE**

安装好vscode后，Ctrl + Shift + X 打开应用商店,搜索chinese安装中文语言包，搜索Rust (rls)官方的插件.