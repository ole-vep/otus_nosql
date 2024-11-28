DCS

#### ETCD
Развернем кластер etcd следующей топологии, описанной в yaml-файле:

```yaml
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

Зайдём в любой контейнер, посмотрим удалось ли создать кластер, все ли члены кластера нашлись

```sh
# docker exec -ti etcd3 bash

$ etcdctl member list
ade526d28b1f92f7, started, etcd1, http://etcd1:2380, http://etcd1:2379, false
bd388e7810915853, started, etcd3, http://etcd3:2380, http://etcd3:2379, false
d282ac2ce600c1ce, started, etcd2, http://etcd2:2380, http://etcd2:2379, false

# Используется API v3
$ ETCDCTL_API=3 etcdctl endpoint status
127.0.0.1:2379, bd388e7810915853, 3.5.17, 20 kB, false, false, 3, 12, 12,
# не очень удобное представление

# с перечислением енд-поинтов и в виде таблички удобнее
$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |     false |      false |         3 |         12 |                 12 |        |
| http://etcd2:2379 | d282ac2ce600c1ce |  3.5.17 |   20 kB |      true |      false |         3 |         12 |                 12 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |     false |      false |         3 |         12 |                 12 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

# посмотрим, живы ли узлы
$ etcdctl --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint health
http://etcd3:2379 is healthy: successfully committed proposal: took = 4.357796ms
http://etcd2:2379 is healthy: successfully committed proposal: took = 4.299359ms
http://etcd1:2379 is healthy: successfully committed proposal: took = 3.848866ms
```
Как видно лидером является вторая нода, кластер функционирует, отключим второй узел 

```sh
# docker stop etcd2
# docker exec -ti etcd1 bash

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
Выключим нового лидера 

```sh
# docker stop etcd1
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
# docker exec -it etcd3 bash
@etcd3:/opt/bitnami/etcd$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
{"level":"warn","ts":"2024-11-26T18:58:52.086367Z","logger":"etcd-client","caller":"v3@v3.5.17/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0004f6000/etcd1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing: dial tcp: lookup etcd2 on 127.0.0.11:53: server misbehaving\""}
Failed to get the status of endpoint http://etcd2:2379 (context deadline exceeded)
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |     false |      false |         6 |         18 |                 18 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |      true |      false |         6 |         18 |                 18 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
exit

# docker start etcd2
# docker exec -it etcd3 bash
@etcd3:/opt/bitnami/etcd$ etcdctl --write-out=table --endpoints=http://etcd1:2379,http://etcd2:2379,http://etcd3:2379 endpoint status
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://etcd1:2379 | ade526d28b1f92f7 |  3.5.17 |   20 kB |     false |      false |         6 |         21 |                 21 |        |
| http://etcd2:2379 | d282ac2ce600c1ce |  3.5.17 |   20 kB |     false |      false |         6 |         21 |                 21 |        |
| http://etcd3:2379 | bd388e7810915853 |  3.5.17 |   20 kB |      true |      false |         6 |         21 |                 21 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

#### Consul
Запускаем в контейнере, образ скачивается последний, так как не указали тэг, в детач режиме, порты проброшены, имя cons-serv, нода server-1
```sh
#docker run -d -p 8500:8500 -p 8600:8600/udp --name=cons-serv hashicorp/consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
Unable to find image 'hashicorp/consul:latest' locally
latest: Pulling from hashicorp/consul
5bafb31cae1b: Pull complete
6da9b68c8106: Pull complete
e43f206c86b8: Pull complete
b0faedef9ffa: Pull complete
a77c018aa078: Pull complete
613ded3f7b83: Pull complete
bd9ddc54bea9: Pull complete
a7297f4b08c3: Pull complete
Digest: sha256:884b855d051dea677c8f3d3191bab5f079f02595f3f6a04e4c47ac3b84b3e12b
Status: Downloaded newer image for hashicorp/consul:latest
838b88f951238ed3d44d6d2fc2944573e372e78008799bcbecba05c77c94024a
```
по умолчанию получил такой IP адрес
```
docker inspect cons-serv | grep IPAddress
            "IPAddress": "172.17.0.2"
