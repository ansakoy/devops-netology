# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

>Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
>[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

>- составьте Dockerfile-манифест для elasticsearch
>- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
>- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

>Требования к `elasticsearch.yml`:
>- данные `path` должны сохраняться в `/var/lib`
>- имя ноды должно быть `netology_test`

>В ответе приведите:
>- текст Dockerfile манифеста

```
# syntax=docker/dockerfile:1
FROM centos:7

RUN groupadd elastic \
    && useradd -g elastic elastic \
    && mkdir -p /var/lib/data \
    && chown elastic:elastic /var/lib/data \
    && mkdir -p /var/lib/snapshots \
    && chown elastic:elastic /var/lib/snapshots \
    && yum -y install wget && yum clean all


# Вообще это всё должно устанавливаться через wget:
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.3-linux-x86_64.tar.gz
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.3-linux-x86_64.tar.gz.sha512
# Но т.к. буржуи перекрыли доступ из России (возвращает 403), пришлось скачать через VPN и положить
# на сервер руками

COPY elasticsearch-7.17.3-linux-x86_64.tar.gz /home/elastic/elasticsearch-7.17.3-linux-x86_64.tar.gz
COPY elasticsearch-7.17.3-linux-x86_64.tar.gz.sha512 /home/elastic/elasticsearch-7.17.3-linux-x86_64.tar.gz.sha512

USER elastic

RUN cd /home/elastic && tar -xzf elasticsearch-7.17.3-linux-x86_64.tar.gz

COPY elasticsearch.yml /home/elastic/elasticsearch-7.17.3/config/

EXPOSE 9200
EXPOSE 9300

ENV ES_USER=elastic
ENV ES_GROUP=elastic
ENV ES_HOME=/elasticsearch-7.17.3

CMD ["/home/elastic/elasticsearch-7.17.3/bin/elasticsearch"]
```
>- ссылку на образ в репозитории dockerhub

https://hub.docker.com/repository/docker/ansakoy/centos7elsearch717

>- ответ `elasticsearch` на запрос пути `/` в json виде

```
curl http://127.0.0.1:9200
```
```json
{
  "name" : "netology_test",
  "cluster_name" : "netology_test_cluster",
  "cluster_uuid" : "9FNTQ--URa6h9TrfShq5DQ",
  "version" : {
    "number" : "7.17.3",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "5ad023604c8d7416c9eb6c0eadb62b14e766caff",
    "build_date" : "2022-04-19T08:11:19.070913226Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

>Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
>и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

>| Имя | Количество реплик | Количество шард |
>|-----|-------------------|-----------------|
>| ind-1| 0 | 1 |
>| ind-2 | 1 | 2 |
>| ind-3 | 2 | 4 |

>Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Список:
```
curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases tRnJDO-BSHGFbvsppl46ow   1   0         41            0     38.8mb         38.8mb
green  open   ind-1            JozycFsrShq7l9agEfeNdw   1   0          0            0       226b           226b
yellow open   ind-3            eWb8U6ltRfW9Q1FKCPf5lA   4   2          0            0       904b           904b
yellow open   ind-2            gAlk--0LT8ixkoKQTLDMtQ   2   1          0            0       452b           452b
```
Статусы по отдельности:
```
curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
```
```json
{
  "cluster_name" : "netology_test_cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```
```
curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
```
```json
{
  "cluster_name" : "netology_test_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```
```
curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
```
```json
{
  "cluster_name" : "netology_test_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```
>Получите состояние кластера `elasticsearch`, используя API.

```
curl -X GET 'localhost:9200/_cluster/health/?pretty=true'
```
```json
{
  "cluster_name" : "netology_test_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

>Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Потому что в этом кластере одна нода, а индексы 2 и 3 предполагают более одной реплики. Статус сигналит, 
что есть неназначенные реплики. На уровне состояния кластера сообщается, что как минимум у одного из 
индексов желтый статус.

>Удалите все индексы.

```
ansakoy@devnet:~$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
ansakoy@devnet:~$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
ansakoy@devnet:~$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
ansakoy@devnet:~$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases tRnJDO-BSHGFbvsppl46ow   1   0         41            0     38.8mb         38.8mb
```

## Задача 3

>Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

>Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
>данную директорию как `snapshot repository` c именем `netology_backup`.

>**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```
curl -X POST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/var/lib/snapshots" }}'
```
```json
{
  "acknowledged" : true
}
```

>Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```
ansakoy@devnet:~/06_5$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases uPbDMj8zRQWK_Wpr2aGBXA   1   0         41            0     38.8mb         38.8mb
green  open   test             l12xdnc6SmOVgBA8EYCGsA   1   0          0            0       226b           226b
```

>[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

```
ansakoy@devnet:~$ curl -X PUT http://localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"owLjjKDwR6-SLQpb3ei0tA","repository":"netology_backup","version_id":7170399,"version":"7.17.3","indices":[".ds-.logs-deprecation.elasticsearch-default-2022.05.15-000001","test",".ds-ilm-history-5-2022.05.15-000001",".geoip_databases"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-05-15T10:46:26.649Z","start_time_in_millis":1652611586649,"end_time":"2022-05-15T10:46:28.049Z","end_time_in_millis":1652611588049,"duration_in_millis":1400,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}
```

>**Приведите в ответе** список файлов в директории со `snapshot`ами.

```
ansakoy@devnet:~$ sudo docker exec -ti 24b9c2641b52 bash
[elastic@24b9c2641b52 /]$ ls -lha /var/lib/snapshots/
total 60K
drwxr-xr-x 1 elastic elastic 4.0K May 15 10:46 .
drwxr-xr-x 1 root    root    4.0K May 15 10:13 ..
-rw-r--r-- 1 elastic elastic 1.4K May 15 10:46 index-0
-rw-r--r-- 1 elastic elastic    8 May 15 10:46 index.latest
drwxr-xr-x 6 elastic elastic 4.0K May 15 10:46 indices
-rw-r--r-- 1 elastic elastic  29K May 15 10:46 meta-owLjjKDwR6-SLQpb3ei0tA.dat
-rw-r--r-- 1 elastic elastic  712 May 15 10:46 snap-owLjjKDwR6-SLQpb3ei0tA.dat
```

>Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.



>[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

>**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

