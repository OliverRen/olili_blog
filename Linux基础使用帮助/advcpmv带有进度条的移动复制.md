---
title: advcpmv带有进度条的移动复制
---

# no root user
curl https://raw.githubusercontent.com/jarun/advcpmv/master/install.sh --create-dirs -o ./advcpmv/install.sh && (cd advcpmv && sh install.sh)

# root user
env FORCE_UNSAFE_CONFIGURE=1 sh install.sh

cp advcp /usr/local/bin/
cp advmv /usr/local/bin/

echo "alias cp='/usr/local/bin/advcp -g'" >> ~/.bashrc
echo "alias mv='/usr/local/bin/advmv -g'" >> ~/.bashrc
