## Redis
Установка на Ubuntu 22.04
```sh
# sudo apt update
# sudo apt install redis-server

# redis-server --version
Redis server v=6.0.16 sha=00000000:0 malloc=jemalloc-5.2.1 bits=64 build=a3fdef44459b3ad6

```
Бенчмарк из коробки с параметром quiet
```sh
# redis-benchmark -q

PING_INLINE: 75357.95 requests per second
PING_BULK: 72833.21 requests per second
SET: 76569.68 requests per second
GET: 80385.85 requests per second
INCR: 69589.42 requests per second
LPUSH: 71787.51 requests per second
RPUSH: 73637.70 requests per second
LPOP: 72254.34 requests per second
RPOP: 72202.16 requests per second
SADD: 71428.57 requests per second
HSET: 72674.41 requests per second
SPOP: 70126.23 requests per second
ZADD: 71377.59 requests per second
ZPOPMIN: 66755.67 requests per second
LPUSH (needed to benchmark LRANGE): 71123.76 requests per second
LRANGE_100 (first 100 elements): 51124.75 requests per second
LRANGE_300 (first 300 elements): 26504.11 requests per second
LRANGE_500 (first 450 elements): 18573.55 requests per second
LRANGE_600 (first 600 elements): 15318.63 requests per second
MSET (10 keys): 71073.21 requests per second
```
Подготовка файла.
Скачаем для тестирования файлик отсюда https://microsoftedge.github.io/Demos/json-dummy-data/5MB-min.json

Необходимо его отредактировать.

### Строки
Сделаем файлик для первого варианта структур данных(строки)
```sh
cp redis/5MB-min.json redis/set_result
sed -i 's/\[//g; s/\]//g; s/"//g; s/},/"\n/g; s/{/SET test:n "/g' redis/set_result

# получится что-то типа этого
SET test:n "name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
SET test:n "name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
SET test:n "name: Aamir Solangi,language: Sindhi,id: IAKPO3R4761JDRVG,bio: Vestibulum pharetra libero et velit gravida euismod. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Fusce eu ultrices elit, vel posuere neque.,version: 7.27" ...
```
Теперь баш-скриптом, написанным на коленке, сделаем замену test:n на "test:номер строки", соответсвенно так и будут называться наши ключи
```sh
~#cat redis/.scr.sh
#!/bin/bash
file="redis/set_result"
t=1
IFS=$'\n'
for var in $(cat $file)
do
#echo "$t"
#echo "$var"
sed -i $t's/test:n/test:'$t'/' $file
t=$[$t+1]
done

redis/.scr.sh
```
Получится уже то, что можно скормить редис
```sh
SET test:1 "name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
SET test:2 "name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
SET test:3 "name: Aamir Solangi,language: Sindhi,id: IAKPO3R4761JDRVG,bio: Vestibulum pharetra libero et velit gravida euismod. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Fusce eu ultrices elit, vel posuere neque.,version: 7.27" 
...
SET test:15839 "name: Zamokuhle Zulu,language: isiZulu,id: XU7BX2F8M5PVZ1EF,bio: Etiam congue dignissim volutpat. Phasellus tincidunt sollicitudin posuere. Phasellus tincidunt sollicitudin posuere. Nam tristique feugiat est vitae mollis.,version: 8.39"
SET test:15840 "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
```
Установим параметр в конфиге /etc/redis/redis.conf
```
slowlog-log-slower-than 100
# systemctl restart redis
```

Загрузка строк, смотрим slow-log, 713 микросекунд. Сами вставки не попадают, так как в этот момент включен параметр slowlog-log-slower-than 100. Оценим это время по другому далее
```sh
redis-cli < redis/set_result

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 8
   2) (integer) 1738155973
   3) (integer) 713
   4) 1) "COMMAND"
   5) "127.0.0.1:53744"
   6) ""
```
Монитор выдаёт такую картину:
```sh
127.0.0.1:6379> MONITOR
OK
1738167913.182012 [0 127.0.0.1:38364] "COMMAND"
1738167913.185272 [0 127.0.0.1:38364] "SET" "test:1" "name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
...
1738167914.649576 [0 127.0.0.1:38364] "SET" "test:15840" "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
```
то есть почти полторы секунды (1,46)

Вычитать список ключей test, 5583 микросекунд
```sh
127.0.0.1:6379> KEYS test*
    1) "test:11041"
    2) "test:4411"
...
15839) "test:6984"
15840) "test:25"

1738258316.255652 [0 127.0.0.1:45436] "KEYS" "test*"


127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 30
   2) (integer) 1738159171
   3) (integer) 5583
   4) 1) "KEYS"
      2) "test*"
   5) "127.0.0.1:45436"
   6) ""

```
Прочитать список ключей со значениями, зафиксированы такие действия, 5817 микросекунд
```sh
echo 'keys test*' | redis-cli | sed 's/^/get /' | redis-cli

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 28
   2) (integer) 1738159051
   3) (integer) 5817
   4) 1) "keys"
      2) "test*"
   5) "127.0.0.1:37572"
   6) ""
2) 1) (integer) 27
   2) (integer) 1738159051
   3) (integer) 476
   4) 1) "COMMAND"
   5) "127.0.0.1:37572"
   6) ""
3) 1) (integer) 26
   2) (integer) 1738159051
   3) (integer) 524
   4) 1) "COMMAND"
   5) "127.0.0.1:37574"
   6) ""
```

Просто прочитать одно значение 7 микросек, попадает под фильтр медленного запроса, только со значением slowlog-log-slower-than 1
```sh
~# redis-cli
127.0.0.1:6379> GET test:12345
"name: Maria Sammut,language: Maltese,id: BJRF0BWIHJ0Q12A1,bio: Maecenas tempus neque ut porttitor malesuada. Curabitur ultricies id urna nec ultrices.,version: 6.83"

127.0.0.1:6379> MONITOR
OK
1738258080.369228 [0 127.0.0.1:59756] "GET" "test:12345"

3) 1) (integer) 0
   2) (integer) 1738257992
   3) (integer) 7
   4) 1) "GET"
      2) "test:12345"
   5) "127.0.0.1:59756"
   6) ""
```

