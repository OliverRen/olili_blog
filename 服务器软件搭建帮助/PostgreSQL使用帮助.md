---
title: PostgreSQL使用帮助
---

[toc]

#### PostgreSQL的安装

源码安装总体流程：默认都不开启 SELinux
使用yum等软件包管理器安装会省点下载的力气
强烈推荐使用docker容器安装,维护更方便

```shell
# 编译
# --prefix=PREFIX：指定安装PostgreSQL的安装目前，如果没有指定，则安装到/usr/local/pgsql目录下。
# --with-pgport=NUMBER:指定PostgreSQL的监听端口，默认为5432
# --with-wal-segsize=SEGSIZE： 指定WAL日志文件的大小。
# --with-wal-blocksize=BLOCKSIZE:指定WAL日志的块大小。
# --enable-thread-safety：允许客户端的库函数是线程安全的。
./configure

# 安装
gmake && make isntall

# 卸载
make uninstall

# 设置环境变量 vim /etc/profile
LD_LIBRARY_PATH=/usr/local/pgsql/lib
export LD_LIBRARY_PATH
PATH=/usr/local/pgsql/bin:$PATH
export PATH
MANPATH=/usr/local/pgsql/man:$MANPATH
export MANPATH

# 安装contrib目录下的工具
cd contrib
make && make install

# postgres用户 用户组
useradd -m -u 701 postgres

# 创建数据库目录 配置用户权限
mkdir /usr/local/pgsql/data
chown postgres:postgres /usr/local/pgsql/data

# 快速启动关闭pg的alias快捷方式
# 可以在postgres用户的.bash_profile文件中配置 启动数据库一定要用postgres用户
su - postgres
export PGDATA=/usr/local/pgsql/data
alias pgstart='pg_ctl -D $PGDATA start'
alias pgstop='pg_ctl kill INT `head -1 $PGDATA/postmaster.pid`'

# 初始化数据库目录
su - postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data

# 修改数据库配置文件
vim $PGDATA/postgresql.conf
vim $PGDATA/pg_hba.conf
# 一些配置参数可以通过命令行的方式传给守护进程,这个行为有可能覆盖conf文件中的设置.
# postgresql.conf接受网络连接
	``` postgres.conf
	listen_address='*' 
	```
# pg_hba配置数据库访问
	``` pg_hba.conf
	TYPE	DATABASE	USER	ADDRESS		METHOD
	host	all			all		10.0.0.1/32	md5
	```
	第一个字段代表连接类型,可以设置为:
	1.local — Unix-domain socket  
	2.host — plain or SSL-encrypted TCP/IP socket  
	3.hostssl — is an SSL-encrypted TCP/IP socket  
	4.hostnossl — plain TCP/IP socket
	
	最后一列指定了使用的认证方法
	1.md5 -- 客户端需要提供密码来进行md5算法处理  
	2.ident -- 根据操作系统获取连接的客户端的用户名，并且使用指定匹配查询用户名  
	3.trust -- 任何连接到PostgreSQL的人都可以作为任何用户并且不需要提供密码  
	4.peer -- 从操作系统中获取用户名，并确认用户名是否匹配数据库用户名  

# 优化配置
	``` postgres.conf
	# 连接数
	max_connections=<number>
	# postgresql可用缓存,设置为总内存的15-40%,一般25%
	shared_buffers=<memory unit>
	# 查询计划可用内存,与max_connections相关
	work_mem=<memory unit>
	# 配置日志收集
	logging_collector=on
	# 日志输出格式
	log_destination='syslog,stderr'
	# 日志输入文件名
	log_filename='postgresql-%a.log' or 'postgresql-%G-%m.log'
	# 日志循环
	log_truncate_on_rotation=off
	log_rotation_age=31d
	# 日志等级 
	client_min_messages=notice
	log_min_messages=info
	log_min_error_statement=noteice
	# 慢查询
	log_min_duration_statement=1000 # 毫秒
	# 日志前缀
	log_line_prefix = '%t %u@%r:%d [%p] '	
	```

```

------------

#### PostgreSQL的索引

##### 索引的类型

PostgreSQL提供了多种索引类型：B-Tree、Hash、GiST和GIN，由于它们使用了不同的算法，因此每种索引类型都有其适合的查询类型，缺省时，CREATE INDEX命令将创建B-Tree索引。

###### B-Tree

* B-Tree索引主要用于等于和范围查询，特别是当索引列包含操作符" <、<=、=、>=和>"作为查询条件时，PostgreSQL的查询规划器都会考虑使用B-Tree索引。
* 在使用 BETWEEN、IN、IS NULL和IS NOT NULL的查询中，PostgreSQL也可以使用B-Tree索引。
* 然而对于基于模式匹配操作符的查询，如LIKE、ILIKE、~和 ~\*，仅当模式存在一个常量，且该常量位于模式字符串的开头时，如col LIKE 'foo%'或col ~ '^foo'，索引才会生效，否则将会执行全表扫描，如：col LIKE '%bar'。 


###### Hash
* 散列(Hash)索引只能处理简单的等于比较。当索引列使用等于操作符进行比较时，查询规划器会考虑使用散列索引。
* 这里需要额外说明的是，PostgreSQL散列索引的性能不比B-Tree索引强，但是散列索引的尺寸和构造时间则更差。另外，由于散列索引操作目前没有记录WAL日志，因此一旦发生了数据库崩溃，我们将不得不用REINDEX重建散列索引。
* 即用hash索引不如直接用 btree 索引.

###### GiST
* GiST索引不是一种单独的索引类型，而是一种架构，可以在该架构上实现很多不同的索引策略。从而可以使GiST索引根据不同的索引策略，而使用特定的操作符类型。 

###### GIN
* GIN索引是反转索引，它可以处理包含多个键的值(比如数组)。

##### 复合索引

- PostgreSQL中的索引可以定义在数据表的多个字段上
- 在当前的版本中，只有B-tree、GiST和GIN支持复合索引，其中最多可以声明32个字段。

###### B-Tree类型的复合索引

在B-Tree类型的复合索引中，该索引字段的==任意子集均可用于查询条件 #F44336==，不过，只有当复合索引中的第一个索引字段(最左边)被包含其中时，才可以获得最高效率。
	
###### GiST类型的复合索引
在GiST类型的复合索引中，只有当第一个索引字段被包含在查询条件中时，才能决定该查询会扫描多少索引数据，而其他索引字段上的条件只是会限制索引返回的条目。假如第一个索引字段上的大多数数据都有相同的键值，那么此时应用GiST索引就会比较低效。 
	
###### GIN类型的复合索引
与B-Tree和GiST索引不同的是，GIN复合索引不会受到查询条件中使用了哪些索引字段子集的影响，无论是哪种组合，都会得到相同的效率。
	
