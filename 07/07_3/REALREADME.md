# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"
[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/07-terraform-03-basic/README.md)

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

AWS нам по-прежнему недоступен, так что будем располагаться в доступном ЯО.

[Инструкция по бакетам (Object Storage)](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-state-storage)

Провайдер был настроен еще на [предыдущем этапе](../07_2/REALREADME.md).

Сервисный аккаунт у нас пока только один, и права у него админские. В инструкции рекомендуют 
сделать его editor, так что создадим нового.

```
yc iam service-account create --name sa-editor
```
```
ansakoy@devnetbig:~$ yc iam service-account create --name sa-editor
id: ajee1rodl5qa3nut4t9e
folder_id: b1gjed8md31ldtt38dov
created_at: "2022-07-06T00:16:40.530463450Z"
name: sa-editor
```
и привяжем к нему соответсвующую роль
```
yc resource-manager folder add-access-binding b1gjed8md31ldtt38dov \
    --role editor \
    --subject serviceAccount:ajee1rodl5qa3nut4t9e
```
Готово.

И сгенерим для него ключ:
```
ansakoy@devnetbig:~/hwtf2$ yc iam key create --service-account-name sa-editor --output key.json
id: ajenvca7ucv1ls63cgab
service_account_id: ajee1rodl5qa3nut4t9e
created_at: "2022-07-06T22:13:35.689358298Z"
key_algorithm: RSA_2048
```
Важно. Этот ключ - не то же самое, что [access_key](https://cloud.yandex.ru/docs/iam/operations/sa/create-access-key) 
(статический ключ), используемый для авторизации в бакете. Он генерится так:
```
yc iam access-key create --service-account-name sa-editor
```
И на выходе получается что-то вроде:
```
access_key:
  id: ajeh22k3jhsu84voa2qe
  service_account_id: ajee1rodl5qa3nut4t9e
  created_at: "2022-07-06T22:18:29.013388634Z"
  key_id: **********
secret: **********
```
Из этого важны key_id  и secret, которые нужно скрывать. Можно было бы сохранить в каких-нибудь файлах 
на сервере, но для разнообразия сложим это в переменные окружения:
```
export TF_VAR_access_key_id="YCAJ**********N5I"
export TF_VAR_access_key_secret="YCO**********oE"
```
А в переменных [variables.tf](terraform/variables.tf) добавим соответствующие 
заглушки:
```hcl
variable "access_key_id" {
  description = "Access key для бакета"
  type        = string
}

variable "access_key_secret" {
  description = "Secret для access key бакета"
  type        = string
}
```
А вот нет, переменные тут не работают:
```
ansakoy@devnetbig:~/hwtf2$ terraform init

Initializing the backend...
╷
│ Error: Variables not allowed
│ 
│   on providers.tf line 14, in terraform:
│   14:     access_key = var.access_key_id
│ 
│ Variables may not be used here.
╵

╷
│ Error: Variables not allowed
│ 
│   on providers.tf line 15, in terraform:
│   15:     secret_key = var.access_key_secret
│ 
│ Variables may not be used here.
```

Ладно, пойдем другим путем. Как советуют на [stackoverflow](https://stackoverflow.com/questions/63048738/how-to-declare-variables-for-s3-backend-in-terraform), 
просто запустим terraform init с дополнительным конфигом бэкенда, передав туда нужные 
переменные окружения. Таким образом, мы можем хранить эти значения, например, в зашифрованном 
файле на сервере и брать их оттуда по мере надобности.
```
terraform init \
-backend-config="access_key=${TF_VAR_access_key_id}" \
-backend-config="secret_key=${TF_VAR_access_key_secret}" 
```
```
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

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

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.

Создаем воркспейсы:
```
ansakoy@devnetbig:~/hwtf2$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
```
```
ansakoy@devnetbig:~/hwtf2$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```
Итого имеем 2 воркспейса, помимо дефолтного:
```
ansakoy@devnetbig:~/hwtf2$ terraform workspace list
  default
* prod
  stage
```

1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.

Создадим локальную переменную `instance_type`, которая определяет определяет в процентах 
нагрузку.
```
locals {
  instance_type = {
    stage = "10"
    prod  = "20"
  }
}
```
И привяжем этот параметр описания ресурса к тому, какой воркспейс мы используем:
```
  resources {
    cores  = 4
    memory = 4
    core_fraction = local.instance_type[terraform.workspace]
  }
```

1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 

Еще одна локальная переменная
```
locals {
  instance_count = {
    stage = 1
    prod  = 2
  }
}
```
Про вычислительные операции в ТФ см. [здесь](https://www.terraform.io/language/configuration-0-11/interpolation#math)

1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.

О жизненном цикле ресурсов [раз](https://www.terraform.io/language/meta-arguments/lifecycle), 
[два](https://learn.hashicorp.com/tutorials/terraform/resource-lifecycle?in=terraform/state)

Добавляем в описание ресурса параметр:

```
lifecycle {
    create_before_destroy = true
  }
```

1. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  