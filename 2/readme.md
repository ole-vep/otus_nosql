Развернута машина с OS Ubuntu 22.04

Установлено по инструкции с офф сайта [MongoDB Community Edition](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/) последней версии

```
sudo apt-get install gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org
```

Наполним коллекцию [готовыми сэмплами](https://github.com/neelabalan/mongodb-sample-dataset)

```
~# cd neelabalan/
root@dvtest-dbc001lk:~/neelabalan# ./script.sh localhost 27017


~# mongosh --port 27017

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
```