##### 组合多个索引进行查询

> 我PostgreSQL可以在查询时组合多个索引(包括同一索引的多次使用)，来处理单个索引扫描不能实现的场合。与此同时，系统还可以在多个索引扫描之 间组成AND和OR的条件。比如，一个类似WHERE x = 42 OR x = 47 OR x = 53 OR x = 99的查询，可以被分解成四个独立的基于x字段索引的扫描，每个扫描使用一个查询子句，之后再将这些扫描结果OR在一起并生成最终的结果。另外一个例子 是，如果我们在x和y上分别存在独立的索引，那么一个类似WHERE x = 5 AND y = 6的查询，就会分别基于这两个字段的索引进行扫描，之后再将各自扫描的结果进行AND操作并生成最终的结果行。

> 为了组合多个索引，系统扫描每个需要的索引，然后在内存里组织一个BITMAP，它将给出索引扫描出的数据在数据表中的物理位置。然后，再根据查询的需 要，把这些位图进行AND或者OR的操作并得出最终的BITMAP。最后，检索数据表并返回数据行。表的数据行是按照物理顺序进行访问的，因为这是位图的 布局，这就意味着任何原来的索引的排序都将消失。如果查询中有ORDER BY子句，那么还将会有一个额外的排序步骤。因为这个原因，以及每个额外的索引扫描都会增加额外的时间，这样规划器有时候就会选择使用简单的索引扫描，即 使有多个索引可用也会如此.

##### 唯一索引

目前只有B-Tree索引可以被声明为唯一索引.NULL值相互间是不相等的.

##### 表达式索引

表达式索引主要用于在查询条件中存在基于某个字段的函数或表达式的结果与其他值进行比较的情况，如：

 ==SELECT * FROM test1 WHERE lower(col1) = 'value'; #2196F3==
	
此时，如果我们仅仅是在col1字段上建立索引，那么该查询在执行时一定不会使用该索引，而是直接进行全表扫描。如果该表的数据量较大，那么执行该查询也将会需要很长时间。解决该问题的办法非常简单，在test1表上建立基于col1字段的表达式索引，如：
	
 ==CREATE INDEX test1_lower_col1_idx ON test1 (lower(col1)); #2196F3==
	
如果我们把该索引声明为UNIQUE，那么它会禁止创建那种col1数值只是大小写有区别的数据行，以及col1数值完全相同的数据行。因此，在表达式上的索引可以用于强制那些无法定义为简单唯一约束的约束。现在让我们再看一个应用表达式索引的例子。
	
==SELECT * FROM people WHERE (first_name || ' ' || last_name) = 'John Smith'; #2196F3==
	
和上面的例子一样，尽管我们可能会为first_name和last_name分别创建独立索引，或者是基于这两个字段的复合索引，在执行该查询语句时，这些索引均不会被使用，该查询能够使用的索引只有我们下面创建的表达式索引。
	
==CREATE INDEX people_names ON people ((first_name || ' ' || last_name)); #2196F3==
	
CREATE INDEX命令的语法通常要求在索引表达式周围书写圆括弧，就像我们在第二个例子里显示的那样。如果表达式只是一个函数调用，那么可以省略，就像我们在第一个例子里显示的那样。
	
从索引维护的角度来看，索引表达式要相对低效一些，因为在插入数据或者更新数据的时候，都必须为该行计算表达式的结果，并将该结果直接存储到索引里。然 而在查询时，PostgreSQL就会把它们看做WHERE idxcol = 'constant'，因此搜索的速度等效于基于简单索引的查询。通常而言，我们只是应该在检索速度比插入和更新速度更重要的场景下使用表达式索引。 

##### 部分索引

部分索引==(partial index) #2196F3==是建立在一个表的子集上的索引，而该子集是由一个条件表达式定义的(叫做部分索引的谓词)。该索引只包含表中那些满足这个谓词的行。

由于不是在所有的情况下都需要更新索引，因此部分索引会提高数据插入和数据更新的效率。然而又因为部分索引比普通索引要小，因此可以更好的提高确实需要索引部分的查询效率。

##### 检查索引的使用

1. 总是先运行ANALYZE。
    该命令将会收集表中数值分布状况的统计。在估算一个查询返回的行数时需要这个信息，而规划器则需要这个行数以便给每个可能的查询规划赋予真实的开销值。 如果缺乏任何真实的统计信息，那么就会使用一些缺省数值，这样肯定是不准确的。因此，如果还没有运行ANALYZE就检查一个索引的使用状况，那将会是一 次失败的检查。 
	
2. 使用真实的数据做实验。
    用测试数据填充数据表，那么该表的索引将只会基于测试数据来评估该如何使用索引，而不是对所有的数据都如此使用。比如从100000行中选1000行， 规划器可能会考虑使用索引，那么如果从100行中选1行就很难说也会使用索引了。因为100行的数据很可能是存储在一个磁盘页面中，然而没有任何查询规划 能比通过顺序访问一个磁盘页面更加高效了。与此同时，在模拟测试数据时也要注意，如果这些数据是非常相似的数据、完全随机的数据，或按照排序顺序插入的数 据，都会令统计信息偏离实际数据应该具有的特征。    
	
3. 如果索引没有得到使用，那么在测试中强制它的使用也许会有些价值。有一些运行时参数可以关闭各种各样的查询规划。

4. 强制使用索引用法将会导致两种可能：一是系统选择是正确的，使用索引实际上并不合适，二是查询计划的开销计算并不能反映现实情况。这样你就应该对使用和不使用索引的查询进行计时，这个时候EXPLAIN ANALYZE命令就很有用了。

----------

#### PostgreSQL的维护

##### 获取所有数据表及字段
```sql
SELECT
	C .relname,
	col_description (A .attrelid, A .attnum) AS COMMENT,
	format_type (A .atttypid, A .atttypmod) AS TYPE,
	A .attname AS NAME,
	A .attnotnull AS NOTNULL
FROM
	pg_class AS C,
	pg_attribute AS A
WHERE
	A .attrelid = C .oid
AND C .relname NOT LIKE 'pg%'
AND format_type (A .atttypid, A .atttypmod) LIKE '%[]';
```
##### 数据维护命令
- reindexdb
为一个指定的PostgreSQL数据库重建索引
 
- vacuumdb
收集垃圾并且分析一个PostgreSQL数据库

