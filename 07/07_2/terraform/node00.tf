resource "yandex_compute_instance" "node00" {
  name                      = "node00"
  zone                      = var.yc_zone
  hostname                  = "node00.devnet.cloud"
  description = "Инстанс для задания 7.2"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu-latest-version
      name        = "root-node00"
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