## Task 2
Файл: [docker-compose.yml](docker-compose.yml)
```yaml
version: "3.8"

services:
  db:
    image: postgres:14-alpine
    restart: always
    container_name: psql14alpine
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
запускаем:
```
sudo docker-compose up -d
```
смотрим, что получилось:
```
$ sudo docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
59fb176b234c   postgres:14-alpine   "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp              psql14alpine
3d7867ececd5   mysql:8              "docker-entrypoint.s…"   3 weeks ago     Up 3 weeks     0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql8
```
убираем старый контейнер:
```
ansakoy@devnet:~/06_4$ sudo docker stop mysql8
mysql8
ansakoy@devnet:~/06_4$ sudo docker rm mysql8
mysql8
ansakoy@devnet:~/06_4$ sudo docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
59fb176b234c   postgres:14-alpine   "docker-entrypoint.s…"   9 minutes ago   Up 9 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   psql14alpine
```
подключаемся к контейнеру:
```
sudo docker exec -it psql14alpine bash

# и затем к постгресу
su - postgres
psql
```
или однострочником:
```
sudo docker exec -it psql14alpine psql -U postgres
```
создаем базу
```sql
create user "test_user" with password 'test_user';
create database test_database lc_collate 'ru_RU.UTF-8' lc_ctype 'ru_RU.UTF-8' owner "test_user" template template0;
\q
```
заливаем в базу дамп
```
sudo docker exec -i psql14alpine psql -U postgres -h 127.0.0.1 -p 5432 -d test_database < /var/tmp/test_dump.sql
```
```
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```

> Вариант - скопировать дамп в контейнер и оттуда уже восстановить
> ```
> sudo docker cp test_dump.sql psql14alpine:/var/tmp/test_dump.sql
> ```

снова подключаемся к базе
```
sudo docker exec -it psql14alpine psql -U postgres
```
и проверяем, что получилось
```
postgres=# \l
                                    List of databases
     Name      |   Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
---------------+-----------+----------+-------------+-------------+-----------------------
 postgres      | postgres  | UTF8     | en_US.utf8  | en_US.utf8  | 
 template0     | postgres  | UTF8     | en_US.utf8  | en_US.utf8  | =c/postgres          +
               |           |          |             |             | postgres=CTc/postgres
 template1     | postgres  | UTF8     | en_US.utf8  | en_US.utf8  | =c/postgres          +
               |           |          |             |             | postgres=CTc/postgres
 test_database | test_user | UTF8     | ru_RU.UTF-8 | ru_RU.UTF-8 | 
(4 rows)

postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)
test_database=# select * from orders;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
(8 rows)
```
дальше нужно провести операцию analyze
> [доки постгреса](https://www.postgresql.org/docs/current/sql-analyze.html)
> ANALYZE collects statistics about the contents of tables in the database, 
> and stores the results in the pg_statistic system catalog. 
> Subsequently, the query planner uses these statistics to help determine the most efficient 
> execution plans for queries.
```
test_database=# analyze;
ANALYZE
```
без особых оговорок довольно лаконичный вывод. если нужна очень большая простыня:
```
test_database=# analyze verbose;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
INFO:  analyzing "pg_catalog.pg_type"
INFO:  "pg_type": scanned 15 of 15 pages, containing 603 live rows and 0 dead rows; 603 rows in sample, 603 estimated total rows
INFO:  analyzing "pg_catalog.pg_foreign_table"
INFO:  "pg_foreign_table": scanned 0 of 0 pages, containing 0 live rows and 0 dead rows; 0 rows in sample, 0 estimated total rows
...
```
теперь надо обследовать pg_stats на предмет таблицы `orders`.  
[доки постгреса по pg_stats](https://www.postgresql.org/docs/current/view-pg-stats.html)

>The view pg_stats provides access to the information stored in the pg_statistic catalog. 
>This view allows access only to rows of pg_statistic that correspond to tables the user has 
>permission to read, and therefore it is safe to allow public read access to this view.
>
>pg_stats is also designed to present the information in a more readable format than the underlying 
>catalog — at the cost that its schema must be extended whenever new slot types are defined for pg_statistic.

``` sql
select
    tablename,
    attname,
    avg_width
from pg_stats
where tablename = 'orders'
order by avg_width desc
limit 1;
```
## Task 3
похоже, что речь о секционировании таблиц, говоря в постгресовских терминах.  
[доки постгреса](https://www.postgresql.org/docs/current/ddl-partitioning.html)

[хороший материал про шардирование без привязки лично к постгресу](https://www.digitalocean.com/community/tutorials/understanding-database-sharding)

можно сразу создать секционированную таблицу:
```sql
create table orders (
    id integer not null,
    title character varying(80) not null,
    price integer default 0
) partition by range (price);

create table orders_1 partition of orders for values from (500) to (999999999);