Добавить вручную еще один ключ, 12 микросек
```sh
127.0.0.1:6379> SET test:15841 "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
OK

127.0.0.1:6379> MONITOR
OK
1738257825.690265 [0 127.0.0.1:48156] "SET" "test:15841" "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"


127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 886
   2) (integer) 1738257825
   3) (integer) 12
   4) 1) "SET"
      2) "test:15841"
      3) "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligu... (165 more bytes)"
   5) "127.0.0.1:48156"
   6) ""

```


### Хэш-таблицы
Теперь аналогично подготовим файл данных в виде хэш-таблицы
```sh

cp redis/5MB-min.json redis/hset_result
sed -i 's/\[//g; s/\]//g; s/://g; s/},/\n/g; s/{/HSET htest:n /g' redis/hset_result
sed -i 's/","/" "/g; s/}/\n/g' redis/hset_result
```

Для файла redis/hset_result прогоним слегка модифицированный баш-скрипт и получатся названия ключей htest:номер строки
```sh
~# cat redis/.scr_h.sh
#!/bin/bash
file="redis/hset_result"
t=1
IFS=$'\n'
for var in $(cat $file)
do
sed -i $t's/htest:n/htest:'$t'/' $file
t=$[$t+1]
done

redis/.scr_h.sh

# head -n 3 redis/hset_result
HSET htest:1 "name" "Adeel Solangi" "language" "Sindhi" "id" "V59OF92YF627HFY0" "bio" "Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc." "version" 6.1
HSET htest:2 "name" "Afzal Ghaffar" "language" "Sindhi" "id" "ENTOCR13RSCLZ6KU" "bio" "Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod." "version" 1.88
HSET htest:3 "name" "Aamir Solangi" "language" "Sindhi" "id" "IAKPO3R4761JDRVG" "bio" "Vestibulum pharetra libero et velit gravida euismod. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Fusce eu ultrices elit, vel posuere neque." "version" 7.27
```

Загрузка хэш-таблиц, смотрим slow-log, 783 микросекунд. Сами вставки не попадают, так как в этот момент включен параметр slowlog-log-slower-than 100. Оценим это время по другому далее
```sh
redis-cli < redis/hset_result

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 58
   2) (integer) 1738166684
   3) (integer) 783
   4) 1) "COMMAND"
   5) "127.0.0.1:50154"
   6) ""
```
Монитор выдаёт такую картину, полторы секунды (1,477)
```sh
127.0.0.1:6379> MONITOR
OK
1738167623.135513 [0 127.0.0.1:52570] "COMMAND"
1738167623.138832 [0 127.0.0.1:52570] "HSET" "htest:1" "name" "Adeel Solangi" "language" "Sindhi" "id" "V59OF92YF627HFY0" "bio" "Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc." "version" "6.1"
....
1738167624.612018 [0 127.0.0.1:52570] "HSET" "htest:15840" "name" "Bhupesh Menon" "language" "Hindi" "id" "0CEPNRDV98KT3ORP" "bio" "Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc." "version" "2.69"

```
Вычитать список ключей htest, 6414 микросекунд
```sh
127.0.0.1:6379> KEYS htest*
    1) "htest:4010"
    2) "htest:12764"
    3) "htest:9908"
...
15839) "htest:7782"
15840) "htest:8966"

1738258484.121056 [0 127.0.0.1:59756] "KEYS" "htest*"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 45186
   2) (integer) 1738258484
   3) (integer) 6414
   4) 1) "KEYS"
      2) "htest*"
   5) "127.0.0.1:59756"
   6) ""
```
Прочитать все значения HVALS всех ключей htest*, зафиксированы такие действия, 6483 микросекунд
```sh
echo 'keys htest*' | redis-cli | sed 's/^/hvals /' | redis-cli

4) 1) (integer) 65
   2) (integer) 1738166906
   3) (integer) 6483
   4) 1) "keys"
      2) "htest*"
   5) "127.0.0.1:33524"
   6) ""
5) 1) (integer) 64
   2) (integer) 1738166906
   3) (integer) 403
   4) 1) "COMMAND"
   5) "127.0.0.1:33524"
   6) ""
```
Вычитать значения одного ключа 16 микросекунд, попадает под фильтр медленного запроса со значением slowlog-log-slower-than 10, 
```sh
# redis-cli
127.0.0.1:6379> HVALS htest:12345
1) "BJRF0BWIHJ0Q12A1"
2) "Maecenas tempus neque ut porttitor malesuada. Curabitur ultricies id urna nec ultrices."
3) "Maltese"
4) "Maria Sammut"
5) "6.83"

127.0.0.1:6379> MONITOR
OK
1738232970.266255 [0 127.0.0.1:60580] "COMMAND"
1738233021.371873 [0 127.0.0.1:60580] "HVALS" "htest:12345"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 410
   2) (integer) 1738233021
   3) (integer) 16
   4) 1) "HVALS"
      2) "htest:12345"
   5) "127.0.0.1:60580"
   6) ""
```
Получить пары ключ-значений по элементу, 11 микросек
```sh
127.0.0.1:6379> HGETALL htest:12345
 1) "language"
 2) "Maltese"
 3) "bio"
 4) "Maecenas tempus neque ut porttitor malesuada. Curabitur ultricies id urna nec ultrices."
 5) "id"
 6) "BJRF0BWIHJ0Q12A1"
 7) "name"
 8) "Maria Sammut"
 9) "version"
10) "6.83"

127.0.0.1:6379> MONITOR
OK
1738257357.545648 [0 127.0.0.1:48156] "HGETALL" "htest:12345"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 824
   2) (integer) 1738257357
   3) (integer) 11
   4) 1) "HGETALL"
      2) "htest:12345"
   5) "127.0.0.1:48156"
   6) ""

```

