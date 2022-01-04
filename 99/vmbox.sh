#!/bin/bash

# Включаю очень подробный вывод информации о происходящем для отчетности и дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu
set -euxo

VBOXNAME_FILE=vboxname
HOST_PATH=/home/ansakoy/shared

echo "Installing Virtualbox..."
apt update && sudo apt install -y virtualbox

# Устанавливаем nmap, чтобы потом смотреть валидность сертификатов
echo "Installing nmap..."
apt install -y nmap

echo "Installing Vagrant..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt install -y vagrant

echo "Setting up Virtualbox..."
mkdir -p /home/ansakoy/vagrant
cd /home/ansakoy/vagrant

vagrant init

tee Vagrantfile <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "forwarded_port", guest: 443, host: 443
end
EOF

vagrant up

# Находим имя виртуальной машины
vboxmanage list vms | egrep -o '\".+\"' |tr -d '"' > $VBOXNAME_FILE

# Создаем папку для обмена файлами между хостом и гестом
mkdir -p $HOST_PATH
vboxmanage sharedfolder add "$(cat $VBOXNAME_FILE)" --name myshare --hostpath=$HOST_PATH --transient

# Дальнейшие действия:
# - Подключиться к виртуалке (sudo vagrant ssh)
# - Создать каталог для расшаренных файлов mkdir -p /home/vagrant/vboxshare
# - замаунтить туда расшаренную папку sudo mount -t vboxsf -o uid=1000,gid=1000 myshare /home/vagrant/vboxshare