- pg_dump
pg_dump是一个用于备份PostgreSQL数据库的工具。它甚至可以在数据库正在并发使用时进行完整一致的备份，而不会阻塞其它用户对数据库的访问。该工具生成的转储格式可以分为两种，脚本和归档文件。其中脚本格式是包含许多SQL命令的纯文本格式，这些SQL命令可以用于重建该数据库并将之恢复到生成此脚本时的状态，该操作需要使用psql来完成。至于归档格式，如果需要重建数据库就必须和pg_restore工具一起使用。在重建过程中，可以对恢复的对象进行选择，甚至可以在恢复之前对需要恢复的条目进行重新排序。

- pg_restore
pg_restore用于恢复pg_dump导出的任何非纯文本格式的文件，它将数据库重建成保存它时的状态。对于归档格式的文件，pg_restore可以进行有选择的恢复，甚至也可以在恢复前重新排列数据的顺序。 
    pg_restore可以在两种模式下操作。如果指定数据库，归档将直接恢复到该数据库。否则，必须先手工创建数据库，之后再通过pg_restore恢复数据到该新建的数据库中。

##### 查看数据库占用的物理存储空间大小
- 手动查看
```sql
SELECT oid from pg_database where datname='postgres';
# 然后查看 $PGDATA目录下 data/base 相同id的大小即为数据库的大小
```

- sql语句查询
```sql
SELECT pg_size_pretty(pg_database_size('postgres'));
```
| 函数名 | 返回类型 | 描述 |
| --- | --- | --- |
| pg_column_size(any) | int | 存储一个指定的数值需要的字节数（可能压缩过） |
| pg_database_size(oid) | bigint | 指定OID的数据库使用的磁盘空间 |
| pg_database_size(name) | bigint | 指定名称的数据库使用的磁盘空间 |
| pg_indexes_size(regclass) | bigint | 关联指定表OID或表名的表索引的使用总磁盘空间 |
| pg_relation_size(relation regclass, fork text) | bigint | 指定OID或名的表或索引，通过指定fork('main', 'fsm' 或'vm')所使用的磁盘空间 |
| pg_relation_size(relation regclass) | bigint | pg_relation_size(..., 'main')的缩写 |
| pg_size_pretty(bigint) | text | Converts a size in bytes expressed as a 64-bit integer into a human-readable format with size units |
| pg_size_pretty(numeric) | text | 把以字节计算的数值转换成一个人类易读的尺寸单位 |
| pg_table_size(regclass) | bigint | 指定表OID或表名的表使用的磁盘空间，除去索引（但是包含TOAST，自由空间映射和可视映射） |
| pg_tablespace_size(oid) | bigint | 指定OID的表空间使用的磁盘空间 |
| pg_tablespace_size(name) | bigint | 指定名称的表空间使用的磁盘空间 |
| pg_total_relation_size(regclass) | bigint | 指定表OID或表名使用的总磁盘空间，包括所有索引和TOAST数据 |

##### 数据库死锁得处理

如果有使用pgadmin,在数据库得界面上可以看到locked得进程,直接界面操作即可.

``` sql
-- 查询出死锁得进程id
SELECT * FROM pg_stat_activity WHERE datname='死锁的数据库ID';
-- wating=t的数据找到对应的procpid

-- 如果activity活动表没有记录,则需要查看locks是否有锁
SELECT oid,relname FROM pg_class WHERE relname='table name';
SELECT locktype,pid,relation,mode,granted,* FROM pg_locks WHERE relation= '上面查询出来的oid';

-- 取消死锁进程
SELECT pg_cancel_backend('死锁那条数据的procpid值');

-- 杀死死锁进程
SELECT pg_terminate_backend();

```

##### 数据库的升级
- 小版本升级 可以直接更新数据库软件,对数据应该没有影响,最好先导出数据以防万一

- 方法1:使用pg_dump或pg_dumpall导出数据后,在新数据库使用pg_restore导入

- 方法2:大版本,跨版本升级工具,如10.1->10.3,使用pg_upgrade升级,主要用在数据库较大的时候
	需要老库,新库都停,使用 pg_upgrade   -c 先检测.特别是一些数据库扩展两边都需要统一,如果检测失败,需要在新库删除data后重新initdb,同步数据库扩展,检测通过后即可升级

写的很笼统,毕竟不是运维,只操作过测试库,正式库建议交给运维方便甩锅.

---------------

#### 外部表的使用

使用诸如 file_fdw,foreign_fdw等方式使用外部数据源.
暂没有过成熟的使用体验.

----------------

#### 分区表
pg的分区表经历了几个过程,性能也得到了很大的提升,如果数据能在单库中或经过hash后保证在单库中,使用分区表可以对程序的复杂度有极大的减少.

- 第一代.使用表继承+触发器实现分区表
	简单描述就是 1.create master table,2.create child table inherits master table,3.add check on child table,4.create trigger before insert
	就是很复杂,需要在插入主表时对数据进行重定向插入到适当的分区,性能和功能性都较差,已经基本不会使用.
	
- 第二代 使用postgrespro开发的pg_pathman插件使用分区表

- 内置paritition分区表 PG10 只支持 range,list,hash(POC),没有默认table
	性能较差,甚至不如使用pathman

- 内置partition分区表 PG11 支持range,list,hash,有默认table
	完成对pathman的超越,性能为个位数倍
	但对分区非分区字段查询导致的并行查询依然时顺序执行的,同时对分区字段也需要对分区执行一次查询来确定最后的查询分区表.
		1. 查询计划阶段更快的分区排除，可以提高分区表（尤其是包含许多分区的分区表）的访问性能。
		2. 支持执行阶段的分区排除。
	同时支持了默认分区
	需要注意的是使用内置分区表,对配置文件要开启一些参数
	**智能分区连接**
	set enable_partitionwise_join = on;
	**智能聚合分组**
	set enable_partitionwise_aggregate = on;
	**分区裁剪**
	set enable_partition_pruning=on
	
- 内置partition分区表 PG12 对分区表的并行查询进行了很大的优化

----------------

#### 学习手册

##### insert复制表语句

- INSERT INTO ... SELECT ... FROM ...
语句形式为：Insert into Table2(field1,field2,…) select value1,value2,… from Table1
要求目标表Table2必须存在，由于目标表Table2已经存在，所以我们除了插入源表Table1的字段外，还可以插入常量.

- SELECT ... INTO ... FROM ...
语句形式为：SELECT vale1, value2 into Table2 from Table1
要求目标表Table2不存在，因为在插入时会自动创建表Table2，并将Table1中指定字段数据复制到Table2中。

##### PostgreSQL函数和操作符

###### 逻辑操作符
	AND , OR , NOT

###### 比较操作符

| 操作符 | 描述 |
| --- | --- |
| < | 小于 |
|  >. | 大于 |
| <= | 小于或等于 |
| >= | 大于或等于 |
| = | 等于 |
| != | 不等于 |

a BETWEEN x AND y 等效于 a >= x AND a <= y    
a NOT BETWEEN x AND y 等效于 a < x OR a > y

