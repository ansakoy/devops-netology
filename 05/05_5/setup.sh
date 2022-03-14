#!/bin/bash

set -eu

#apt update
#apt install -y curl
#apt install -y vim
#apt install -y ufw
#apt install -y screen
#apt install -y gnupg gnupg2 gnupg1
#apt install -y python3-pip
#pip install ansible
## Установить утилиту управления yc
#curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

#sudo apt install -y software-properties-common

# Установить Packer
#curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
#apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
#apt install -y packer

# Установить Terraform
apt install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt install -y terraform