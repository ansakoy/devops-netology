# Задание 1
Пытаемся понять, что имелось в виду. В старой версии задания требовалось создать образ на основе 
centos7 с elasticsearch. Тут задача ясна. А в новой версии требуется создать опять же некий образ, 
но уже на основе образа, где уже установлен elasticsearch. Непонятно, зачем тогда его еще раз создавать. 
Но попробуем.

Для начала попробуем создать докерфайл с указанным образом elasticsearch и запустить этот контейнер.
```
# syntax=docker/dockerfile:1
FROM elasticsearch:7
```
Создаем образ:
```
sudo docker build -t elsearch .
```
Упс:
```
Sending build context to Docker daemon  2.048kB
Step 1/1 : FROM elasticsearch:7
manifest for elasticsearch:7 not found: manifest unknown: manifest unknown
```
А все потому, что elasticseatch не дается устанавливаться с недотегами, надо конкретику:
```
# syntax=docker/dockerfile:1
FROM elasticsearch:7.17.3
```
И почему-то прикатилась latest
```
Sending build context to Docker daemon  2.048kB
Step 1/1 : FROM elasticsearch:7.17.3
7.17.3: Pulling from library/elasticsearch
e0b25ef51634: Pull complete 
0ed156f90b4d: Pull complete 
0b3c161c8ebd: Pull complete 
157de9ee3c7a: Pull complete 
eea187b8272b: Pull complete 
a04594f99bf2: Pull complete 
c88cab9df767: Pull complete 
b95579404185: Pull complete 
3da4afe05b7a: Pull complete 
Digest: sha256:5e6ac15bf6a57c42fa702a647c13749b1249c89e59be8f654f61a3feade9dc47
Status: Downloaded newer image for elasticsearch:7.17.3
 ---> 3c91aa69ae06
Successfully built 3c91aa69ae06
Successfully tagged elsearch:latest
```
Теперь попробуем посмотреть, что получается и запустить контейнер:
```
sudo docker run  -d --name elsearch elsearch
```
Запустился
```$ sudo docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
cf5124376022   elsearch             "/bin/tini -- /usr/l…"   9 seconds ago   Up 6 seconds   9200/tcp, 9300/tcp                          elsearch
```
При этом отключается самостоятельно примерно через 15 секунд после запуска.  
Попробуем использовать [инструкции от производителя](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html):
```docker network create elastic```
```
docker run --name elsearch --net elastic -p 9200:9200 -p 9300:9300 -it elsearch
```
и... нам не хватает памяти:
```
bootstrap check failure [1] of [2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
bootstrap check failure [2] of [2]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```
Ладно, попробуем поднять виртуалку покруче на яндекс-клауде

Для ее обустройства создадим скрипт [setup.sh](setup.sh)

Попробуем изобразить по [инструкции](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html), 
чтобы хоть посмотреть, что это такое
```
sudo docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.3

sudo docker network create elastic

sudo docker run --name es01 --net elastic -p 9200:9200 -p 9300:9300 -it docker.elastic.co/elasticsearch/elasticsearch:7.17.3
```
Опять не хватает памяти, хотя у виртуалки б8 ГБ

Проверяем `less /proc/sys/vm/max_map_count`: действительно, 65530

Попробуем увеличить:
```
sudo sysctl -w vm.max_map_count=262144
```
Это сработало, но новая ошибка:
```
ERROR: [1] bootstrap checks failed. You must address the points described in the following [1] lines before starting Elasticsearch.
bootstrap check failure [1] of [1]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```
А все потому, что использовались инструкции к ES8, а у нас таки ES7. Правильная команда:
```
sudo docker run -p 127.0.0.1:9200:9200 -p 127.0.0.1:9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.17.3
```
Теперь по инструкции всё сработало

Попробуем устроить то же самое с помощью докер-имиджа

(получилось, см. докерфайл и конфиг ЭС)

Создание индексов [дока](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html):
```
$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "index": {
>       "number_of_shards": 1,  
>       "number_of_replicas": 0 
>     }
>   }
> }
> '
```
```json
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
```
```
$ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "index": {
>       "number_of_shards": 2,  
>       "number_of_replicas": 1 
>     }
>   }
> }
> '
```
```json
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
```
```
curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 4,  
      "number_of_replicas": 2 
    }
  }
}
'
```
```json
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```
Проверка состояния (кластера, индексов): [дока](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)