###### 数学操作符

| 操作符 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- |
| + | 加 | 2 + 3 | 5 |
| - | 减 | 2 - 3 | -1 |
| * | 乘 | 2 * 3 | 6 |
| / | 除 | 4 / 2 | 2 |
| % | 模 | 5 % 4 | 1 |
| ^. | 幂 | 2.0 ^ 3.0 | 8 |
| \|/ | 平方根 | |/ 25.0 | 5 |
| \|\|/ | 立方根 | ||/ 27.0 | 3 |
| ! | 阶乘 | 5 ! | 120 |
| !! | 阶乘 | !! 5 | 120 |
| @ | 绝对值 | @ -5.0 | 5 |
| & | 按位AND | 91 & 15 | 11 |
| \| | 按位OR | 32 | 3 | 35 |
| # | 按位XOR | 17 # 5 | 20 |
| ~ | 按位NOT | ~1 | -2 |
| << | 按位左移 | 1 << 4 | 16 |
| >> | 按位右移 | 8 >> 2 | 2 |

###### 数学函数

| 函数 | 返回类型  | 描述 | 例子  | 结果 |
| --- | --- | --- | --- | --- |
| abs(x) | .  | 绝对值 | abs(-17.4) | 17.4 |
| cbrt(double) | .  | 立方根 | cbrt(27.0) | 3 |
| ceil(double/numeric) | .  | 不小于参数的最小的整数 | ceil(-42.8) | -42 |
| degrees(double)  | .  | 把弧度转为角度 | degrees(0.5) | 28.6478897565412 |
| exp(double/numeric) | .  | 自然指数 | exp(1.0) | 2.71828182845905 |
| floor(double/numeric) | .  | 不大于参数的最大整数 | floor(-42.8) | -43 |
| ln(double/numeric) | .  | 自然对数 | ln(2.0) | 0.693147180559945 |
| log(double/numeric) | .  | 10为底的对数 | log(100.0) | 2 |
| log(b numeric,x numeric) | .  | numeric指定底数的对数 | log(2.0, 64.0) | 6.0000000000 |
| mod(y, x) | .  | 取余数 | mod(9,4) | 1 |
| pi()  | double | "π"常量 | pi()  | 3.14159265358979 |
| power(a double, b double) | double | 求a的b次幂 | power(9.0, 3.0) | 729 |
| power(a numeric, b numeric) | numeric | 求a的b次幂 | power(9.0, 3.0) | 729 |
| radians(double) | double | 把角度转为弧度 | radians(45.0) | 0.785398163397448 |
| random() | double | 0.0到1.0之间的随机数值 | random() | .  |
| round(double/numeric) | .  | 圆整为最接近的整数 | round(42.4) | 42 |
| round(v numeric, s int) | numeric | 圆整为s位小数数字 | round(42.438,2) | 42.44 |
| sign(double/numeric) | .  | 参数的符号(-1,0,+1)  | sign(-8.4) | -1 |
| sqrt(double/numeric) | .  | 平方根 | sqrt(2.0) | 1.4142135623731 |
| trunc(double/numeric) | .  | 截断(向零靠近) | trunc(42.8) | 42 |
| trunc(v numeric, s int) | numeric | 截断为s小数位置的数字 | trunc(42.438,2) | 42.43 |

###### 三角函数

| 函数 | 描述 |
| --- | --- |
| acos(x) | 反余弦 |
| asin(x) | 反正弦 |
| atan(x) | 反正切 |
| atan2(x, y) | 正切 y/x 的反函数 |
| cos(x) | 余弦 |
| cot(x) | 余切 |
| sin(x) | 正弦 |
| tan(x) | 正切 |

###### 字符串函数和操作符

| 函数 | 返回类型 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- | --- |
| string | . | string | text | 字串连接 | 'Post' || 'greSQL' | PostgreSQL |
| bit_length(string) | int | 字串里二进制位的个数 | bit_length('jose') | 32 |
| char_length(string) | int | 字串中的字符个数 | char_length('jose') | 4 |
| convert(string using conversion_name) | text | 使用指定的转换名字改变编码。 | convert('PostgreSQL' using iso_8859_1_to_utf8) | 'PostgreSQL' |
| lower(string) | text | 把字串转化为小写 | lower('TOM') | tom |
| octet_length(string) | int | 字串中的字节数 | octet_length('jose') | 4 |
| overlay(string placing string from int \[for int]) | text | 替换子字串 | overlay('Txxxxas' placing 'hom' from 2 for 4) | Thomas |
| position(substring in string) | int | 指定的子字串的位置 | position('om' in 'Thomas') | 3 |
| substring(string \[from int] \[for int]) | text | 抽取子字串 | substring('Thomas' from 2 for 3) | hom |
| substring(string from pattern) | text | 抽取匹配 POSIX 正则表达式的子字串 | substring('Thomas' from '...$') | mas |
| substring(string from pattern for escape) | text | 抽取匹配SQL正则表达式的子字串 | substring('Thomas' from '%#"o_a#"\_' for '#') | oma |
| trim(\[leading | trailing | both] \[characters] from string) | text | 从字串string的开头/结尾/两边/ 删除只包含characters(缺省是一个空白)的最长的字串 | trim(both 'x' from 'xTomxx') | Tom |
| upper(string) | text | 把字串转化为大写。 | upper('tom') | TOM |
| ascii(text) | int | 参数第一个字符的ASCII码 | ascii('x') | 120 |
| btrim(string text \, characters text]) | text | 从string开头和结尾删除只包含在characters里(缺省是空白)的字符的最长字串 | btrim('xyxtrimyyx','xy') | trim |
| chr(int) | text | 给出ASCII码的字符 | chr(65) | A |
| convert(string text, \[src_encoding name,] dest_encoding name) | text | 把字串转换为dest_encoding | convert( 'text_in_utf8', 'UTF8', 'LATIN1') | 以ISO 8859-1编码表示的text_in_utf8 |
| initcap(text) | text | 把每个单词的第一个子母转为大写，其它的保留小写。单词是一系列字母数字组成的字符，用非字母数字分隔。 | initcap('hi thomas') | Hi Thomas |
| length(string text) | int | string中字符的数目 | length('jose') | 4 |
| lpad(string text, length int \[, fill text]) | text | 通过填充字符fill(缺省时为空白)，把string填充为长度length。 如果string已经比length长则将其截断(在右边)。 | lpad('hi', 5, 'xy') | xyxhi |
| ltrim(string text \[, characters text]) | text | 从字串string的开头删除只包含characters(缺省是一个空白)的最长的字串。 | ltrim('zzzytrim','xyz') | trim |
| md5(string text) | text | 计算给出string的MD5散列，以十六进制返回结果。 | md5('abc') |   |
| repeat(string text, number int) | text | 重复string number次。 | repeat('Pg', 4) | PgPgPgPg |
| replace(string text, from text, to text) | text | 把字串string里出现地所有子字串from替换成子字串to。 | replace('abcdefabcdef', 'cd', 'XX') | abXXefabXXef |
| rpad(string text, length int \[, fill text]) | text | 通过填充字符fill(缺省时为空白)，把string填充为长度length。如果string已经比length长则将其截断。 | rpad('hi', 5, 'xy') | hixyx |
| rtrim(string text \[, character text]) | text | 从字串string的结尾删除只包含character(缺省是个空白)的最长的字 | rtrim('trimxxxx','x') | trim |
| split_part(string text, delimiter text, field int) | text | 根据delimiter分隔string返回生成的第field个子字串(1 Base)。 | split_part('abc~@~def~@~ghi', '~@~', 2) | def |
| strpos(string, substring) | text | 声明的子字串的位置。 | strpos('high','ig') | 2 |
| substr(string, from \[, count]) | text | 抽取子字串。 | substr('alphabet', 3, 2) | ph |
| to_ascii(text \[, encoding]) | text | 把text从其它编码转换为ASCII。 | to_ascii('Karel') | Karel |
| to_hex(number int/bigint) | text | 把number转换成其对应地十六进制表现形式。 | to_hex(9223372036854775807) | 0x7fffffffffffffff |
| translate(string text, from text, to text) | text | 把在string中包含的任何匹配from中的字符的字符转化为对应的在to中的字符。 | translate('12345', '14', 'ax') | a23x5 |