```
Посмотрим состояние кластера
```sh
#docker exec cons-serv consul members
Node      Address          Status  Type    Build   Protocol  DC   Partition  Segment
server-1  172.17.0.2:8301  alive   server  1.20.1  2         dc1  default    <all>
```

Логи на сервере, выбран новый лидер server-1
```
2024-11-28T12:37:24.988Z [INFO]  agent: Starting server: address=[::]:8500 network=tcp protocol=http
2024-11-28T12:37:24.988Z [INFO]  agent: Started gRPC listeners: port_name=grpc_tls address=[::]:8503 network=tcp
2024-11-28T12:37:24.988Z [INFO]  agent: started state syncer
2024-11-28T12:37:24.988Z [INFO]  agent: Consul agent running!
2024-11-28T12:37:33.248Z [WARN]  agent.server.raft: heartbeat timeout reached, starting election: last-leader-addr= last-leader-id=
2024-11-28T12:37:33.248Z [INFO]  agent.server.raft: entering candidate state: node="Node at 172.17.0.2:8300 [Candidate]" term=2
2024-11-28T12:37:33.253Z [INFO]  agent.server.raft: election won: term=2 tally=1
2024-11-28T12:37:33.253Z [INFO]  agent.server.raft: entering leader state: leader="Node at 172.17.0.2:8300 [Leader]"
2024-11-28T12:37:33.253Z [INFO]  agent.server: cluster leadership acquired
2024-11-28T12:37:33.253Z [INFO]  agent.server: New leader elected: payload=server-1
```

Запускаем ноду клиента client-1 указывая ip-адрес сервера, чтобы она засинкалась с лидером, это видно по логам в конце
```sh
docker run --name=cons-client hashicorp/consul agent -node=client-1 -retry-join=172.17.0.2

==> Starting Consul agent...
               Version: '1.20.1'
            Build Date: '2024-10-29 19:04:05 +0000 UTC'
               Node ID: '5ae1bdf4-eb46-4c36-18f9-8e6665ddf0cb'
             Node name: 'client-1'
            Datacenter: 'dc1' (Segment: '')
                Server: false (Bootstrap: false)
           Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, gRPC: -1, gRPC-TLS: -1, DNS: 8600)
          Cluster Addr: 172.17.0.3 (LAN: 8301, WAN: 8302)
     Gossip Encryption: false
      Auto-Encrypt-TLS: false
           ACL Enabled: false
    ACL Default Policy: allow
             HTTPS TLS: Verify Incoming: false, Verify Outgoing: false, Min Version: TLSv1_2
              gRPC TLS: Verify Incoming: false, Min Version: TLSv1_2
      Internal RPC TLS: Verify Incoming: false, Verify Outgoing: false (Verify Hostname: false), Min Version: TLSv1_2

==> Log data will now stream in as it occurs:

