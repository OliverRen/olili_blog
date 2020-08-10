---
title: 搭建api仓库rap2
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

[toc]

> rap2我部署的版本还是有挺多问题的,比如脚本经常不刷新之类的,不过只是作为一个超轻量级的文档共享仓库还是ok的

#### rap2前后端分离
后端: [https://github.com/thx/rap2-delos](https://github.com/thx/rap2-delos)
后端docker: [https://hub.docker.com/r/blackdog1987/rap2-delos/tags](https://hub.docker.com/r/blackdog1987/rap2-delos/tags)
前端: [https://github.com/thx/rap2-dolores](https://github.com/thx/rap2-dolores)

> 我使用了rap2.docker的集成，包含了delos的官方的docker，再在本地编译dolores

#### 本地编译 dolores
修改配置后端地址 /src/config/config.prod.js,改成后端ip port
`npm install`
`npm run build`
把build拷贝到 rap2-docker中，是从本地获取而不是image

#### 容器运行 delos
rap2-docker集成地址 https://github.com/Rynxiao/rap2-docker
修改delos的最新image tag
**其中有一个 `node scripts/init` 需要注释掉，不然每次都会drop table重建**
```
docker-compose up -d
docker exec -it rap2-delos sh
node scripts/init
exit
```

#### 配置nginx
最后nignx配置好，不然就算登录了刷新一下就404
```
server {
    listen       80;
    server_name  localhost;

    root /usr/share/nginx/html/rap2-dolores;

    # web
    location / {
        add_header Cache-Control "no-store";
		try_files $uri $uri/index.html /index.html;
    }

    location ~ \.(?!html) {
		add_header Cache-Control "public, max-age=2678400";
		try_files $uri =404;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }
}
```