###### 位串函数和操作符

> 对于类型bit和bit varying，除了常用的比较操作符之外，还可以使用以下列表中由PostgreSQL提供的位串函数和操作符，其中&、|和#的位串操作数必须等长。在移位的时候，保留原始的位串的的长度。

| 操作符 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- |
| \|\| | 连接 | B'10001' \|\| B'011' | 10001011 |
| & | 按位AND | B'10001' & B'01101' | 00001 |
| \| | 按位OR | B'10001' \| B'01101' | 11101 |
| # | 按位XOR | B'10001' # B'01101' | 11100 |
| ~ | 按位NOT | ~ B'10001' | 01110 |
| << | 按位左移 | B'10001' << 3 | 01000 |
| >> | 按位右移 | B'10001' >> 2 | 00100 |

除了以上列表中提及的操作符之外，位串还可以使用字符串函数：length， bit_length， octet_length， position， substring。此外，我们还可以在整数和bit之间来回转换，如：

``` sql
	MyTest=# SELECT 44::bit(10);
        bit
    ------------
     0000101100
    (1 row)
    MyTest=# SELECT 44::bit(3);
     bit
    -----
     100
    (1 row)
    MyTest=# SELECT cast(-44 as bit(12));
         bit
    --------------
     111111010100
    (1 row)
    MyTest=# SELECT '1110'::bit(4)::integer;
     int4
    ------
       14
    (1 row)
    注意：如果只是转换为"bit"，意思是转换成bit(1)，因此只会转换成整数的最低位。
```

###### 模式匹配

> PostgreSQL中提供了三种实现模式匹配的方法：SQL LIKE操作符，更近一些的SIMILAR TO操作符，和POSIX-风格正则表达式。

- LIKE
	- string LIKE pattern [ ESCAPE escape-character ]
	- string NOT LIKE pattern [ ESCAPE escape-character ]
	e.g
	``` sql
	'abc' LIKE 'abc'     true
    'abc' LIKE 'a%'     true
    'abc' LIKE '_b_'    true
    'abc' LIKE 'c'        false  
	```
	> 关键字ILIKE可以用于替换LIKE，令该匹配就当前的区域设置是大小写无关的。这个特性不是SQL标准，是PostgreSQL的扩展。操作符\~\~等效于LIKE， 而\~\~*对应ILIKE。还有!\~\~和!\~\~*操作符分别代表NOT LIKE和NOT ILIKE。所有这些操作符都是PostgreSQL特有的。 

- SIMILAR TO 正则表达式
	- string SIMILAR TO pattern [ESCAPE escape-character]
	- string NOT SIMILAR TO pattern [ESCAPE escape-character]

	> 它和LIKE非常类似，支持LIKE的通配符('_'和'%')且保持其原意。除此之外，SIMILAR TO还支持一些自己独有的元字符，如：    
    1). | 标识选择(两个候选之一)。
    2). * 表示重复前面的项零次或更多次。
    3). + 表示重复前面的项一次或更多次。
    4). 可以使用圆括弧()把项组合成一个逻辑项。
    5). 一个方括弧表达式[...]声明一个字符表，就像POSIX正则表达式一样。

	``` sql
	'abc' SIMILAR TO 'abc'           true
    'abc' SIMILAR TO 'a'              false
    'abc' SIMILAR TO '%(b|d)%'  true
    'abc' SIMILAR TO '(b|c)%'     false
	```

- POSIX 正则表达式

###### 数据类型格式化函数

> PostgreSQL格式化函数提供一套有效的工具用于把各种数据类型(日期/时间、integer、floating point和numeric)转换成格式化的字符串以及反过来从格式化的字符串转换成指定的数据类型。下面列出了这些函数，它们都遵循一个公共的调用习 惯：第一个参数是待格式化的值，而第二个是定义输出或输出格式的模板。

| 函数 | 返回类型 | 描述 | 例子 |
| --- | --- | --- | --- |
| to_char(timestamp, text) | text | 把时间戳转换成字串 | to_char(current_timestamp, 'HH12:MI:SS') |
| to_char(interval, text) | text | 把时间间隔转为字串 | to_char(interval '15h 2m 12s', 'HH24:MI:SS') |
| to_char(int, text) | text | 把整数转换成字串 | to_char(125, '999') |
| to_char(double precision, text) | text | 把实数/双精度数转换成字串 | to_char(125.8::real, '999D9') |
| to_char(numeric, text) | text | 把numeric转换成字串 | to_char(-125.8, '999D99S') |
| to_date(text, text) | date | 把字串转换成日期 | to_date('05 Dec 2000', 'DD Mon YYYY') |
| to_timestamp(text, text) | timestamp | 把字串转换成时间戳 | to_timestamp('05 Dec 2000', 'DD Mon YYYY') |
| to_timestamp(double) | timestamp | 把UNIX纪元转换成时间戳 | to_timestamp(200120400) |
| to_number(text, text) | numeric | 把字串转换成numeric | to_number('12,454.8-', '99G999D9S') |

###### 用于 日期/时间 格式化的模式定义