Добавить вручную еще один ключ, 20 микросек
```sh
127.0.0.1:6379> HSET htest:15841 "name" "Bhupesh Menon" "language" "Hindi" "id" "0CEPNRDV98KT3ORP" "bio" "Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc." "version" 2.69
(integer) 5

127.0.0.1:6379> MONITOR
OK
1738257165.397728 [0 127.0.0.1:48156] "HSET" "htest:15841" "name" "Bhupesh Menon" "language" "Hindi" "id" "0CEPNRDV98KT3ORP" "bio" "Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc." "version" "2.69"

127.0.0.1:6379> SLOWLOG RESET
OK
127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 822
   2) (integer) 1738257165
   3) (integer) 20
   4)  1) "HSET"
       2) "htest:15841"
       3) "name"
       4) "Bhupesh Menon"
       5) "language"
       6) "Hindi"
       7) "id"
       8) "0CEPNRDV98KT3ORP"
       9) "bio"
      10) "Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisqu... (89 more bytes)"
      11) "version"
      12) "2.69"
   5) "127.0.0.1:48156"
   6) ""
```


### Список
Сделаем файлик для структур данных список
```sh
cp redis/5MB-min.json redis/rpush_result
sed -i 's/\[//g; s/\]//g; s/"//g; s/},/"\n/g; s/{/RPUSH rtest "/g' redis/rpush_result

# получится что-то типа этого
# head -n 3 redis/rpush_result
RPUSH rtest "name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
RPUSH rtest "name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
RPUSH rtest "name: Aamir Solangi,language: Sindhi,id: IAKPO3R4761JDRVG,bio: Vestibulum pharetra libero et velit gravida euismod. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Fusce eu ultrices elit, vel posuere neque.,version: 7.27" ...
```
Скрипт для данных структур не нужен, будем вставлять новые значения просто в конец списка rtest

Загрузка cписка, смотрим slow-log, 968 микросекунд на саму команду со значением slowlog-log-slower-than 100, также пара длинных вставок вышла за этот лимит и также отображается в логе. Скорость всего импорта оценим далее
```sh
redis-cli < redis/rpush_result

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 5
   2) (integer) 1738234689
   3) (integer) 106
   4) 1) "RPUSH"
      2) "rtest"
      3) "name: Sigurj\xc3\xb3n Gu\xc3\xb0mundsson,language: Icelandic,id: IAYT285H2U8JU94F,bio: Sed eu libero maximus nunc lacinia lobortis et sit am... (331 more bytes)"
   5) "127.0.0.1:46822"
   6) ""
2) 1) (integer) 4
   2) (integer) 1738234689
   3) (integer) 219
   4) 1) "RPUSH"
      2) "rtest"
      3) "name: Qahar Abdulla,language: Uyghur,id: OGLODUPEHKEW0K83,bio: Duis commodo orci ut dolor iaculis facilisis. Aliquam sollicitudi... (270 more bytes)"
   5) "127.0.0.1:46822"
   6) ""
3) 1) (integer) 3
   2) (integer) 1738234688
   3) (integer) 968
   4) 1) "COMMAND"
   5) "127.0.0.1:46822"
   6) ""
```
Монитор выдаёт такую картину, 1.33 секунды 
```sh
127.0.0.1:6379> MONITOR
OK
1738234688.723284 [0 127.0.0.1:46822] "RPUSH" "rtest" "name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
1738234688.723497 [0 127.0.0.1:46822] "RPUSH" "rtest" "name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
...
1738234690.052395 [0 127.0.0.1:46822] "RPUSH" "rtest" "name: Zamokuhle Zulu,language: isiZulu,id: XU7BX2F8M5PVZ1EF,bio: Etiam congue dignissim volutpat. Phasellus tincidunt sollicitudin posuere. Phasellus tincidunt sollicitudin posuere. Nam tristique feugiat est vitae mollis.,version: 8.39"
1738234690.052485 [0 127.0.0.1:46822] "RPUSH" "rtest" "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"

```

Посмотреть наличие списка rtest по шаблону, 7 микросекунд
```sh
127.0.0.1:6379> KEYS rtest*
1) "rtest"

1738258666.751310 [0 127.0.0.1:59756] "KEYS" "rtest*"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 60750
   2) (integer) 1738258666
   3) (integer) 7
   4) 1) "KEYS"
      2) "rtest*"
   5) "127.0.0.1:59756"
   6) ""
```

Длина списка, 728 микросекунд
```sh
127.0.0.1:6379> LLEN rtest
(integer) 15840

127.0.0.1:6379> MONITOR
OK
1738235184.254239 [0 127.0.0.1:33554] "COMMAND"
1738235190.162061 [0 127.0.0.1:33554] "LLEN" "rtest"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 6
   2) (integer) 1738235184
   3) (integer) 728
   4) 1) "COMMAND"
   5) "127.0.0.1:33554"
   6) ""
```
Вычитать все значения почти 2 сек на отображение, 8925 микросекунд команда
```sh
127.0.0.1:6379> LRANGE rtest 0 15840
...
15840) "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
(1.99s)

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 7
   2) (integer) 1738236772
   3) (integer) 8925
   4) 1) "LRANGE"
      2) "rtest"
      3) "0"
      4) "15840"
   5) "127.0.0.1:33554"
   6) ""
```

Получить элемент по индексу, 23 микросек.
```sh
127.0.0.1:6379> LINDEX rtest 12345
"name: Rita Busuttil,language: Maltese,id: 1QLMU6QZ7EYUNNZV,bio: Phasellus tincidunt sollicitudin posuere. Quisque efficitur vel sapien ut imperdiet. Vestibulum pharetra libero et velit gravida euismod. Maecenas tempus neque ut porttitor malesuada.,version: 2.09"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 2
   2) (integer) 1738237084
   3) (integer) 23
   4) 1) "LINDEX"
      2) "rtest"
      3) "12345"
   5) "127.0.0.1:52642"
   6) ""
```
Получить срез списка - один элемент, 63 микросек.
```sh
127.0.0.1:6379> LRANGE rtest 12345 12345
1) "name: Rita Busuttil,language: Maltese,id: 1QLMU6QZ7EYUNNZV,bio: Phasellus tincidunt sollicitudin posuere. Quisque efficitur vel sapien ut imperdiet. Vestibulum pharetra libero et velit gravida euismod. Maecenas tempus neque ut porttitor malesuada.,version: 2.09"

127.0.0.1:6379> MONITOR
OK
1738256800.201498 [0 127.0.0.1:48156] "LRANGE" "rtest" "12345" "12345"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 184
   2) (integer) 1738256800
   3) (integer) 63
   4) 1) "LRANGE"
      2) "rtest"
      3) "12345"
      4) "12345"
   5) "127.0.0.1:48156"
   6) ""
```

