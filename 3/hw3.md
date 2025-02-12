MongoDB 2

#### Шардированный кластер
Поднимем с помощью docker compose шардированный кластер следующей топологии:
* кластер конфига - 3 инстанса
* три шарда также по 3 инстанса с репликацией
* mongo сервер (mongos)

![Alt text](shards.png?raw=true "Shards cluster")

docker-compose.yml :
```yaml
version: "3.9"

services:
# config server
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
docker compose -f ./docker-compose.yml up -d

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
Прольём везде конфиги репликации
```bash
#mongosh --port 40001
rs.initiate({
"_id": "config-replica-set",
members : [
{"_id": 0, "host": "mongo-configsvr-1:40001"},
{"_id": 1, "host": "mongo-configsvr-2:40002"},
{"_id": 2, "host": "mongo-configsvr-3:40003" }
]
});

#mongosh --port 40011
rs.initiate({
"_id" : "shard-replica-set-1",
members : [
{"_id" : 0, host : "mongo-shard-1-rs-1:40011"},
{"_id" : 1, host : "mongo-shard-1-rs-2:40012"},
{"_id" : 2, host : "mongo-shard-1-rs-3:40013" }
]
});

#mongosh --port 40021
rs.initiate({
"_id" : "shard-replica-set-2",
members : [
{"_id" : 0, host : "mongo-shard-2-rs-1:40021"},
{"_id" : 1, host : "mongo-shard-2-rs-2:40022"},
{"_id" : 2, host : "mongo-shard-2-rs-3:40023" }
]
});

#mongosh --port 40031
rs.initiate({
"_id" : "shard-replica-set-3",
members : [
{"_id" : 0, host : "mongo-shard-3-rs-1:40031"},
{"_id" : 1, host : "mongo-shard-3-rs-2:40032"},
{"_id" : 2, host : "mongo-shard-3-rs-3:40033" }
]
});
```
Заходим на mongos, добавляем шарды, посмотрим статус шардирования
```bash
#mongosh --port 40100
> sh.addShard("shard-replica-set-1/mongo-shard-1-rs-1:40011,mongo-shard-1-rs-2:40012,mongo-shard-1-rs-3:40013")
> sh.addShard("shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023")
> sh.addShard("shard-replica-set-3/mongo-shard-3-rs-1:40031,mongo-shard-3-rs-2:40032,mongo-shard-3-rs-3:40033")

[direct: mongos] test> sh.status()
shardingVersion
{ _id: 1, clusterId: ObjectId('67264c095e50d8230b41ca1c') }
---
shards
[
  {
    _id: 'shard-replica-set-1',
    host: 'shard-replica-set-1/mongo-shard-1-rs-1:40011,mongo-shard-1-rs-2:40012,mongo-shard-1-rs-3:40013',
    state: 1,
    topologyTime: Timestamp({ t: 1730563790, i: 10 }),
    replSetConfigVersion: Long('-1')
  },
  {
    _id: 'shard-replica-set-2',
    host: 'shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023',
    state: 1,
    topologyTime: Timestamp({ t: 1730563805, i: 9 }),
    replSetConfigVersion: Long('-1')
  },
  {
    _id: 'shard-replica-set-3',
    host: 'shard-replica-set-3/mongo-shard-3-rs-1:40031,mongo-shard-3-rs-2:40032,mongo-shard-3-rs-3:40033',
    state: 1,
    topologyTime: Timestamp({ t: 1730563811, i: 9 }),
    replSetConfigVersion: Long('-1')
  }
]
---
active mongoses
[ { '8.0.3': 1 } ]
---
autosplit
{ 'Currently enabled': 'yes' }
---
balancer
{
  'Currently running': 'no',
  'Currently enabled': 'yes',
  'Failed balancer rounds in last 5 attempts': 0,
  'Migration Results for the last 24 hours': 'No recent migrations'
}
---
shardedDataDistribution
[]
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {}
  }
]
```

#### Наполнение данными, перебалансировка

Воспользуемся имеющейся коллекцией в ранее поднятом инстансе монго,
там датасеты были взяты [отсюда](https://github.com/ozlerhakan/mongodb-json-files)
и заодно посмотрим утилиты дампа и рестор для баз данных в монго
```bash
mongodump --port 27017 --db samples
# При этом создалась директория dump/samples, восстановимся из неё
mongorestore --port 40100 --verbose dump
```
Посмотрим как восстановилась база и создадим индекс в коллекции компаний по полю год основания
```javascript
# mongosh --port 40100
Current Mongosh Log ID: 6728eff0df62858714c1c18b
Connecting to:          mongodb://127.0.0.1:40100/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.3
Using MongoDB:          8.0.3
Using Mongosh:          2.3.3