| 模式 | 描述 |
| --- | --- |
| HH | 一天的小时数(01-12) |
| HH12 | 一天的小时数(01-12) |
| HH24 | 一天的小时数(00-23) |
| MI | 分钟(00-59) |
| SS | 秒(00-59) |
| MS | 毫秒(000-999) |
| US | 微秒(000000-999999) |
| AM | 正午标识(大写) |
| Y,YYY | 带逗号的年(4和更多位) |
| YYYY | 年(4和更多位) |
| YYY | 年的后三位 |
| YY | 年的后两位 |
| Y | 年的最后一位 |
| MONTH | 全长大写月份名(空白填充为9字符) |
| Month | 全长混合大小写月份名(空白填充为9字符) |
| month | 全长小写月份名(空白填充为9字符) |
| MON | 大写缩写月份名(3字符) |
| Mon | 缩写混合大小写月份名(3字符) |
| mon | 小写缩写月份名(3字符) |
| MM | 月份号(01-12) |
| DAY | 全长大写日期名(空白填充为9字符) |
| Day | 全长混合大小写日期名(空白填充为9字符) |
| day | 全长小写日期名(空白填充为9字符) |
| DY | 缩写大写日期名(3字符) |
| Dy | 缩写混合大小写日期名(3字符) |
| dy | 缩写小写日期名(3字符) |
| DDD | 一年里的日子(001-366) |
| DD | 一个月里的日子(01-31) |
| D | 一周里的日子(1-7；周日是1) |
| W | 一个月里的周数(1-5)(第一周从该月第一天开始) |
| WW | 一年里的周数(1-53)(第一周从该年的第一天开始) |

###### 用于数值格式化的模式

| 模式 | 描述 |
| --- | --- |
| 9 | 带有指定数值位数的值 |
| 0 | 带前导零的值 |
| .(句点) | 小数点 |
| ,(逗号) | 分组(千)分隔符 |
| PR | 尖括号内负值 |
| S | 带符号的数值 |
| L | 货币符号 |
| D | 小数点 |
| G | 分组分隔符 |
| MI | 在指明的位置的负号(如果数字 < 0) |
| PL | 在指明的位置的正号(如果数字 > 0) |
| SG | 在指明的位置的正/负号 |

###### 时间/日期 支持的操作符

| 操作符 | 例子 | 结果 |
| --- | --- | --- |
| + | date '2001-09-28' + integer '7' | date '2001-10-05' |
| + | date '2001-09-28' + interval '1 hour' | timestamp '2001-09-28 01:00' |
| + | date '2001-09-28' + time '03:00' | timestamp '2001-09-28 03:00' |
| + | interval '1 day' + interval '1 hour' | interval '1 day 01:00' |
| + | timestamp '2001-09-28 01:00' + interval '23 hours' | timestamp '2001-09-29 00:00' |
| + | time '01:00' + interval '3 hours' | time '04:00' |
| - | - interval '23 hours' | interval '-23:00' |
| - | date '2001-10-01' - date '2001-09-28' | integer '3' |
| - | date '2001-10-01' - integer '7' | date '2001-09-24' |
| - | date '2001-09-28' - interval '1 hour' | timestamp '2001-09-27 23:00' |
| - | time '05:00' - time '03:00' | interval '02:00' |
| - | time '05:00' - interval '2 hours' | time '03:00' |
| - | timestamp '2001-09-28 23:00' - interval '23 hours' | timestamp '2001-09-28 00:00' |
| - | interval '1 day' - interval '1 hour' | interval '23:00' |
| - | timestamp '2001-09-29 03:00' - timestamp '2001-09-27 12:00' | interval '1 day 15:00' |
| * | interval '1 hour' * double precision '3.5' | interval '03:30' |
| / | interval '1 hour' / double precision '1.5' | interval '00:40' |

###### 时间/日期 的函数

| 函数 | 返回类型 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- | --- |
| age(timestamp, timestamp) | interval | 减去参数，生成一个使用年、月的"符号化"的结果 | age('2001-04-10', timestamp '1957-06-13') | 43 years 9 mons 27 days |
| age(timestamp) | interval | 从current_date减去得到的数值 | age(timestamp '1957-06-13') | 43 years 8 mons 3 days |
| current_date | date | 今天的日期 | .  | .  |
| current_time | time | 现在的时间 | .  | .  |
| current_timestamp | timestamp | 日期和时间 | .  | .  |
| date_part(text, timestamp) | double | 获取子域(等效于extract) | date_part('hour', timestamp '2001-02-16 20:38:40') | 20 |
| date_part(text, interval) | double | 获取子域(等效于extract) | date_part('month', interval '2 years 3 months') | 3 |
| date_trunc(text, timestamp) | timestamp | 截断成指定的精度 | date_trunc('hour', timestamp '2001-02-16 20:38:40') | 2001-02-16 20:00:00+00 |
| extract(field from timestamp) | double | 获取子域 | extract(hour from timestamp '2001-02-16 20:38:40') | 20 |
| extract(field from interval) | double | 获取子域 | extract(month from interval '2 years 3 months') | 3 |
| localtime | time | 今日的时间 | .  | .  |
| localtimestamp | timestamp | 日期和时间 | .  | .  |
| now() | timestamp | 当前的日期和时间(等效于 current_timestamp) | .  | .  |
| timeofday() | text | 当前日期和时间 | .  | .  |

###### 时间/日期 EXTRACT函数,Date_Part函数支持的 Field

| 域 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- |
| CENTURY | 世纪 | EXTRACT(CENTURY FROM TIMESTAMP '2000-12-16 12:21:13'); | 20 |
| DAY | (月分)里的日期域(1-31) | EXTRACT(DAY from TIMESTAMP '2001-02-16 20:38:40'); | 16 |
| DECADE | 年份域除以10 | EXTRACT(DECADE from TIMESTAMP '2001-02-16 20:38:40'); | 200 |
| DOW | 每周的星期号(0-6；星期天是0) (仅用于timestamp) | EXTRACT(DOW FROM TIMESTAMP '2001-02-16 20:38:40'); | 5 |
| DOY | 一年的第几天(1 -365/366) (仅用于 timestamp) | EXTRACT(DOY from TIMESTAMP '2001-02-16 20:38:40'); | 47 |
| HOUR | 小时域(0-23) | EXTRACT(HOUR from TIMESTAMP '2001-02-16 20:38:40'); | 20 |
| MICROSECONDS | 秒域，包括小数部分，乘以 1,000,000。 | EXTRACT(MICROSECONDS from TIME '17:12:28.5'); | 28500000 |
| MILLENNIUM | 千年 | EXTRACT(MILLENNIUM from TIMESTAMP '2001-02-16 20:38:40'); | 3 |
| MILLISECONDS | 秒域，包括小数部分，乘以 1000。 | EXTRACT(MILLISECONDS from TIME '17:12:28.5'); | 28500 |
| MINUTE | 分钟域(0-59) | EXTRACT(MINUTE from TIMESTAMP '2001-02-16 20:38:40'); | 38 |
| MONTH | 对于timestamp数值，它是一年里的月份数(1-12)；对于interval数值，它是月的数目，然后对12取模(0-11) | EXTRACT(MONTH from TIMESTAMP '2001-02-16 20:38:40'); | 2 |
| QUARTER | 该天所在的该年的季度(1-4)(仅用于 timestamp) | EXTRACT(QUARTER from TIMESTAMP '2001-02-16 20:38:40'); | 1 |
| SECOND | 秒域，包括小数部分(0-59[1]) | EXTRACT(SECOND from TIMESTAMP '2001-02-16 20:38:40'); | 40 |
| WEEK | 该天在所在的年份里是第几周。 | EXTRACT(WEEK from TIMESTAMP '2001-02-16 20:38:40'); | 7 |
| YEAR | 年份域 | EXTRACT(YEAR from TIMESTAMP '2001-02-16 20:38:40'); | 2001 |

