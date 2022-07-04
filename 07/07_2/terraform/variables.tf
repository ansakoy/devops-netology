# yc resource-manager cloud get <CLOUD_NAME>
variable "yc_cloud_id" {
  type = string
  default = "b1gkltlcig08copnc8bc"
  description = "ID облака"
}

# yc resource-manager folder get <FOLDER_NAME>
variable "yc_folder_id" {
  type = string
  default = "b1gjed8md31ldtt38dov"
  description = "ID каталога"
}

variable "yc_sa_account" {
  type = string
  default = "b1gjed8md31ldtt38dov"
  description = "ID сервисного аккаунта"
}

# yc iam key create --service-account-name <SERVICE_ACCOUNT_NAME> --output <PATH/TO/KEY/FILE>
variable "yc_sa_key_path" {
  type = string
  default = "/home/ansakoy/hwtf1/key.json"
  description = "Путь к ключу сервисного аккаунта"
}

variable "yc_zone" {
  type = string
  default = "ru-central1-a"
  description = "Зона доступности"
}

# yc compute image list --folder-id standard-images | grep ubuntu-20-04-lts-v2022
variable "ubuntu-latest-version" {
  type = string
  default = "fd8f1tik9a7ap9ik2dg1"
  description = "ID распоследнего образа ubuntu"
}
