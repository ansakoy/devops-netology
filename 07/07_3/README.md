# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"
[Источник](https://github.com/netology-code/virt-homeworks/blob/virt-11/07-terraform-03-basic/README.md)

Подробное описание происходившего находится в [REALREADME.md](REALREADME.md)

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

> Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

> 1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
> а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
> [здесь](https://www.terraform.io/docs/backends/types/s3.html).
> 1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

Доступа к AWS у нас по-прежнему нет, но почему бы не попробовать бэкенд ЯО.
```
ansakoy@devnetbig:~/hwtf2$ export TF_VAR_access_key_id="YCAJ**********LtqN5I"
ansakoy@devnetbig:~/hwtf2$ export TF_VAR_access_key_secret="YCOm**********Kyf_LoE"
ansakoy@devnetbig:~/hwtf2$ terraform init \
> -backend-config="access_key=${TF_VAR_access_key_id}" \
> -backend-config="secret_key=${TF_VAR_access_key_secret}"

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

> 1. Выполните `terraform init`:
>     * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
>     * иначе будет создан локальный файл со стейтами.  
    
(выше)

> 1. Создайте два воркспейса `stage` и `prod`.
> 1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
> 1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
> 1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
> 1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
> 1. При желании поэкспериментируйте с другими параметрами и рессурсами.

> В виде результата работы пришлите:
> * Вывод команды `terraform workspace list`.

```
ansakoy@devnetbig:~/hwtf2$ terraform workspace list
  default          
* prod
  stage
```

> * Вывод команды `terraform plan` для воркспейса `prod`.  

```
ansakoy@devnetbig:~/hwtf2$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.node_with_count[0] will be created
  + resource "yandex_compute_instance" "node_with_count" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Инстанс для задания 7.3"
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node1.devnet.cloud"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2RSc+UgrCP+GO4iZsPHTsVXKAliAw0oJeQtSD9DrSW devnet-ed-key
            EOT
        }
      + name                      = "node1-prod"
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
              + name        = "root-node1"
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
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.node_with_count[1] will be created
  + resource "yandex_compute_instance" "node_with_count" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Инстанс для задания 7.3"
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node2.devnet.cloud"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2RSc+UgrCP+GO4iZsPHTsVXKAliAw0oJeQtSD9DrSW devnet-ed-key
            EOT
        }
      + name                      = "node2-prod"
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
              + name        = "root-node2"
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
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.node_with_for_each["prod"] will be created
  + resource "yandex_compute_instance" "node_with_for_each" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Инстанс для задания 7.3, созданный циклом"
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node3.devnet.cloud"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2RSc+UgrCP+GO4iZsPHTsVXKAliAw0oJeQtSD9DrSW devnet-ed-key
            EOT
        }
      + name                      = "node3-prod"
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
              + name        = "root-node3"
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
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }
  # yandex_compute_instance.node_with_for_each["stage"] will be created
  + resource "yandex_compute_instance" "node_with_for_each" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Инстанс для задания 7.3, созданный циклом"
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node2.devnet.cloud"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2RSc+UgrCP+GO4iZsPHTsVXKAliAw0oJeQtSD9DrSW devnet-ed-key
            EOT
        }
      + name                      = "node2-prod"
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
              + name        = "root-node2"
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
          + core_fraction = 20
          + cores         = 2
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

Plan: 6 to add, 0 to change, 0 to destroy.
```