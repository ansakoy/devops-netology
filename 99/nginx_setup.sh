#!/bin/bash

# Включаю очень подробный вывод информации о происходящем в образовательных целях дебаггинга ради.
# FIXME В реальной жизни должно быть просто -eu
set -euxo

PAGE_FOLDER="/var/www/test"
INDEX_PAGE="index.html"

SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

NGINX_CONF_NAME="test.catabasis.site"

echo "Creating site page..."

mkdir -p $PAGE_FOLDER
tee "$PAGE_FOLDER/$INDEX_PAGE" <<EOF
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
EOF

echo "Configuring NGINX..."

tee "$SITES_AVAILABLE/$NGINX_CONF_NAME" <<EOF
server {
    listen              443 ssl;
    server_name         test.catabasis.site;
    root /var/www/test;
    index index.html;
    ssl_certificate     /etc/ssl/certs/test.catabasis.site.crt;
    ssl_certificate_key /etc/ssl/private/test.catabasis.site.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
}
EOF

ln -s "$SITES_AVAILABLE/$NGINX_CONF_NAME" $SITES_ENABLED

nginx -t

echo "Restarting NGINX..."

systemctl restart nginx