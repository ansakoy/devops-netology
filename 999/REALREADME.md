# Дипломный практикум в YandexCloud

[Официальный источник](https://netology.ru/profile/program/fdvpspdc-2/lessons/135374/lesson_items/696439)
[Источник маркдауна](https://github.com/olegbukatchuk/devops-diplom-yandexcloud/blob/main/README.md)

  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
      * [Регистрация доменного имени](#регистрация-доменного-имени)
      * [Создание инфраструктуры](#создание-инфраструктуры)
          * [Установка Nginx и LetsEncrypt](#установка-nginx)
          * [Установка кластера MySQL](#установка-mysql)
          * [Установка WordPress](#установка-wordpress)
          * [Установка Gitlab CE, Gitlab Runner и настройка CI/CD](#установка-gitlab)
          * [Установка Prometheus, Alert Manager, Node Exporter и Grafana](#установка-prometheus)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

---
## Этапы выполнения:

### Регистрация доменного имени

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.

ПРИМЕЧАНИЕ: Далее в качестве примера используется домен `you.domain` замените его вашим доменом.

Рекомендуемые регистраторы:
  - [nic.ru](https://nic.ru)
  - [reg.ru](https://reg.ru)

Цель:

1. Получить возможность выписывать [TLS сертификаты](https://letsencrypt.org) для веб-сервера.

Ожидаемые результаты:

1. У вас есть доступ к личному кабинету на сайте регистратора.
2. Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

### Создание инфраструктуры

Для начала необходимо подготовить инфраструктуру в YC при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

> - Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
> - Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Почти. Использую последнюю стабильную с зеркала.

> 
> Предварительная подготовка:

Немного надоело настраивать YC из командной строки, использовать баш и потом парсить на нем 
ответы - странно, попробуем оборудовать всё через АПИ и Python.  
Смотрим, что мы имеем на этот счет: [доки](https://cloud.yandex.ru/docs/functions/lang/python/)

Довольно мутный, как обычно у яндекса, Cloud Functions. Не хочется углубляться без большой 
уверенности, что понадобится в ближайшее время (а потом еще и изменится всё). Так что 
ограничимся тем, что у них есть просто [устанавливаемый SDK](https://github.com/yandex-cloud/python-sdk).
```
pip install yandexcloud
```
А еще можно забить на SDK и использовать requests. Что мы и сделаем.

[Дока по АПИ](https://cloud.yandex.ru/docs/api-design-guide/)
[Аутентификация](https://cloud.yandex.ru/docs/iam/api-ref/authentication)

> 1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя

Создан специальный сервисный аккаунт по имени `hey-sa` с ролью `editor`. Написан 
[питоний скрипт](https://github.com/ansakoy/devnet-diploma/blob/master/scripts/yc_setup.py), 
который обустраивает ЯО для дальнейший работы.

> 2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
>    а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
>    б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.

Следуем альтернативному варианту. Бакет в ЯО уже есть. Нужно только добавить его ключи в 
уже имеющийся `.env`. Так их проще хранить, не являя миру. Запускать `terraform init`, 
соответственно, проще через питон, там уже для этого всё готово.

> 3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
>    а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  

Почему бы и не создать
```
terraform workspace new stage
terraform workspace new prod
```

>    б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
> 4. Создайте VPC с подсетями в разных зонах доступности.

[Суть истории про зоны доступности](https://cloud.yandex.ru/docs/overview/concepts/geo-scope) в доках ЯО.  
Также из доки мы устанавливаем, что фактически есть всего 2 зоны:
```
ru-central1-a
ru-central1-b
```
А [ru-central1-c](https://cloud.yandex.ru/docs/overview/concepts/ru-central1-c-deprecation) выводится 
из эксплуатации с апреля 2022 и лучше в ее сторону не смотреть.

В целом насчет [сетей и подсетей в ЯО](https://cloud.yandex.ru/docs/vpc/concepts/network)

<details>
<summary>В итоге получился вот такой план</summary>:

```
(venvdiploma) ansakoy@devnetbig:~/diploma/terraform$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # yandex_vpc_network.diploma-vpc-network will be created
  + resource "yandex_vpc_network" "diploma-vpc-network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "vpc-net-a"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-a will be created
  + resource "yandex_vpc_subnet" "subnet-a" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "vpc-subnet-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.subnet-b will be created
  + resource "yandex_vpc_subnet" "subnet-b" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "vpc-subnet-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.100.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```
</details>

> 5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.

<details>
<summary>`terraform apply -auto-approve`</summary>

```
(venvdiploma) ansakoy@devnetbig:~/diploma/terraform$ terraform apply -auto-approve
 
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_vpc_network.diploma-vpc-network will be created
  + resource "yandex_vpc_network" "diploma-vpc-network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "vpc-net-a"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-a will be created
  + resource "yandex_vpc_subnet" "subnet-a" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "vpc-subnet-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.subnet-b will be created
  + resource "yandex_vpc_subnet" "subnet-b" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "vpc-subnet-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.100.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

Plan: 3 to add, 0 to change, 0 to destroy.
yandex_vpc_network.diploma-vpc-network: Creating...
yandex_vpc_network.diploma-vpc-network: Creation complete after 1s [id=enpd2b1lnsj11tm1s6hd]
yandex_vpc_subnet.subnet-b: Creating...
yandex_vpc_subnet.subnet-a: Creating...
yandex_vpc_subnet.subnet-b: Creation complete after 2s [id=e2l94lmp78et14i35h84]
yandex_vpc_subnet.subnet-a: Creation complete after 2s [id=e9baqvrvfijivoce63rv]
```
</details>

Сработало:

![](images/ya_vpc_zones.png)

<details>
<summary> `terraform destroy` </summary>

```
(venvdiploma) ansakoy@devnetbig:~/diploma/terraform$ terraform destroy
yandex_vpc_network.diploma-vpc-network: Refreshing state... [id=enpd2b1lnsj11tm1s6hd]
yandex_vpc_subnet.subnet-b: Refreshing state... [id=e2l94lmp78et14i35h84]
yandex_vpc_subnet.subnet-a: Refreshing state... [id=e9baqvrvfijivoce63rv]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # yandex_vpc_network.diploma-vpc-network will be destroyed
  - resource "yandex_vpc_network" "diploma-vpc-network" {
      - created_at = "2022-07-17T09:33:29Z" -> null
      - folder_id  = "b1gjed8md31ldtt38dov" -> null
      - id         = "enpd2b1lnsj11tm1s6hd" -> null
      - labels     = {} -> null
      - name       = "vpc-net-a" -> null
      - subnet_ids = [
          - "e2l94lmp78et14i35h84",
          - "e9baqvrvfijivoce63rv",
        ] -> null
    }

  # yandex_vpc_subnet.subnet-a will be destroyed
  - resource "yandex_vpc_subnet" "subnet-a" {
      - created_at     = "2022-07-17T09:33:31Z" -> null
      - folder_id      = "b1gjed8md31ldtt38dov" -> null
      - id             = "e9baqvrvfijivoce63rv" -> null
      - labels         = {} -> null
      - name           = "vpc-subnet-a" -> null
      - network_id     = "enpd2b1lnsj11tm1s6hd" -> null
      - v4_cidr_blocks = [
          - "192.168.10.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-a" -> null
    }

  # yandex_vpc_subnet.subnet-b will be destroyed
  - resource "yandex_vpc_subnet" "subnet-b" {
      - created_at     = "2022-07-17T09:33:31Z" -> null
      - folder_id      = "b1gjed8md31ldtt38dov" -> null
      - id             = "e2l94lmp78et14i35h84" -> null
      - labels         = {} -> null
      - name           = "vpc-subnet-b" -> null
      - network_id     = "enpd2b1lnsj11tm1s6hd" -> null
      - v4_cidr_blocks = [
          - "192.168.100.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-b" -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

yandex_vpc_subnet.subnet-b: Destroying... [id=e2l94lmp78et14i35h84]
yandex_vpc_subnet.subnet-a: Destroying... [id=e9baqvrvfijivoce63rv]
yandex_vpc_subnet.subnet-a: Destruction complete after 7s
yandex_vpc_subnet.subnet-b: Destruction complete after 9s
yandex_vpc_network.diploma-vpc-network: Destroying... [id=enpd2b1lnsj11tm1s6hd]
yandex_vpc_network.diploma-vpc-network: Destruction complete after 2s
```

</details>

> 6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Цель:

1. Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2. Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Установка Nginx и LetsEncrypt

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.

**Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь [тестовыми сертификатами](https://letsencrypt.org/docs/staging-environment/), так как количество запросов к боевым серверам LetsEncrypt [лимитировано](https://letsencrypt.org/docs/rate-limits/).**

Рекомендации:
  - Имя сервера: `you.domain`
  - Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

Цель:

1. Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.

Ожидаемые результаты:

1. В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - `https://www.you.domain` (WordPress)
    - `https://gitlab.you.domain` (Gitlab)
    - `https://grafana.you.domain` (Grafana)
    - `https://prometheus.you.domain` (Prometheus)
    - `https://alertmanager.you.domain` (Alert Manager)
2. Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
2. В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!

___
### Установка кластера MySQL

Необходимо разработать Ansible роль для установки кластера MySQL.

Рекомендации:
  - Имена серверов: `db01.you.domain` и `db02.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получить отказоустойчивый кластер баз данных MySQL.

Ожидаемые результаты:

1. MySQL работает в режиме репликации Master/Slave.
2. В кластере автоматически создаётся база данных c именем `wordpress`.
3. В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.

**Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!**

___
### Установка WordPress

Необходимо разработать Ansible роль для установки WordPress.

Рекомендации:
  - Имя сервера: `app.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Установить [WordPress](https://wordpress.org/download/). Это система управления содержимым сайта ([CMS](https://ru.wikipedia.org/wiki/Система_управления_содержимым)) с открытым исходным кодом.


По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

Ожидаемые результаты:

1. Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://www.you.domain` (WordPress)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
4. В браузере можно открыть URL `https://www.you.domain` и увидеть главную страницу WordPress.
---
### Установка Gitlab CE и Gitlab Runner

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

Рекомендации:
  - Имена серверов: `gitlab.you.domain` и `runner.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:
1. Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер `app.you.domain` при коммите в репозиторий с WordPress.

Подробнее об [Gitlab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс Gitlab доступен по https.
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://gitlab.you.domain` (Gitlab)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
3. При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

___
### Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

Рекомендации:
  - Имя сервера: `monitoring.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получение метрик со всей инфраструктуры.

Ожидаемые результаты:

1. Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
2. В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
3. На сервере `you.domain` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5. У Alert Manager есть необходимый [набор правил](https://awesome-prometheus-alerts.grep.to/rules.html) для создания алертов.
2. В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
3. В Grafana есть дашборд отображающий метрики из MySQL (*).
4. В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

---
## Что необходимо для сдачи задания?

1. Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
2. Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
3. Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.
  - `https://www.you.domain` (WordPress)
  - `https://gitlab.you.domain` (Gitlab)
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
4. Все репозитории рекомендуется хранить на одном из ресурсов ([github.com](https://github.com) или [gitlab.com](https://gitlab.com)).

