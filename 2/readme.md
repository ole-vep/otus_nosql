#### 1. Установка
Развернута машина с OS Ubuntu 22.04

Установлено по инструкции с офф сайта [MongoDB Community Edition](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/) последней версии (8.0.3)

```bash
sudo apt-get install gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org

~# dpkg -l | grep mongo
ii  mongodb-database-tools           100.10.0     amd64        mongodb-database-tools package provides tools for working with the MongoDB server:
ii  mongodb-mongosh                  2.3.3        amd64        MongoDB Shell CLI REPL Package
ii  mongodb-org                      8.0.3        amd64        MongoDB open source document-oriented database system (metapackage)
ii  mongodb-org-database             8.0.3        amd64        MongoDB open source document-oriented database system (metapackage)
ii  mongodb-org-database-tools-extra 8.0.3        amd64        Extra MongoDB database tools
ii  mongodb-org-mongos               8.0.3        amd64        MongoDB sharded cluster query router
ii  mongodb-org-server               8.0.3        amd64        MongoDB database server
ii  mongodb-org-shell                8.0.3        amd64        MongoDB shell client
ii  mongodb-org-tools                8.0.3        amd64        MongoDB tools

```
#### 2. Заполнение данными
Наполним коллекцию [готовыми сэмплами](https://github.com/neelabalan/mongodb-sample-dataset)

```bash
~# cd neelabalan/
~/neelabalan# ./script.sh localhost 27017

~# mongosh --port 27017
```
Посмотрим какие подтянулись базы и коллекции
```javascript
test> show dbs
admin                40.00 KiB
config               48.00 KiB
local                72.00 KiB
sample_airbnb        51.84 MiB
sample_analytics      9.38 MiB
sample_geospatial   788.00 KiB
sample_mflix         28.20 MiB
sample_supplies     968.00 KiB
sample_training      60.49 MiB
sample_weatherdata    2.52 MiB

test> use sample_training
switched to db sample_training

sample_training> db.stats()
{
  db: 'sample_training',
  collections: Long('9'),
  views: Long('0'),
  objects: Long('331176'),
  avgObjSize: 513.3017368408339,
  dataSize: 169993216,
  storageSize: 59932672,
  indexes: Long('9'),
  indexSize: 3493888,
  totalSize: 63426560,
  scaleFactor: Long('1'),
  fsUsedSize: 6309634048,
  fsTotalSize: 31024283648,
  ok: 1
}

sample_training> show collections
companies
grades
inspections
posts
routes
stories
trips
tweets
zips
```
#### 3. Запросы

Поработаем с коллекцией компаний, выберем количество компаний с оффисами в России и примеры с оффисами в Москве
```javascript
sample_training> db.companies.countDocuments({'offices.country_code' : 'RUS'})
26

sample_training> db.companies.find({'offices.city' : 'Moscow'}, { name : 1 , permalink :1 , founded_year :1 , category_code : 1 ,'offices.city' : 1,'offices.country_code' : 1}).sort({founded_year : 1}).limit(3)
[
  {
    _id: ObjectId('52cdef7f4bab8bd67529c435'),
    name: 'OSG Records Management',
    permalink: 'osg-records-management',
    category_code: 'software',
    founded_year: null,
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('52cdef7d4bab8bd6752992f8'),
    name: '1C Company',
    permalink: '1c-company',
    category_code: 'software',
    founded_year: 1991,
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('52cdef7f4bab8bd67529c2ba'),
    name: 'Mobile TeleSystems OJSC',
    permalink: 'mobile-telesystems-ojsc',
    category_code: 'mobile',
    founded_year: 1993,
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  }
]

```
обновим год основания для компании 'OSG Records Management'
```javascript
sample_training> db.companies.updateOne({name:  'OSG Records Management'}, {$set: {founded_year: 1998}})
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
```
вставим значения
```javascript
sample_training> db.companies.insertMany([ {name: "Test Company", founded_year: 1990, category_code: "testware", offices: [ { city: 'Moscow', country_code: 'RUS' } ] }, {name: "Mongo RUS", founded_year: 1991, category_code: "sales", offices: [ { city: 'St. Petersburg', country_code: 'RUS' } ] } ])
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('67260e2e9cbfc929d5c1c192'),
    '1': ObjectId('67260e2e9cbfc929d5c1c193')
  }
}
```
Посмотрим, что получилось уже по фильтру оффисов в России
```javascript
sample_training> db.companies.find({'offices.country_code' : 'RUS'}, { name : 1, founded_year :1 , category_code : 1 ,'offices.city' : 1,'offices.country_code' : 1}).sort({founded_year : 1}).skip(2).limit(11)
[
  {
    _id: ObjectId('52cdef7d4bab8bd675298bd4'),
    name: 'Talkonaut',
    category_code: 'public_relations',
    founded_year: 1985,
    offices: [ { city: 'Tyumen', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('67260e2e9cbfc929d5c1c192'),
    name: 'Test Company',
    founded_year: 1990,
    category_code: 'testware',
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('52cdef7d4bab8bd6752992f8'),
    name: '1C Company',
    category_code: 'software',
    founded_year: 1991,
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('67260e2e9cbfc929d5c1c193'),
    name: 'Mongo RUS',
    founded_year: 1991,
    category_code: 'sales',
    offices: [ { city: 'St. Petersburg', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('52cdef7e4bab8bd67529a6a2'),
    name: 'CASON',
    category_code: 'hardware',
    founded_year: 1992,
    offices: [
      { city: 'Ã‰rd', country_code: 'HUN' },
      { city: 'Bucharest', country_code: 'ROM' },
      { city: 'Paris', country_code: 'FRA' },
      { city: 'Kiev', country_code: 'UKR' },
      { city: 'Troitsk, Moskovskaya Obl.', country_code: 'RUS' },
      { city: 'Singapore', country_code: 'SGP' }
    ]
  },
  {
    _id: ObjectId('52cdef7e4bab8bd67529b9df'),
    name: 'EPAM Systems',
    category_code: 'software',
    founded_year: 1993,
    offices: [
      { city: 'Newtown', country_code: 'USA' },
      { city: 'London', country_code: 'GBR' },
      { city: 'Moscow', country_code: 'RUS' }
    ]
  },
  {
    _id: ObjectId('52cdef7f4bab8bd67529c2ba'),
    name: 'Mobile TeleSystems OJSC',
    category_code: 'mobile',
    founded_year: 1993,
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('52cdef7d4bab8bd67529943c'),
    name: 'Paragon Software',
    category_code: 'software',
    founded_year: 1994,
    offices: [
      { city: 'Irvine', country_code: 'USA' },
      { city: '79100', country_code: 'DEU' },
      { city: 'Moscow', country_code: 'RUS' },
      { city: 'Tokyo', country_code: 'JPN' }
    ]
  },
  {
    _id: ObjectId('52cdef7c4bab8bd6752985eb'),
    name: 'The Orchard',
    category_code: null,
    founded_year: 1997,
    offices: [
      { city: 'New York', country_code: 'USA' },
      { city: 'Nashville', country_code: 'USA' },
      { city: 'London', country_code: 'GBR' },
      { city: '', country_code: 'JPN' },
      { city: '', country_code: 'AUS' },
      { city: '', country_code: 'ARG' },
      { city: '', country_code: 'BRA' },
      { city: '', country_code: 'MEX' },
      { city: '', country_code: 'ESP' },
      { city: '', country_code: 'FRA' },
      { city: '', country_code: 'GRC' },
      { city: '', country_code: 'DEU' },
      { city: '', country_code: 'CZE' },
      { city: '', country_code: 'POL' },
      { city: '', country_code: 'RUS' },
      { city: '', country_code: 'ROM' },
      { city: '', country_code: 'BGR' },
      { city: '', country_code: 'TUR' },
      { city: '', country_code: 'ISR' },
      { city: '', country_code: 'PST' },
      { city: '', country_code: 'ZAF' },
      { city: '', country_code: 'NGA' },
      { city: '', country_code: 'BFA' },
      { city: '', country_code: 'KOR' },
      { city: '', country_code: 'IND' }
    ]
  },
  {
    _id: ObjectId('52cdef7c4bab8bd67529847c'),
    name: 'Gazprom-Media',
    category_code: null,
    founded_year: 1998,
    offices: [ { city: 'Saint-Petersburg', country_code: 'RUS' } ]
  },
  {
    _id: ObjectId('52cdef7f4bab8bd67529c435'),
    name: 'OSG Records Management',
    category_code: 'software',
    founded_year: 1998,
    offices: [ { city: 'Moscow', country_code: 'RUS' } ]
  }
]
```
посмотрим кол-во компаний,основанных после 1989 года невключительно, сгруппируем кол-во по годам и отсортируем по кол-ву, начиная с наибольшего
```javascript
sample_training>  db.companies.aggregate([{$match:{founded_year:{$gt: 1989}}},{"$group":{_id:{founded_year:"$founded_year"},count:{$sum:1}}},{$sort:{count:-1}}]).toArray()
[
  { _id: { founded_year: 2008 }, count: 1224 },
  { _id: { founded_year: 2007 }, count: 1159 },
  { _id: { founded_year: 2006 }, count: 744 },
  { _id: { founded_year: 2005 }, count: 467 },
  { _id: { founded_year: 2004 }, count: 385 },
  { _id: { founded_year: 2009 }, count: 357 },
  { _id: { founded_year: 2003 }, count: 291 },
  { _id: { founded_year: 2000 }, count: 276 },
  { _id: { founded_year: 2002 }, count: 256 },
  { _id: { founded_year: 1999 }, count: 250 },
  { _id: { founded_year: 2001 }, count: 247 },
  { _id: { founded_year: 1998 }, count: 148 },
  { _id: { founded_year: 1996 }, count: 115 },
  { _id: { founded_year: 1997 }, count: 88 },
  { _id: { founded_year: 1995 }, count: 73 },
  { _id: { founded_year: 1994 }, count: 43 },
  { _id: { founded_year: 1993 }, count: 37 },
  { _id: { founded_year: 1992 }, count: 34 },
  { _id: { founded_year: 2010 }, count: 33 },
  { _id: { founded_year: 1990 }, count: 26 },
  { _id: { founded_year: 1991 }, count: 24 },
  { _id: { founded_year: 2011 }, count: 22 },
  { _id: { founded_year: 2012 }, count: 17 },
  { _id: { founded_year: 2013 }, count: 5 }
]
```
Создадим индекс для коллекции компаний по году основания
```javascript
sample_training> db.companies.getIndexes()
[ { v: 2, key: { _id: 1 }, name: '_id_' } ]
sample_training> db.companies.createIndex({ founded_year: 1})
founded_year_1
sample_training> db.companies.getIndexes()
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  { v: 2, key: { founded_year: 1 }, name: 'founded_year_1' }
]
```
Включим профилирование медленных запросов, slowms и sampleRate не меняем, под "медленным", как видно тут принимается запрос дольше 100 мс
```javascript
sample_training> db.getProfilingStatus()
{ was: 0, slowms: 100, sampleRate: 1, ok: 1 }
sample_training> db.setProfilingLevel(1)
{ was: 0, slowms: 100, sampleRate: 1, ok: 1 }
sample_training> db.getProfilingStatus()
{ was: 1, slowms: 100, sampleRate: 1, ok: 1 }
```

Прогоним тот же запрос для компаний и посмотрим проекции на интересные поля в специальной системной коллекции для профилирования запросов с фильтрами интересующей нас коллекции компаний и для запросов дольше 300 мс

```javascript
sample_training>  db.companies.aggregate([{$match:{founded_year:{$gt: 1989}}},{"$group":{_id:{founded_year:"$founded_year"},count:{$sum:1}}},{$sort:{count:-1}}]).toArray()
...

sample_training> db.system.profile.find({$and: [{millis : {$gte : 300} }, {ns: 'sample_training.companies'}]}, {nreturned:1,millis:1,responseLength:1,cpuNanos:1,planSummary:1,planningTimeMicros:1,keysExamined:1,docsExamined:1})
[
  {
    keysExamined: 0,
    docsExamined: 9504,
    nreturned: 24,
    responseLength: 1256,
    cpuNanos: 35048556,
    millis: 449,
    planSummary: 'COLLSCAN',
    planningTimeMicros: 144490
  },
  {
    keysExamined: 6321,
    docsExamined: 0,
    nreturned: 24,
    responseLength: 1256,
    cpuNanos: 29143858,
    millis: 302,
    planSummary: 'IXSCAN { founded_year: 1 }',
    planningTimeMicros: 90533
  }
]
```
Ну и собственно, как и ожидалось, видим по значению поля planSummary, что первый запрос использует сканирование коллекции и соответственно показывает, сколько документов было проверено (docsExamined), а второй запрос использует скан по индексу и отображает уже ненулевым поле keysExamined - количество проверенных ключей индекса.
Все тайминги (millis,cpuNanos,planningTimeMicros) меньше для запроса с индексом, он выполняется быстрее