2024-11-28T12:46:00.463Z [INFO]  agent.client.serf.lan: serf: EventMemberJoin: client-1 172.17.0.3
2024-11-28T12:46:00.464Z [INFO]  agent.router: Initializing LAN area manager
2024-11-28T12:46:00.464Z [INFO]  agent: Started DNS server: address=127.0.0.1:8600 network=udp
2024-11-28T12:46:00.464Z [INFO]  agent: Started DNS server: address=127.0.0.1:8600 network=tcp
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/album
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v2/festival
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/namespaceexportedservices
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/executive
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/recordlabel
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/artist
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/concept
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v2/artist
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v2/album
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/internal/v1/tombstone
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/partitionexportedservices
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/computedexportedservices
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/hcp/v2/telemetrystate
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/exportedservices
2024-11-28T12:46:00.466Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/hcp/v2/link
2024-11-28T12:46:00.466Z [INFO]  agent: Starting server: address=127.0.0.1:8500 network=tcp protocol=http
2024-11-28T12:46:00.467Z [INFO]  agent: started state syncer
2024-11-28T12:46:00.467Z [INFO]  agent: Consul agent running!
2024-11-28T12:46:00.467Z [INFO]  agent: Retry join is supported for the following discovery methods: cluster=LAN discovery_methods="aliyun aws azure digitalocean gce hcp k8s linode mdns os packet scaleway softlayer tencentcloud triton vsphere"
2024-11-28T12:46:00.467Z [INFO]  agent: Joining cluster...: cluster=LAN
2024-11-28T12:46:00.467Z [INFO]  agent: (LAN) joining: lan_addresses=["172.17.0.2"]
2024-11-28T12:46:00.467Z [WARN]  agent.router.manager: No servers available
2024-11-28T12:46:00.469Z [INFO]  agent.client.serf.lan: serf: EventMemberJoin: server-1 172.17.0.2
2024-11-28T12:46:00.469Z [INFO]  agent: (LAN) joined: number_of_nodes=1
2024-11-28T12:46:00.469Z [INFO]  agent: Join cluster completed. Synced with initial agents: cluster=LAN num_agents=1
2024-11-28T12:46:00.469Z [INFO]  agent.client: adding server: server="server-1 (Addr: tcp/172.17.0.2:8300) (DC: dc1)"
2024-11-28T12:46:02.433Z [INFO]  agent: Synced node info
```
также в логах сервера в этот момент аналогично прошел джоин в кластер
```
2024-11-28T12:46:00.468Z [INFO]  agent.server.serf.lan: serf: EventMemberJoin: client-1 172.17.0.3
2024-11-28T12:46:00.469Z [INFO]  agent.server: member joined, marking health alive: member=client-1 partition=default
2024-11-28T12:46:33.275Z [INFO]  agent.server.raft.logstore.verifier: verification checksum OK: elapsed="181.384µs" leaderChecksum=872851ab92cca80c rangeEnd=63 rangeStart=56 readChecksum=872851ab92cca80c
```

Оба контейнера работают
```
#docker ps
CONTAINER ID   IMAGE              COMMAND                  CREATED          STATUS          PORTS                                                                                                                          NAMES
678cc08d09fe   hashicorp/consul   "docker-entrypoint.s…"   25 minutes ago   Up 25 minutes   8300-8302/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp                                                                     cons-client
838b88f95123   hashicorp/consul   "docker-entrypoint.s…"   34 minutes ago   Up 34 minutes   8300-8302/tcp, 8600/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, :::8500->8500/tcp, 0.0.0.0:8600->8600/udp, :::8600->8600/udp   cons-serv
```
Посмотрим статус членов кластера
```sh
#docker exec cons-serv consul members
Node      Address          Status  Type    Build   Protocol  DC   Partition  Segment
server-1  172.17.0.2:8301  alive   server  1.20.1  2         dc1  default    <all>
client-1  172.17.0.3:8301  alive   client  1.20.1  2         dc1  default    <default>
```

На UI по порту 8500 такая картина на вкладке обзор
![Alt text](overview.png?raw=true "overview")

У нас один пока сервис, сам консул, который находится на ноде server-1
![Alt text](cons_services.png?raw=true "cons_services")

Если провалиться в него

![Alt text](consul.png?raw=true "consul")


Посмотреть его health-чек
![Alt text](consul_health.png?raw=true "consul_health")

Всего две ноды, на клиенте пока нет сервисов

![Alt text](cons_nodes.png?raw=true "cons_nodes")


Поднимем простенький тестовый сервис-счётчик посещений страницы на 9001 порту
```sh
# docker pull hashicorp/counting-service:0.0.2
0.0.2: Pulling from hashicorp/counting-service
c67f3896b22c: Pull complete
3d19f41a0302: Pull complete
99ac07894780: Pull complete
Digest: sha256:ba4ec6f77f4cdbf6abbc1259ae8d9616155e54625e814e6da949bce82adb00e9
Status: Downloaded newer image for hashicorp/counting-service:0.0.2
docker.io/hashicorp/counting-service:0.0.2

#docker run -p 9001:9001 -d --name=counting hashicorp/counting-service:0.0.2
```

Зарегистрируем его в консуле
```sh
#docker exec cons-client /bin/sh -c "echo '{\"service\": {\"name\": \"counting\", \"tags\": [\"go\"], \"port\": 9001}}' >> /consul/config/counting.json"

