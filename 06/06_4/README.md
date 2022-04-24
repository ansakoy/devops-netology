# Домашнее задание к занятию "6.4. PostgreSQL"
[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/06-db-04-postgresql/README.md)
## Задача 1

> Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
> 
> Подключитесь к БД PostgreSQL используя `psql`.
> 
> Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` 
>управляющим командам.
> 
> **Найдите и приведите** управляющие команды для:
> - вывода списка БД
`\l`
> - подключения к БД
`\c`
> - вывода списка таблиц
`\dt`
> - вывода описания содержимого таблиц
`\d`
> - выхода из psql
`\q`

## Задача 2

>Используя `psql` создайте БД `test_database`.
>
>Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).
>
>Восстановите бэкап БД в `test_database`.
>
>Перейдите в управляющую консоль `psql` внутри контейнера.
>
>Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
>
>Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
>с наибольшим средним значением размера элементов в байтах.

*Милая подробность: из ссылки следует, что мы продолжаем жить во времена 12-го постгреса, как и в 06.2. 
было бы куда полезнее, если бы как-то задавался принцип, что надо смотреть в современные доки 
или хотя бы обращать внимание на версию*

>
>**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

Команда:
```
select attname from pg_stats where tablename = 'orders' order by avg_width desc limit 1;
```
Результат:
```
 attname 
---------
 title
(1 row)
```

## Задача 3

>Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до 
>невиданных размеров и поиск по ней занимает долгое время. 
>Вам, как успешному выпускнику курсов DevOps в нетологии предложили 
>провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
>
>Предложите SQL-транзакцию для проведения данной операции.

```
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
Чтобы это еще и работало, желательно добавить триггер, который будет дальше 
распределять значения по нужным секциям:
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
>Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Можно, путем создания сразу секционированной таблицы. Вопрос, нужно ли.
```sql
create table orders (
    id integer not null,
    title character varying(80) not null,
    price integer default 0
) partition by range (price);

create table orders_1 partition of orders
    for values from (499);

create table orders_2 partition of orders
    for values from (0) to (499);
```

## Задача 4

>Используя утилиту `pg_dump` создайте бекап БД `test_database`.
>
>Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца 
>`title` для таблиц `test_database`?

Вообще за "доработку" бэкап-файлов нужно отрывать руки. Поэтому если что-то такое 
делать, то потом это следует тщательно скрывать и никогда об этом никому не рассказывать. 
Если понадобилось обеспечить уникальность значений в столбце, то это надо делать 
путем изменения схемы в работающей базе:
```sql
alter table table_name add constraint constraint_name unique column_name;
```
От этого, конечно, полезут ошибки в случае, если там уже есть неуникальные значения, 
и надо будет их сначала извести, затем добавить уникальность, а потом сделать дамп 
с новой версией схемы.  
Еще более жизненный вариант - это поправить схему, написанную в какой-нибудь ORM, 
смигрировать ее в базу (исправив вылезшие ошибки) и опять же сделать дамп с новой схемой.  
Но у меня есть нехорошее подозрение, что в задании требуется сделать ужасное, то есть 
открыть файл с дампом и прямо написать там что-то в духе:
```
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```
Мы, конечно, знаем, что так делать ни в коем случае нельзя.