Добавление вручную еще одного элемента, 13 микросек.
```sh
127.0.0.1:6379> RPUSH rtest "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.70"
(integer) 15841

127.0.0.1:6379> MONITOR
OK
1738256671.654819 [0 127.0.0.1:48156] "RPUSH" "rtest" "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.70"

127.0.0.1:6379> SLOWLOG RESET
OK
127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 182
   2) (integer) 1738256671
   3) (integer) 13
   4) 1) "RPUSH"
      2) "rtest"
      3) "name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligu... (165 more bytes)"
   5) "127.0.0.1:48156"
   6) ""
```

### Упорядоченное множество
Сделаем файлик для структур данных в виде упорядоченного множества
```sh
cp redis/5MB-min.json redis/zadd_result
sed -i 's/\[//g; s/\]//g; s/"//g; s/},/"\n/g; s/{/ZADD ztest "/g' redis/zadd_result
sed -i 's/}/"/g' redis/zadd_result
sed -i 's/ "/ "row: n, /g' redis/zadd_result


# получится что-то типа этого
# cat redis/zadd_result | head -n 3
ZADD ztest "row :n, name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
ZADD ztest "row: n, name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
ZADD ztest "row: n, name: Aamir Solangi,language: Sindhi,id: IAKPO3R4761JDRVG,bio: Vestibulum pharetra libero et velit gravida euismod. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Fusce eu ultrices elit, vel posuere neque.,version: 7.27" ...
```
Скриптом заменим ztest на "ztest рандомное значение рейтинга", а row: n на "row: номер строки в файле", для уникальности значений. Так как выяснилось в процессе, что в json есть неуникальные значения, а для наглядного примера с множествами нужна уникальность.
```sh
~# cat redis/.scr_z.sh
#!/bin/bash
file="redis/zadd_result"
t=1
r=0
IFS=$'\n'
for var in $(cat $file)
do
let r=$RANDOM+$RANDOM+$RANDOM
sed -i $t's/ztest/ztest '$r'/; '$t's/row: n/row: '$t'/' $file
t=$[$t+1]
done

redis/.scr_z.sh

# результат
~# tail -n3 redis/zadd_result
ZADD ztest 49912 "row: 15838, name: Sunil Kapoor,language: Hindi,id: VY2A0APGVHK5NAW2,bio: Proin tempus eu risus nec mattis. Ut dictum, ligula eget sagittis maximus, tellus mi varius ex, a accumsan justo tellus vitae leo. In id elit malesuada, pulvinar mi eu, imperdiet nulla.,version: 8.04"
ZADD ztest 29115 "row: 15839, name: Zamokuhle Zulu,language: isiZulu,id: XU7BX2F8M5PVZ1EF,bio: Etiam congue dignissim volutpat. Phasellus tincidunt sollicitudin posuere. Phasellus tincidunt sollicitudin posuere. Nam tristique feugiat est vitae mollis.,version: 8.39"
ZADD ztest 67511 "row: 15840, name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
```
Загрузка данных, смотрим slow-log, 567 микросекунд. Сами вставки не попадают, так как в этот момент включен параметр slowlog-log-slower-than 100. Оценим это время по другому далее
```sh
redis-cli < redis/zadd_result

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 18
   2) (integer) 1738252412
   3) (integer) 567
   4) 1) "COMMAND"
   5) "127.0.0.1:39280"
   6) ""

```
Монитор выдаёт такую картину, 1.3 секунды
```sh
127.0.0.1:6379> MONITOR
OK
1738252412.588611 [0 127.0.0.1:39280] "COMMAND"
1738252412.591629 [0 127.0.0.1:39280] "ZADD" "ztest" "37932" "row: 1, name: Adeel Solangi,language: Sindhi,id: V59OF92YF627HFY0,bio: Donec lobortis eleifend condimentum. Cras dictum dolor lacinia lectus vehicula rutrum. Maecenas quis nisi nunc. Nam tristique feugiat est vitae mollis. Maecenas quis nisi nunc.,version: 6.1"
1738252412.591767 [0 127.0.0.1:39280] "ZADD" "ztest" "35333" "row: 2, name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
...
1738252413.882734 [0 127.0.0.1:39280] "ZADD" "ztest" "67511" "row: 15840, name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
```

Посмотреть наличие множества ztest по шаблону, 7 микросекунд
```sh
127.0.0.1:6379> KEYS ztest*
1) "ztest"

1738259050.902831 [0 127.0.0.1:59756] "KEYS" "ztest*"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 76597
   2) (integer) 1738259050
   3) (integer) 7
   4) 1) "KEYS"
      2) "ztest*"
   5) "127.0.0.1:59756"
   6) ""

```

Команды: посмотреть мощность и кол-во упорядоченного множества, попадают в лог медленных операций со значением параметра slowlog-log-slower-than 10, соответственно 11 и 33 микросек.
```sh
127.0.0.1:6379> ZCARD ztest
(integer) 15840

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 5
   2) (integer) 1738256146
   3) (integer) 11
   4) 1) "ZCARD"
      2) "ztest"
   5) "127.0.0.1:48156"
   6) ""


127.0.0.1:6379> ZCOUNT ztest 0 99999
(integer) 15840

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 7
   2) (integer) 1738256258
   3) (integer) 33
   4) 1) "ZCOUNT"
      2) "ztest"
      3) "0"
      4) "99999"
   5) "127.0.0.1:48156"
   6) ""

```

