# Домашнее задание к занятию "6.2. SQL"

[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/06-db-02-sql/README.md)

## Задача 1

>Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
>в который будут складываться данные БД и бэкапы.
>
>Приведите получившуюся команду или docker-compose манифест.

```
$ docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
7f2f6d54fb19   postgres:12-alpine   "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   psql12alpine
```
[docker-compose.yml](src/docker-compose.yml)
```yaml
version: "3.8"

services:
  db:
    image: postgres:12-alpine
    restart: always
    container_name: psql12alpine
    environment:
      POSTGRES_PASSWORD: example
    ports:
      - 5432:5432
    volumes:
      - dbdata:/var/lib/postgresql/data
      - backupdata:/var/tmp

volumes:
  dbdata:
  backupdata:
```

## Задача 2

>В БД из задачи 1: 
>- создайте пользователя test-admin-user и БД test_db
>- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
>- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
>- создайте пользователя test-simple-user  
>- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
>
>Таблица orders:
>- id (serial primary key)
>- наименование (string)
>- цена (integer)
>
>Таблица clients:
>- id (serial primary key)
>- фамилия (string)
>- страна проживания (string, index)
>- заказ (foreign key orders)

>Приведите:
>- итоговый список БД после выполнения пунктов выше,

```
test_db=# \l
                                     List of databases
   Name    |      Owner      | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+-----------------+----------+-------------+-------------+-----------------------
 postgres  | postgres        | UTF8     | en_US.utf8  | en_US.utf8  | 
 template0 | postgres        | UTF8     | en_US.utf8  | en_US.utf8  | =c/postgres          +
           |                 |          |             |             | postgres=CTc/postgres
 template1 | postgres        | UTF8     | en_US.utf8  | en_US.utf8  | =c/postgres          +
           |                 |          |             |             | postgres=CTc/postgres
 test_db   | test-admin-user | UTF8     | ru_RU.UTF-8 | ru_RU.UTF-8 | 
(4 rows)
```

>- описание таблиц (describe)

```
test_db=# \d
               List of relations
 Schema |      Name      |   Type   |  Owner   
--------+----------------+----------+----------
 public | clients        | table    | postgres
 public | clients_id_seq | sequence | postgres
 public | orders         | table    | postgres
 public | orders_id_seq  | sequence | postgres
(4 rows)
```

>- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```
select * 
from information_schema.table_privileges
where grantee like 'test%';
```

>- список пользователей с правами над таблицами test_db

```
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(22 rows)
```
Товарищи, имена пользователей через `-`, равно как и названия колонок, 
в постгресе - плохая идея, не надо так делать. А называть колонки таблиц кириллицей - 
это еще более плохая идея. Я уже не говорю о названиях, содержащих пробелы. Это просто 
абсурд.

## Задача 3

>Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:
>
>Таблица orders
>
>|Наименование|цена|
>|------------|----|
>|Шоколад| 10 |
>|Принтер| 3000 |
>|Книга| 500 |
>|Монитор| 7000|
>|Гитара| 4000|
>
>Таблица clients
>
>|ФИО|Страна проживания|
>|------------|----|
>|Иванов Иван Иванович| USA |
>|Петров Петр Петрович| Canada |
>|Иоганн Себастьян Бах| Japan |
>|Ронни Джеймс Дио| Russia|
>|Ritchie Blackmore| Russia|
>
>Используя SQL синтаксис:
>- вычислите количество записей для каждой таблицы 

Вообще количество записей возвращается по умолчанию по итогам выполнения `insert`, если 
не указано специально `returning`, и в обоих случаях вернулось `INSERT 0 5`. Но, наверно, 
имеется в виду, что надо через селект написать отдельно.

>- приведите в ответе:
>    - запросы

```sql
select count(*) as orders_count from orders;
```
```sql
select count(*) as clients_count from clients;
```

>    - результаты их выполнения.

```
 orders_count 
--------------
            5
(1 row)
```
```
 clients_count 
---------------
             5
(1 row)
```
Товарищи, если в задании выше в схеме таблицы задали поле `фамилия`, то немного странно 
в следующем же задании предполагать, что оно называется `"ФИО"`

## Задача 4

>Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
>
>Используя foreign keys свяжите записи из таблиц, согласно таблице:
>
>|ФИО|Заказ|
>|------------|----|
>|Иванов Иван Иванович| Книга |
>|Петров Петр Петрович| Монитор |
>|Иоганн Себастьян Бах| Гитара |
>
>Приведите SQL-запросы для выполнения данных операций.

```
update
  clients
  set "заказ" = (
    select id from orders
    where "наименование" = 'Книга'
  )
  where "фамилия" = 'Иванов Иван Иванович';

update
  clients
  set "заказ" = (
    select id from orders
    where "наименование" = 'Монитор'
  )
  where "фамилия" = 'Петров Петр Петрович';

update
  clients
  set "заказ" = (
    select id from orders
    where "наименование" = 'Гитара'
  )
  where "фамилия" = 'Иоганн Себастьян Бах';
```

>Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```sql
select "фамилия" from clients where "заказ" is not null;
```
```
       фамилия        
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)
```

>Подсказк - используйте директиву `UPDATE`.

## Задача 5

>Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
>(используя директиву EXPLAIN).

```sql
explain select "фамилия" from clients where "заказ" is not null;
```

>Приведите получившийся результат и объясните что значат полученные значения.

```
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..10.70 rows=70 width=516)
   Filter: ("заказ" IS NOT NULL)
(2 rows)
```
* `Seq Scan` используется simple scan plan (без учета индексации)
* `cost`: 0.00 - ожидаемое время до того момента, когда начнется выдача (после предварительных 
операций, таких, как, например, сортировка); 10.70 - ожидаемое время завершения плана
* `rows=70` - сколько строк ожидается к обработке в этом узле плана
* `width=516` - ожидаемая средняя ширина строк в этом узле плана (в байтах)

## Задача 6

>Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
>
>Остановите контейнер с PostgreSQL (но не удаляйте volumes).

*Товарищи, если не удалять совсем никакие вольюмы, то восстановить БД не получится, 
потому что база в контейнере окажется в полной сохранности без всякого восстановления. 
Надо исправить формулировку задачи*.

>Поднимите новый пустой контейнер с PostgreSQL.
>
>Восстановите БД test_db в новом контейнере.
>
>Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

```bash
pg_dump --clean -h 127.0.0.1 -U postgres -d test_db -W > /var/tmp/test_db_dump.sql
exit
sudo docker ps
sudo docker stop psql12alpine
sudo docker rm psql12alpine
sudo docker volume ls
sudo docker volume rm 06_2_dbdata
vim docker-compose.yml (-> -container_name: psql12alpine +container_name: psql12alpine_new)
sudo docker-compose up -d
sudo docker exec -it psql12alpine_new bash
su - postgres
psql
```
В новом контейнере дефолтные базы
```
 \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```
```sql
create user "test-admin-user" with password 'test';
create database test_db lc_collate 'ru_RU.UTF-8' lc_ctype 'ru_RU.UTF-8' owner "test-admin-user" template template0;
\c test_db
grant all
on all tables
in schema "public"
to "test-admin-user";
create user "test-simple-user" with password 'tests';
grant select, insert, update, delete
on all tables
in schema public
to "test-simple-user";
\q
```
```bash
psql -U postgres -h 127.0.0.1 -p 5432 -d test_db < /var/tmp/test_db_dump.sql
```
Проверка:
```bash
psql
```
```
postgres=# \l
                                     List of databases
   Name    |      Owner      | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+-----------------+----------+-------------+-------------+-----------------------
 postgres  | postgres        | UTF8     | en_US.utf8  | en_US.utf8  |
 template0 | postgres        | UTF8     | en_US.utf8  | en_US.utf8  | =c/postgres          +
           |                 |          |             |             | postgres=CTc/postgres
 template1 | postgres        | UTF8     | en_US.utf8  | en_US.utf8  | =c/postgres          +
           |                 |          |             |             | postgres=CTc/postgres
 test_db   | test-admin-user | UTF8     | ru_RU.UTF-8 | ru_RU.UTF-8 |
(4 rows)

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# select * from orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)

test_db=# select * from clients;
 id |       фамилия        | страна проживания | заказ 
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |      
  5 | Ritchie Blackmore    | Russia            |      
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)
```