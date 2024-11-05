### Разворот кластер couchbase
Развернем с помощью docker compose кластер следующей топологии
```bash
# cat docker-compose.yaml
version: '3.9'

services:
  couchbase1:
    image: couchbase:community-7.0.2
    container_name: couchbase1
    volumes:
      - ./node1:/opt/couchbase/var
    ports:
      - 8091:8091
  couchbase2:
    image: couchbase:community-7.0.2
    container_name: couchbase2
    volumes:
      - ./node2:/opt/couchbase/var
    ports:
      - 8092:8091
  couchbase3:
    image: couchbase:community-7.0.2
    container_name: couchbase3
    volumes:
      - ./node3:/opt/couchbase/var
    ports:
      - 8093:8091

# docker compose -f docker-compose.yaml up -d
[+] Running 3/3
 ✔ Container couchbase2  Started                                                                                                                                                    1.0s
 ✔ Container couchbase3  Started                                                                                                                                                    1.0s
 ✔ Container couchbase1  Started 

# docker ps
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS          PORTS                                                                                                     NAMES
2b60a5fb4c31   couchbase:community-7.0.2   "/entrypoint.sh couc…"   32 minutes ago   Up 32 minutes   8092-8096/tcp, 11207/tcp, 11210-11211/tcp, 0.0.0.0:8091->8091/tcp, :::8091->8091/tcp, 18091-18096/tcp     couchbase1
ca4f780f018a   couchbase:community-7.0.2   "/entrypoint.sh couc…"   32 minutes ago   Up 32 minutes   8092-8096/tcp, 11207/tcp, 11210-11211/tcp, 18091-18096/tcp, 0.0.0.0:8093->8091/tcp, [::]:8093->8091/tcp   couchbase3
566cf4fd745d   couchbase:community-7.0.2   "/entrypoint.sh couc…"   32 minutes ago   Up 32 minutes   8092-8096/tcp, 11207/tcp, 11210-11211/tcp, 18091-18096/tcp, 0.0.0.0:8092->8091/tcp, [::]:8092->8091/tcp   couchbase2
```
Заходим http://localhost:8091
Создаем новый кластер test со значениями по умолчанию, придумываем пароль для admin
![Alt text](1.png?raw=true "first node")

Заходим http://localhost:8092

присоединяемся к уже имеющемуся кластеру следующим образом 
![Alt text](2.png?raw=true "2 node")

Теперь у нас две ноды жмем [Rebalance]
![Alt text](3.png?raw=true "reb")

Заходим http://localhost:8093 Аналогично третью ноду подключаем и делаем ребалансировку
![Alt text](4.png?raw=true "3")

### Создание БД / Наполнение данными
В разделе buckets создадим тестовый бакет из нескольких предлагаемых из коробки тестовых сэмплов, например, "beer-samples" и провалимся в него чтобы посмотреть внутреннюю структуру: какие есть скоупы и коллекции, сколько документов и сколько они занимают места и прочее
![Alt text](bucket.png?raw=true "bucket")

из документации
```
In Couchbase Server 7.0 and later, documents are stored in collections, which are stored in scopes, which are in turn stored in buckets within a namespace. The query engine needs to be aware of the full path of the collection. The fully qualified path of a collection has the following format:
namespace:bucket.scope.collection
```
Попробуем сделать простейший запрос в разделе Query
![Alt text](query_.png?raw=true "query")
### Проверка отказоустойчивости
Остановим первый инстанс
```
# docker stop couchbase1
```
web-ui отпал
![Alt text](lost1.png?raw=true "lost1")

Заходим на вторую, прожимаем фейловер, жмем потом ребалансировку
![Alt text](fail_rebal.png?raw=true "fail_reb")

Остановим теперь ещё второй инстанс
```
# docker stop couchbase2
```
если прожать и теперь фейловер то потеряем данные, выходит предупреждение
![Alt text](attent_lost_data.png?raw=true "fail2")

Примечательно, что в этот момент сервер знает, что у него осталась половина items, но sql-запросом count показывает 0 
![Alt text](items_e.png?raw=true "items")
![Alt text](count0.png?raw=true "count")

Поднимаем обратно второй
```
# docker start couchbase2
```
Его не надо повторно заносить в кластер, нашелся сам, попросил только авторизацию admin`a
![Alt text](admin2auth.png?raw=true "auth")
![Alt text](10_finded.png?raw=true "finded")

Поднимаем теперь обратно и первый, его уже нужно повторно заносить в кластер
```
# docker start couchbase1
```
![Alt text](rejoin.png?raw=true "rejoin")

Тут аналогично добавляем, доступна ребалансировка

![Alt text](rejoin_.png?raw=true "rejoin_")
![Alt text](reb_.png?raw=true "reb_")

Сломался индекс кстати после всех этих манипуляций, ну что ж, пересоздадим

![Alt text](no_index.png?raw=true "no_index")
![Alt text](create_indx.png?raw=true "create_indx")
![Alt text](count_with_index.png?raw=true "count_with_index")