Поднимем с помощью docker compose шардированный кластер следующей топологии:

```yaml
version: "3.9"

services:
# Config Server
  mongo-configsvr-1:
    image: mongo:8
    container_name: mongo-configsvr-1
    hostname: mongo-configsvr-1
    command: ["--configsvr", "--replSet", "config-replica-set", "--bind_ip_all", "--port", "40001"]
    ports:
      - 40001:40001

  mongo-configsvr-2:
    image: mongo:8
    container_name: mongo-configsvr-2
    hostname: mongo-configsvr-2
    command: ["--configsvr", "--replSet", "config-replica-set", "--bind_ip_all", "--port", "40002"]
    ports:
      - 40002:40002

  mongo-configsvr-3:
    image: mongo:8
    container_name: mongo-configsvr-3
    hostname: mongo-configsvr-3
    command: ["--configsvr", "--replSet", "config-replica-set", "--bind_ip_all", "--port", "40003"]
    ports:
      - 40003:40003
# shard 1
  mongo-shard-1-rs-1:
    image: mongo:8
    container_name: mongo-shard-1-rs-1
    hostname: mongo-shard-1-rs-1
    command: ["--shardsvr", "--replSet", "shard-replica-set-1", "--bind_ip_all", "--port", "40011"]
    ports:
      - 40011:40011

  mongo-shard-1-rs-2:
    image: mongo:8
    container_name: mongo-shard-1-rs-2
    hostname: mongo-shard-1-rs-2
    command: ["--shardsvr", "--replSet", "shard-replica-set-1", "--bind_ip_all", "--port", "40012"]
    ports:
      - 40012:40012

  mongo-shard-1-rs-3:
    image: mongo:8
    container_name: mongo-shard-1-rs-3
    hostname: mongo-shard-1-rs-3
    command: ["--shardsvr", "--replSet", "shard-replica-set-1", "--bind_ip_all", "--port", "40013"]
    ports:
      - 40013:40013
#shard 2
  mongo-shard-2-rs-1:
    image: mongo:8
    container_name: mongo-shard-2-rs-1
    hostname: mongo-shard-2-rs-1
    command: ["--shardsvr", "--replSet", "shard-replica-set-2", "--bind_ip_all", "--port", "40021"]
    ports:
      - 40021:40021

  mongo-shard-2-rs-2:
    image: mongo:8
    container_name: mongo-shard-2-rs-2
    hostname: mongo-shard-2-rs-2
    command: ["--shardsvr", "--replSet", "shard-replica-set-2", "--bind_ip_all", "--port", "40022"]
    ports:
      - 40022:40022

  mongo-shard-2-rs-3:
    image: mongo:8
    container_name: mongo-shard-2-rs-3
    hostname: mongo-shard-2-rs-3
    command: ["--shardsvr", "--replSet", "shard-replica-set-2", "--bind_ip_all", "--port", "40023"]
    ports:
      - 40023:40023
# shard 3
  mongo-shard-3-rs-1:
    image: mongo:8
    container_name: mongo-shard-3-rs-1
    hostname: mongo-shard-3-rs-1
    command: ["--shardsvr", "--replSet", "shard-replica-set-3", "--bind_ip_all", "--port", "40031"]
    ports:
      - 40031:40031

  mongo-shard-3-rs-2:
    image: mongo:8
    container_name: mongo-shard-3-rs-2
    hostname: mongo-shard-3-rs-2
    command: ["--shardsvr", "--replSet", "shard-replica-set-3", "--bind_ip_all", "--port", "40032"]
    ports:
      - 40032:40032

  mongo-shard-3-rs-3:
    image: mongo:8
    container_name: mongo-shard-3-rs-3
    hostname: mongo-shard-3-rs-3
    command: ["--shardsvr", "--replSet", "shard-replica-set-3", "--bind_ip_all", "--port", "40033"]
    ports:
      - 40033:40033
# mongos
  mongos-shard:
    image: mongo:8
    container_name: mongos-shard
    hostname: mongos-shard
    command: mongos --configdb config-replica-set/mongo-configsvr-1:40001,mongo-configsvr-2:40002,mongo-configsvr-3:40003 --bind_ip_all
    ports:
      - "40100:27017"
```
Запуск 

```
docker compose -f ./docker-compose.shard.yml up -d

# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS                   PORTS                                                      NAMES
b2b52ad9e746   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40031->40031/tcp, :::40031->40031/tcp   mongo-shard-3-rs-1
cb05261dd81c   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 7 seconds             27017/tcp, 0.0.0.0:40002->40002/tcp, :::40002->40002/tcp   mongo-configsvr-2
30c94d334751   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 7 seconds             27017/tcp, 0.0.0.0:40012->40012/tcp, :::40012->40012/tcp   mongo-shard-1-rs-2
76ed9afb3e77   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40022->40022/tcp, :::40022->40022/tcp   mongo-shard-2-rs-2
f3ec5ab1ef0d   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40003->40003/tcp, :::40003->40003/tcp   mongo-configsvr-3
b86cd48c9553   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40032->40032/tcp, :::40032->40032/tcp   mongo-shard-3-rs-2
f2a8253e8802   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40011->40011/tcp, :::40011->40011/tcp   mongo-shard-1-rs-1
35dd09c063b7   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 7 seconds             27017/tcp, 0.0.0.0:40023->40023/tcp, :::40023->40023/tcp   mongo-shard-2-rs-3
6d3b17623bd9   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 7 seconds             27017/tcp, 0.0.0.0:40021->40021/tcp, :::40021->40021/tcp   mongo-shard-2-rs-1
9bcb72edd751   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40013->40013/tcp, :::40013->40013/tcp   mongo-shard-1-rs-3
a50ea539d924   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             0.0.0.0:40100->27017/tcp, [::]:40100->27017/tcp            mongos-shard
7d8593e14bae   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40001->40001/tcp, :::40001->40001/tcp   mongo-configsvr-1
62d58152830d   mongo:8   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds             27017/tcp, 0.0.0.0:40033->40033/tcp, :::40033->40033/tcp   mongo-shard-3-rs-3
```