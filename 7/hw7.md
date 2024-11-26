DCS

Развернем кластер etcd следующей топологии, описанной в yaml-файле:

```sh
# cat docker-compose.yaml
services:
  etcd1:
    image: docker.io/bitnami/etcd:latest
    container_name: etcd1
    hostname: etcd1
    restart: always
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_NAME=etcd1
      - ETCD_INITIAL_ADVERTISE_PEER_URLS=http://etcd1:2380
      - ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd1:2379
      - ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
      - ETCD_INITIAL_CLUSTER=etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380
      - ETCD_INITIAL_CLUSTER_STATE=new
    ports:
      - 2381:2379
    volumes:
      - /data/etcd1:/etcd_data

  etcd2:
    image: docker.io/bitnami/etcd:latest
    container_name: etcd2
    hostname: etcd2
    restart: always
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_NAME=etcd2
      - ETCD_INITIAL_ADVERTISE_PEER_URLS=http://etcd2:2380
      - ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd2:2379
      - ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
      - ETCD_INITIAL_CLUSTER=etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380
      - ETCD_INITIAL_CLUSTER_STATE=new
    ports:
      - 2382:2379
    volumes:
      - /data/etcd2:/etcd_data

  etcd3:
    image: docker.io/bitnami/etcd:latest
    container_name: etcd3
    hostname: etcd3
    restart: always
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_NAME=etcd3
      - ETCD_INITIAL_ADVERTISE_PEER_URLS=http://etcd3:2380
      - ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd3:2379
      - ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
      - ETCD_INITIAL_CLUSTER=etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380
      - ETCD_INITIAL_CLUSTER_STATE=new
    ports:
      - 2383:2379
    volumes:
      - /data/etcd3:/etcd_data
```
Запускаем, проверяем

```
# docker compose -f docker-compose.yaml up -d
[+] Running 4/4
 ✔ Network etcd_default  Created                                                                                                                                                         0.1s
 ✔ Container etcd2       Started                                                                                                                                                         0.5s
 ✔ Container etcd1       Started                                                                                                                                                         0.4s
 ✔ Container etcd3       Started                                                                                                                                                         0.5s

# docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED              STATUS              PORTS                                                   NAMES
706684a1f555   bitnami/etcd:latest   "/opt/bitnami/script…"   About a minute ago   Up About a minute   2380/tcp, 0.0.0.0:2383->2379/tcp, [::]:2383->2379/tcp   etcd3
dc95023621e8   bitnami/etcd:latest   "/opt/bitnami/script…"   About a minute ago   Up About a minute   2380/tcp, 0.0.0.0:2382->2379/tcp, [::]:2382->2379/tcp   etcd2
fcd715eeaf14   bitnami/etcd:latest   "/opt/bitnami/script…"   About a minute ago   Up About a minute   2380/tcp, 0.0.0.0:2381->2379/tcp, [::]:2381->2379/tcp   etcd1
```

Зайдём в любой посмотрим удалось ли создать кластер все ли члены кластера нашлись

```sh
# docker exec -ti etcd3 bash

$ etcdctl member list
ade526d28b1f92f7, started, etcd1, http://etcd1:2380, http://etcd1:2379, false
bd388e7810915853, started, etcd3, http://etcd3:2380, http://etcd3:2379, false
d282ac2ce600c1ce, started, etcd2, http://etcd2:2380, http://etcd2:2379, false

#Используется API v3
$ ETCDCTL_API=3 etcdctl endpoint status
127.0.0.1:2379, bd388e7810915853, 3.5.17, 20 kB, false, false, 3, 12, 12,
#не очень удобное представление

#с перечилсением енд-поинтов и виде таблички удобнее
$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |     false |      false |         3 |         12 |                 12 |        |
| http://etcd2:2379 | d282ac2ce600c1ce |  3.5.17 |   20 kB |      true |      false |         3 |         12 |                 12 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |     false |      false |         3 |         12 |                 12 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```
Как видно лидером является вторая нода, кластер функционирует, отключим второй узел # docker stop etcd2

```sh
@etcd1:/opt/bitnami/etcd$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
{"level":"warn","ts":"2024-11-26T18:54:08.229354Z","logger":"etcd-client","caller":"v3@v3.5.17/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc00057e000/etcd1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing: dial tcp: lookup etcd2 on 127.0.0.11:53: server misbehaving\""}
Failed to get the status of endpoint http://etcd2:2379 (context deadline exceeded)
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |      true |      false |         4 |         13 |                 13 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |     false |      false |         4 |         13 |                 13 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```
Ругается на отсутствие второго узла, но тем не менее прошли перевыборы и кластер работает.
Выключим лидера # docker stop etcd1

```sh
# docker exec -it etcd3 bash
@etcd3:/opt/bitnami/etcd$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
{"level":"warn","ts":"2024-11-26T18:56:55.093349Z","logger":"etcd-client","caller":"v3@v3.5.17/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc00052e000/etcd1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing: dial tcp: lookup etcd1 on 127.0.0.11:53: server misbehaving\""}
Failed to get the status of endpoint http://etcd1:2379 (context deadline exceeded)
{"level":"warn","ts":"2024-11-26T18:57:00.093864Z","logger":"etcd-client","caller":"v3@v3.5.17/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc00052e000/etcd1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing: dial tcp: lookup etcd2 on 127.0.0.11:53: server misbehaving\""}
Failed to get the status of endpoint http://etcd2:2379 (context deadline exceeded)
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+-----------------------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX |        ERRORS         |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+-----------------------+
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |     false |      false |         5 |         14 |                 14 | etcdserver: no leader |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+-----------------------+

```
третья нода живая, но выборы не происходят

Поднимем всё обратно, третья нода станет лидером

```
# docker start etcd1
etcd1
root@dvtest-dbc001lk:~/dcs/etcd# docker exec -it etcd3 bash
@etcd3:/opt/bitnami/etcd$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
{"level":"warn","ts":"2024-11-26T18:58:52.086367Z","logger":"etcd-client","caller":"v3@v3.5.17/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0004f6000/etcd1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing: dial tcp: lookup etcd2 on 127.0.0.11:53: server misbehaving\""}
Failed to get the status of endpoint http://etcd2:2379 (context deadline exceeded)
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |     false |      false |         6 |         18 |                 18 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |      true |      false |         6 |         18 |                 18 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
@etcd3:/opt/bitnami/etcd$
exit
root@dvtest-dbc001lk:~/dcs/etcd# docker start etcd2
etcd2
root@dvtest-dbc001lk:~/dcs/etcd# docker exec -it etcd3 bash
@etcd3:/opt/bitnami/etcd$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |     false |      false |         6 |         21 |                 21 |        |
| http://etcd2:2379 | d282ac2ce600c1ce |  3.5.17 |   20 kB |     false |      false |         6 |         21 |                 21 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |      true |      false |         6 |         21 |                 21 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

```