#docker exec cons-client consul reload
Configuration reload triggered

#в логах клиента
2024-11-28T13:14:10.414Z [INFO]  agent: Synced service: service=counting
```

Посмотрим что он отображает на  http://localhost:9001
```
{"count":3,"hostname":"ac3daae99cd0"}
```

Поднимем аналогично еще один клиент cons-client2 на ноде client-2
```
#docker run --name=cons-client2 hashicorp/consul agent -node=client-2 -retry-join=172.17.0.2
==> Starting Consul agent...
               Version: '1.20.1'
            Build Date: '2024-10-29 19:04:05 +0000 UTC'
               Node ID: 'b251f339-23e7-a5d4-7abc-6f2aeae0c1c3'
             Node name: 'client-2'
            Datacenter: 'dc1' (Segment: '')
                Server: false (Bootstrap: false)
           Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, gRPC: -1, gRPC-TLS: -1, DNS: 8600)
          Cluster Addr: 172.17.0.4 (LAN: 8301, WAN: 8302)
     Gossip Encryption: false
      Auto-Encrypt-TLS: false
           ACL Enabled: false
    ACL Default Policy: allow
             HTTPS TLS: Verify Incoming: false, Verify Outgoing: false, Min Version: TLSv1_2
              gRPC TLS: Verify Incoming: false, Min Version: TLSv1_2
      Internal RPC TLS: Verify Incoming: false, Verify Outgoing: false (Verify Hostname: false), Min Version: TLSv1_2

==> Log data will now stream in as it occurs:

2024-11-28T13:35:35.878Z [INFO]  agent.client.serf.lan: serf: EventMemberJoin: client-2 172.17.0.4
2024-11-28T13:35:35.879Z [INFO]  agent.router: Initializing LAN area manager
2024-11-28T13:35:35.879Z [INFO]  agent: Started DNS server: address=127.0.0.1:8600 network=tcp
2024-11-28T13:35:35.879Z [INFO]  agent: Started DNS server: address=127.0.0.1:8600 network=udp
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v2/artist
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/computedexportedservices
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/album
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v2/festival
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/partitionexportedservices
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v2/album
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/executive
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/recordlabel
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/artist
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/demo/v1/concept
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/hcp/v2/link
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/internal/v1/tombstone
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/namespaceexportedservices
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/hcp/v2/telemetrystate
2024-11-28T13:35:35.880Z [INFO]  agent.http: Registered resource endpoint: endpoint=/api/multicluster/v2/exportedservices
2024-11-28T13:35:35.880Z [INFO]  agent: Starting server: address=127.0.0.1:8500 network=tcp protocol=http
2024-11-28T13:35:35.880Z [INFO]  agent: started state syncer
2024-11-28T13:35:35.880Z [INFO]  agent: Consul agent running!
2024-11-28T13:35:35.881Z [WARN]  agent.router.manager: No servers available
2024-11-28T13:35:35.885Z [INFO]  agent: Retry join is supported for the following discovery methods: cluster=LAN discovery_methods="aliyun aws azure digitalocean gce hcp k8s linode mdns os packet scaleway softlayer tencentcloud triton vsphere"
2024-11-28T13:35:35.885Z [INFO]  agent: Joining cluster...: cluster=LAN
2024-11-28T13:35:35.885Z [INFO]  agent: (LAN) joining: lan_addresses=["172.17.0.2"]
2024-11-28T13:35:35.887Z [INFO]  agent.client.serf.lan: serf: EventMemberJoin: client-1 172.17.0.3
2024-11-28T13:35:35.887Z [INFO]  agent.client.serf.lan: serf: EventMemberJoin: server-1 172.17.0.2
2024-11-28T13:35:35.887Z [INFO]  agent: (LAN) joined: number_of_nodes=1
2024-11-28T13:35:35.887Z [INFO]  agent: Join cluster completed. Synced with initial agents: cluster=LAN num_agents=1
2024-11-28T13:35:35.887Z [INFO]  agent.client: adding server: server="server-1 (Addr: tcp/172.17.0.2:8300) (DC: dc1)"
2024-11-28T13:35:37.387Z [INFO]  agent: Synced node info
```
Запущенные контейнеры теперь так:
```
# docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED              STATUS              PORTS                                                                                                                          NAMES
ac3daae99cd0   hashicorp/counting-service:0.0.2   "./counting-service"     About a minute ago   Up About a minute   0.0.0.0:9001->9001/tcp, :::9001->9001/tcp                                                                                      counting
b844c9e1bc33   hashicorp/consul                   "docker-entrypoint.s…"   About a minute ago   Up About a minute   8300-8302/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp                                                                     cons-client2
678cc08d09fe   hashicorp/consul                   "docker-entrypoint.s…"   51 minutes ago       Up 8 minutes        8300-8302/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp                                                                     cons-client
838b88f95123   hashicorp/consul                   "docker-entrypoint.s…"   59 minutes ago       Up 59 minutes       8300-8302/tcp, 8600/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, :::8500->8500/tcp, 0.0.0.0:8600->8600/udp, :::8600->8600/udp   cons-serv
```
Посмотрим статус членов кластера консула
```sh
#docker exec cons-serv consul members
Node      Address          Status  Type    Build   Protocol  DC   Partition  Segment
server-1  172.17.0.2:8301  alive   server  1.20.1  2         dc1  default    <all>
client-1  172.17.0.3:8301  alive   client  1.20.1  2         dc1  default    <default>
client-2  172.17.0.4:8301  alive   client  1.20.1  2         dc1  default    <default>
```
и аналогично тоже зарегистрируем сервис-счетчик на втором клиенте
```sh
#docker exec cons-client2 /bin/sh -c "echo '{\"service\": {\"name\": \"counting\", \"tags\": [\"go\"], \"port\": 9001}}' >> /consul/config/counting.json"

