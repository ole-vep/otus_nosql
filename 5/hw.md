
Опишем топологию поднимаемого кластера в yml:

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
после старта выглядит пока вот так:

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