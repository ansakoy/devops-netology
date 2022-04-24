# 1
[Докер-композ](docker-compose.yml)  
([Инструкция по развертыванию в докере](https://hub.docker.com/_/mysql))
```
sudo docker-compose up -d

ansakoy@devnet:~/06_3$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                          PORTS     NAMES
b352a65b9ce9   mysql:8   "docker-entrypoint.s…"   11 minutes ago   Restarting (1) 21 seconds ago             mysql8
```
Проблема: контейнер перманентно перезагружается. Диагностика:
```
sudo docker logs --tail 50 --follow --timestamps mysql8
```
Повторяющийся сценарий:
```
2022-03-27T21:25:28.214699034Z 2022-03-27T21:25:28.214626Z 0 [System] [MY-010910] [Server] /usr/sbin/mysqld: Shutdown complete (mysqld 8.0.28)  MySQL Community Server - GPL.
2022-03-27T21:25:54.880229423Z 2022-03-27 21:25:54+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.28-1debian10 started.
2022-03-27T21:25:54.991508606Z 2022-03-27 21:25:54+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2022-03-27T21:25:55.003602571Z 2022-03-27 21:25:55+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.28-1debian10 started.
2022-03-27T21:25:55.113696877Z 2022-03-27 21:25:55+00:00 [Note] [Entrypoint]: Initializing database files
2022-03-27T21:25:55.130806357Z 2022-03-27T21:25:55.128295Z 0 [System] [MY-013169] [Server] /usr/sbin/mysqld (mysqld 8.0.28) initializing of server in progress as process 41
2022-03-27T21:25:55.130946742Z 2022-03-27T21:25:55.130486Z 0 [ERROR] [MY-010457] [Server] --initialize specified but the data directory has files in it. Aborting.
2022-03-27T21:25:55.131059215Z 2022-03-27T21:25:55.130521Z 0 [ERROR] [MY-013236] [Server] The designated data directory /var/lib/mysql/ is unusable. You can remove all files that the server added to it.
2022-03-27T21:25:55.131175423Z 2022-03-27T21:25:55.131125Z 0 [ERROR] [MY-010119] [Server] Aborting
```
Итого, оно хочет класть данные в `/var/lib/mysql/`, а мы определили ему вольюм `/var/lib/mysql/data`. 
В данном случае исправим на дефолт.  
И оно сработало.
```
ansakoy@devnet:~/06_3$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
3d7867ececd5   mysql:8   "docker-entrypoint.s…"   12 seconds ago   Up 10 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql8
```
Подключаемся:
```
ansakoy@devnet:~/06_3$ sudo docker exec -it mysql8 mysql -h localhost -P 3306 -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> quit
Bye
```
Копируем файл с дампом в контейнер:
```
sudo docker cp /home/ansakoy/06_3/test_dump.sql mysql8:/var/tmp/test_dump.sql
```
Подключаемся к контейнеру:
```
sudo docker exec -it mysql8 bash

root@3d7867ececd5:/# ls /var/tmp/
test_dump.sql
```
Создаем новую БД
[Доки mysql](https://dev.mysql.com/doc/)
```
root@3d7867ececd5:/# mysql -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database test_db;
Query OK, 1 row affected (0.02 sec)

mysql> quit
Bye
```
* mysql -p - -p - это мы кагбе намекаем мускулу, что мы осознаем, что при логине 
потребуется пароль, иначе будет скандал, что доступ запаролен

Заливаем в нее дамп
```
mysql -u root -p test_db < /var/tmp/test_dump.sql
```
Смотрим, какие бывают команды:
```
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.

For server side help, type 'help contents'
```
Смотрим "статус БД" (кажется, имелось в виду СУБД)
```
mysql> status
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          14
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.28 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 59 min 3 sec

Threads: 2  Questions: 40  Slow queries: 0  Opens: 137  Flush tables: 3  Open tables: 55  Queries per second avg: 0.011
--------------
```
Подключаемся к БД (прямо как в монге):
```
mysql> use test_db
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
```
Список таблиц в ней (опять как в монге):
```
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```
Отравляем базе запрос:
```
mysql> select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.01 sec)
```
Убеждаемся в своей правоте:
```
mysql> select * from orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)
```
# 2
Создаем юзера
```
create user
'test'@'localhost'
identified with mysql_native_password by 'test-pass'
with max_queries_per_hour 100
password expire interval 180 day
failed_login_attempts 3
attribute '{"lname": "Pretty", "fname": "James"}';
```
Даем ему право на запросы
```
grant select on test_db.* to 'test'@'localhost';
```
Смотрим `information_schema.user_attributes`
```
select * from information_schema.user_attributes where user = 'test';
```
#3
To control profiling, use the profiling session variable, which has a default value of 0 (OFF). 
Enable profiling by setting profiling to 1 or ON
```
set profiling = 1;
```
SHOW PROFILES displays a list of the most recent statements sent to the server
```
mysql> show profiles;
+----------+------------+----------------------+
| Query_ID | Duration   | Query                |
+----------+------------+----------------------+
|        1 | 0.00284425 | set profiling = 1    |
|        2 | 0.00527125 | select * from orders |
+----------+------------+----------------------+
2 rows in set, 1 warning (0.00 sec)
```
Engines (вообще все, которые доступны в СУБД)
```
show engines;
```
Посмотреть, какие используются в таблицах определенной БД
```
select table_name, engine
from information_schema.tables
where table_schema = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.02 sec)
```
Изменить engine
```
alter table orders engine = MyISAM;
alter table orders engine = InnoDB;
```