###### 获取当前日期/时间

> 我们可以使用下面的函数获取当前的日期和/或时间∶

``` sql
	CURRENT_DATE
    CURRENT_TIME
    CURRENT_TIMESTAMP
    CURRENT_TIME (precision)
    CURRENT_TIMESTAMP (precision)
    LOCALTIME
    LOCALTIMESTAMP
    LOCALTIME (precision)
    LOCALTIMESTAMP (precision)
```

###### 序列操作函数

>  序列对象(也叫序列生成器)都是用CREATE SEQUENCE创建的特殊的单行表。一个序列对象通常用于为行或者表生成唯一的标识符,即我们使用 serial 作为字段类型时即会创建一个序列.

| 函数 | 返回类型 | 描述 |
| --- | --- | --- |
| nextval(regclass) | bigint | 递增序列对象到它的下一个数值并且返回该值。这个动作是自动完成的。即使多个会话并发运行nextval，每个进程也会安全地收到一个唯一的序列值。 |
| currval(regclass) | bigint | 在当前会话中返回最近一次nextval抓到的该序列的数值。(如果在本会话中从未在该序列上调用过 nextval，那么会报告一个错误。)请注意因为此函数返回一个会话范围的数值，而且也能给出一个可预计的结果，因此可以用于判断其它会话是否执行过nextval。 |
| lastval() | bigint | 返回当前会话里最近一次nextval返回的数值。这个函数等效于currval，只是它不用序列名为参数，它抓取当前会话里面最近一次nextval使用的序列。如果当前会话还没有调用过nextval，那么调用lastval将会报错。 |
| setval(regclass, bigint) | bigint | 重置序列对象的计数器数值。设置序列的last_value字段为指定数值并且将其is_called字段设置为true，表示下一次nextval将在返回数值之前递增该序列。 |
| setval(regclass, bigint, boolean) | bigint | 重置序列对象的计数器数值。功能等同于上面的setval函数，只是is_called可以设置为true或false。如果将其设置为false，那么下一次nextval将返回该数值，随后的nextval才开始递增该序列。 |

###### 条件表达式

- CASE
	SQL CASE表达式是一种通用的条件表达式，类似于其它语言中的if/else语句。
	``` sql
	CASE WHEN condition THEN result
        [WHEN ...]
        [ELSE result]
    END
	```

- COALESCE
	COALESCE返回它的第一个非NULL的参数的值。它常用于在为显示目的检索数据时用缺省值替换NULL值。
	``` sql
	COALESCE(value[, ...])
	```

- NULLIF
	当且仅当value1和value2相等时，NULLIF才返回NULL。否则它返回value1。
	``` sql
	NULLIF(value1, value2)
	```

- GREATEST和LEAST
	GREATEST和LEAST函数从一个任意的数字表达式列表里选取最大或者最小的数值。列表中的NULL数值将被忽略。只有所有表达式的结果都是NULL的时候，结果才会是NULL。
	``` sql
	GREATEST(value [, ...])
    LEAST(value [, ...])
	```
	
###### 数组的声明

``` sql
-- 数组元素值是用双引号的,如果是单引号就会出错.
'{"Page", "Plant", "Jones", "Bonham"}'

-- 使用数组构造器,数组元素是用单引号的
ARRAY['Barrett', 'Gilmour']

-- 使用下标对数组进行访问
this_is_array[0]

-- 使用切片对数组进行访问
this_is_array[1:2]

-- 可以使用下标对数组指定元素进行操作,也可以对数组整个操作
this_is_array[0]=1
this_is_array='{1,2,3}'

-- 对数组进行元素查,使用ANY关键字
1=ANY(this_is_array)

-- 对数组判定所有值都匹配,使用ALL关键字
1=ALL(this_is_array)

```
	
######   数组的操作符

| 操作符 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- |
| = | 等于 | ARRAY\[1.1,2.1,3.1]::int\[] = ARRAY\[1,2,3] | t |
| <> | 不等于 | ARRAY\[1,2,3] <> ARRAY\[1,2,4] | t |
| < | 小于 | ARRAY\[1,2,3] < ARRAY\[1,2,4] | t |
| > | 大于 | ARRAY\[1,4,3] > ARRAY\[1,2,4] | t |
| <= | 小于或等于 | ARRAY\[1,2,3] <= ARRAY\[1,2,3] | t |
| >= | 大于或等于 | ARRAY\[1,4,3] >= ARRAY\[1,4,3] | t |
| @> | contains | ARRAY\[1,4,3] @> ARRAY\[3,1] | t |
| <@ | is contained by | ARRAY\[2,7] <@ ARRAY\[1,7,4,2,6] | t |
| && | overlap (have elements in common) | ARRAY\[1,4,3] && ARRAY\[2,1] | t |
| \|\| | 数组与数组连接 | ARRAY\[1,2,3] \|\| ARRAY\[4,5,6] | {1,2,3,4,5,6} |
| \|\| | 数组与数组连接 | ARRAY\[1,2,3] \|\| ARRAY\[\[4,5,6],\[7,8,9]] | {{1,2,3},{4,5,6},{7,8,9}} |
| \|\| | 元素与数组连接 | 3 \|\| ARRAY\[4,5,6] | {3,4,5,6} |
| \|\| | 元素与数组连接 | ARRAY\[4,5,6] \|\| 7 | {4,5,6,7} |

###### 数组的函数

