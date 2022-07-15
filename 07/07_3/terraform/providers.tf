terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.70"
    }
  }
  required_version = ">= 0.13"
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "bucket-07-3"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = var.access_key_id
    secret_key = var.access_key_secret

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = var.yc_sa_key_path
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}