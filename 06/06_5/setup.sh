#!/bin/bash

set -euxo

# https://docs.docker.com/engine/install/ubuntu/

WORK_DIR="/home/ansakoy/06_5"

apt update

# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
apt install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

# Install Docker Engine
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Checking version..."
docker version

mkdir -p $WORK_DIR

cd $WORK_DIR

tee "$WORK_DIR/Dockerfile" <<EOF
# syntax=docker/dockerfile:1
FROM elasticsearch:7.17.3
COPY elasticsearch.yml /usr/share/elasticsearch/config/
RUN mkdir -p /var/lib/data && chmod 777 /var/lib/data && mkdir -p /var/lib/snapshots && chmod 777 /var/lib/snapshots
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
EOF

tee "$WORK_DIR/elasticsearch.yml" <<EOF
cluster.name: netology_test_cluster
node.name: netology_test
discovery.type: single-node
path.data: /var/lib/data
network.host: 0.0.0.0
path.repo: /var/lib/snapshots
EOF

docker build -t elsearch .