| 函数 | 返回类型 | 描述 | 例子 | 结果 |
| --- | --- | --- | --- | --- |
| array_cat(anyarray, anyarray) | anyarray | 连接两个数组 | array_cat(ARRAY\[1,2,3], ARRAY\[4,5]) | {1,2,3,4,5} |
| array_append(anyarray, anyelement) | anyarray | 向一个数组末尾附加一个元素 | array_append(ARRAY\[1,2], 3) | {1,2,3} |
| array_prepend(anyelement, anyarray) | anyarray | 向一个数组开头附加一个元素 | array_prepend(1, ARRAY\[2,3]) | {1,2,3} |
| array_dims(anyarray) | text | 返回一个数组维数的文本表示 | array_dims(ARRAY\[\[1,2,3], \[4,5,6]]) | \[1:2]\[1:3] |
| array_lower(anyarray, int) | int | 返回指定的数组维数的下界 | array_lower(array_prepend(0, ARRAY\[1,2,3]), 1) | 0 |
| array_upper(anyarray, int) | int | 返回指定数组维数的上界 | array_upper(ARRAY\[1,2,3,4], 1) | 4 |
| array_to_string(anyarray, text) | text | 使用提供的分隔符连接数组元素 | array_to_string(ARRAY\[1, 2, 3], '~^~') | 1~^~2~^~3 |
| string_to_array(text, text) | text\[] | 使用指定的分隔符把字串拆分成数组元素 | string_to_array('xx~^~yy~^~zz', '~^~') | {xx,yy,zz} |
| unnest(anyarray) | setof anyelement | expand an array to a set of rows | unnest(ARRAY[1,2]) | 12(2 rows) |

###### 系统信息函数

> PostgreSQL中提供的和数据库相关的函数列表：

| 名字 | 返回类型 | 描述 |
| --- | --- | --- |
| current_database() | name | 当前数据库的名字 |
| current_schema() | name | 当前模式的名字 |
| current_schemas(boolean) | name\[] | 在搜索路径中的模式名字 |
| current_user | name | 目前执行环境下的用户名 |
| inet_client_addr() | inet | 连接的远端地址 |
| inet_client_port() | int | 连接的远端端口 |
| inet_server_addr() | inet | 连接的本地地址 |
| inet_server_port() | int | 连接的本地端口 |
| session_user | name | 会话用户名 |
| pg_postmaster_start_time() | timestamp | postmaster启动的时间 |
| user | name | current_user |
| version() | text | PostgreSQL版本信息 |

> 允许用户在程序里查询对象访问权限的函数：

| 名字 | 描述 | 可用权限 |
| --- | --- | --- |
| has_table_privilege<br/>(user,table,privilege) | 用户是否有访问表的权限 | SELECT/INSERT/UPDATE/DELETE/<br/>RULE/REFERENCES/TRIGGER |
| has_table_privilege<br/>(table,privilege) | 当前用户是否有访问表的权限 | SELECT/INSERT/UPDATE/DELETE/<br/>RULE/REFERENCES/TRIGGER |
| has_database_privilege<br/>(user,database,privilege) | 用户是否有访问数据库的权限 | CREATE/TEMPORARY |
| has_database_privilege<br/>(database,privilege) | 当前用户是否有访问数据库的权限 | CREATE/TEMPORARY |
| has_function_privilege<br/>(user,function,privilege) | 用户是否有访问函数的权限 | EXECUTE |
| has_function_privilege<br/>(function,privilege) | 当前用户是否有访问函数的权限 | EXECUTE |
| has_language_privilege<br/>(user,language,privilege) | 用户是否有访问语言的权限 | USAGE |
| has_language_privilege<br/>(language,privilege) | 当前用户是否有访问语言的权限 | USAGE |
| has_schema_privilege<br/>(user,schema,privilege) | 用户是否有访问模式的权限 | CREAT/USAGE |
| has_schema_privilege<br/>(schema,privilege) | 当前用户是否有访问模式的权限 | CREAT/USAGE |
| has_tablespace_privilege<br/>(user,tablespace,privilege) | 用户是否有访问表空间的权限 | CREATE |
| has_tablespace_privilege<br/>(tablespace,privilege) | 当前用户是否有访问表空间的权限 | CREATE |

*注：以上函数均返回boolean类型。要评估一个用户是否在权限上持有赋权选项，给权限键字附加 WITH GRANT OPTION；比如 'UPDATE WITH GRANT OPTION'.*

###### 系统管理配置函数

| 名字 | 返回类型 | 描述 |
| --- | --- | --- | --- |
| current_setting(setting_name) | text | 当前设置的值 | 等价于命令 SHOW |
| set_config(setting_name,new_value,is_local) | text | 设置参数并返回新值 | 等于于命令 SET |

###### 查询数据库对象尺寸函数

| 名字 | 返回类型 | 描述 |
| --- | --- | --- |
| pg_tablespace_size(oid) | bigint | 指定OID代表的表空间使用的磁盘空间 |
| pg_tablespace_size(name) | bigint | 指定名字的表空间使用的磁盘空间 |
| pg_database_size(oid) | bigint | 指定OID代表的数据库使用的磁盘空间 |
| pg_database_size(name) | bigint | 指定名称的数据库使用的磁盘空间 |
| pg_relation_size(oid) | bigint | 指定OID代表的表或者索引所使用的磁盘空间 |
| pg_relation_size(text) | bigint | 指定名称的表或者索引使用的磁盘空间。<br/> 这个名字可以用模式名修饰 |
| pg_total_relation_size(oid) | bigint | 指定OID代表的表使用的磁盘空间，<br/> 包括索引和压缩数据 |
| pg_total_relation_size(text) | bigint | 指定名字的表所使用的全部磁盘空间，<br/> 包括索引和压缩数据。表名字可以用模式名修饰。 |
| pg_size_pretty(bigint) | text | 把字节计算的尺寸转换成一个人类易读的尺寸单位 |

----------------

#### 踩过的坑

##### invalid byte sequence for encoding

> invalid byte sequence for encoding "UTF8": 0x00（注意：若不是0x00则很可能是字符集设置有误），是PostgreSQL独有的错误信息，直接原因是varchar型的字段或变量不接受含有'\0'（也即数值0x00、UTF编码'\u0000'）的字符串 。官方给出的解决方法：事先去掉字符串中的'\0'，例如在代码中使用str.replaceAll('\u0000', '')，貌似这是目前唯一可行的方法。

> 按照官方的推荐做法而直接对嫌疑字符串使用str.replaceAll('\u0000', '')，虽然避免了错误发生，之后的乱码却会存入数据库并最终显示在页面。经与客户沟通，确认'\0'之后均为乱码，于是在程序代码中将所有的嫌疑字段的'\0'及乱码一起截断：
str.trim().split('\u0000')[0];
