# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."
[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/07-terraform-02-syntax/README.md)

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud.
Идеально будет познакомится с обоими облаками, потому что они отличаются. 

## Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 

AWS предоставляет достаточно много бесплатных ресурсов в первый год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
    * AmazonEC2FullAccess
    * AmazonS3FullAccess
    * AmazonDynamoDBFullAccess
    * AmazonRDSFullAccess
    * CloudWatchFullAccess
    * IAMFullAccess
1. Добавьте переменные окружения 
    ```
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)
    ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 

В виде результата задания приложите вывод команды `aws configure list`.

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

> 1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
> 2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
> 3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
> 4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

Яндекс предлагает качать терраформ с [зеркала](https://hashicorp-releases.website.yandexcloud.net/terraform/), 
что мы и сделаем. Устанавливаем терраформ:
```
wget https://hashicorp-releases.website.yandexcloud.net/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip
unzip terraform_1.1.9_linux_amd64.zip
```
```
$ ./terraform --version
Terraform v1.1.9
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.2.4. You can update by downloading from https://www.terraform.io/downloads.html
```
Устанавливаем заодно и yc для ручной проверки происходящего
```
ansakoy@devnetbig:~$ curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9739  100  9739    0     0   182k      0 --:--:-- --:--:-- --:--:--  182k
Downloading yc 0.91.0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 86.5M  100 86.5M    0     0  5666k      0  0:00:15  0:00:15 --:--:-- 5871k
Yandex Cloud CLI 0.91.0 linux/amd64

yc PATH has been added to your '/home/ansakoy/.bashrc' profile
yc bash completion has been added to your '/home/ansakoy/.bashrc' profile.
Now we have zsh completion. Type "echo 'source /home/ansakoy/yandex-cloud/completion.zsh.inc' >>  ~/.zshrc" to install itTo complete installation, start a new shell (exec -l $SHELL) or type 'source "/home/ansakoy/.bashrc"' in the current one
ansakoy@devnetbig:~$ yc --version
bash: yc: command not found
ansakoy@devnetbig:~$ source "/home/ansakoy/.bashrc"
ansakoy@devnetbig:~$ yc --version
Yandex Cloud CLI 0.91.0 linux/amd64
```
Получить id каталога
```
yc resource-manager folder get my-folder
```
Посмотрим на наш текущий сервисный аккаунт:
```
ansakoy@devnetbig:~$ yc iam service-account list
+----------------------+--------+
|          ID          |  NAME  |
+----------------------+--------+
| ajeplur8fore43hkmk9u | sa-055 |
+----------------------+--------+
```
И сгенерим для него файл с ключом:
```
ansakoy@devnetbig:~/hwtf1$ yc iam key create --service-account-name sa-055 --output key.json
id: ajeho0a7lcltd5arjd93
service_account_id: ajeplur8fore43hkmk9u
created_at: "2022-07-03T17:18:21.045301405Z"
key_algorithm: RSA_2048

ansakoy@devnetbig:~/hwtf1$ ls
key.json
```
Теперь, чтобы не палить токен, будем передавать в ТФ этот файл.

Инициализируем терраформ с указанным провайдером:
```
ansakoy@devnetbig:~/hwtf1$ ../terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
Результат
```
yc config list
token: *******
cloud-id: b1gkltlcig08copnc8bc
folder-id: b1gjed8md31ldtt38dov
compute-default-zone: ru-central1-a
```
## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 


В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
1. Ссылку на репозиторий с исходной конфигурацией терраформа.  


