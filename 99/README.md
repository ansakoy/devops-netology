# Курсовая работа по итогам модуля "DevOps и системное администрирование"
[Источник](https://github.com/netology-code/pcs-devsys-diplom/blob/main/README.md)

*Дисклеймер: по причине загруженности рабочего компьютера используемое
 в задании ПО  разворачивается на VPS с установленной на нем Ubuntu 20.04*
 
*Дисклеймер 2: В этом файле представлены логи в соответствии с пунктами демонстрации результата, 
указанными в задании. Реальный полуавтоматизированный процесс со ссылками на скрипты по шагам описан 
в файле [REALREADME.md](REALREADME.md)*
 
### Процесс установки и настройки ufw
ufw на 20.04 уже установлен, поэтому только настройка.  
Фрагмент из лога скрипта с `-euxo`
```
+ echo 'Setting up UFW ports...'
Setting up UFW ports...
+ ufw allow 22
Rules updated
Rules updated (v6)
+ ufw allow 443
Rules updated
Rules updated (v6)
+ ufw allow in on lo to any
Rules updated
Rules updated (v6)
+ ufw allow out on lo to any
Rules updated
Rules updated (v6)
+ ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
+ ufw status
Status: active

To                         Action      From
--                         ------      ----
22                         ALLOW       Anywhere
443                        ALLOW       Anywhere
Anywhere on lo             ALLOW       Anywhere
22 (v6)                    ALLOW       Anywhere (v6)
443 (v6)                   ALLOW       Anywhere (v6)
Anywhere (v6) on lo        ALLOW       Anywhere (v6)

Anywhere                   ALLOW OUT   Anywhere on lo
Anywhere (v6)              ALLOW OUT   Anywhere (v6) on lo
```
### Процесс установки и выпуска сертификата с помощью hashicorp vault
Логи соответствующих скриптов (`-euxo`)
```
sudo ./vault_init.sh
+ USER=vagrant
+ CONFIG_FILE=/home/vagrant/config.hcl
+ echo 'Creating /home/vagrant/config.hcl...'
Creating /home/vagrant/config.hcl...
+ tee /home/vagrant/config.hcl
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
+ echo 'Creating storage for Vault data...'
Creating storage for Vault data...
+ mkdir -p /home/vagrant/vault/data
```
Руками:
```
sudo vault server -config=config.hcl
```
Логи следующего скрипта:
```
sudo ./certs.sh
+ VAULT_ADDR=http://127.0.0.1:8200
+ export VAULT_ADDR
+ USER=vagrant
+ INIT_KEYS_FILE=/home/vagrant/init_keys
+ KEYS_STORAGE=/home/vagrant/key_files
+ SCRIPTS_PATH=/home/vagrant/vboxshare
+ UNSEAL_KEY_PREFIX=unseal
+ ROOT_TOKEN=root_key
+ MY_POLICY=/home/vagrant/my-policy
+ MY_DOMAIN=catabasis.site
+ MY_DOMAIN_ROLE=catabasis-dot-site
+ ROOT_CERT=/home/vagrant/CA_cert.crt
+ INT_CERT=/home/vagrant/pki_intermediate.csr
+ SIGNED_INT_CERT=/home/vagrant/intermediate.cert.pem
+ /home/vagrant/vboxshare/parse_keys.py /home/vagrant/init_keys /home/vagrant/key_files
++ cat /home/vagrant/key_files/root_key
+ VAULT_TOKEN=s.se0pCIaYhn8BJDNBqeWO0j1a
+ export VAULT_TOKEN
+ for i in {1..3}
++ cat /home/vagrant/key_files/unseal1
+ vault operator unseal hHwbykgH0Lu6oYDFC9MKQZtlC0n4ZKZQ+MXadd55kSdX
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       3afec85d-5523-2255-c396-7027ac7a5e9b
Version            1.9.2
Storage Type       raft
HA Enabled         true
+ for i in {1..3}
++ cat /home/vagrant/key_files/unseal2
+ vault operator unseal efVMOgH4kJznljgkG/d3otldH/jIucLbF4jIixtudEPr
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       3afec85d-5523-2255-c396-7027ac7a5e9b
Version            1.9.2
Storage Type       raft
HA Enabled         true
+ for i in {1..3}
++ cat /home/vagrant/key_files/unseal3
+ vault operator unseal ZHYNlVL3AhsYEVriQSQJN5fthQfnaPyonoTa5TFBHofh
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.9.2
Storage Type            raft
Cluster Name            vault-cluster-129b898c
Cluster ID              fb537866-0350-a531-b420-82d9aa461d70
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    25
Raft Applied Index      25
++ cat /home/vagrant/key_files/root_key
+ vault login s.se0pCIaYhn8BJDNBqeWO0j1a

################################################################################################
Здесь оборвалось с ошибкой:
Error authenticating: error looking up token: Error making API request.

URL: GET http://127.0.0.1:8200/v1/auth/token/lookup-self
Code: 500. Errors:

* local node not active but active cluster node not found

Логин был произведен вручную
vagrant@vagrant:~$ export VAULT_ADDR='http://127.0.0.1:8200'
vagrant@vagrant:~$ export VAULT_TOKEN=s.se0pCIaYhn8BJDNBqeWO0j1a
vagrant@vagrant:~$ vault login s.se0pCIaYhn8BJDNBqeWO0j1a
WARNING! The VAULT_TOKEN environment variable is set! This takes precedence
over the value set by this command. To use the value set by this command,
unset the VAULT_TOKEN environment variable or set it to the token displayed
below.

Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.se0pCIaYhn8BJDNBqeWO0j1a
token_accessor       rBoVYWFWfbL2lbDovYWC6tRR
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
################################################################################################
sudo ./certs.sh
+ VAULT_ADDR=http://127.0.0.1:8200
+ export VAULT_ADDR
+ USER=vagrant
+ INIT_KEYS_FILE=/home/vagrant/init_keys
+ KEYS_STORAGE=/home/vagrant/key_files
+ SCRIPTS_PATH=/home/vagrant/vboxshare
+ UNSEAL_KEY_PREFIX=unseal
+ ROOT_TOKEN=root_key
+ MY_POLICY=/home/vagrant/my-policy
+ MY_DOMAIN=catabasis.site
+ MY_DOMAIN_ROLE=catabasis-dot-site
+ ROOT_CERT=/home/vagrant/CA_cert.crt
+ INT_CERT=/home/vagrant/pki_intermediate.csr
+ SIGNED_INT_CERT=/home/vagrant/intermediate.cert.pem
++ cat /home/vagrant/key_files/root_key
+ VAULT_TOKEN=s.se0pCIaYhn8BJDNBqeWO0j1a
+ export VAULT_TOKEN
+ vault policy write /home/vagrant/my-policy -
Success! Uploaded policy: /home/vagrant/my-policy
+ echo 'Generating root certificate...'
Generating root certificate...
+ vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
+ vault secrets tune -max-lease-ttl=87600h pki
Success! Tuned the secrets engine at: pki/
+ vault write -field=certificate pki/root/generate/internal common_name=catabasis.site ttl=87600h
+ vault write pki/config/urls issuing_certificates=http://127.0.0.1:8200/v1/pki/ca crl_distribution_points=http://127.0.0.1:8200/v1/pki/crl
Success! Data written to: pki/config/urls
+ echo 'Generating intermediate certificate...'
Generating intermediate certificate...
+ vault secrets enable -path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/
+ vault secrets tune -max-lease-ttl=43800h pki_int
Success! Tuned the secrets engine at: pki_int/
+ jq -r .data.csr
+ vault write -format=json pki_int/intermediate/generate/internal 'common_name=catabasis.site Intermediate Authority'
+ vault write -format=json pki/root/sign-intermediate csr=@/home/vagrant/pki_intermediate.csr format=pem_bundle ttl=43800h
+ jq -r .data.certificate
+ vault write pki_int/intermediate/set-signed certificate=@/home/vagrant/intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed
+ echo 'Creating role catabasis-dot-site...'
Creating role catabasis-dot-site...
+ vault write pki_int/roles/catabasis-dot-site allowed_domains=catabasis.site allow_subdomains=true max_ttl=720h
Success! Data written to: pki_int/roles/catabasis-dot-site
```
Логи выпуска сертификата сайта:
```
sudo ./gen_cert.sh
+ MY_USER=vagrant
+ KEYS_STORAGE=/home/vagrant/key_files
+ COMMON_NAME=test.catabasis.site
+ MY_DOMAIN_ROLE=catabasis-dot-site
+ CERT_DATA=catabasis_cert_data.json
+ VAULT_ADDR=http://127.0.0.1:8200
+ export VAULT_ADDR
++ cat /home/vagrant/key_files/root_key
+ VAULT_TOKEN=s.se0pCIaYhn8BJDNBqeWO0j1a
+ export VAULT_TOKEN
+ vault write -format=json pki_int/issue/catabasis-dot-site common_name=test.catabasis.site ttl=720h
+ cat catabasis_cert_data.json
+ jq -r .data.certificate
+ cat catabasis_cert_data.json
+ jq -r '.data.ca_chain[0]'
+ jq -r .data.private_key
+ cat catabasis_cert_data.json
```
### Процесс установки и настройки сервера nginx
Фрагменты из логов:
```
+ echo 'Installing EngineX...'
Installing EngineX...
+ apt install -y nginx
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0
  libjpeg-turbo8 libjpeg8 libnginx-mod-http-image-filter
  libnginx-mod-http-xslt-filter libnginx-mod-mail libnginx-mod-stream libtiff5
  libwebp6 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxpm4 nginx-common
  nginx-core
Suggested packages:
  libgd-tools fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0
  libjpeg-turbo8 libjpeg8 libnginx-mod-http-image-filter
  libnginx-mod-http-xslt-filter libnginx-mod-mail libnginx-mod-stream libtiff5
  libwebp6 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxpm4 nginx
  nginx-common nginx-core
0 upgraded, 22 newly installed, 0 to remove and 0 not upgraded.
Need to get 3,183 kB of archives.
After this operation, 11.1 MB of additional disk space will be used.
Get:1 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libxau6 amd64 1:1.0.9-0ubuntu1 [7,488 B]
Get:2 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libxdmcp6 amd64 1:1.1.3-0ubuntu1 [10.6 kB]
Get:3 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libxcb1 amd64 1.14-2 [44.7 kB]
Get:4 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libx11-data all 2:1.6.9-2ubuntu1.2 [113 kB]
Get:5 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libx11-6 amd64 2:1.6.9-2ubuntu1.2 [575 kB]
Get:6 http://us.archive.ubuntu.com/ubuntu focal/main amd64 fonts-dejavu-core all 2.37-1 [1,041 kB]
Get:7 http://us.archive.ubuntu.com/ubuntu focal/main amd64 fontconfig-config all 2.13.1-2ubuntu3 [28.8 kB]
Get:8 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libfontconfig1 amd64 2.13.1-2ubuntu3 [114 kB]
Get:9 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libjpeg-turbo8 amd64 2.0.3-0ubuntu1.20.04.1 [117 kB]
Get:10 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libjpeg8 amd64 8c-2ubuntu8 [2,194 B]
Get:11 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libjbig0 amd64 2.1-3.1build1 [26.7 kB]
Get:12 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libwebp6 amd64 0.6.1-2ubuntu0.20.04.1 [185 kB]
Get:13 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libtiff5 amd64 4.1.0+git191117-2ubuntu0.20.04.2 [162 kB]
Get:14 http://us.archive.ubuntu.com/ubuntu focal/main amd64 libxpm4 amd64 1:3.5.12-1 [34.0 kB]
Get:15 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libgd3 amd64 2.2.5-5.2ubuntu2.1 [118 kB]
Get:16 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx-common all 1.18.0-0ubuntu1.2 [37.5 kB]
Get:17 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-http-image-filter amd64 1.18.0-0ubuntu1.2 [14.4 kB]
Get:18 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-http-xslt-filter amd64 1.18.0-0ubuntu1.2 [12.7 kB]
Get:19 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-mail amd64 1.18.0-0ubuntu1.2 [42.5 kB]
Get:20 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-stream amd64 1.18.0-0ubuntu1.2 [67.3 kB]
Get:21 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx-core amd64 1.18.0-0ubuntu1.2 [425 kB]
Get:22 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx all 1.18.0-0ubuntu1.2 [3,620 B]
Fetched 3,183 kB in 1s (3,139 kB/s)
Preconfiguring packages ...
Selecting previously unselected package libxau6:amd64.
(Reading database ... 40626 files and directories currently installed.)
Preparing to unpack .../00-libxau6_1%3a1.0.9-0ubuntu1_amd64.deb ...
Unpacking libxau6:amd64 (1:1.0.9-0ubuntu1) ...
Selecting previously unselected package libxdmcp6:amd64.
Preparing to unpack .../01-libxdmcp6_1%3a1.1.3-0ubuntu1_amd64.deb ...
Unpacking libxdmcp6:amd64 (1:1.1.3-0ubuntu1) ...
Selecting previously unselected package libxcb1:amd64.
Preparing to unpack .../02-libxcb1_1.14-2_amd64.deb ...
Unpacking libxcb1:amd64 (1.14-2) ...
Selecting previously unselected package libx11-data.
Preparing to unpack .../03-libx11-data_2%3a1.6.9-2ubuntu1.2_all.deb ...
Unpacking libx11-data (2:1.6.9-2ubuntu1.2) ...
Selecting previously unselected package libx11-6:amd64.
Preparing to unpack .../04-libx11-6_2%3a1.6.9-2ubuntu1.2_amd64.deb ...
Unpacking libx11-6:amd64 (2:1.6.9-2ubuntu1.2) ...
Selecting previously unselected package fonts-dejavu-core.
Preparing to unpack .../05-fonts-dejavu-core_2.37-1_all.deb ...
Unpacking fonts-dejavu-core (2.37-1) ...
Selecting previously unselected package fontconfig-config.
Preparing to unpack .../06-fontconfig-config_2.13.1-2ubuntu3_all.deb ...
Unpacking fontconfig-config (2.13.1-2ubuntu3) ...
Selecting previously unselected package libfontconfig1:amd64.
Preparing to unpack .../07-libfontconfig1_2.13.1-2ubuntu3_amd64.deb ...
Unpacking libfontconfig1:amd64 (2.13.1-2ubuntu3) ...
Selecting previously unselected package libjpeg-turbo8:amd64.
Preparing to unpack .../08-libjpeg-turbo8_2.0.3-0ubuntu1.20.04.1_amd64.deb ...
Unpacking libjpeg-turbo8:amd64 (2.0.3-0ubuntu1.20.04.1) ...
Selecting previously unselected package libjpeg8:amd64.
Preparing to unpack .../09-libjpeg8_8c-2ubuntu8_amd64.deb ...
Unpacking libjpeg8:amd64 (8c-2ubuntu8) ...
Selecting previously unselected package libjbig0:amd64.
Preparing to unpack .../10-libjbig0_2.1-3.1build1_amd64.deb ...
Unpacking libjbig0:amd64 (2.1-3.1build1) ...
Selecting previously unselected package libwebp6:amd64.
Preparing to unpack .../11-libwebp6_0.6.1-2ubuntu0.20.04.1_amd64.deb ...
Unpacking libwebp6:amd64 (0.6.1-2ubuntu0.20.04.1) ...
Selecting previously unselected package libtiff5:amd64.
Preparing to unpack .../12-libtiff5_4.1.0+git191117-2ubuntu0.20.04.2_amd64.deb ...
Unpacking libtiff5:amd64 (4.1.0+git191117-2ubuntu0.20.04.2) ...
Selecting previously unselected package libxpm4:amd64.
Preparing to unpack .../13-libxpm4_1%3a3.5.12-1_amd64.deb ...
Unpacking libxpm4:amd64 (1:3.5.12-1) ...
Selecting previously unselected package libgd3:amd64.
Preparing to unpack .../14-libgd3_2.2.5-5.2ubuntu2.1_amd64.deb ...
Unpacking libgd3:amd64 (2.2.5-5.2ubuntu2.1) ...
Selecting previously unselected package nginx-common.
Preparing to unpack .../15-nginx-common_1.18.0-0ubuntu1.2_all.deb ...
Unpacking nginx-common (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-http-image-filter.
Preparing to unpack .../16-libnginx-mod-http-image-filter_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-http-image-filter (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-http-xslt-filter.
Preparing to unpack .../17-libnginx-mod-http-xslt-filter_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-http-xslt-filter (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-mail.
Preparing to unpack .../18-libnginx-mod-mail_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-mail (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-stream.
Preparing to unpack .../19-libnginx-mod-stream_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-stream (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package nginx-core.
Preparing to unpack .../20-nginx-core_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking nginx-core (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package nginx.
Preparing to unpack .../21-nginx_1.18.0-0ubuntu1.2_all.deb ...
Unpacking nginx (1.18.0-0ubuntu1.2) ...
Setting up libxau6:amd64 (1:1.0.9-0ubuntu1) ...
Setting up libxdmcp6:amd64 (1:1.1.3-0ubuntu1) ...
Setting up libxcb1:amd64 (1.14-2) ...
Setting up nginx-common (1.18.0-0ubuntu1.2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.
Setting up libjbig0:amd64 (2.1-3.1build1) ...
Setting up libnginx-mod-http-xslt-filter (1.18.0-0ubuntu1.2) ...
Setting up libx11-data (2:1.6.9-2ubuntu1.2) ...
Setting up libwebp6:amd64 (0.6.1-2ubuntu0.20.04.1) ...
Setting up fonts-dejavu-core (2.37-1) ...
Setting up libjpeg-turbo8:amd64 (2.0.3-0ubuntu1.20.04.1) ...
Setting up libx11-6:amd64 (2:1.6.9-2ubuntu1.2) ...
Setting up libjpeg8:amd64 (8c-2ubuntu8) ...
Setting up libnginx-mod-mail (1.18.0-0ubuntu1.2) ...
Setting up libxpm4:amd64 (1:3.5.12-1) ...
Setting up fontconfig-config (2.13.1-2ubuntu3) ...
Setting up libnginx-mod-stream (1.18.0-0ubuntu1.2) ...
Setting up libtiff5:amd64 (4.1.0+git191117-2ubuntu0.20.04.2) ...
Setting up libfontconfig1:amd64 (2.13.1-2ubuntu3) ...
Setting up libgd3:amd64 (2.2.5-5.2ubuntu2.1) ...
Setting up libnginx-mod-http-image-filter (1.18.0-0ubuntu1.2) ...
Setting up nginx-core (1.18.0-0ubuntu1.2) ...
Setting up nginx (1.18.0-0ubuntu1.2) ...
Processing triggers for ufw (0.36-6ubuntu1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for libc-bin (2.31-0ubuntu9.2) ...
```
```
sudo ./nginx_setup.sh
+ PAGE_FOLDER=/var/www/test
+ INDEX_PAGE=index.html
+ SITES_AVAILABLE=/etc/nginx/sites-available
+ SITES_ENABLED=/etc/nginx/sites-enabled
+ NGINX_CONF_NAME=test.catabasis.site
+ echo 'Creating site page...'
Creating site page...
+ mkdir -p /var/www/test
+ tee /var/www/test/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Курсовая</title>
</head>
<body>
    <h1>Работает</h1>
    <h3>EngineX, сертификаты, Hashicorp Vault</h3>
</body>
</html>
+ echo 'Configuring NGINX...'
Configuring NGINX...
+ tee /etc/nginx/sites-available/test.catabasis.site
server {
    listen              443 ssl;
    server_name         test.catabasis.site;
    root /var/www/test;
    index /var/www/test/index.html;
    ssl_certificate     /etc/ssl/certs/test.catabasis.site.crt;
    ssl_certificate_key /etc/ssl/private/test.catabasis.site.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
}
+ ln -s /etc/nginx/sites-available/test.catabasis.site /etc/nginx/sites-enabled
+ nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
+ echo 'Restarting NGINX...'
Restarting NGINX...
+ systemctl restart nginx
```
### Страница сервера nginx в браузере хоста не содержит предупреждений
Т.к. речь по-прежнему о VPS с виртуальной машиной, проверяем страницу через терминал хостовой машины
```
root@devnet:/home/ansakoy/vagrant# curl -v -i https://test.catabasis.site
*   Trying 165.227.130.76:443...
* TCP_NODELAY set
* Connected to test.catabasis.site (165.227.130.76) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: CN=test.catabasis.site
*  start date: Jan  3 21:51:49 2022 GMT
*  expire date: Feb  2 21:52:18 2022 GMT
*  subjectAltName: host "test.catabasis.site" matched cert's "test.catabasis.site"
*  issuer: CN=catabasis.site Intermediate Authority
*  SSL certificate verify ok.
> GET / HTTP/1.1
> Host: test.catabasis.site
> User-Agent: curl/7.68.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Server: nginx/1.18.0 (Ubuntu)
Server: nginx/1.18.0 (Ubuntu)
< Date: Mon, 03 Jan 2022 21:55:32 GMT
Date: Mon, 03 Jan 2022 21:55:32 GMT
< Content-Type: text/html
Content-Type: text/html
< Content-Length: 226
Content-Length: 226
< Last-Modified: Mon, 03 Jan 2022 21:54:19 GMT
Last-Modified: Mon, 03 Jan 2022 21:54:19 GMT
< Connection: keep-alive
Connection: keep-alive
< ETag: "61d3708b-e2"
ETag: "61d3708b-e2"
< Accept-Ranges: bytes
Accept-Ranges: bytes

<
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Курсовая</title>
</head>
<body>
    <h1>Работает</h1>
    <h3>EngineX, сертификаты, Hashicorp Vault</h3>
</body>
</html>
* Connection #0 to host test.catabasis.site left intact
```
```
root@devnet:/home/ansakoy/vagrant# nmap -p 443 --script ssl-cert test.catabasis.site
Starting Nmap 7.80 ( https://nmap.org ) at 2022-01-03 22:01 UTC
Nmap scan report for test.catabasis.site (165.227.130.76)
Host is up (0.000089s latency).
rDNS record for 165.227.130.76: devnet

PORT    STATE SERVICE
443/tcp open  https
| ssl-cert: Subject: commonName=test.catabasis.site
| Subject Alternative Name: DNS:test.catabasis.site
| Issuer: commonName=catabasis.site Intermediate Authority
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2022-01-03T21:51:49
| Not valid after:  2022-02-02T21:52:18
| MD5:   da0e 6848 e4f7 e090 c213 ec3c 2fe7 6e7a
|_SHA-1: a77f 916e d3f7 a5f2 c574 df65 c6bb 7531 7ddc 3d4f

Nmap done: 1 IP address (1 host up) scanned in 0.68 seconds
```
### Скрипт генерации нового сертификата работает (сертификат сервера ngnix должен быть "зеленым")
Частично подтверждается логами выше, частично - скринкастом по ссылке ниже
### Crontab работает (выберите число и время так, чтобы показать что crontab запускается и делает что надо)
```
sudo crontab -e
40 22 3 * * /home/vagrant/vboxshare/update_certs.sh > /home/vagrant/upd.log 2> /home/vagrant/upd.err
```
https://www.youtube.com/watch?v=1LZkEgJBYpI
