#!/bin/bash

set -euxo

echo "Installing Virtualbox..."
apt update && sudo apt install -y virtualbox

echo "Installing Vagrant..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt install -y vagrant

echo "Installing Ansible..."
apt install -y python3-pip
pip install ansible

echo "Checking out versions..."

echo "Vagrant"
vagrant --version

echo "Ansible"
ansible --version

echo "Virtualbox"
vboxmanage --version