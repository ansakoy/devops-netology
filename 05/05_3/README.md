
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-03-docker/README.md)

## Задача 1

> Сценарий выполения задачи:

> - создайте свой репозиторий на https://hub.docker.com;
> - выберете любой образ, который содержит веб-сервер Nginx;
> - создайте свой fork образа;
> - реализуйте функциональность:
> запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
> ```
> <html>
> <head>
> Hey, Netology
> </head>
> <body>
> <h1>I’m DevOps Engineer!</h1>
> </body>
> </html>
> ```
> Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

https://hub.docker.com/repository/docker/ansakoy/webpage

* [index.html](task_1/index.html)
* [Dockerfile](task_1/Dockerfile)

## Задача 2

> Посмотрите на сценарий ниже и ответьте на вопрос:
> "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

> Детально опишите и обоснуйте свой выбор.

--

> Сценарий:

> - Высоконагруженное монолитное java веб-приложение;

Для монолитного приложения использование контейнеров имеет мало смысла. Удобство контейнеров 
в том, что они могут запускаться и останавливаться прямо в процессе работы приложения, 
не препятствуя этой работе. Для этого требуется распределенная архитектура приложения. 
монолитную систему лучше запускать на физической или виртуальной машине.

> - Nodejs веб-приложение;

С вероятностью удобно запускать в контейнерах с уже готовой средой. В таком виде удобно 
перезапускать и масштабировать. Если масштабирования не требуется, 
можно обойтись и без контейнеров, а просто прописанными, например в ansible, 
ценариями создания среды.

> - Мобильное приложение c версиями для Android и iOS;

С разработкой мобильных приложений не случалось сталкиваться. Из беглого просмотра статей о 
развертывании мобильных приложений складывается впечатление, что в ходе разработки 
используются виртуальные симуляторы мобильных устройств с соответствующими ОС (фактически виртуальные 
машины). Если приложение постоянно обменивается данными с сервером, то в серверной части 
возможно использование контейнеров, что удобно для масштабирования и регулирования нагрузки.

> - Шина данных на базе Apache Kafka;

Из описания складывается впечатление, что Kafka - это высоконагруженная система, которая 
еще и должна быть постоянно доступна, т.к. обрабатывает данные в реальном времени. 
Контейнер в таком случае - не лучшее решение, скорее ВМ или физическая.

> - Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

Производитель всячески рекомендует докер, в хабе официальные образы - по всей видимости, 
стоит хотя бы попробовать применить рекомендованный подход.

> - Мониторинг-стек на базе Prometheus и Grafana;

Использование контейнеров в этой области очень распространено. Это закономерно: фактически 
речь о том, что установка, настройка и запуск этого стека - это рутинная процедура, 
которая может быть полностью записана в образ и затем воспроизводиться по мере надобности.

> - MongoDB, как основное хранилище данных для java-приложения;

Базы данных лучше хранить на физических машинах, возможно даже в кластерах из нескольких 
машин. Это связанно с тем, что главное действующее лицо тут собственно данные и операции с ними, 
а не код, определяющий поведение приложения, который можно легко и быстро копировать, запускать 
и останавливать.

> - Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Физическая машина. Нагрузка у нее будет не такая большая, тем более с учетом приватности. 
От этого сервера требуется стабильность и доступность для разработчиков.

## Задача 3

> - Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
> - Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
> - Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
> - Добавьте еще один файл в папку ```/data``` на хостовой машине;
> - Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % docker run --name=centos -div ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data:/data centos
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete 
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
93add561c7875085350fefc68da69e8f4bf9035568cb0f8f6134fb67bd257852
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % docker run --name=debian -div ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data:/data debian
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
0c6b8ff8c37e: Pull complete 
Digest: sha256:fb45fd4e25abe55a656ca69a7bef70e62099b8bb42a279a5e0ea4ae1ab410e0d
Status: Downloaded newer image for debian:latest
ac6bef7228e78d0c390ec5b371fb73317b8e24c7284ea3664adc61564fd8e0c9
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
ac6bef7228e7   debian    "bash"        20 seconds ago   Up 19 seconds             debian
93add561c787   centos    "/bin/bash"   54 seconds ago   Up 44 seconds             centos
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % docker exec -ti centos bash
[root@93add561c787 /]# ls
bin  data  dev	etc  home  lib	lib64  lost+found  media  mnt  opt  proc  root	run  sbin  srv	sys  tmp  usr  var
[root@93add561c787 /]# cd data
[root@93add561c787 data]# ls
[root@93add561c787 data]# echo "file from centos" > file_from_centos
[root@93add561c787 data]# ls
file_from_centos
[root@93add561c787 data]# exit
exit
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % echo "file from host" > file_from_host
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % ls
file_from_centos	file_from_host
ansakoy ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data % docker exec -ti debian bash
root@ac6bef7228e7:/# ls /data
file_from_centos  file_from_host
```

## Задача 4 (*)

> Воспроизвести практическую часть лекции самостоятельно.

> Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.