#docker exec cons-client2 consul reload
Configuration reload triggered
```

Запишем какие-нибудь тестовые значения в key-value хранилище через второй клиент
```sh
#docker exec cons-client2 consul kv put test/kv test_1
Success! Data written to: test/kv
```

Прочитаем на первом
```sh
#docker exec cons-client consul kv get test/kv
test_1
```

Теперь наоборот положим значение в kv на первом клиенте
```sh
#docker exec cons-client consul kv put service/config/counting 2
Success! Data written to: service/config/counting
```

Остановим первый клиент
```sh
#docker stop cons-client
#на сервере в логах
2024-11-28T13:55:58.349Z [INFO]  agent.server.serf.lan: serf: EventMemberLeave: client-1 172.17.0.3
2024-11-28T13:55:58.349Z [INFO]  agent.server: deregistering member: member=client-1 partition=default reason=left
```

Прочитаем на втором, значение никуда не пропало
```sh
#docker exec cons-client2 consul kv get service/config/counting
2
```

также не пропала регистрация сервиса, она осталась только на втором клиенте, сервис тоже работает 
![Alt text](counting_only2.png?raw=true "counting_only2")

![Alt text](counting_only2_.png?raw=true "counting_only2_")

![Alt text](counting9001.png?raw=true "counting9001")

Значения можно также посмотреть и на UI, провалившись в соответствующие папочки, так как сами создали структуру ключей запросами выше

![Alt text](key_value.png?raw=true "key_value")

![Alt text](kv_2.png?raw=true "kv_2")

![Alt text](kv_test.png?raw=true "kv_test")

cтартанем обратно, джойнится обратно без проблем

```sh
#docker start cons-client

2024-11-28T14:00:08.306Z [INFO]  agent.server.serf.lan: serf: EventMemberJoin: client-1 172.17.0.3
2024-11-28T14:00:08.306Z [INFO]  agent.server: member joined, marking health alive: member=client-1 partition=default

#docker exec cons-serv consul members
Node      Address          Status  Type    Build   Protocol  DC   Partition  Segment
server-1  172.17.0.2:8301  alive   server  1.20.1  2         dc1  default    <all>
client-1  172.17.0.3:8301  alive   client  1.20.1  2         dc1  default    <default>
client-2  172.17.0.4:8301  alive   client  1.20.1  2         dc1  default    <default>
```