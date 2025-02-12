#### Масштабирование и отказоустойчивость Cassandra

Опишем топологию поднимаемого кластера Cassandra в yml:

```yaml
# cat docker-compose.yml

version: '3.9'

services:
  cass1:
    image: cassandra
    container_name: cass1
    hostname: cass1
    environment:
        CASSANDRA_CLUSTER_NAME: TestCluster
        CASSANDRA_ENDPOINT_SNITCH: GossipingPropertyFileSnitch
        CASSANDRA_DC: dc1
    ports:
      - 9042:9042
      - 7000:7000

  cass2:
    image: cassandra
    container_name: cass2
    hostname: cass2
    environment:
        CASSANDRA_CLUSTER_NAME: TestCluster
        CASSANDRA_ENDPOINT_SNITCH: GossipingPropertyFileSnitch
        CASSANDRA_DC: dc2
        CASSANDRA_SEEDS: cass1


  cass3:
    image: cassandra
    container_name: cass3
    hostname: cass3
    environment:
        CASSANDRA_CLUSTER_NAME: TestCluster
        CASSANDRA_ENDPOINT_SNITCH: GossipingPropertyFileSnitch
        CASSANDRA_DC: dc1
        CASSANDRA_SEEDS: cass1

```
Используем в качестве снитча для распределений механизм распространения сплетен, причем обмен на основе файлов. Для второго и третьего узла указываем в качестве seeds-узла - первый узел (IP-адрес, используемый gossip для начальной загрузки новых узлов, присоединяющихся к кластеру) можно указать хостнейм как и сделали. Второй узел помещаем в другой датацентр2.

Запускаем командой, (причем удачно запустилось только со второго раза - видимо изза нехватки RAM-8Gb) проверяем
```bash
docker compose -f docker-compose.yml up -d
[+] Running 3/3
 ✔ Container cass1  Running                                                                                                                                                               0.0s
 ✔ Container cass3  Started                                                                                                                                                               0.3s
 ✔ Container cass2  Started

# docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                                                                                                                NAMES
26412b5933ea   cassandra   "docker-entrypoint.s…"   21 minutes ago   Up 18 minutes   7000-7001/tcp, 7199/tcp, 9042/tcp, 9160/tcp                                                                          cass2
f51f4d2f34e5   cassandra   "docker-entrypoint.s…"   21 minutes ago   Up 21 minutes   7001/tcp, 0.0.0.0:7000->7000/tcp, :::7000->7000/tcp, 7199/tcp, 0.0.0.0:9042->9042/tcp, :::9042->9042/tcp, 9160/tcp   cass1
740525a59538   cassandra   "docker-entrypoint.s…"   21 minutes ago   Up 18 minutes   7000-7001/tcp, 7199/tcp, 9042/tcp, 9160/tcp                                                                          cass3

# docker inspect cass1 | grep '"IPAddress": "172.21.0.'
                    "IPAddress": "172.21.0.3",
# docker inspect cass2 | grep '"IPAddress": "172.21.0.'
                    "IPAddress": "172.21.0.4",
# docker inspect cass3 | grep '"IPAddress": "172.21.0.'
                    "IPAddress": "172.21.0.2",

```
после старта выглядит статус пока вот так:

```bash
# docker exec -ti cass1 nodetool status
Datacenter: dc1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load        Tokens  Owns (effective)  Host ID                               Rack
UN  172.21.0.3  119.82 KiB  16      100.0%            df808870-79ac-4a69-a814-10fae669d481  rack1
UN  172.21.0.2  171.45 KiB  16      100.0%            0f4a6533-1bf5-48f6-9020-2e58d37eaf80  rack1

Datacenter: dc2
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load        Tokens  Owns (effective)  Host ID                               Rack
UJ  172.21.0.4  171.43 KiB  16      ?                 ded9c5f7-2b54-422e-8d8d-94bbd2636b60  rack1
```

через некоторое время стало так:

![Alt text](status.png?raw=true "status")

для интереса посмотрим конфиг
```sh
docker exec -ti cass1 bash

root@cass1:/# cat /etc/cassandra/cassandra.yaml | grep cluster_name
cluster_name: TestCluster

root@cass1:/# cat /etc/cassandra/cassandra.yaml | grep endpoint_snitch
# endpoint_snitch -- Set this to a class that implements
endpoint_snitch: GossipingPropertyFileSnitch

root@cass1:/# cat /etc/cassandra/cassandra.yaml | grep partitioner
# The partitioner is responsible for distributing groups of rows (by
# partition key) across nodes in the cluster. The partitioner can NOT be
# you should set this to the same partitioner that you are currently using.
# The default partitioner is the Murmur3Partitioner. Older partitioners
partitioner: org.apache.cassandra.dht.Murmur3Partitioner

root@cass1:/# cat /etc/cassandra/cassandra.yaml | grep seeds
      # seeds is actually a comma-delimited list of addresses.
      - seeds: "172.21.0.3"
```