Получить все элементы с ранжированием, 1.62 секунды
```sh
127.0.0.1:6379> ZRANGE ztest 0 99999 WITHSCORES
    1) "row: 1821, name: Meladi Papo,language: Sesotho sa Leboa,id: RJAZQ6BBLRT72CD9,bio: Quisque efficitur vel sapien ut imperdiet. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Ut accumsan, est vel fringilla varius, purus augue blandit nisl, eu rhoncus ligula purus vel dolor. Etiam congue dignissim volutpat. Donec congue sapien vel euismod interdum.,version: 7.22"
    2) "1489"
...
31679) "row: 5482, name: Mohan Pandey,language: Hindi,id: XAHKVLM3I1WSPNIW,bio: Maecenas quis nisi nunc. Ut dictum, ligula eget sagittis maximus, tellus mi varius ex, a accumsan justo tellus vitae leo. Ut maximus, libero nec facilisis fringilla, ex sem sollicitudin leo, non congue tortor ligula in eros. Morbi ac tellus erat.,version: 8.1"
31680) "95896"
(1.62s)
```
в логе команда заняла 26 с лишним миллисекунд (26799 микросек)
```sh
127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 19
   2) (integer) 1738254386
   3) (integer) 26799
   4) 1) "ZRANGE"
      2) "ztest"
      3) "0"
      4) "99999"
      5) "WITHSCORES"
   5) "127.0.0.1:57790"
   6) ""
```
Получить один элемент, занимает 19 микросекунд
```sh
127.0.0.1:6379> ZRANGE ztest 12345 12345 WITHSCORES
1) "row: 4356, name: Afzal Ghaffar,language: Sindhi,id: ENTOCR13RSCLZ6KU,bio: Aliquam sollicitudin ante ligula, eget malesuada nibh efficitur et. Pellentesque massa sem, scelerisque sit amet odio id, cursus tempor urna. Etiam congue dignissim volutpat. Vestibulum pharetra libero et velit gravida euismod.,version: 1.88"
2) "62034"

2) 1) (integer) 0
   2) (integer) 1738254680
   3) (integer) 19
   4) 1) "ZRANGE"
      2) "ztest"
      3) "12345"
      4) "12345"
      5) "WITHSCORES"
   5) "127.0.0.1:48156"
   6) ""
```
Добавить вручную еще одно значение, 41 микросекунда
```sh
127.0.0.1:6379> ZADD ztest 67512 "row: 15841, name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"
(integer) 1

127.0.0.1:6379> MONITOR
OK
1738255961.383747 [0 127.0.0.1:48156] "ZADD" "ztest" "67512" "row: 15841, name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellus massa ligula, hendrerit eget efficitur eget, tincidunt in ligula. Quisque mauris ligula, efficitur porttitor sodales ac, lacinia non ex. Maecenas quis nisi nunc.,version: 2.69"

127.0.0.1:6379> SLOWLOG GET
1) 1) (integer) 3
   2) (integer) 1738255961
   3) (integer) 41
   4) 1) "ZADD"
      2) "ztest"
      3) "67512"
      4) "row: 15841, name: Bhupesh Menon,language: Hindi,id: 0CEPNRDV98KT3ORP,bio: Maecenas tempus neque ut porttitor malesuada. Phasellu... (177 more bytes)"
   5) "127.0.0.1:48156"
   6) ""
```

## Redis CLuster
Создадим три виртуальные машины в яндекс облаке
```sh
#yc compute instance create redis1 --ssh-key .ssh/id_rsa.pub --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=30 --network-interface subnet-name=default-ru-central1-d,nat-ip-version=ipv4 --memory 4G --cores 2 --zone ru-central1-d --hostname redis1
#yc compute instance create redis2 --ssh-key .ssh/id_rsa.pub --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=30 --network-interface subnet-name=default-ru-central1-d,nat-ip-version=ipv4 --memory 4G --cores 2 --zone ru-central1-d --hostname redis2
#yc compute instance create redis3 --ssh-key .ssh/id_rsa.pub --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=30 --network-interface subnet-name=default-ru-central1-d,nat-ip-version=ipv4 --memory 4G --cores 2 --zone ru-central1-d --hostname redis3

#yc compute instance list
+----------------------+----------+---------------+---------+----------------+-------------+
|          ID          |   NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+----------+---------------+---------+----------------+-------------+
| fv4ofl352fkdapfgh3b2 | redis1   | ru-central1-d | RUNNING | 158.160.149.79 | 10.130.0.29 |
| fv4ldavd6gorg1vif58q | redis2   | ru-central1-d | RUNNING | 84.201.146.150 | 10.130.0.3  |
| fv4spq2fse6j0fcbsp82 | redis3   | ru-central1-d | RUNNING | 84.201.145.34  | 10.130.0.16 |
+----------------------+----------+---------------+---------+----------------+-------------+

```
Заходим на машину, сделаем подготовки, установим redis, остановим созданный сервис
```sh
#ssh yc-user@158.160.149.79

sysctl vm.overcommit_memory=1
sudo apt-get update
sudo apt-get install redis-server
sudo systemctl disable redis-server.service
sudo systemctl stop redis-server.service
```
Создадим свои сервисы redis по два на каждую машину.
Забиндим общение между службами по внутренним ip-адресам.
На первой машинке создадим сервисы redis на портах 6379 и 6380, каждый со своим конфигом с пометкой порта

