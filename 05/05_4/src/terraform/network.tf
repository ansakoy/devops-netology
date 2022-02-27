# Network
resource "yandex_vpc_network" "default" {
  name = "my-yc-network"
}

resource "yandex_vpc_subnet" "default" {
  name = "my-yc-subnet-b"
  zone           = "${var.ya-zone}"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}