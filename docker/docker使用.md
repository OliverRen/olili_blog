---
title: docker使用
---

[toc]

#### 安装

1. 使用官方安装脚本自动安装

安装命令如下：

`curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun`

也可以使用国内 daocloud 一键安装命令：

`curl -sSL https://get.daocloud.io/docker | sh`

2. 手动卸载

`apt remove docker docker-engine docker.io containerd runc`

3. 启动

```
systemctl start docker #启动
systemctl enable docker #配置开机自启
```

4. 配置镜像加速源和dns

对于 systemd管理服务的系统，通过daemon方式载入环境配置
```
/etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://reg-mirror.qiniu.com/",
		......
    ], 
    "dns": [
        "114.114.114.114", 
        "8.8.8.8"
    ]
}

sudo systemctl daemon-reload #重载配置
sudo systemctl restart docker #重启docker

docker info # check info
```

科大镜像：https://docker.mirrors.ustc.edu.cn/
网易：https://hub-mirror.c.163.com/
阿里云：https://<你的ID>.mirror.aliyuncs.com（打开此地址登录你的阿里云账号获取你的专属镜像源 https://cr.console.aliyun.com/#/accelerator）
七牛云加速器：https://reg-mirror.qiniu.com

5. docker运行文件

服务端执行文件 也是docker.service的启动文件

`/usr/bin/dockerd`

客户端执行文件 客户端控制服务端的命令执行文件

`/usr/bin/docker`

运行文件的root docker runtime

`cd /var/lib/docker/`

执行文件的root docker state files

`cd /var/run/docker/`

运行的pid文件

`cat /var/run/docker.pid`

#### 常用命令

```
docker search xxxx	# 搜索镜像
docker pull xxxx	# 下载镜像
docker images 		# 列出所有安装过的镜像
docker rmi hello-world # 删除镜像
docker tag 2b1b7a428627	runoob/centos:dev # 给镜像添加tag

docker run learn/tutorial apt-get install -y net-tools
docker ps -l
docker commit 0d1d learn/net-tools
docker run learn/net-tools ifconfig
# 修改镜像并保存，每一个命令行都会使镜像的layer增加一层，最多层数是有限制的，使用commit来提交，每次commit都是一个新的镜像
# -m:提交的描述，-a:指定作者
-----------------------
docker ps -a		# 查看容器
docker ps -l		# 最后运行的容器

docker run -i -t ubuntu:15.10 /bin/bash		# 运行交互式容器
docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world; sleep 1; done" 		# 后台启动容器
docker stop 2b1b7a428627	# 停止容器
docker restart 2b1b7a428627	# 重启容器
docker rm -f 2b1b7a428627	# 删除容器
docker exec -i -t 243c32535da7 /bin/bash # 进入容器

docker export 2b1b7a428627 > ubuntu.tar 				# 导出容器
cat docker/ubuntu.tar | docker import - test/ubuntu:v1	# 导入容器

docker port 2b1b7a428627	# 查看 -P 或 -p 等指定的端口映射情况
docker logs 2b1b7a428627	# 查看容器内标准输出
-----------------------
docker network create -d bridge test-net # 创建容器互联网络
docker run -itd --name test1 --network test-net ubuntu /bin/bash # 创建容器并加入互联网络
```

#### Dockerfile构建镜像

```
cat Dockerfile 
FROM    centos:6.7
MAINTAINER      Fisher "fisher@sudops.com"

RUN     /bin/echo 'root:123456' |chpasswd
RUN     useradd runoob
RUN     /bin/echo 'runoob:123456' |chpasswd
RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" >/etc/default/local
EXPOSE  22
EXPOSE  80
CMD     /usr/sbin/sshd -D

docker build -t runoob/centos:6.7
```

每一个指令都会在镜像上创建一个新的层，每一个指令的前缀都必须是大写的。

第一条FROM，指定使用哪个镜像源

RUN 指令告诉docker 在镜像内执行命令，安装了什么。。。

然后，我们使用 Dockerfile 文件，通过 docker build 命令来构建一个镜像。

#### docker-compose

1. Compose 使用的三个步骤：

使用 Dockerfile 定义应用程序的环境。

使用 docker-compose.yml 定义构成应用程序的服务，这样它们可以在隔离环境中一起运行。

最后，执行 docker-compose up 命令来启动并运行整个应用程序。

2. 依赖项，py-pip，python-dev，libffi-dev，openssl-dev，gcc，libc-dev，和 make