Для redis на порту 6379, например:
```sh
sudo mkdir /var/lib/redis/6379
chown redis:redis -R /var/lib/redis/6379/

sudo vi /etc/redis/redis_6379.conf
#
bind 10.130.0.29 10.130.0.3 10.130.0.16
port 6379
dir /var/lib/redis/6379/
appendonly yes
protected-mode no
cluster-enabled yes
cluster-node-timeout 5000
cluster-config-file /etc/redis/nodes_6379.conf
pidfile /var/run/redis/redis_6379.pid
logfile /var/log/redis/redis_6379.log
#

chown redis:redis /etc/redis/redis_6379.conf

sudo vi /etc/systemd/system/redis_6379.service
#
[Unit]
Description=Redis key-value database on 6379
After=network.target
[Service]
ExecStart=/usr/bin/redis-server /etc/redis/redis_6379.conf --supervised systemd
ExecStop=/bin/redis-cli -h 127.0.0.1 -p 6379 shutdown
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
#

systemctl daemon-reload
systemctl start redis_6379.service
```
Для redis на порту 6380, аналогично
```sh
sudo mkdir /var/lib/redis/6380
chown redis:redis -R /var/lib/redis/6380/

sudo vi /etc/redis/redis_6380.conf
#
bind 10.130.0.29 10.130.0.3 10.130.0.16
port 6380
dir /var/lib/redis/6380/
appendonly yes
protected-mode no
cluster-enabled yes
cluster-node-timeout 5000
cluster-config-file /etc/redis/nodes_6380.conf
pidfile /var/run/redis/redis_6380.pid
logfile /var/log/redis/redis_6380.log
#

chown redis:redis /etc/redis/redis_6380.conf

sudo vi /etc/systemd/system/redis_6380.service
#
[Unit]
Description=Redis key-value database on 6380
After=network.target
[Service]
ExecStart=/usr/bin/redis-server /etc/redis/redis_6380.conf --supervised systemd
ExecStop=/bin/redis-cli -h 127.0.0.1 -p 6380 shutdown
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
#
systemctl start redis_6380.service
```
В логе redis на порту 6379 такая картина
```
18702:M 31 Jan 2025 16:31:58.668 # User requested shutdown...
18702:M 31 Jan 2025 16:31:58.668 * Calling fsync() on the AOF file.
18702:M 31 Jan 2025 16:31:58.668 * Removing the pid file.
18702:M 31 Jan 2025 16:31:58.668 # Redis is now ready to exit, bye bye...
19023:C 31 Jan 2025 16:31:58.680 # WARNING supervised by systemd - you MUST set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
19023:C 31 Jan 2025 16:31:58.680 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
19023:C 31 Jan 2025 16:31:58.680 # Redis version=6.0.16, bits=64, commit=00000000, modified=0, pid=19023, just started
19023:C 31 Jan 2025 16:31:58.680 # Configuration loaded
19023:M 31 Jan 2025 16:31:58.681 # Could not create server TCP listening socket 10.130.0.3:6379: bind: Cannot assign requested address
19023:M 31 Jan 2025 16:31:58.681 # Could not create server TCP listening socket 10.130.0.16:6379: bind: Cannot assign requested address
19023:M 31 Jan 2025 16:31:58.682 * Node configuration loaded, I'm d0de94ca2d18af9dd67cc7f25d501b858d1872f9
19023:M 31 Jan 2025 16:31:58.682 # Could not create server TCP listening socket 10.130.0.3:16379: bind: Cannot assign requested address
19023:M 31 Jan 2025 16:31:58.682 # Could not create server TCP listening socket 10.130.0.16:16379: bind: Cannot assign requested address
19023:M 31 Jan 2025 16:31:58.683 * Running mode=cluster, port=6379.
19023:M 31 Jan 2025 16:31:58.683 # Server initialized
19023:M 31 Jan 2025 16:31:58.684 * Ready to accept connections
```
На других двух машинах redis2 и redis3 установим redis и создадим аналогично по два сервиса 

на машине redis2 10.130.0.3 на портах 6381 и 6382

на машине redis3 10.130.0.16 на портах 6383 и 6384

Создадим кластер из этих шести отдельных инстансов командой:
```sh
# redis-cli --cluster create 10.130.0.29:6379 10.130.0.29:6380 10.130.0.3:6381 10.130.0.3:6382 10.130.0.16:6383 10.130.0.16:6384 --cluster-replicas 1
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 10.130.0.3:6382 to 10.130.0.29:6379
Adding replica 10.130.0.16:6384 to 10.130.0.3:6381
Adding replica 10.130.0.29:6380 to 10.130.0.16:6383
M: d0de94ca2d18af9dd67cc7f25d501b858d1872f9 10.130.0.29:6379
   slots:[0-5460] (5461 slots) master
S: dd088d12267b292756e4394b163a2fd9bd311d59 10.130.0.29:6380
   replicates 716171e7ea71f2947f4fe7ee09dd16ad4afd6710
M: cbe5fe995cf13788a8a779f3bfa1596b080e82ff 10.130.0.3:6381
   slots:[5461-10922] (5462 slots) master
S: 95110a7682a8eee49830640426f0c69c0505b052 10.130.0.3:6382
   replicates d0de94ca2d18af9dd67cc7f25d501b858d1872f9
M: 716171e7ea71f2947f4fe7ee09dd16ad4afd6710 10.130.0.16:6383
   slots:[10923-16383] (5461 slots) master
S: 31f4b857dd0a7262dcba588aaf79fd1d5ece809e 10.130.0.16:6384
   replicates cbe5fe995cf13788a8a779f3bfa1596b080e82ff
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
.
>>> Performing Cluster Check (using node 10.130.0.29:6379)
M: d0de94ca2d18af9dd67cc7f25d501b858d1872f9 10.130.0.29:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 31f4b857dd0a7262dcba588aaf79fd1d5ece809e 10.130.0.16:6384
   slots: (0 slots) slave
   replicates cbe5fe995cf13788a8a779f3bfa1596b080e82ff
S: dd088d12267b292756e4394b163a2fd9bd311d59 10.130.0.29:6380
   slots: (0 slots) slave
   replicates 716171e7ea71f2947f4fe7ee09dd16ad4afd6710
S: 95110a7682a8eee49830640426f0c69c0505b052 10.130.0.3:6382
   slots: (0 slots) slave
   replicates d0de94ca2d18af9dd67cc7f25d501b858d1872f9
M: 716171e7ea71f2947f4fe7ee09dd16ad4afd6710 10.130.0.16:6383
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: cbe5fe995cf13788a8a779f3bfa1596b080e82ff 10.130.0.3:6381
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
root@redis1:~#
```
Соглашаемся с предложенной конфигурацией, у нас три мастера с указанным распределением слотов и у каждого по реплике.
Получилась топология, какую и хотели получить: на трех машинах и со смещением реплик для отказоустойчивости

![Alt text](topology.png?raw=true "topology")


