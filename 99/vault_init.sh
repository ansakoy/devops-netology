#!/bin/bash

# Включаю очень подробный вывод информации о происходящем в образовательных целях дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu
set -euxo

USER=vagrant

CONFIG_FILE="/home/$USER/config.hcl"

echo "Creating $CONFIG_FILE..."

tee "$CONFIG_FILE" <<EOF
storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true
EOF

echo "Creating storage for Vault data..."
mkdir -p "/home/$USER/vault/data"