For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/

------
   The server generated these startup warnings when booting
   2024-11-02T15:46:53.625+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
------

[direct: mongos] test> show dbs
admin    112.00 KiB
config     3.50 MiB
samples   73.36 MiB
[direct: mongos] test> use samples
switched to db samples
[direct: mongos] samples> show collections
city_inspections
companies
countries-big
countries-small
products
profiles
restaurants
zips

samples> db.companies.createIndex({ founded_year: 1})
founded_year_1

samples> db.companies.getIndexes()
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  { v: 2, key: { founded_year: 1 }, name: 'founded_year_1' }
]
```

Создадим шард, посмотрим как первоначально легли данные (всё на втором шарде)
```javascript
use admin
db.runCommand({shardCollection: "samples.companies", key: {founded_year: 1}})
[direct: mongos] admin> db.runCommand({shardCollection: "samples.companies", key: {founded_year: 1}})
{
  collectionsharded: 'samples.companies',
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1730571444, i: 38 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1730571444, i: 37 })
}



[direct: mongos] admin> use samples
switched to db samples
[direct: mongos] samples> db.companies.getShardDistribution()
Shard shard-replica-set-2 at shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023
{
  data: '57.06MiB',
  docs: 13136,
  chunks: 1,
  'estimated data per chunk': '57.06MiB',
  'estimated docs per chunk': 13136
}
---
Totals
{
  data: '57.06MiB',
  docs: 13136,
  chunks: 1,
  'Shard shard-replica-set-2': [
    '100 % data',
    '100 % docs in cluster',
    '4KiB avg obj size on shard'
  ]
}
```

Изменим размер чанка и посмотрим как прошла перебалансировка
```javascript
[direct: mongos] samples> use config
switched to db config

[direct: mongos] config> db.settings.updateOne(
... { _id: "chunksize" },
... { $set: { _id: "chunksize", value: 1 } },
... { upsert: true }
... )
{
  acknowledged: true,
  insertedId: 'chunksize',
  matchedCount: 0,
  modifiedCount: 0,
  upsertedCount: 1
}

[direct: mongos] config> use samples
switched to db samples