В логе любого из трех мастеров такая картина, например первого:
```
19023:M 31 Jan 2025 16:38:20.414 # configEpoch set to 1 via CLUSTER SET-CONFIG-EPOCH
19023:M 31 Jan 2025 16:38:20.462 # IP address for this node updated to 10.130.0.29
19023:M 31 Jan 2025 16:38:22.730 * Replica 10.130.0.3:6382 asks for synchronization
19023:M 31 Jan 2025 16:38:22.730 * Partial resynchronization not accepted: Replication ID mismatch (Replica asked for 'b41d3a71fdb97cf6dd6a094464edd89b0a3e51f3', my replication IDs are '131449c6b1e95f5d9c393b7041faafd9d3bec331' and '0000000000000000000000000000000000000000')
19023:M 31 Jan 2025 16:38:22.730 * Replication backlog created, my new replication IDs are '2c458bf41236d8d2e881d7cf44777716eb68c7ce' and '0000000000000000000000000000000000000000'
19023:M 31 Jan 2025 16:38:22.730 * Starting BGSAVE for SYNC with target: disk
19023:M 31 Jan 2025 16:38:22.731 * Background saving started by pid 19112
19112:C 31 Jan 2025 16:38:22.734 * DB saved on disk
19112:C 31 Jan 2025 16:38:22.735 * RDB: 0 MB of memory used by copy-on-write
19023:M 31 Jan 2025 16:38:22.769 * Background saving terminated with success
19023:M 31 Jan 2025 16:38:22.769 * Synchronization with replica 10.130.0.3:6382 succeeded
19023:M 31 Jan 2025 16:38:25.375 # Cluster state changed: ok
```
в логе реплики
```
19048:M 31 Jan 2025 16:38:20.414 # configEpoch set to 2 via CLUSTER SET-CONFIG-EPOCH
19048:M 31 Jan 2025 16:38:20.563 # IP address for this node updated to 10.130.0.29
19048:S 31 Jan 2025 16:38:22.421 * Before turning into a replica, using my own master parameters to synthesize a cached master: I may be able to synchronize with the new master with just a partial transfer.
19048:S 31 Jan 2025 16:38:22.421 # Cluster state changed: ok
19048:S 31 Jan 2025 16:38:23.386 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 16:38:23.386 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 16:38:23.386 * Non blocking connect for SYNC fired the event.
19048:S 31 Jan 2025 16:38:23.386 * Master replied to PING, replication can continue...
19048:S 31 Jan 2025 16:38:23.387 * Trying a partial resynchronization (request 701ee81a8e8cb8897de91c810edf6294faeaedd8:1).
19048:S 31 Jan 2025 16:38:23.388 * Full resync from master: c6c89cb26d932fa90a669e8c89149a9d642ad915:0
19048:S 31 Jan 2025 16:38:23.388 * Discarding previously cached master state.
19048:S 31 Jan 2025 16:38:23.486 * MASTER <-> REPLICA sync: receiving 176 bytes from master to disk
19048:S 31 Jan 2025 16:38:23.486 * MASTER <-> REPLICA sync: Flushing old data
19048:S 31 Jan 2025 16:38:23.486 * MASTER <-> REPLICA sync: Loading DB in memory
19048:S 31 Jan 2025 16:38:23.489 * Loading RDB produced by version 6.0.16
19048:S 31 Jan 2025 16:38:23.489 * RDB age 0 seconds
19048:S 31 Jan 2025 16:38:23.489 * RDB memory usage when created 2.54 Mb
19048:S 31 Jan 2025 16:38:23.489 * MASTER <-> REPLICA sync: Finished with success
19048:S 31 Jan 2025 16:38:23.489 * Background append only file rewriting started by pid 19113
19048:S 31 Jan 2025 16:38:23.526 * AOF rewrite child asks to stop sending diffs.
19113:C 31 Jan 2025 16:38:23.526 * Parent agreed to stop sending diffs. Finalizing AOF...
19113:C 31 Jan 2025 16:38:23.526 * Concatenating 0.00 MB of AOF diff received from parent.
19113:C 31 Jan 2025 16:38:23.526 * SYNC append only file rewrite performed
19113:C 31 Jan 2025 16:38:23.527 * AOF rewrite: 0 MB of memory used by copy-on-write
19048:S 31 Jan 2025 16:38:23.586 * Background AOF rewrite terminated with success
19048:S 31 Jan 2025 16:38:23.586 * Residual parent diff successfully flushed to the rewritten AOF (0.00 MB)
19048:S 31 Jan 2025 16:38:23.586 * Background AOF rewrite finished successfully
```
Вывод команды о нодах кластера:
```sh
# redis-cli -c -h 10.130.0.29
10.130.0.29:6379> CLUSTER NODES
31f4b857dd0a7262dcba588aaf79fd1d5ece809e 10.130.0.16:6384@16384 slave cbe5fe995cf13788a8a779f3bfa1596b080e82ff 0 1738342740997 3 connected
dd088d12267b292756e4394b163a2fd9bd311d59 10.130.0.29:6380@16380 slave 716171e7ea71f2947f4fe7ee09dd16ad4afd6710 0 1738342741999 5 connected
95110a7682a8eee49830640426f0c69c0505b052 10.130.0.3:6382@16382 slave d0de94ca2d18af9dd67cc7f25d501b858d1872f9 0 1738342740595 1 connected
716171e7ea71f2947f4fe7ee09dd16ad4afd6710 10.130.0.16:6383@16383 master - 0 1738342742502 5 connected 10923-16383
cbe5fe995cf13788a8a779f3bfa1596b080e82ff 10.130.0.3:6381@16381 master - 0 1738342741000 3 connected 5461-10922
d0de94ca2d18af9dd67cc7f25d501b858d1872f9 10.130.0.29:6379@16379 myself,master - 0 1738342741000 1 connected 0-5460
```