Заходим в командную строку, создадим keyspace
```sh
# docker exec -ti cass1 cqlsh
Connected to TestCluster at 127.0.0.1:9042
[cqlsh 6.2.0 | Cassandra 5.0.2 | CQL spec 3.4.7 | Native protocol v5]
Use HELP for help.
cqlsh> DESCRIBE CLUSTER;

Cluster: TestCluster
Partitioner: Murmur3Partitioner
Snitch: DynamicEndpointSnitch


cqlsh>  CREATE KEYSPACE IF NOT EXISTS my_test_ks
   ... WITH REPLICATION = {
   ... 'class' : 'NetworkTopologyStrategy',
   ... 'dc1' : 1,
   ... 'dc2' : 1
   ... };

cqlsh> DESCRIBE KEYSPACE my_test_ks;
CREATE KEYSPACE my_test_ks WITH replication = {'class': 'NetworkTopologyStrategy', 'dc2': '1', 'dc1': '1'}  AND durable_writes = true;
```
Смотрим статус снова:
```sh
# docker exec -ti cass1 nodetool status my_test_ks
Datacenter: dc1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load        Tokens  Owns (effective)  Host ID                               Rack
UN  172.21.0.3  109.51 KiB  16      48.8%             df808870-79ac-4a69-a814-10fae669d481  rack1
UN  172.21.0.2  141.3 KiB   16      51.2%             0f4a6533-1bf5-48f6-9020-2e58d37eaf80  rack1

Datacenter: dc2
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load        Tokens  Owns (effective)  Host ID                               Rack
UN  172.21.0.4  136.25 KiB  16      100.0%            ded9c5f7-2b54-422e-8d8d-94bbd2636b60  rack1
```

![Alt text](status2.png?raw=true "status2")


Создадим две таблицы (Одна из таблиц должна иметь составной Partition key, как минимум одно поле - clustering key, как минимум одно поле не входящее в primary key)
и наполним данными
```bash
cqlsh> use my_test_ks ;
cqlsh:my_test_ks> CREATE TABLE IF NOT EXISTS movies (id timeuuid, title text, year int, PRIMARY KEY (year,id)) CLUSTERING ORDER BY (id DESC);
cqlsh:my_test_ks> CREATE TABLE IF NOT EXISTS books (id int PRIMARY KEY, title text, pages int);

cqlsh:my_test_ks> INSERT INTO movies (id,title,year) VALUES (now(),'test_title',2000);
cqlsh:my_test_ks> INSERT INTO movies (id,title,year) VALUES (now(),'The Shawshank Redemption',1994);
cqlsh:my_test_ks> INSERT INTO movies (id,title,year) VALUES (now(),'Forrest Gump',1994);
cqlsh:my_test_ks> INSERT INTO movies (id,title,year) VALUES (now(),'Fight Club',1999);

cqlsh:my_test_ks> INSERT INTO books (id,title,pages) VALUES (1,'title1',123);
cqlsh:my_test_ks> INSERT INTO books (id,title,pages) VALUES (2,'title2',413);
cqlsh:my_test_ks> INSERT INTO books (id,title,pages) VALUES (3,'title3',234);
cqlsh:my_test_ks> INSERT INTO books (id,title,pages) VALUES (4,'title4',3234);
```

запрос для первой таблички кино отрабатывает с условием по полю год, так как есть индекс.
```sh
cqlsh:my_test_ks> select * from movies ;

 year | id                                   | title
------+--------------------------------------+--------------------------
 1999 | 75dfa0d0-ab2e-11ef-bf3b-25b35ee928d5 |               Fight Club
 2000 | 578eb3f0-ab2e-11ef-bf3b-25b35ee928d5 |               test_title
 1994 | 6e252c70-ab2e-11ef-bf3b-25b35ee928d5 |             Forrest Gump
 1994 | 641a1150-ab2e-11ef-bf3b-25b35ee928d5 | The Shawshank Redemption

(4 rows)
cqlsh:my_test_ks> select * from movies  where year = 1994;

 year | id                                   | title
------+--------------------------------------+--------------------------
 1994 | 6e252c70-ab2e-11ef-bf3b-25b35ee928d5 |             Forrest Gump
 1994 | 641a1150-ab2e-11ef-bf3b-25b35ee928d5 | The Shawshank Redemption

(2 rows)
```
Для таблички книг с условием по полю, по которому нет индекса, запрос не будет выполняться, только при использовании команды ALLOW FILTERING, либо только после создания индекса
```sh
cqlsh:my_test_ks> select * from books ;

 id | pages | title
----+-------+--------
  1 |   123 | title1
  2 |   413 | title2
  4 |  3234 | title4
  3 |   234 | title3

(4 rows)

cqlsh:my_test_ks> select * from books where  title = 'title2';
InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and thus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"
cqlsh:my_test_ks> select * from books where  title = 'title2' ALLOW FILTERING;

 id | pages | title
----+-------+--------
  2 |   413 | title2

(1 rows)
cqlsh:my_test_ks> CREATE INDEX books_indx ON books (title);
cqlsh:my_test_ks> select * from books where  title = 'title2';

 id | pages | title
----+-------+--------
  2 |   413 | title2

(1 rows)
```

(*) нагрузить кластер при помощи Cassandra Stress Tool (используя "How to use Apache Cassandra Stress Tool.pdf" из материалов).
Данная пдф не обнаружена ни в материалах лекций Cassandra: Distributed Key Value, Architecture / Cassandra: System Components (ДЗ), ни в лекции "Занятие в формате вопрос-ответ"