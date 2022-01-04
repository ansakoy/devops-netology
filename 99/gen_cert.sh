#!/bin/bash

# Включаю очень подробный вывод информации о происходящем в образовательных целях дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu
set -euxo

MY_USER=vagrant
KEYS_STORAGE="/home/$MY_USER/key_files"

COMMON_NAME="test.catabasis.site"
MY_DOMAIN_ROLE="catabasis-dot-site"
CERT_DATA="catabasis_cert_data.json"

VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_ADDR
VAULT_TOKEN="$(cat $KEYS_STORAGE/root_key)"
export VAULT_TOKEN

vault write -format=json pki_int/issue/$MY_DOMAIN_ROLE common_name=$COMMON_NAME ttl="720h" > $CERT_DATA
cat $CERT_DATA | jq -r '.data.certificate' > "/etc/ssl/certs/$COMMON_NAME.crt"
cat $CERT_DATA | jq -r '.data.ca_chain[0]' >> "/etc/ssl/certs/$COMMON_NAME.crt"
cat $CERT_DATA | jq -r '.data.private_key' > "/etc/ssl/private/$COMMON_NAME.key"