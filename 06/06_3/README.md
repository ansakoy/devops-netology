# Домашнее задание к занятию "6.3. MySQL"

[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/06-db-03-mysql/README.md)
## Задача 1

>Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
>
>Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
>восстановитесь из него.
>
>Перейдите в управляющую консоль `mysql` внутри контейнера.
>
>Используя команду `\h` получите список управляющих команд.
>
>Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
```

>Подключитесь к восстановленной БД и получите список таблиц из этой БД.
>
>**Приведите в ответе** количество записей с `price` > 300.

```
1
```

>В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

>Создайте пользователя test в БД c паролем test-pass, используя:
>- плагин авторизации mysql_native_password
>- срок истечения пароля - 180 дней 
>- количество попыток авторизации - 3 
>- максимальное количество запросов в час - 100
>- аттрибуты пользователя:
>    - Фамилия "Pretty"
>   - Имя "James"
>
>Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

*Товарищи, слово "привилегия" пишется как слышится. Все "и", и только под ударением 
"е". Очень легко запомнить.*

>Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
>**приведите в ответе к задаче**.

```
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

>Установите профилирование `SET profiling = 1`.
>Изучите вывод профилирования команд `SHOW PROFILES;`.
>
>Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
```

>Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
>- на `MyISAM`
>- на `InnoDB`

```
+----------+------------+-----------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                   |
+----------+------------+-----------------------------------------------------------------------------------------+
...
|        5 | 0.05737900 | alter table orders engine = MyISAM                                                      |
|        6 | 0.07030125 | alter table orders engine = InnoDB                                                      |
+----------+------------+-----------------------------------------------------------------------------------------+
```

## Задача 4 

>Изучите файл `my.cnf` в директории /etc/mysql.
>
>Измените его согласно ТЗ (движок InnoDB):
>- Скорость IO важнее сохранности данных
>- Нужна компрессия таблиц для экономии места на диске
>- Размер буффера с незакомиченными транзакциями 1 Мб
>- Буффер кеширования 30% от ОЗУ
>- Размер файла логов операций 100 Мб
>
>Приведите в ответе измененный файл `my.cnf`.

```
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
innodb_flush_method = O_DSYNC  # Скорость IO важнее сохранности данных
innodb_flush_log_at_trx_commit = 2  # Скорость IO важнее сохранности данных
innodb_file_per_table = 1  # Нужна компрессия таблиц для экономии места на диске
innodb_log_buffer_size = 1M  # Размер буффера с незакомиченными транзакциями 1 Мб
innodb_buffer_pool_size = 120M  # Буфер кеширования 30% от ОЗУ
innodb_log_file_size = 100M  # Размер файла логов операций 100 Мб
```
