#!/bin/bash

# Включаю очень подробный вывод информации о происходящем в образовательных целях дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu
set -euxo

# Настройка ufw

echo 'Setting up UFW ports...'
ufw allow 22
ufw allow 443
ufw allow in on lo to any
ufw allow out on lo to any
ufw enable
ufw status

# Установка Hashicorp Vault

echo 'Downloading Hashicorp Vault...'
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

echo 'Adding Hashicorp Vault repo...'
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo 'Installing Hashicorp Vault repo...'
apt update && apt install -y vault

# Установка nginx

echo 'Installing EngineX...'
apt install -y nginx

# Установка jq

echo 'Installing jq...'
apt install -y jq



