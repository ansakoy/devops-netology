output "yandex_account_id" {
  value = var.yc_sa_account
}

output "yandex_user_id" {
  value = "Т.к. это не AWS, кажется, имеет смысл только ID сервисного аккаунта"
}

output "yandex_avail_zone" {
  value = var.yc_zone
}

output "internal_ip_address_node01_yandex_cloud" {
  value = yandex_compute_instance.node00.network_interface[0].ip_address
}

output "external_ip_address_node01_yandex_cloud" {
  value = yandex_compute_instance.node00.network_interface.0.nat_ip_address
}

output "subnet_id" {
  value = yandex_compute_instance.node00.network_interface.0.subnet_id
}