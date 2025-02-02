Сравнение с неграфовыми БД

### Neo4j

Варианты применения графовой базы данных:
1. Логистика, задача доставки груза из пункта А в пункт Г, например, с промежуточными узлами Б и В (уже из контекста понятно что это будут ноды графа). Также свойствами ребер такого графа будут различные типы транспорта, например, имеющего характеристики скорости доставки, стоимости, вместимости.
2. Социальные связи человека, узлы графа - люди. Ребра - это тип возникновения социальных отношений: родственники, друзья, коллеги, однокурсники, одноклассники и прочее. Дополнительно можно навешать нужных свойств как на ребра (как давно знакомы, поддерживаете общение и пр.), так и на узлы графа - то есть "характеристики" человека, которые необходимо и уместно будет отобразить для решения конкректной задачи.

Для практической части развернем neo4j в докере
```sh
~# docker pull neo4j

~# docker run -p7474:7474 -p7687:7687 -e NEO4J_AUTH=neo4j/password neo4j
Changed password for user 'neo4j'. IMPORTANT: this change will only take effect if performed before the database is started for the first time.
2025-02-02 11:45:13.675+0000 INFO  Logging config in use: File '/var/lib/neo4j/conf/user-logs.xml'
2025-02-02 11:45:13.691+0000 INFO  Starting...
2025-02-02 11:45:14.883+0000 INFO  This instance is ServerId{e65967dc} (e65967dc-93e2-4cbe-af55-f645b0f6b83b)
2025-02-02 11:45:16.149+0000 INFO  ======== Neo4j 5.26.1 ========
2025-02-02 11:45:18.870+0000 INFO  Anonymous Usage Data is being sent to Neo4j, see https://neo4j.com/docs/usage-data/
2025-02-02 11:45:18.925+0000 INFO  Bolt enabled on 0.0.0.0:7687.
2025-02-02 11:45:19.689+0000 INFO  HTTP enabled on 0.0.0.0:7474.
2025-02-02 11:45:19.690+0000 INFO  Remote interface available at http://localhost:7474/
2025-02-02 11:45:19.693+0000 INFO  id: 9B997A0831B8EF157B6AA9A9CF35A09E2974470E31A2DF78A42C5C7F65944F42
2025-02-02 11:45:19.694+0000 INFO  name: system
2025-02-02 11:45:19.694+0000 INFO  creationDate: 2025-02-02T11:45:17.41Z
2025-02-02 11:45:19.694+0000 INFO  Started.
```
После проверки доступности портов можно пройти аутентификацию с кредитами которые задали при старте контейнера
![Alt text](neo4j_auth.png?raw=true "neo4j_auth")

Для наглядности сравнения с другой СУБД, создадим одной командой простейший граф о кино
```sh
create (:Director {name:'Joel Coen',born: 1954}) -[:CREATED {have_oscar: 0}]-> (blood:Movie {title:'Blood Simple', year:1983}) <-[:PLAYED_IN {character: 'Abby',role : 'leading',have_oscar: 1}]- (:Actor {name: 'Frances McDormand', born:1957})
```
![Alt text](create_neo4j.png?raw=true "create_neo4j")

В результате 'Added 3 labels, created 3 nodes, set 10 properties, created 2 relationships, completed after 3 ms.' То есть на задавая никакие форматы данных мы сразу создали нужную нам структуру узлов с отношениями и их свойствами.

Посмотрим на результат, для интереса, добавил немного дополнительных свойств и узлам (дата выхода фильма, год рождения для людей) и ребрам (получен ли оскар за эту работу - для всех, персонаж и какая роль сыграна (главная, второго плана) - для актёров)

![Alt text](result_neo4j.png?raw=true "result_neo4j")

### PostgreSQL
Попробуем сделать что-то подобное на реляционной СУБД 

Создадим таблицы кино, людей, лейблов (участие в производстве фильма).

При описывании схемы мы создаём нужные поля с типами данных, добавим для фильма названия и дату выхода, для людей имя и год рождения, для лейблов - функциональную роль участия в создании кино.
Наполним созданные таблички данными
```sql
CREATE TABLE movies
(   "id" integer NOT NULL PRIMARY KEY,
    title text NOT NULL,
    release_year integer NOT NULL);

INSERT INTO movies VALUES
    (1, 'Three Billboards Outside Ebbing, Missouri',2017),
    (2, 'Blood Simple',1983),
    (3, 'The Dark Knight Rises',2012),
    (4, 'Matrix',1999);
	
CREATE TABLE people
(   "id" integer NOT NULL PRIMARY KEY,
    "name" text NOT NULL,
    born integer NOT NULL);

INSERT INTO people VALUES
    (1, 'Ethan Coen',1957),
    (2, 'Joel Coen',1954),
    (3, 'Frances McDormand',1957);
	
CREATE TABLE labels
(   "id" integer NOT NULL PRIMARY KEY,
    "label" text NOT NULL);
	
INSERT INTO labels VALUES
    (1, 'Director'),
    (2, 'Producer'),
    (3, 'Actor'),
    (4, 'Scenario'),
    (5, 'Music'),   
    (6, 'Cinematography');
```
Создадим таблицу отношений, в которой и будем хранить связи между объектами, также навесим внешние ключи для строгости данных
```sql
CREATE TABLE IF NOT EXISTS relations
(
    "id" integer NOT NULL PRIMARY KEY,
	relation text NOT NULL,
    movie_id integer NOT NULL,
    label_id integer NOT NULL,
	people_id integer NOT NULL,
    have_oscar boolean NOT NULL,
    character text NULL,
    type_role text NULL,
	CONSTRAINT fk_movies FOREIGN KEY (movie_id) REFERENCES movies (id),
	CONSTRAINT fk_labels FOREIGN KEY (label_id) REFERENCES labels (id),
	CONSTRAINT fk_people FOREIGN KEY (people_id) REFERENCES people (id)
);
```
Наконец, добавим туда значения, согласно нашей легенде
```
INSERT INTO labels VALUES
    (1, 'CREATED', 2, 1, 2, false,NULL,NULL),
    (2, 'PLAYED', 2, 3, 3, true,'Abby','leading');
```
Чтобы получить удобный для восприятия результат по интересующему нас фильму, можно составить запрос вида
```sql
select m.title,m.release_year,r.relation,l.label,p.name,have_oscar,character,type_role,p.born  from relations r 
join movies m on m.id=r.movie_id
join people p on p.id=r.people_id
join labels l on l.id=r.label_id
where m.title = 'Blood Simple';


    title     | release_year | relation |  label   |       name        | have_oscar | character | type_role | born
--------------+--------------+----------+----------+-------------------+------------+-----------+-----------+------
 Blood Simple |         1983 | CREATED  | Director | Joel Coen         | f          |           |           | 1954
 Blood Simple |         1983 | PLAYED   | Actor    | Frances McDormand | t          | Abby      | leading   | 1957
(2 rows)
```
Для реляционной СУБД, как видно, потребовалось достаточно громоздкое описание, это даже без учёта того, что тут опущен момент ориентации рёбер.
Очевидно работать с графовой бд для данного примера было удобнее для восприятия и более комфортно без необходимости описывать схему данных и задавать типы данных, их обязательность и необходимость. Также можно было придавать необходимые свойства объектам и ребрам на ходу, тогда как для реляционной СУБД схема была задана в начале и более накладно её модифицировать с накоплением данных, тем более на таблицах на которых есть FK.