[Рекомендации по структуре](https://www.terraform.io/language/modules/develop/structure):  
Рекомендуется создавать модули main.tf, variables.tf и outputs.tf, даже если они пустые.

[Еще про модули](https://learn.hashicorp.com/tutorials/terraform/module)

Получить список доступных образов:
```
yc compute image list --folder-id standard-images
```
Можно даже уточнить:
```
yc compute image list --folder-id standard-images | grep ubuntu-20-04-lts-v2022
```
Похоже, что последняя версия - от 20 июня
```
ansakoy@devnetbig:~$ yc compute image list --folder-id standard-images | grep ubuntu-20-04-lts-v2022
| fd82re2tpfl4chaupeuf | ubuntu-20-04-lts-v20220502                                     | ubuntu-2004-lts                                 | f2eljveqcurh622633be           | READY  |
| fd83n3uou8m03iq9gavu | ubuntu-20-04-lts-v20220207                                     | ubuntu-2004-lts                                 | f2e7dln09c42avcbtirs           | READY  |
| fd86cpunl4kkspv0u25a | ubuntu-20-04-lts-v20220411                                     | ubuntu-2004-lts                                 | f2e1omt88cms6s04srtq           | READY  |
| fd86t95gnivk955ulbq8 | ubuntu-20-04-lts-v20220509                                     | ubuntu-2004-lts                                 | f2ecfju2g0fri0pesgeq           | READY  |
| fd879gb88170to70d38a | ubuntu-20-04-lts-v20220404                                     | ubuntu-2004-lts                                 | f2etas6dbq2is1l8lp50           | READY  |
| fd87tirk5i8vitv9uuo1 | ubuntu-20-04-lts-v20220606                                     | ubuntu-2004-lts                                 | f2e8tnsqjeor74blquqc           | READY  |
| fd89ka9p6idl8htbmhok | ubuntu-20-04-lts-v20220124                                     | ubuntu-2004-lts                                 | f2eei02oardlpedocvan           | READY  |
| fd89ovh4ticpo40dkbvd | ubuntu-20-04-lts-v20220530                                     | ubuntu-2004-lts                                 | f2ek1vhoppg2l2afslmq           | READY  |
| fd8anitv6eua45627i0e | ubuntu-20-04-lts-v20220418                                     | ubuntu-2004-lts                                 | f2ema6pmtbjl2kmcjlbv           | READY  |
| fd8ba0ukgkn46r0qr1gi | ubuntu-20-04-lts-v20220117                                     | ubuntu-2004-lts                                 | f2e0m9t25irr79kalsdn           | READY  |
| fd8ciuqfa001h8s9sa7i | ubuntu-20-04-lts-v20220523                                     | ubuntu-2004-lts                                 | f2eupbrht1hd5ooqe9ec           | READY  |
| fd8f1tik9a7ap9ik2dg1 | ubuntu-20-04-lts-v20220620                                     | ubuntu-2004-lts                                 | f2eu4hp2k4r04d1usuh3           | READY  |
```
Вообще еще есть такое `yc compute image get-latest-from-family <IMAGE-FAMILY> [Global Flags...]`, но 
в варианте `yc compute image get-latest-from-family ubuntu-2004-lts` почему-то дает ошибку
```
ansakoy@devnetbig:~/hwtf1$ yc compute image get-latest-from-family ubuntu-2004-lts
ERROR: rpc error: code = NotFound desc = Image "ubuntu-2004-lts" not found


server-request-id: e4a1ac3f-e7e8-464f-b537-9c1df21e4990
client-request-id: 1a4f56c1-37a4-43f6-8d0d-98b71208a9b1
server-trace-id: dd21567cf1b284eb:8d85f9b127203e0b:dd21567cf1b284eb:1
client-trace-id: 4c8a3973-998f-4ca7-8811-0542e40764f4

Use server-request-id, client-request-id, server-trace-id, client-trace-id for investigation of issues in cloud support
If you are going to ask for help of cloud support, please send the following trace file: /home/ansakoy/.config/yandex-cloud/logs/2022-07-04T00-58-07.161-yc_compute_image_get-latest-from-family_ubuntu-2004-lts.txt
```

Инициализируем терраформ:
```
ansakoy@devnetbig:~/hwtf1$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding yandex-cloud/yandex versions matching "~> 0.70"...
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
И запускаем ТФ-план
```
ansakoy@devnetbig:~/hwtf1$ terraform plan                                                                                                                                          
                                                                                                                                                                                   
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:                                         
  + create                                                                                                                                                                         
                                                                                                                                                                                   
Terraform will perform the following actions:                                                                                                                                      
                                                                                                                                                                                   
  # yandex_compute_instance.node00 will be created                                                                                                                                 
  + resource "yandex_compute_instance" "node00" {                                                                                                                                  
      + allow_stopping_for_update = true
      + created_at                = (known after apply)                   
      + description               = "Инстанс для задания 7.2"                 
      + folder_id                 = (known after apply)         
      + fqdn                      = (known after apply)         
      + hostname                  = "node00.devnet.cloud"         
      + id                        = (known after apply)              
      + metadata                  = {                                                                                                                                              
          + "ssh-keys" = <<-EOT                                     
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2RSc+UgrCP+GO4iZsPHTsVXKAliAw0oJeQtSD9DrSW devnet-ed-key                                                              
            EOT                                                                                                                                                                    
        } 

      + name                      = "node00"                    
      + network_acceleration_type = "standard"                 
      + platform_id               = "standard-v1"               
      + service_account_id        = (known after apply)       
      + status                    = (known after apply)         
      + zone                      = "ru-central1-a"                                                                                                                               
      + boot_disk {                                      
          + auto_delete = true                               
          + device_name = (known after apply)                       
          + disk_id     = (known after apply)                      
          + mode        = (known after apply)                          
                                                                                                                                                                                   
          + initialize_params {                                    
              + block_size  = (known after apply)                       
              + description = (known after apply)                       
              + image_id    = "fd8f1tik9a7ap9ik2dg1"                     
              + name        = "root-node00"                               
              + size        = 20                                      
              + snapshot_id = (known after apply)                      
              + type        = "network-nvme"                                                      
            }                                                           
        }

      + network_interface {                         
          + index              = (known after apply)                 
          + ip_address         = (known after apply)                
          + ipv4               = true                          
          + ipv6               = (known after apply)                 
          + ipv6_address       = (known after apply)                 
          + mac_address        = (known after apply)                               
          + nat                = true                        
          + nat_ip_address     = (known after apply)                 
          + nat_ip_version     = (known after apply)                     
          + security_group_ids = (known after apply)                
          + subnet_id          = (known after apply)                                 
        }                                                                                                                                    
      + placement_policy {                                                                                                                                                         
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "yandex-network-72"
      + subnet_ids                = (known after apply)


  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "yandex-network-72"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.default will be created
  + resource "yandex_vpc_subnet" "default" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "yandex-subnet-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.101.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_node01_yandex_cloud = (known after apply)
  + internal_ip_address_node01_yandex_cloud = (known after apply)
  + subnet_id                               = (known after apply)
  + yandex_account_id                       = "b1gjed8md31ldtt38dov"
  + yandex_avail_zone                       = "ru-central1-a"
  + yandex_user_id                          = "Т.к. это не AWS, кажется, имеет смысл только ID сервисного аккаунта"                                                                                                                                                                          + name                      = "node00"                                                                                                                                             + network_acceleration_type = "standard"                                                                                                                                           + platform_id               = "standard-v1"                                                                                                                                        + service_account_id        = (known after apply)                                                                                                                                  + status                    = (known after apply)                                                                                                                                  + zone                      = "ru-central1-a"                                                                                                                                                                                                                                                                                                                         + boot_disk {                                                                                                                                                                          + auto_delete = true                                                                                                                                                               + device_name = (known after apply)                                                                                                                                                + disk_id     = (known after apply)                                                                                                                                                + mode        = (known after apply)                                                                                                                                                                                                                                                                                                                                   + initialize_params {                                                                                                                                                                  + block_size  = (known after apply)                                                                                                                                                + description = (known after apply)                                                                                                                                                + image_id    = "fd8f1tik9a7ap9ik2dg1"                                                                                                                                             + name        = "root-node00"                                                                                                                                                      + size        = 20                                                                                                                                                                 + snapshot_id = (known after apply)                                                                                                                                                + type        = "network-nvme"                                                                                                                                                   }                                                                                                                                                                              }                                                                                                                                                                  
```
Этот вывод можно сохранить в файл 
```
terraform plan -out=tf_plan
```
и потом этот файл непосредственно и заапплаить.

А если этот файл просматривать человеком, так он нечеловекочитаемый. Чтобы человекопрочитать, 
нужно его посмотреть с помощью `terraform show tf_plan`. Можно сразу с дополнительными 
опциями, например в виде джейсона.
