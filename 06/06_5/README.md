# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

>В этом задании вы потренируетесь в:
>- установке elasticsearch
>- первоначальном конфигурировании elastcisearch
>- запуске elasticsearch в docker
>
>Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:
>
>- составьте Dockerfile-манифест для elasticsearch
>- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
>- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины
>
>Требования к `elasticsearch.yml`:
>- данные `path` должны сохраняться в `/var/lib` 
>- имя ноды должно быть `netology_test`
>
>В ответе приведите:
>- текст Dockerfile манифеста

```
# syntax=docker/dockerfile:1
FROM elasticsearch:7.17.3
COPY elasticsearch.yml /usr/share/elasticsearch/config/
RUN mkdir -p /var/lib/data && chmod 777 /var/lib/data
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
```

>- ссылку на образ в репозитории dockerhub

https://hub.docker.com/repository/docker/ansakoy/elsearch

>- ответ `elasticsearch` на запрос пути `/` в json виде
```
$ curl http://127.0.0.1:9200
```
```json
{
  "name" : "netology_test",
  "cluster_name" : "netology_test_cluster",
  "cluster_uuid" : "I6FopEf7QRubwPGyRAEgRg",
  "version" : {
    "number" : "7.17.3",
    "build_flavor" : "default",
    "build_type" : "docker",
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

>В этом задании вы научитесь:
>- создавать и удалять индексы
>- изучать состояние кластера
>- обосновывать причину деградации доступности данных
>
>Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
>и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:
>
>| Имя | Количество реплик | Количество шард |
>|-----|-------------------|-----------------|
>| ind-1| 0 | 1 |
>| ind-2 | 1 | 2 |
>| ind-3 | 2 | 4 |
>
>Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Список:
```
$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases p-RQYEzcRU6hP_w1wkJl9g   1   0         41            0     38.8mb         38.8mb
green  open   ind-1            B0HDPHLlSfWeOcsQyDpeKQ   1   0          0            0       226b           226b
yellow open   ind-3            R2vllQ7bTi2KbIM6YgvhZg   4   2          0            0       904b           904b
yellow open   ind-2            oe95C5iHSe6B5oO9VHU8sQ   2   1          0            0       452b           452b
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
ansakoy@devnet:~/06_5$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
ansakoy@devnet:~/06_5$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
ansakoy@devnet:~/06_5$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
ansakoy@devnet:~/06_5$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases p-RQYEzcRU6hP_w1wkJl9g   1   0         41            0     38.8mb         38.8mb
```

(.geoip_databases само завелось, видимо, встроено в исходный образ эластика)

## Задача 3

>В данном задании вы научитесь:
>- создавать бэкапы данных
>- восстанавливать индексы из бэкапов
>
>Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
>
>Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
>данную директорию как `snapshot repository` c именем `netology_backup`.
>
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
>состояния кластера `elasticsearch`.

```
ansakoy@devnet:~/06_5$ curl -X PUT http://localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"qpOMO-J_Q3mvrq2WhRpBrw","repository":"netology_backup","version_id":7170399,"version":"7.17.3","indices":["test",".geoip_databases",".ds-.logs-deprecation.elasticsearch-default-2022.05.14-000001",".ds-ilm-history-5-2022.05.14-000001"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-05-14T22:49:42.536Z","start_time_in_millis":1652568582536,"end_time":"2022-05-14T22:49:44.137Z","end_time_in_millis":1652568584137,"duration_in_millis":1601,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}
```

>**Приведите в ответе** список файлов в директории со `snapshot`ами.

```
drwxrwxrwx 1 root          root 4.0K May 14 22:49 .
drwxr-xr-x 1 root          root 4.0K May 14 22:28 ..
-rw-rw-r-- 1 elasticsearch root 1.4K May 14 22:49 index-0
-rw-rw-r-- 1 elasticsearch root    8 May 14 22:49 index.latest
drwxrwxr-x 6 elasticsearch root 4.0K May 14 22:49 indices
-rw-rw-r-- 1 elasticsearch root  29K May 14 22:49 meta-qpOMO-J_Q3mvrq2WhRpBrw.dat
-rw-rw-r-- 1 elasticsearch root  712 May 14 22:49 snap-qpOMO-J_Q3mvrq2WhRpBrw.dat
```

>Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```
ansakoy@devnet:~/06_5$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases uPbDMj8zRQWK_Wpr2aGBXA   1   0         41            0     38.8mb         38.8mb
green  open   test2            LV9iWr6DRSaO0gEkYZChmg   1   0          0            0       226b           226b
```

>[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
>кластера `elasticsearch` из `snapshot`, созданного ранее. 
>
>**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```
ansakoy@devnet:~/06_5$ curl -X POST "localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty" -H 'Content-Type: application/json' -d'
> {
>   "indices": "test"
> }
> '
{
  "accepted" : true
}
ansakoy@devnet:~/06_5$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases uPbDMj8zRQWK_Wpr2aGBXA   1   0         41            0     38.8mb         38.8mb
green  open   test2            LV9iWr6DRSaO0gEkYZChmg   1   0          0            0       226b           226b
green  open   test             jMtnEPy8SBOzblRRw0EF8w   1   0          0            0       226b           226b
```

>Подсказки:
>- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