Зададим три значения, они равномерно распределились по кластеру. Запись ключа "a" произошла на третий мастер
```sh
10.130.0.29:6379> SET a 1
-> Redirected to slot [15495] located at 10.130.0.16:6383
OK
10.130.0.16:6383> SET b 2
-> Redirected to slot [3300] located at 10.130.0.29:6379
OK
10.130.0.29:6379> SET c 3
-> Redirected to slot [7365] located at 10.130.0.3:6381
OK
```
Остановим третий мастер
```sh
systemctl stop redis_6383.service
#лог
15619:signal-handler (1738343106) Received SIGTERM scheduling shutdown...
15619:M 31 Jan 2025 17:05:06.684 # User requested shutdown...
15619:M 31 Jan 2025 17:05:06.684 * Calling fsync() on the AOF file.
15619:M 31 Jan 2025 17:05:06.684 * Removing the pid file.
15619:M 31 Jan 2025 17:05:06.684 # Redis is now ready to exit, bye bye...
```
в логах других сервисов
```
tail -f /var/log/redis/redis_6381.log
15734:M 31 Jan 2025 17:05:14.908 * FAIL message received from 95110a7682a8eee49830640426f0c69c0505b052 about 716171e7ea71f2947f4fe7ee09dd16ad4afd6710
15734:M 31 Jan 2025 17:05:14.908 # Cluster state changed: fail
15734:M 31 Jan 2025 17:05:16.016 # Failover auth granted to dd088d12267b292756e4394b163a2fd9bd311d59 for epoch 7
15734:M 31 Jan 2025 17:05:16.024 # Cluster state changed: ok
```
В логе его бывшей реплики на первой машине на порту 6380:
```sh
tail -fn50 /var/log/redis/redis_6380.log
19048:S 31 Jan 2025 17:05:06.698 # Connection with master lost.
19048:S 31 Jan 2025 17:05:06.698 * Caching the disconnected master state.
19048:S 31 Jan 2025 17:05:07.504 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:07.504 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:07.504 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:08.508 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:08.508 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:08.510 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:09.512 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:09.512 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:09.512 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:10.515 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:10.515 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:10.515 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:11.518 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:11.518 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:11.519 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:12.520 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:12.520 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:12.521 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:13.522 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:13.522 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:13.523 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:14.526 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:14.527 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:14.527 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:14.929 * FAIL message received from 95110a7682a8eee49830640426f0c69c0505b052 about 716171e7ea71f2947f4fe7ee09dd16ad4afd6710
19048:S 31 Jan 2025 17:05:14.929 # Cluster state changed: fail
19048:S 31 Jan 2025 17:05:15.028 # Start of election delayed for 932 milliseconds (rank #0, offset 2290).
19048:S 31 Jan 2025 17:05:15.530 * Connecting to MASTER 10.130.0.16:6383
19048:S 31 Jan 2025 17:05:15.531 * MASTER <-> REPLICA sync started
19048:S 31 Jan 2025 17:05:15.531 # Error condition on socket for SYNC: Connection refused
19048:S 31 Jan 2025 17:05:16.034 # Starting a failover election for epoch 7.
19048:S 31 Jan 2025 17:05:16.042 # Failover election won: I'm the new master.
19048:S 31 Jan 2025 17:05:16.042 # configEpoch set to 7 after successful failover
19048:M 31 Jan 2025 17:05:16.042 * Discarding previously cached master state.
19048:M 31 Jan 2025 17:05:16.042 # Setting secondary replication ID to c6c89cb26d932fa90a669e8c89149a9d642ad915, valid up to offset: 2291. New replication ID is dfc6608efb88597a0da3eeeb4060099be4ca6c7d
19048:M 31 Jan 2025 17:05:16.042 # Cluster state changed: ok
```
После фейловера стал мастером. Текущее состояние кластера
```sh
10.130.0.29:6379> CLUSTER NODES
31f4b857dd0a7262dcba588aaf79fd1d5ece809e 10.130.0.16:6384@16384 slave cbe5fe995cf13788a8a779f3bfa1596b080e82ff 0 1738343428124 3 connected
dd088d12267b292756e4394b163a2fd9bd311d59 10.130.0.29:6380@16380 master - 0 1738343427000 7 connected 10923-16383
95110a7682a8eee49830640426f0c69c0505b052 10.130.0.3:6382@16382 slave d0de94ca2d18af9dd67cc7f25d501b858d1872f9 0 1738343427119 1 connected
716171e7ea71f2947f4fe7ee09dd16ad4afd6710 10.130.0.16:6383@16383 master,fail - 1738343108908 1738343106599 5 disconnected
cbe5fe995cf13788a8a779f3bfa1596b080e82ff 10.130.0.3:6381@16381 master - 0 1738343428123 3 connected 5461-10922
d0de94ca2d18af9dd67cc7f25d501b858d1872f9 10.130.0.29:6379@16379 myself,master - 0 1738343426000 1 connected 0-5460
```

Также можно посмотреть информацию по репликации, у первого мастера есть слейв
```
~#redis-cli -c -h 10.130.0.29
10.130.0.29:6379> INFO replication
# Replication
role:master
connected_slaves:1
slave0:ip=10.130.0.3,port=6382,state=online,offset=6000,lag=0
master_replid:2c458bf41236d8d2e881d7cf44777716eb68c7ce
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:6000
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:6000
10.130.0.29:6379>

# redis по порту 6380 уже сам является мастером, слейва у него нет
~# redis-cli -c -h 10.130.0.29 -p 6380
10.130.0.29:6380> INFO replication
# Replication
role:master
connected_slaves:0
master_replid:dfc6608efb88597a0da3eeeb4060099be4ca6c7d
master_replid2:c6c89cb26d932fa90a669e8c89149a9d642ad915
master_repl_offset:2290
second_repl_offset:2291
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:2290
10.130.0.29:6380>
```

Получим значение ключа "a", ожидаемо оно вернулось со второго сервиса первой машины (порт 6380) который раньше был репликой. Данные доступны, фейловер отработал корректно.
```sh
# redis-cli -c -h 10.130.0.29
10.130.0.29:6379> GET a
-> Redirected to slot [15495] located at 10.130.0.29:6380
"1"
10.130.0.29:6380> GET b
-> Redirected to slot [3300] located at 10.130.0.29:6379
"2"
10.130.0.29:6379> GET c
-> Redirected to slot [7365] located at 10.130.0.3:6381
"3"
```