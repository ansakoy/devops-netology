# Network
resource "yandex_vpc_network" "default" {
  name = "yandex-network-72"
}

resource "yandex_vpc_subnet" "default" {
  name = "yandex-subnet-b"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.101.0/24"]
}