安装下载地址 https://github.com/docker/compose/releases , 直接下载二进制包

```
curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

3. 配置参考

###### version

指定本 yml 依从的 compose 哪个版本制定的。

###### build

指定为构建镜像上下文路径：

例如 webapp 服务，指定为从上下文路径 ./dir/Dockerfile 所构建的镜像：

<pre class="prettyprint prettyprinted">version: "3.7"
services:
  webapp:
    build: ./dir</pre>

或者，作为具有在上下文指定的路径的对象，以及可选的 Dockerfile 和 args：

<pre class="prettyprint prettyprinted">version: "3.7"
services:
  webapp:
    build:
      context: ./dir
      dockerfile: Dockerfile-alternate
      args:
        buildno: 1
      labels:
        - "com.example.description=Accounting webapp"
        - "com.example.department=Finance"
        - "com.example.label-with-empty-value"
      target: prod</pre>

*   context：上下文路径。
*   dockerfile：指定构建镜像的 Dockerfile 文件名。
*   args：添加构建参数，这是只能在构建过程中访问的环境变量。
*   labels：设置构建镜像的标签。
*   target：多层构建，可以指定构建哪一层。

###### cap_add，cap_drop

添加或删除容器拥有的宿主机的内核功能。

<pre class="prettyprint prettyprinted">cap_add:
  - ALL # 开启全部权限

cap_drop:
  - SYS_PTRACE # 关闭 ptrace权限</pre>

###### cgroup_parent

为容器指定父 cgroup 组，意味着将继承该组的资源限制。

<pre class="prettyprint prettyprinted">cgroup_parent: m-executor-abcd</pre>

###### command

覆盖容器启动的默认命令。

<pre class="prettyprint prettyprinted">command: ["bundle", "exec", "thin", "-p", "3000"]</pre>

###### container_name

指定自定义容器名称，而不是生成的默认名称。

<pre class="prettyprint prettyprinted">container_name: my-web-container</pre>

###### depends_on

设置依赖关系。

*   docker-compose up ：以依赖性顺序启动服务。在以下示例中，先启动 db 和 redis ，才会启动 web。
*   docker-compose up SERVICE ：自动包含 SERVICE 的依赖项。在以下示例中，docker-compose up web 还将创建并启动 db 和 redis。
*   docker-compose stop ：按依赖关系顺序停止服务。在以下示例中，web 在 db 和 redis 之前停止。

<pre class="prettyprint prettyprinted">version: "3.7"
services:
  web:
    build: .
    depends_on:
      - db
      - redis
  redis:
    image: redis
  db:
    image: postgres</pre>

注意：web 服务不会等待 redis db 完全启动 之后才启动。

###### deploy

指定与服务的部署和运行有关的配置。只在 swarm 模式下才会有用。

<pre class="prettyprint prettyprinted">version: "3.7"
services:
  redis:
    image: redis:alpine
    deploy:
      mode：replicated
      replicas: 6
      endpoint_mode: dnsrr
      labels: 
        description: "This redis service label"
      resources:
        limits:
          cpus: '0.50'
          memory: 50M
        reservations:
          cpus: '0.25'
          memory: 20M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s</pre>

可以选参数：

**endpoint_mode**：访问集群服务的方式。

<pre class="prettyprint prettyprinted">endpoint_mode: vip 
# Docker 集群服务一个对外的虚拟 ip。所有的请求都会通过这个虚拟 ip 到达集群服务内部的机器。
endpoint_mode: dnsrr
# DNS 轮询（DNSRR）。所有的请求会自动轮询获取到集群 ip 列表中的一个 ip 地址。</pre>

**labels**：在服务上设置标签。可以用容器上的 labels（跟 deploy 同级的配置） 覆盖 deploy 下的 labels。

**mode**：指定服务提供的模式。

*   **replicated**：复制服务，复制指定服务到集群的机器上。

*   **global**：全局服务，服务将部署至集群的每个节点。

*   图解：下图中黄色的方块是 replicated 模式的运行情况，灰色方块是 global 模式的运行情况。

    ![](https://raw.githubusercontent.com/OliverRen/olili_blog_img/master/docker使用/1644906624835.png)

**replicas：mode** 为 replicated 时，需要使用此参数配置具体运行的节点数量。

**resources**：配置服务器资源使用的限制，例如上例子，配置 redis 集群运行需要的 cpu 的百分比 和 内存的占用。避免占用资源过高出现异常。

**restart_policy**：配置如何在退出容器时重新启动容器。

*   condition：可选 none，on-failure 或者 any（默认值：any）。
*   delay：设置多久之后重启（默认值：0）。
*   max_attempts：尝试重新启动容器的次数，超出次数，则不再尝试（默认值：一直重试）。
*   window：设置容器重启超时时间（默认值：0）。

**rollback_config**：配置在更新失败的情况下应如何回滚服务。

*   parallelism：一次要回滚的容器数。如果设置为0，则所有容器将同时回滚。
*   delay：每个容器组回滚之间等待的时间（默认为0s）。
*   failure_action：如果回滚失败，该怎么办。其中一个 continue 或者 pause（默认pause）。
*   monitor：每个容器更新后，持续观察是否失败了的时间 (ns|us|ms|s|m|h)（默认为0s）。
*   max_failure_ratio：在回滚期间可以容忍的故障率（默认为0）。
*   order：回滚期间的操作顺序。其中一个 stop-first（串行回滚），或者 start-first（并行回滚）（默认 stop-first ）。

**update_config**：配置应如何更新服务，对于配置滚动更新很有用。

*   parallelism：一次更新的容器数。
*   delay：在更新一组容器之间等待的时间。
*   failure_action：如果更新失败，该怎么办。其中一个 continue，rollback 或者pause （默认：pause）。
*   monitor：每个容器更新后，持续观察是否失败了的时间 (ns|us|ms|s|m|h)（默认为0s）。
*   max_failure_ratio：在更新过程中可以容忍的故障率。
*   order：回滚期间的操作顺序。其中一个 stop-first（串行回滚），或者 start-first（并行回滚）（默认stop-first）。

**注**：仅支持 V3.4 及更高版本。

###### devices

指定设备映射列表。

<pre class="prettyprint prettyprinted">devices:
  - "/dev/ttyUSB0:/dev/ttyUSB0"</pre>

###### dns

自定义 DNS 服务器，可以是单个值或列表的多个值。

<pre class="prettyprint prettyprinted">dns: 8.8.8.8

dns:
  - 8.8.8.8
  - 9.9.9.9</pre>

###### dns_search

自定义 DNS 搜索域。可以是单个值或列表。

<pre class="prettyprint prettyprinted">dns_search: example.com

dns_search:
  - dc1.example.com
  - dc2.example.com</pre>

###### entrypoint

覆盖容器默认的 entrypoint。

<pre class="prettyprint prettyprinted">entrypoint: /code/entrypoint.sh</pre>

也可以是以下格式：

<pre class="prettyprint prettyprinted">entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit</pre>

###### env_file

从文件添加环境变量。可以是单个值或列表的多个值。

<pre class="prettyprint prettyprinted">env_file: .env</pre>

也可以是列表格式：

<pre class="prettyprint prettyprinted">env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env</pre>

###### environment

添加环境变量。您可以使用数组或字典、任何布尔值，布尔值需要用引号引起来，以确保 YML 解析器不会将其转换为 True 或 False。

<pre class="prettyprint prettyprinted">environment:
  RACK_ENV: development
  SHOW: 'true'</pre>

###### expose

暴露端口，但不映射到宿主机，只被连接的服务访问。

仅可以指定内部端口为参数：

<pre class="prettyprint prettyprinted">expose:
 - "3000"
 - "8000"</pre>

###### extra_hosts

添加主机名映射。类似 docker client --add-host。

<pre class="prettyprint prettyprinted">extra_hosts:
 - "somehost:162.242.195.82"
 - "otherhost:50.31.209.229"</pre>

以上会在此服务的内部容器中 /etc/hosts 创建一个具有 ip 地址和主机名的映射关系：

<pre class="prettyprint prettyprinted">162.242.195.82  somehost
50.31.209.229   otherhost</pre>

###### healthcheck

用于检测 docker 服务是否健康运行。

<pre class="prettyprint prettyprinted">healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"] # 设置检测程序
  interval: 1m30s # 设置检测间隔
  timeout: 10s # 设置检测超时时间
  retries: 3 # 设置重试次数
  start_period: 40s # 启动后，多少秒开始启动检测程序</pre>

###### image

指定容器运行的镜像。以下格式都可以：

<pre class="prettyprint prettyprinted">image: redis
image: ubuntu:14.04
image: tutum/influxdb
image: example-registry.com:4000/postgresql
image: a4bc65fd # 镜像id</pre>

###### logging

服务的日志记录配置。

driver：指定服务容器的日志记录驱动程序，默认值为json-file。有以下三个选项

<pre class="prettyprint prettyprinted">driver: "json-file"
driver: "syslog"
driver: "none"</pre>

仅在 json-file 驱动程序下，可以使用以下参数，限制日志得数量和大小。

<pre class="prettyprint prettyprinted">logging:
  driver: json-file
  options:
    max-size: "200k" # 单个文件大小为200k
    max-file: "10" # 最多10个文件</pre>

当达到文件限制上限，会自动删除旧得文件。

syslog 驱动程序下，可以使用 syslog-address 指定日志接收地址。

<pre class="prettyprint prettyprinted">logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"</pre>

###### network_mode

设置网络模式。

<pre class="prettyprint prettyprinted">network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"</pre>

networks

配置容器连接的网络，引用顶级 networks 下的条目 。

<pre class="prettyprint prettyprinted">services:
  some-service:
    networks:
      some-network:
        aliases:
         - alias1
      other-network:
        aliases:
         - alias2
networks:
  some-network:
    # Use a custom driver
    driver: custom-driver-1
  other-network:
    # Use a custom driver which takes special options
    driver: custom-driver-2</pre>

**aliases** ：同一网络上的其他容器可以使用服务名称或此别名来连接到对应容器的服务。

###### restart

*   no：是默认的重启策略，在任何情况下都不会重启容器。
*   always：容器总是重新启动。
*   on-failure：在容器非正常退出时（退出状态非0），才会重启容器。
*   unless-stopped：在容器退出时总是重启容器，但是不考虑在Docker守护进程启动时就已经停止了的容器

<pre class="prettyprint prettyprinted">restart: "no"
restart: always
restart: on-failure
restart: unless-stopped</pre>

注：swarm 集群模式，请改用 restart_policy。

###### secrets

存储敏感数据，例如密码：

<pre class="prettyprint prettyprinted">version: "3.1"
services:

mysql:
  image: mysql
  environment:
    MYSQL_ROOT_PASSWORD_FILE: /run/secrets/my_secret
  secrets:
    - my_secret

secrets:
  my_secret:
    file: ./my_secret.txt</pre>

###### security_opt

修改容器默认的 schema 标签。

<pre class="prettyprint prettyprinted">security-opt：
  - label:user:USER   # 设置容器的用户标签
  - label:role:ROLE   # 设置容器的角色标签
  - label:type:TYPE   # 设置容器的安全策略标签
  - label:level:LEVEL  # 设置容器的安全等级标签</pre>

###### stop_grace_period

指定在容器无法处理 SIGTERM (或者任何 stop_signal 的信号)，等待多久后发送 SIGKILL 信号关闭容器。

<pre class="prettyprint prettyprinted">stop_grace_period: 1s # 等待 1 秒
stop_grace_period: 1m30s # 等待 1 分 30 秒 </pre>

默认的等待时间是 10 秒。

###### stop_signal

设置停止容器的替代信号。默认情况下使用 SIGTERM 。

以下示例，使用 SIGUSR1 替代信号 SIGTERM 来停止容器。

<pre class="prettyprint prettyprinted">stop_signal: SIGUSR1</pre>

###### sysctls

设置容器中的内核参数，可以使用数组或字典格式。

<pre class="prettyprint prettyprinted">sysctls:
  net.core.somaxconn: 1024
  net.ipv4.tcp_syncookies: 0

sysctls:
  - net.core.somaxconn=1024
  - net.ipv4.tcp_syncookies=0</pre>

###### tmpfs

在容器内安装一个临时文件系统。可以是单个值或列表的多个值。

<pre class="prettyprint prettyprinted">tmpfs: /run

tmpfs:
  - /run
  - /tmp</pre>

###### ulimits

覆盖容器默认的 ulimit。

<pre class="prettyprint prettyprinted">ulimits:
  nproc: 65535
  nofile:
    soft: 20000
    hard: 40000</pre>

###### volumes

将主机的数据卷或着文件挂载到容器里。

<pre class="prettyprint prettyprinted">version: "3.7"
services:
  db:
    image: postgres:latest
    volumes:
      - "/localhost/postgres.sock:/var/run/postgres/postgres.sock"
      - "/localhost/data:/var/lib/postgresql/data"</pre>