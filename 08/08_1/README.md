# Домашнее задание к занятию "08.01 Введение в Ansible"

[Источник](https://github.com/netology-code/mnt-homeworks/blob/MNT-7/08-ansible-01-base/README.md)  
(Ветка выбрана на основании указаний куратора в телеграм-чате)

Детальные этапы прохождения [здесь](REALREADME.md)

## Подготовка к выполнению
> 1. Установите ansible версии 2.10 или выше.
```bash
ansible --version
ansible [core 2.12.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/ansakoy/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/ansakoy/08_1/devnet08/devnet08venv/lib/python3.8/site-packages/ansible
  ansible collection location = /home/ansakoy/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/ansakoy/08_1/devnet08/devnet08venv/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 3.1.2
  libyaml = True
```

> 2. Создайте свой собственный публичный репозиторий на github с произвольным именем.

[Репозиторий](https://github.com/ansakoy/devnet08)

> 3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

```bash
$ ls -lha devnet08/playbook
total 24K
drwxr-xr-x 4 ansakoy sudo 4.0K May 20 10:56 .
drwxr-xr-x 5 ansakoy sudo 4.0K May 20 10:56 ..
drwxr-xr-x 5 ansakoy sudo 4.0K May 20 10:56 group_vars
drwxr-xr-x 2 ansakoy sudo 4.0K May 20 10:56 inventory
-rw-r--r-- 1 ansakoy sudo 1.3K May 20 10:56 README.md
-rw-r--r-- 1 ansakoy sudo  209 May 20 10:56 site.yml
```

## Основная часть
> 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```
ansible-playbook site.yml -i inventory/test.yml
```
`some_fact` возвращает значение `12`, прописанное в исходном [all/examp.yml](https://github.com/netology-code/mnt-homeworks/blob/MNT-7/08-ansible-01-base/playbook/group_vars/all/examp.yml)

> 2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

```bash
$ ansible-playbook site.yml -i inventory/test.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP ************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

> 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

docker-compose.yml:
```yaml
---
services:
  ubuntu:
    image: pycontribs/ubuntu
    container_name: ubuntu
    restart: on-failure
    command:
      - sleep
      - infinity
  centos7:
    image: centos:7
    container_name: centos7
    restart: on-failure
    command:
      - sleep
      - infinity
```

> 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```
sudo ansible-playbook site.yml -i inventory/prod.yml
```
centos7 -> `"el"`  
ubuntu -> `"deb"`

> 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

[deb](https://github.com/ansakoy/devnet08/blob/master/playbook/group_vars/deb/examp.yml)
```yaml
---
  some_fact: "deb default fact"
```
[el](https://github.com/ansakoy/devnet08/blob/master/playbook/group_vars/el/examp.yml)
```yaml
---
  some_fact: "el default fact"
```

> 6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook site.yml -i inventory/prod.yml
[sudo] password for ansakoy: 

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

> 7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ ansible-vault encrypt group_vars/el/examp.yml group_vars/deb/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ cat group_vars/el/examp.yml
$ANSIBLE_VAULT;1.1;AES256
31653937633033646239623533613365323037386665636538376662353363613339613064386630
6262656366343636383331316630393830613834666635320a336233616138376532383465366364
31323966353937383265363931616661373934373764336162313663656165343663343839303962
3030663033323339630a356336633938626136316665333738306634653535646265393736383435
35653664336239623934363865343164613336383765373063393031366438626436383536306661
6238353061353134306438333438333531353837313134646465
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ cat group_vars/el/examp.yml
$ANSIBLE_VAULT;1.1;AES256
31653937633033646239623533613365323037386665636538376662353363613339613064386630
6262656366343636383331316630393830613834666635320a336233616138376532383465366364
31323966353937383265363931616661373934373764336162313663656165343663343839303962
3030663033323339630a356336633938626136316665333738306634653535646265393736383435
35653664336239623934363865343164613336383765373063393031366438626436383536306661
6238353061353134306438333438333531353837313134646465
```

> 8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
Vault password: 

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

> 9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

```bash
(devnet08venv) ansakoy@devnet:~/08_1$ ansible-doc -t connection -l
...                                                                          
local                          execute on controller
...
```
Видимо, имеется в виду `local - execute on controller`. 
[Согласно документации](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#non-ssh-connection-types), 
`This connector can be used to deploy the playbook to the control machine itself.`

> 10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

```yaml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

> 11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
[sudo] password for ansakoy: 
Vault password: 

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

> 12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

README традиционно оформляю в репозитории курса. [Репозиторий с заданием](https://github.com/ansakoy/devnet08)

## Необязательная часть

> 1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.

```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ ansible-vault decrypt group_vars/el/examp.yml group_vars/deb/examp.yml
Vault password: 
Decryption successful
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ cat group_vars/el/examp.yml
---
  some_fact: "el default fact"
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ cat group_vars/deb/examp.yml
---
  some_fact: "deb default fact"
```

> 2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.

```bash
ansible-vault encrypt_string PaSSw0rd
```
Результат:
```bash
ansakoy@devnet:~/08_1/devnet08/playbook$ ansible-vault encrypt_string PaSSw0rd
New Vault password: 
Confirm New Vault password: 
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          62303964643366316634633962613934383062316631646261333166306264333231656435613537
          6634616662356638393666363365336163656531653132320a306637616437393031623935336364
          63363335633761633431383631643436383062383865643231306130643034393431373830326336
          3364373961366437640a653130653432373434343338353431663030386337383835333130663661
          6564
Encryption successful
```
Добавляем:
```yaml
---
  some_fact: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    62303964643366316634633962613934383062316631646261333166306264333231656435613537
    6634616662356638393666363365336163656531653132320a306637616437393031623935336364
    63363335633761633431383631643436383062383865643231306130643034393431373830326336
    3364373961366437640a653130653432373434343338353431663030386337383835333130663661
    6564
```

> 3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

```
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
Vault password: 

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

> 4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).

Опять редактируем docker-compose
```yaml
---
services:
  ubuntu:
    image: pycontribs/ubuntu
    container_name: ubuntu
    restart: on-failure
    command:
      - sleep
      - infinity
  centos7:
    image: centos:7
    container_name: centos7
    restart: on-failure
    command:
      - sleep
      - infinity
  fedora:
    image: pycontribs/fedora
    container_name: fedora
    restart: on-failure
    command:
      - sleep
      - infinity
```
А также `playbook/inventory/prod.yml`
```yaml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  fed:
    hosts:
      fedora:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```
А также создаем еще одну групповую переменную `playbook/group_vars/fed/examp.yml`:
```yaml
---
  some_fact: "fed default fact"
```

Контейнеры на месте:
```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo docker ps
CONTAINER ID   IMAGE               COMMAND            CREATED         STATUS         PORTS     NAMES
c356e7802dfe   pycontribs/fedora   "sleep infinity"   3 minutes ago   Up 3 minutes             fedora
bee6adb3c169   pycontribs/ubuntu   "sleep infinity"   3 minutes ago   Up 3 minutes             ubuntu
df36dfc4fcc1   centos:7            "sleep infinity"   3 minutes ago   Up 3 minutes             centos7
```
Плейбук тоже отрабатывает правильно:
```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
Vault password: 

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]
ok: [fedora]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "fed default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

> 5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

Для этого всё-таки понадобится сначала убрать из интерактивного режима ввод пароля.  
Сохраняем пароль в файл:
```bash
echo netology > .vaultpass
```
Добавляем в `.gitignore`.  
Проверяем:
```
sudo ansible-playbook --vault-pass-file .vaultpass site.yml -i inventory/prod.yml
```
Пишем [скрипт](https://github.com/ansakoy/devnet08/blob/master/scripts/run.sh):
```bash
#!/bin/bash

set -euxo

docker-compose up -d

ansible-playbook --vault-pass-file playbook/.vaultpass playbook/site.yml -i playbook/inventory/prod.yml

docker-compose down
```
Делаем запускаемым и запускаем:
```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08$ chmod 700 scripts/run.sh 
(devnet08venv) ansakoy@devnet:~/08_1/devnet08$ sudo scripts/run.sh
```

```bash
+ docker-compose up -d
ubuntu is up-to-date
centos7 is up-to-date
fedora is up-to-date
+ ansible-playbook --vault-pass-file playbook/.vaultpass playbook/site.yml -i playbook/inventory/prod.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [fedora]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [fedora] => {
    "msg": "fed default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

+ docker-compose down
Stopping fedora  ... done
Stopping ubuntu  ... done
Stopping centos7 ... done
Removing fedora  ... done
Removing ubuntu  ... done
Removing centos7 ... done
Removing network 08_1_default
```
> 6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

Есть. Все изменения зафиксированы в истории [репозитория](https://github.com/ansakoy/devnet08/).

