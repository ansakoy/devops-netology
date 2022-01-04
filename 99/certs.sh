#!/bin/bash

# Включаю очень подробный вывод информации о происходящем в образовательных целях дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu
set -euxo

VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_ADDR

MY_USER=vagrant

INIT_KEYS_FILE="/home/$MY_USER/init_keys"
KEYS_STORAGE="/home/$MY_USER/key_files"
SCRIPTS_PATH="/home/$MY_USER/vboxshare"

UNSEAL_KEY_PREFIX=unseal
ROOT_TOKEN=root_key

MY_POLICY="/home/$MY_USER/my-policy"

MY_DOMAIN=catabasis.site

MY_DOMAIN_ROLE=catabasis-dot-site

# CERT FILE NAMES
ROOT_CERT="/home/$MY_USER/CA_cert.crt"
INT_CERT="/home/$MY_USER/pki_intermediate.csr"
SIGNED_INT_CERT="/home/$MY_USER/intermediate.cert.pem"

# Инициализируем ячейку

echo "Initializing vault, storing output in $INIT_KEYS_FILE"
vault operator init > $INIT_KEYS_FILE

# Парсим ключи
$SCRIPTS_PATH/parse_keys.py $INIT_KEYS_FILE $KEYS_STORAGE

# Распечатываем ячейку
for i in {1..3}
  do vault operator unseal "$(cat $KEYS_STORAGE/unseal$i)"
  done

echo "Vault unsealed"

# Экспортируем токен рута:
VAULT_TOKEN="$(cat $KEYS_STORAGE/root_key)"
export VAULT_TOKEN

# Логинимся в ячейку
vault login "$(cat $KEYS_STORAGE/root_key)"

# Создаем новую policy

vault policy write $MY_POLICY - << EOF
# Enable secrets engine
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# List enabled secrets engine
path "sys/mounts" {
  capabilities = [ "read", "list" ]
}

# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
EOF

echo "Generating root certificate..."

# Включаем pki engine
vault secrets enable pki

# Задаем корневому сертифткату максимальный срок жизни - 87600 часов
vault secrets tune -max-lease-ttl=87600h pki

# Генерируем корневой сертификат
vault write -field=certificate pki/root/generate/internal \
     common_name=$MY_DOMAIN \
     ttl=87600h > $ROOT_CERT

# Задаем урлы для сертификата и Certificate Revocation List (CRL)
vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

echo "Generating intermediate certificate..."

# Включаем pki engine по адресу pki_int
vault secrets enable -path=pki_int pki

# Задаем промежуточному сертифткату 43800 часов
vault secrets tune -max-lease-ttl=43800h pki_int

# Генерируем промежуточный сертификат
vault write -format=json pki_int/intermediate/generate/internal \
     common_name="$MY_DOMAIN Intermediate Authority" \
     | jq -r '.data.csr' > $INT_CERT

# Подписываем промежуточный сертификат
vault write -format=json pki/root/sign-intermediate csr=@$INT_CERT \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > $SIGNED_INT_CERT

# Кладем подписанный в ячейку
vault write pki_int/intermediate/set-signed certificate=@$SIGNED_INT_CERT

echo "Creating role $MY_DOMAIN_ROLE..."

# Создаем роль, допускающую поддомены
vault write pki_int/roles/$MY_DOMAIN_ROLE \
     allowed_domains=$MY_DOMAIN \
     allow_subdomains=true \
     max_ttl="720h"