create table orders_2 partition of orders for values from (0) to (500);
```
нижнее значение инклюзивно, верхнее - эксклюзивно
> Recall that adjacent partitions can share a bound value, since range upper bounds are treated as exclusive bounds.

Транзакции:  
[доки постгреса](https://www.postgresql.org/docs/current/tutorial-transactions.html)

`BEGIN` == `START TRANSACTION` ([про start transaction](https://www.postgresql.org/docs/current/sql-start-transaction.html))

переделать существующую монолитную таблицу в секционированную  
[хорошее описание](https://dba.stackexchange.com/questions/106014/how-to-partition-existing-table-in-postgres)
```sql
--Открываем транзакцию
begin;

-- Создаем новую таблицу, которая будет родительской
create table new_world_orders (
    id integer not null,
    title character varying(80) not null,
    price integer default 0
);

-- Создаем таблицы-секции с проверкой корректности различающего значения и индексацией по соответствующей колонке
create table orders_1 (
    constraint pk_lte_499 primary key (id),
    constraint ck_lte_499 check (price <= 499)
) inherits (new_world_orders);
create index idx_lte_499 on orders_1 (price);

create table orders_2 (
    constraint pk_gt_499 primary key (id),
    constraint ck_gt_499 check (price > 499)
) inherits (new_world_orders);
create index idx_gt_499 on orders_2 (price);

-- Раскладываем данные по секциям
insert into orders_1
    select * from orders
    where price <= 499;

insert into orders_2
    select * from orders
    where price > 499;

-- Переименовываем таблицы
alter table orders rename to orders_backup;
alter table new_world_orders rename to orders;

--Закрываем транзакцию
commit;
```
в действии:
```
test_database=# --Открываем транзакцию
test_database=# begin;
BEGIN
test_database=*#
test_database=*# -- Создаем новую таблицу, которая будет родительской
test_database=*# create table new_world_orders (
test_database(*#     id integer not null,
test_database(*#     title character varying(80) not null,
test_database(*#     price integer default 0
test_database(*# );
CREATE TABLE
test_database=*#
test_database=*# -- Создаем таблицы-секции с проверкой корректности различающего значения и индексацией по соответствующей колонке
test_database=*# create table orders_1 (
test_database(*#     constraint pk_lte_499 primary key (id),
test_database(*#     constraint ck_lte_499 check (price <= 499)
test_database(*# ) inherits (new_world_orders);
CREATE TABLE
test_database=*# create index idx_lte_499 on orders_1 (price);
CREATE INDEX
test_database=*# 
test_database=*# create table orders_2 (
test_database(*#     constraint pk_gt_499 primary key (id),
test_database(*#     constraint ck_gt_499 check (price > 499)
test_database(*# ) inherits (new_world_orders);
CREATE TABLE
test_database=*# create index idx_gt_499 on orders_2 (price);
CREATE INDEX
test_database=*# 
test_database=*# -- Раскладываем данные по секциям
test_database=*# insert into orders_1
test_database-*#     select * from orders
test_database-*#     where price <= 499;
INSERT 0 5
test_database=*# 
test_database=*# insert into orders_2
test_database-*#     select * from orders
test_database-*#     where price > 499;
INSERT 0 3
test_database=*#
test_database=*# -- Переименовываем таблицы
test_database=*# alter table orders rename to orders_backup;
ALTER TABLE
test_database=*# alter table new_world_orders rename to orders;
ALTER TABLE
test_database=*#
test_database=*# --Закрываем транзакцию
test_database=*# commit;
COMMIT
```
смотрим, что получилось
```
test_database=# select * from orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

test_database=# select * from orders_1;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

test_database=# select * from orders_2;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)
```

создаем триггер, который будет правильно раскладывать данные по таблицам
```
-- Пишем функцию
create or replace function fn_insert() returns trigger as $$
begin
    if (new.price <= 499) then
        insert into orders_1 values (new.*);
    else
        insert into orders_2 values (NEW.*);
    end if;
    return null;
end;
$$
language plpgsql;

-- Собственно триггер
create trigger tr_insert before insert on orders
for each row execute procedure fn_insert();
```
проверяем в действии
```
insert into orders (id, title, price) values (9, 'New title', 1000);
```
результат:
```
test_database=# select * from orders;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
  9 | New title            |  1000
(9 rows)

test_database=# select * from orders_2;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
  9 | New title          |  1000
(4 rows)

```
примечательно, что в случае секционирования существующей таблицы родительская не считается 
секционированной, тогда как созданная изначально в качестве таковой выделяется:
```
test_database=# \dt
                   List of relations
 Schema |     Name      |       Type        |  Owner   
--------+---------------+-------------------+----------
 public | orders        | table             | postgres
 public | orders_1      | table             | postgres
 public | orders_2      | table             | postgres
 public | orders_backup | table             | postgres
 public | test_orders   | partitioned table | postgres
 public | test_orders_1 | table             | postgres
 public | test_orders_2 | table             | postgres
(7 rows)

```