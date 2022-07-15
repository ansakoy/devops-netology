resource "yandex_compute_instance" "node_with_count" {
  name                      = "node${count.index + 1}-${terraform.workspace}"
  zone                      = var.yc_zone
  hostname                  = "node${count.index + 1}.devnet.cloud"
  description = "Инстанс для задания 7.3"
  count = local.instance_count[terraform.workspace]
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
    core_fraction = local.instance_type[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu-latest-version
      name        = "root-node${count.index + 1}"
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "node_with_for_each" {
  for_each                  = local.instance_count
  name                      = "node${each.value + 1}-${terraform.workspace}"
  zone                      = var.yc_zone
  hostname                  = "node${each.value + 1}.devnet.cloud"
  description = "Инстанс для задания 7.3, созданный циклом"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
    core_fraction = local.instance_type[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu-latest-version
      name        = "root-node${each.value + 1}"
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}