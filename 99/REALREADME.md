## Шаги по развертыванию проекта

Исходные условия:
* удаленная VPS ubuntu 20.04

> NB: не забывать chmod 700 перед первым запуском скриптов  
> NB2: все скрипты запускать из-под sudo

* Устанавливается и конфигурируется виртуальная машина [скрипт 1](vmbox.sh)
```
chmod 700 vmbox.sh
sudo ./vmbox.sh
```
* Подключиться к машине (`sudo vagrant ssh`)
* Создать каталог для расшаренных файлов `mkdir -p /home/vagrant/vboxshare`
* Замаунтить туда расшаренную папку `sudo mount -t vboxsf -o uid=1000,gid=1000 myshare /home/vagrant/vboxshare`
* Положить в папку нужные скрипты
* В виртуальной машине установить всё необходимое ([скрипт 2](setup.sh))
```
cd /home/vagrant/vboxshare
chmod 700 setup.sh
sudo ./setup.sh
```
* Создать конфиг и папку для данных ячейки: [скрипт 3](vault_init.sh)
```
chmod 700 vault_init.sh
sudo ./vault_init.sh
```
* Запустить сервер ячейки
```
cd /home/vagrant
sudo vault server -config=config.hcl
```
* Инициализировать ячейку, создать центр сертификации ([certs.sh](certs.sh), [parse_keys.py](parse_keys.py))
```
# В новом терминале
cd vagrant
sudo vagrant ssh
cd vboxshare
chmod 700 parse_keys.py certs.sh
sudo ./certs.sh
```
> Иногда почему-то скрипт вылетает на этапе логина. Можно залогиниться вручную, 
> экспортировав переменные VAULT_TOKEN, VAULT_ADDR ([stackoverflow](https://stackoverflow.com/questions/63878533/vault-error-server-gave-http-response-to-https-client))

* Сгенерировать сертификат для сайта ([gen_cert.sh](gen_cert.sh))
```
chmod 700 gen_cert.sh
sudo ./gen_cert.sh
```

* Скопировать корневой сертификат в общую папку `cp CA_cert.crt vboxshare/CA_cert.crt`
* На хостовой машине переместить сертификат в доверенные
```
sudo mv /home/ansakoy/shared/CA_cert.crt /usr/local/share/ca-certificates/CA_cert.crt
sudo update-ca-certificates
```
* На гест-машине запустить генерацию конфигов NGINX ([nginx_setup.sh](nginx_setup.sh))
```
chmod 700 nginx_setup.sh
sudo ./nginx_setup.sh
```
* На хост-машине проверить работу сайта и годность сертификата
```
curl -v -i https://test.catabasis.site
nmap -p 443 --script ssl-cert test.catabasis.site
```
* Разрешить исполнение [скрипта апдейта сертификатов](update_certs.sh) (гест)
```
chmod 700 update_certs.sh
```
* Создать задачу в кронтабе через sudo
```
sudo crontab -e
40 22 3 * * /home/vagrant/vboxshare/update_certs.sh > /home/vagrant/upd.log 2> /home/vagrant/upd.err
```