[direct: mongos] samples> db.companies.getShardDistribution()
Shard shard-replica-set-1 at shard-replica-set-1/mongo-shard-1-rs-1:40011,mongo-shard-1-rs-2:40012,mongo-shard-1-rs-3:40013
{
  data: '7MiB',
  docs: 1204,
  chunks: 6,
  'estimated data per chunk': '1.16MiB',
  'estimated docs per chunk': 200
}
---
Shard shard-replica-set-2 at shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023
{
  data: '46.34MiB',
  docs: 13136,
  chunks: 10,
  'estimated data per chunk': '4.63MiB',
  'estimated docs per chunk': 1313
}
---
Shard shard-replica-set-3 at shard-replica-set-3/mongo-shard-3-rs-1:40031,mongo-shard-3-rs-2:40032,mongo-shard-3-rs-3:40033
{
  data: '6.79MiB',
  docs: 1263,
  chunks: 5,
  'estimated data per chunk': '1.35MiB',
  'estimated docs per chunk': 252
}
---
Totals
{
  data: '60.14MiB',
  docs: 15603,
  chunks: 21,
  'Shard shard-replica-set-1': [
    '11.64 % data',
    '7.71 % docs in cluster',
    '5KiB avg obj size on shard'
  ],
  'Shard shard-replica-set-2': [
    '77.05 % data',
    '84.18 % docs in cluster',
    '4KiB avg obj size on shard'
  ],
  'Shard shard-replica-set-3': [
    '11.29 % data',
    '8.09 % docs in cluster',
    '5KiB avg obj size on shard'
  ]
}
```
Много данных все равно осталось на втором шарде
посмотрим еще раз статус шардирования
```javascript
[direct: mongos] samples> sh.status()
shardingVersion
{ _id: 1, clusterId: ObjectId('67264c095e50d8230b41ca1c') }
---
shards
[
  {
    _id: 'shard-replica-set-1',
    host: 'shard-replica-set-1/mongo-shard-1-rs-1:40011,mongo-shard-1-rs-2:40012,mongo-shard-1-rs-3:40013',
    state: 1,
    topologyTime: Timestamp({ t: 1730563790, i: 10 }),
    replSetConfigVersion: Long('1')
  },
  {
    _id: 'shard-replica-set-2',
    host: 'shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023',
    state: 1,
    topologyTime: Timestamp({ t: 1730563805, i: 9 }),
    replSetConfigVersion: Long('1')
  },
  {
    _id: 'shard-replica-set-3',
    host: 'shard-replica-set-3/mongo-shard-3-rs-1:40031,mongo-shard-3-rs-2:40032,mongo-shard-3-rs-3:40033',
    state: 1,
    topologyTime: Timestamp({ t: 1730563811, i: 9 }),
    replSetConfigVersion: Long('1')
  }
]
---
active mongoses
[ { '8.0.3': 1 } ]
---
autosplit
{ 'Currently enabled': 'yes' }
---
balancer
{
  'Currently enabled': 'yes',
  'Currently running': 'no',
  'Failed balancer rounds in last 5 attempts': 0,
  'Migration Results for the last 24 hours': {
    '6': "Failed with error 'aborted', from shard-replica-set-2 to shard-replica-set-3",
    '11': 'Success',
    '14': "Failed with error 'aborted', from shard-replica-set-2 to shard-replica-set-1"
  }
}
---
shardedDataDistribution
[
  {
    ns: 'config.system.sessions',
    shards: [
      {
        shardName: 'shard-replica-set-1',
        numOrphanedDocs: 0,
        numOwnedDocuments: 16,
        ownedSizeBytes: 1584,
        orphanedSizeBytes: 0
      }
    ]
  },
  {
    ns: 'samples.companies',
    shards: [
      {
        shardName: 'shard-replica-set-1',
        numOrphanedDocs: 0,
        numOwnedDocuments: 1204,
        ownedSizeBytes: 7344400,
        orphanedSizeBytes: 0
      },
      {
        shardName: 'shard-replica-set-3',
        numOrphanedDocs: 0,
        numOwnedDocuments: 1263,
        ownedSizeBytes: 7125846,
        orphanedSizeBytes: 0
      },
      {
        shardName: 'shard-replica-set-2',
        numOrphanedDocs: 2467,
        numOwnedDocuments: 10669,
        ownedSizeBytes: 48597295,
        orphanedSizeBytes: 11237185
      }
    ]
  }
]
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {
      'config.system.sessions': {
        shardKey: { _id: 1 },
        unique: false,
        balancing: true,
        chunkMetadata: [ { shard: 'shard-replica-set-1', nChunks: 1 } ],
        chunks: [
          { min: { _id: MinKey() }, max: { _id: MaxKey() }, 'on shard': 'shard-replica-set-1', 'last modified': Timestamp({ t: 1, i: 0 }) }
        ],
        tags: []
      }
    }
  },
  {
    database: {
      _id: 'samples',
      primary: 'shard-replica-set-2',
      version: {
        uuid: UUID('89b9619f-b7de-461b-88d4-cf28f37b53f5'),
        timestamp: Timestamp({ t: 1730569912, i: 3 }),
        lastMod: 1
      }
    },
    collections: {
      'samples.companies': {
        shardKey: { founded_year: 1 },
        unique: false,
        balancing: true,
        chunkMetadata: [
          { shard: 'shard-replica-set-1', nChunks: 6 },
          { shard: 'shard-replica-set-2', nChunks: 10 },
          { shard: 'shard-replica-set-3', nChunks: 5 }
        ],
        chunks: [
          { min: { founded_year: MinKey() }, max: { founded_year: 1969 }, 'on shard': 'shard-replica-set-3', 'last modified': Timestamp({ t: 2, i: 0 }) },
          { min: { founded_year: 1969 }, max: { founded_year: 1983 }, 'on shard': 'shard-replica-set-1', 'last modified': Timestamp({ t: 3, i: 0 }) },
          { min: { founded_year: 1983 }, max: { founded_year: 1989 }, 'on shard': 'shard-replica-set-1', 'last modified': Timestamp({ t: 4, i: 0 }) },
          { min: { founded_year: 1989 }, max: { founded_year: 1993 }, 'on shard': 'shard-replica-set-3', 'last modified': Timestamp({ t: 5, i: 0 }) },
          { min: { founded_year: 1993 }, max: { founded_year: 1995 }, 'on shard': 'shard-replica-set-3', 'last modified': Timestamp({ t: 6, i: 0 }) },
          { min: { founded_year: 1995 }, max: { founded_year: 1996 }, 'on shard': 'shard-replica-set-1', 'last modified': Timestamp({ t: 7, i: 0 }) },
          { min: { founded_year: 1996 }, max: { founded_year: 1997 }, 'on shard': 'shard-replica-set-3', 'last modified': Timestamp({ t: 8, i: 0 }) },
          { min: { founded_year: 1997 }, max: { founded_year: 1998 }, 'on shard': 'shard-replica-set-1', 'last modified': Timestamp({ t: 9, i: 0 }) },
          { min: { founded_year: 1998 }, max: { founded_year: 1999 }, 'on shard': 'shard-replica-set-1', 'last modified': Timestamp({ t: 10, i: 0 }) },
          { min: { founded_year: 1999 }, max: { founded_year: 2000 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 12, i: 1 }), jumbo: 'yes' },
          { min: { founded_year: 2000 }, max: { founded_year: 2001 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 10, i: 4 }), jumbo: 'yes' },
          { min: { founded_year: 2001 }, max: { founded_year: 2002 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 10, i: 6 }), jumbo: 'yes' },
          { min: { founded_year: 2002 }, max: { founded_year: 2003 }, 'on shard': 'shard-replica-set-3', 'last modified': Timestamp({ t: 11, i: 0 }) },
          { min: { founded_year: 2003 }, max: { founded_year: 2004 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 3 }), jumbo: 'yes' },
          { min: { founded_year: 2004 }, max: { founded_year: 2005 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 5 }), jumbo: 'yes' },
          { min: { founded_year: 2005 }, max: { founded_year: 2006 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 7 }), jumbo: 'yes' },
          { min: { founded_year: 2006 }, max: { founded_year: 2007 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 9 }), jumbo: 'yes' },
          { min: { founded_year: 2007 }, max: { founded_year: 2008 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 11 }), jumbo: 'yes' },
          { min: { founded_year: 2008 }, max: { founded_year: 2009 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 13 }), jumbo: 'yes' },
          { min: { founded_year: 2009 }, max: { founded_year: 2010 }, 'on shard': 'shard-replica-set-2', 'last modified': Timestamp({ t: 11, i: 15 }), jumbo: 'yes' },
          'too many chunks to print, use verbose if you want to force print'
        ],
        tags: []
      }
    }
  }
]
```
Второй шард "весит" больше других, так как скорее всего ему достались самые насыщенные на основание компаний годы, проверим это запросом. 
Действительно все топовые годы легли на второй шард.

```javascript
[direct: mongos] samples> db.companies.aggregate([{"$group" : {_id:{founded_year:"$founded_year"}, count:{$sum:1}}},{$sort : { count : -1 }}]).toArray()
[
  { _id: { founded_year: 2008 }, count: 2475 },
  { _id: { founded_year: 2007 }, count: 2277 },
  { _id: { founded_year: 2006 }, count: 1423 },
  { _id: { founded_year: 2005 }, count: 961 },
  { _id: { founded_year: 2004 }, count: 752 },
  { _id: { founded_year: 2009 }, count: 687 },
  { _id: { founded_year: 2003 }, count: 576 },
  { _id: { founded_year: 1999 }, count: 533 },
  { _id: { founded_year: 2000 }, count: 521 },
  { _id: { founded_year: 2001 }, count: 464 },
  { _id: { founded_year: 2002 }, count: 460 },
  { _id: { founded_year: 1998 }, count: 290 },
  { _id: { founded_year: 1996 }, count: 216 },
  { _id: { founded_year: 1997 }, count: 200 },
  { _id: { founded_year: 1995 }, count: 145 },
  ...
  ```

Через некоторое время дистрибуция немного поменялась
```javascript
[direct: mongos] samples> db.companies.getShardDistribution()
Shard shard-replica-set-1 at shard-replica-set-1/mongo-shard-1-rs-1:40011,mongo-shard-1-rs-2:40012,mongo-shard-1-rs-3:40013
{
  data: '7MiB',
  docs: 1204,
  chunks: 4,
  'estimated data per chunk': '1.75MiB',
  'estimated docs per chunk': 301
}
---
Shard shard-replica-set-3 at shard-replica-set-3/mongo-shard-3-rs-1:40031,mongo-shard-3-rs-2:40032,mongo-shard-3-rs-3:40033
{
  data: '6.79MiB',
  docs: 1263,
  chunks: 4,
  'estimated data per chunk': '1.69MiB',
  'estimated docs per chunk': 315
}
---
Shard shard-replica-set-2 at shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023
{
  data: '43.26MiB',
  docs: 10669,
  chunks: 10,
  'estimated data per chunk': '4.32MiB',
  'estimated docs per chunk': 1066
}
---
Totals
{
  data: '57.06MiB',
  docs: 13136,
  chunks: 18,
  'Shard shard-replica-set-1': [
    '12.27 % data',
    '9.16 % docs in cluster',
    '5KiB avg obj size on shard'
  ],
  'Shard shard-replica-set-3': [
    '11.9 % data',
    '9.61 % docs in cluster',
    '5KiB avg obj size on shard'
  ],
  'Shard shard-replica-set-2': [
    '75.81 % data',
    '81.21 % docs in cluster',
    '4KiB avg obj size on shard'
  ]
}
```
#### Отключение инстансов
Посмотрим текущий статус репликации на втором шарде
```bash
shard-replica-set-2 [direct: primary] test
> rs.status()

      _id: 0,
      name: 'mongo-shard-2-rs-1:40021',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',

      _id: 1,
      name: 'mongo-shard-2-rs-2:40022',
      health: 1,
      state: 1,
      stateStr: 'PRIMARY',

      _id: 2,
      name: 'mongo-shard-2-rs-3:40023',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
```

Отключим второй инстанс
```bash
docker stop mongo-shard-2-rs-2
> rs.status()

      _id: 0,
      name: 'mongo-shard-2-rs-1:40021',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
    
      _id: 1,
      name: 'mongo-shard-2-rs-2:40022',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',
    
      _id: 2,
      name: 'mongo-shard-2-rs-3:40023',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
```

Прошли перевыборы, первый стал ведущим
```bash
> rs.status()
    
      _id: 0,
      name: 'mongo-shard-2-rs-1:40021',
      health: 1,
      state: 1,
      stateStr: 'PRIMARY',
    
      _id: 1,
      name: 'mongo-shard-2-rs-2:40022',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',
    
      _id: 2,
      name: 'mongo-shard-2-rs-3:40023',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
```

Отключим третий инстанс. 
Оставшийся первый некоторое время был лидером и потом в ушел в "secondary" довольно быстро

```bash
docker stop mongo-shard-2-rs-3

> rs.status()

      _id: 0,
      name: 'mongo-shard-2-rs-1:40021',
      health: 1,
      state: 1,
      stateStr: 'PRIMARY',

      _id: 1,
      name: 'mongo-shard-2-rs-2:40022',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',
 
      _id: 2,
      name: 'mongo-shard-2-rs-3:40023',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',



shard-replica-set-2 [direct: secondary] test> rs.status()

  members: [
    {
      _id: 0,
      name: 'mongo-shard-2-rs-1:40021',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',

    {
      _id: 1,
      name: 'mongo-shard-2-rs-2:40022',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',

    {
      _id: 2,
      name: 'mongo-shard-2-rs-3:40023',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',
```

На mongos в этот момент получим такую ошибку, так как нужен primary в репликасете второго шарда 
```
[direct: mongos] samples> db.companies.getShardDistribution()
MongoServerError[FailedToSatisfyReadPreference]: Could not find host matching read preference { mode: "primary" } for set shard-replica-set-2
```

Обратно поднимаем третий, прошли выборы нового мастера
```bash
docker start mongo-shard-2-rs-3

shard-replica-set-2 [direct: primary] test> rs.status()
{

  members: [
    {
      _id: 0,
      name: 'mongo-shard-2-rs-1:40021',
      health: 1,
      state: 1,
      stateStr: 'PRIMARY',

    {
      _id: 1,
      name: 'mongo-shard-2-rs-2:40022',
      health: 0,
      state: 8,
      stateStr: '(not reachable/healthy)',

    {
      _id: 2,
      name: 'mongo-shard-2-rs-3:40023',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
```
Функциональность восстановлена

Если останется только одна нода из репликасета конфигсервера например, то получим аналогичное сообщение
direct: mongos] samples> db.companies.getShardDistribution()
MongoServerError[FailedToSatisfyReadPreference]: Encountered non-retryable error during query :: caused by :: Could not find host matching read preference { mode: "primary" } for set config-replica-set

#### Ролевой доступ

Предварительно создадим юзера с ролью root
```javascript
[direct: mongos] samples> use admin
switched to db admin
[direct: mongos] admin> db.getUsers()
{
  users: [],
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1730748914, i: 2 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1730748914, i: 2 })
}

[direct: mongos] admin> db.createUser({user: "root", pwd: "password", roles: [{ role: "root", db: "admin" }]})
{
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1730748991, i: 4 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1730748991, i: 4 })
}

[direct: mongos] admin> db.getUsers()
{
  users: [
    {
      _id: 'admin.root',
      userId: UUID('0050bc9f-b7fb-4996-93ee-930ac00767f0'),
      user: 'root',
      db: 'admin',
      roles: [ { role: 'root', db: 'admin' } ],
      mechanisms: [ 'SCRAM-SHA-1', 'SCRAM-SHA-256' ]
    }
  ],
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1730749014, i: 2 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1730749014, i: 2 })
}
```
Включим авторизацию для этого шардированного кластера с помощью key-файла, создадим его
```bash
mkdir -p /etc/mongo/
echo -e "password" > /etc/mongo/key_pswrd
sudo chown 999:999 /etc/mongo/key_pswrd
```
прокинем keyFile во все контейнеры,отредактировав docker-compose.yml
```
    volumes:
      - /etc/mongo/key_pswrd:/etc/mongo/key_pswrd
```
и дополнительно добавим также опции запуска во все инстансы (обновленный yaml приложил)
```
"--auth","--keyFile", "/etc/mongo/key_pswrd"
```
перезапустим всё
```
docker compose -f ./docker-compose.yml up -d
```

Зайдем, увидим, что без авторизации ничего не доступно, авторизуемся
```javascript
#mongosh --port 40100
Current Mongosh Log ID: 672956b2fffcc4fceec1c18b
Connecting to:          mongodb://127.0.0.1:40100/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.3
Using MongoDB:          8.0.3
Using Mongosh:          2.3.3

For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/

[direct: mongos] test> show dbs
MongoServerError[Unauthorized]: Command listDatabases requires authentication
[direct: mongos] test> db.getUsers()
MongoServerError[Unauthorized]: Command usersInfo requires authentication
[direct: mongos] test> use admin
switched to db admin
[direct: mongos] admin> sh.status()
MongoServerError[Unauthorized]: Command find requires authentication
[direct: mongos] admin> db.auth('root','password')
{ ok: 1 }
```
Теперь все команды доступны
```javascript
[direct: mongos] admin> db.getUsers()
{
  users: [
    {
      _id: 'admin.root',
      userId: UUID('aa627463-5211-4053-b6f1-52253e730e31'),
      user: 'root',
      db: 'admin',
      roles: [ { role: 'root', db: 'admin' } ],
      mechanisms: [ 'SCRAM-SHA-1', 'SCRAM-SHA-256' ]
    }
  ]
    }
  },
  operationTime: Timestamp({ t: 1730762466, i: 1 })
}
[direct: mongos] admin> show dbs
admin    244.00 KiB
config     3.71 MiB
samples   69.98 MiB

[direct: mongos] admin> use samples
switched to db samples
[direct: mongos] samples> db.companies.getShardDistribution()
Shard shard-replica-set-1 at shard-replica-set-1/mongo-shard-1-rs-1:40011,mongo-shard-1-rs-2:40012,mongo-shard-1-rs-3:40013
{
  data: '7MiB',
  docs: 1204,
  chunks: 4,
  'estimated data per chunk': '1.75MiB',
  'estimated docs per chunk': 301
}
---
Shard shard-replica-set-3 at shard-replica-set-3/mongo-shard-3-rs-1:40031,mongo-shard-3-rs-2:40032,mongo-shard-3-rs-3:40033
{
  data: '6.79MiB',
  docs: 1263,
  chunks: 4,
  'estimated data per chunk': '1.69MiB',
  'estimated docs per chunk': 315
}
---
Shard shard-replica-set-2 at shard-replica-set-2/mongo-shard-2-rs-1:40021,mongo-shard-2-rs-2:40022,mongo-shard-2-rs-3:40023
{
  data: '43.26MiB',
  docs: 10669,
  chunks: 10,
  'estimated data per chunk': '4.32MiB',
  'estimated docs per chunk': 1066
}
---
Totals
{
  data: '57.06MiB',
  docs: 13136,
  chunks: 18,
  'Shard shard-replica-set-1': [
    '12.27 % data',
    '9.16 % docs in cluster',
    '5KiB avg obj size on shard'
  ],
  'Shard shard-replica-set-3': [
    '11.9 % data',
    '9.61 % docs in cluster',
    '5KiB avg obj size on shard'
  ],
  'Shard shard-replica-set-2': [
    '75.81 % data',
    '81.21 % docs in cluster',
    '4KiB avg obj size on shard'
  ]
}
```
Для простейшей ролевой модели создадим ReadWrite учетную запись для работы с базой samples и рид-онли пользователя также для это базы

```javascript
use admin
db.createUser({user: "readWriteSamples",pwd: "rwpassword",roles: [{ role: "readWrite", db: "samples" }]})
db.createUser({user: "readSamples",pwd: "rpassword",roles: [{ role: "read", db: "samples" }]})
```
Авторизуемся сначала под rw пользователем, у него нет возможности писать в другие бд, но есть в свою
```javascript
db.auth('readWriteSamples','rwpassword')
[direct: mongos] admin> db.people.insertOne({ name: "John", age: 30, status: "active" })
MongoServerError[Unauthorized]: not authorized on admin to execute command { insert: "people", documents: [ { name: "John", age: 30, status: "active", _id: ObjectId('67295ad8fffcc4fceec1c18c') } ], ordered: true, lsid: { id: UUID("c4e3308e-b9af-451f-bdaf-b59b8d25e7c3") }, txnNumber: 1, $clusterTime: { clusterTime: Timestamp(1730763396, 1), signature: { hash: BinData(0, 701232FF74A285171C03970E0EE2C3CAB5C6BC9A), keyId: 7432711836559998986 } }, $db: "admin" }

[direct: mongos] admin> show dbs
samples  70.02 MiB
[direct: mongos] admin> use samples
switched to db samples
[direct: mongos] samples> db.people.insertOne({ name: "John", age: 30, status: "active" })
{
  acknowledged: true,
  insertedId: ObjectId('67295ae6fffcc4fceec1c18d')
}
```
Теперь авторизуемся под учетной записью пользователя на чтение, ему всё доступно на просмотр в базе samples
```javascript
[direct: mongos] samples> use admin
switched to db admin
[direct: mongos] admin> db.auth('readSamples','rpassword')
{ ok: 1 }
[direct: mongos] admin> show dbs
samples  70.02 MiB
[direct: mongos] admin> use samples
switched to db samples
[direct: mongos] samples> show collections
city_inspections
companies
countries-big
countries-small
people
products
profiles
restaurants
zips
[direct: mongos] samples> db.people
db.people

[direct: mongos] samples> db.people.find()
[
  {
    _id: ObjectId('67295ae6fffcc4fceec1c18d'),
    name: 'John',
    age: 30,
    status: 'active'
  }
]
```
Изменения запрещены
```javascript
[direct: mongos] samples> db.people.insertOne({ name: "Tony", age: 29, status: "active" })
MongoServerError[Unauthorized]: not authorized on samples to execute command { insert: "people", documents: [ { name: "Tony", age: 29, status: "active", _id: ObjectId('67295b78fffcc4fceec1c18e') } ], ordered: true, lsid: { id: UUID("a899c163-27a6-4acd-8709-d4ce3b8df546") }, txnNumber: 1, $clusterTime: { clusterTime: Timestamp(1730763613, 1), signature: { hash: BinData(0, 72ACB6FE45049001FEE82CAE888B137993C41D39), keyId: 7432711836559998986 } }, $db: "samples" }
[direct: mongos] samples> db.people.deleteOne({ name: "John"})
MongoServerError[Unauthorized]: not authorized on samples to execute command { delete: "people", deletes: [ { q: { name: "John" }, limit: 1 } ], ordered: true, lsid: { id: UUID("63a4cdf4-2f0b-4e60-8c08-976b05b3893a") }, txnNumber: 2, $clusterTime: { clusterTime: Timestamp(1730765209, 2), signature: { hash: BinData(0, 02842902A8EB869B15E26C559579C7DB8AE30676), keyId: 7432711836559998986 } }, $db: "samples" }

```
Авторизуемся обратно под rw-пользователем, удалим запись.
```javascript
[direct: mongos] samples> use admin
switched to db admin
[direct: mongos] admin> db.auth('readWriteSamples','rwpassword')
{ ok: 1 }
[direct: mongos] admin> use samples
switched to db samples
[direct: mongos] samples> db.people.deleteOne({ name: "John"})
{ acknowledged: true, deletedCount: 1 }
```