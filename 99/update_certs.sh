#!/bin/bash

# Включаю очень подробный вывод информации о происходящем для отчетности и дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu

set -euxo

MY_USER=vagrant
SCRIPTS_PATH="/home/$MY_USER/vboxshare"

echo 'Generating new certs...'
$SCRIPTS_PATH/gen_cert.sh

echo 'Restarting NGINX...'
systemctl restart nginx

