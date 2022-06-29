# Домашнее задание к занятию "09.06 Gitlab"

Устанавливаем гитлаб CE (Community Edition) по [инструкции](https://about.gitlab.com/install/#ubuntu), 
заменяя везде, где встречается, gitlab-ee на gitlab-ce.

Работающий инстанс: http://gitlab.catabasis.site/

# Домашнее задание к занятию "09.06 Gitlab"

## Подготовка к выполнению

> 1. Необходимо [зарегистрироваться](https://about.gitlab.com/free-trial/)

Буду использовать свой: http://gitlab.catabasis.site/

Лайфхаки:
* по умолчанию первичный юзер нового гитлаба имеет имя root, а его пароль можно посмотреть так:
```bash
ansakoy@devnetbig:/etc/gitlab$ sudo cat initial_root_password 
# WARNING: This value is valid only in the following conditions
#          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for the first time (usually, the first reconfigure run).
#          2. Password hasn't been changed manually, either via UI or via command line.
#
#          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

Password: **************ТАМНАСАМОМДЕЛЕНОРМАЛЬНЫЙПАРОЛЬ************

# NOTE: This file will be automatically deleted in the first reconfigure run after 24 hours.
```
При создании нового юзера из-под рута в веб-интерфейсе сначала нельзя задать пароль, 
сообщается, что он будет отправлен на мейл юзера. Если установка тестовая и никакого почтового 
сервера к ней не прикручено, то ничего страшного. Надо досоздать юзера как есть, сохранить его, 
а потом просто отредактировать его - при редактировании пароль уже можно задать свой.

2. Создайте свой новый проект
3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
4. Проект должен быть публичным, остальные настройки по желанию

## Основная часть

### DevOps

В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
2. Python версии не ниже 3.7
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`
4. Создана директория `/python_api`
5. Скрипт из репозитория размещён в /python_api
6. Точка вызова: запуск скрипта
7. Если сборка происходит на ветке `master`: Образ должен пушится в docker registry вашего gitlab `python-api:latest`, иначе этот шаг нужно пропустить

Во всей этой истории главное - чтобы был раннер. В облачном гитлабе облачный раннер выдается только 
после регистрации карты. Но можно установить свой собственный где-нибудь на сервере, зарегистрировать 
его в проекте и использовать (можно даже в нескольких проектах и в разных гитлабах - 
и облачных, и своих).

[Инструкции](http://gitlab.catabasis.site/ansakoy/devnet_gitlab/-/settings/ci_cd) по установке на линукс:

Установка:
```
# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```
Регистрация:
```
sudo gitlab-runner register --url http://gitlab.catabasis.site/ --registration-token $REGISTRATION_TOKEN
```
$REGISTRATION_TOKEN берется со страницы, на которой настраивается кастомный раннер.

Остальное мелочи жизни. Первый пуш в репозиторий дал ошибку:

```
error during connect: Post "http://docker:2375/v1.24/auth": dial tcp: lookup docker on 8.8.8.8:53: no such host
```
И второй, и девятый пуш, с разными изменениями в соответствиями с веяниями в интернетах, тоже.  
Десятый джоб с пайплайном был отменен по причине вкравшейся опечатки.

После чего начались камлания с гитлаб-раннером в соответствии с [указаниями](https://techoverflow.net/2021/01/12/how-to-fix-gitlab-ci-error-during-connect-post-http-docker2375-v1-40-auth-dial-tcp-lookup-docker-on-no-such-host/)

И оно зависло. Логи сервиса на дебиан/убунту надо смотреть по адресу `/var/log/syslog`

Ну да, там два раза определялось volumes:
```
Jun 28 13:58:31 devnet gitlab-runner[1920470]: #033[31;1mFATAL: Service run failed                         #033[0;m  #033[31;1merror#033[0;m=Near line 45 (last key parsed 'runners.docker.volumes'): Key 'runners.docker.volumes' has already been defined.
Jun 28 13:58:31 devnet systemd[1]: gitlab-runner.service: Main process exited, code=exited, status=1/FAILURE
Jun 28 13:58:31 devnet systemd[1]: gitlab-runner.service: Failed with result 'exit-code'.
```
Убираем лишнее  
Рестартим `sudo gitlab-runner restart`  
Вообще команды раннера описаны [тут](https://docs.gitlab.com/runner/commands/)

И... раннер сразу подхватил джобу, даже без дополнительных напоминаний.

И наконец-то у нас новая ошибка:
```
Error response from daemon: Get "https://registry-1.docker.io/v2/": unauthorized: incorrect username or password
```
Закономерно: registry-то и не сконфигурировано.

Попытки сконфигурировать registry для контейнеров по инструкциям для omnibus привели к тому, 
что сайт в браузере перестал открываться. Пока переходим в облачный гитлаб и пытаемся 
проверить, работает ли всё-таки пайплайн. А потом надо будет ознакомиться с [темой реестра 
контейнеров](https://habr.com/ru/company/timeweb/blog/589675/)

Кстати, что бывает, если забыть поставить -y при инсталляции чего-нибудь:
```
The command '/bin/sh -c yum update -y     && yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel xz-devel     && wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz     && tar xzf Python-3.9.6.tgz     && cd Python-3.9.6     && ./configure --enable-optimizations     && make altinstall     && cd .. && rm Python-3.9.6.tgz     && yum install python3-pip -y     && yum clean all     && pip3 install --upgrade pip3     && pip3 install -r /opt/python_api/requirements.txt' returned a non-zero code: 1
```

Годный конфиг раннера в /etc/gitlab-runner/config.toml
```
[[runners]]
  name = "devnet"
  url = "https://gitlab.com/"
  token = "*******"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "ruby:2.7"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    shm_size = 0

[[runners]]
  name = "devnet"
  url = "http://gitlab.catabasis.site/"
  token = "*******"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "ruby:2.7"
    privileged = true
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    shm_size = 0
```

И после его изменения `sudo gitlab-runner restart`

А еще бывает такая штука, что пайплайн отваливается со словами "на диске не хватает места". 
Это значит, что сожралось дисковое пространство на сервере с раннером, где собственно 
бодро собираются все эти контейнеры из пайплайнов. И тогда это место там надо почистить.

### Product Owner

Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature

### Developer

Вам пришел новый Issue на доработку, вам необходимо:
1. Создать отдельную ветку, связанную с этим issue
2. Внести изменения по тексту из задания
3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

## Итог

После успешного прохождения всех ролей - отправьте ссылку на ваш проект в гитлаб, как решение домашнего задания

## Необязательная часть

Автомазируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---


