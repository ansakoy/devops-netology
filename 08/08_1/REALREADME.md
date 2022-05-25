https://github.com/netology-code/mnt-homeworks/blob/MNT-7/08-ansible-01-base/README.md




# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
> 1. Установите ansible версии 2.10 или выше.

```bash
python3.9 -m venv devnet08venv

devnet08venv/bin/pip install --upgrade pip

devnet08venv/bin/pip install ansible
```
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

https://github.com/ansakoy/devnet08

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
```bash
PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP ************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
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

[Измененный файл](https://github.com/ansakoy/devnet08/blob/master/playbook/group_vars/all/examp.yml)

> 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

Из формулировки не очень понятно, каким должно быть окружение, но пункты ниже указывают на то, 
что будет использоваться `prod.yml`. Там фигурируют два хоста - ubuntu и centos7. Если в `test.yml` 
мы подключались к localhost текущей машины, видимо, нам потребуется две виртуалки или два контейнера, 
где будут установлены соответствующие ОС. Создадим для этого [docker-compose](environment/docker-compose.yml):
```yaml
---
services:
  ubuntu:
    image: ubuntu:20.04
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
По итогам `sudo docker-compose up -d` имеем два соответствующих контейнера:
```bash
ansakoy@devnet:~/08_1$ sudo docker ps
[sudo] password for ansakoy: 
CONTAINER ID   IMAGE          COMMAND            CREATED         STATUS         PORTS     NAMES
664eb0600c70   ubuntu:20.04   "sleep infinity"   3 minutes ago   Up 3 minutes             ubuntu
5fa0edd456e5   centos:7       "sleep infinity"   3 minutes ago   Up 3 minutes             centos7
```

> 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

ОК:
```
$ sudo ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
fatal: [ubuntu]: FAILED! => {"ansible_facts": {}, "changed": false, "failed_modules": {"ansible.legacy.setup": {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "failed": true, "module_stderr": "/bin/sh: 1: /usr/bin/python: not found\n", "module_stdout": "", "msg": "The module failed to execute correctly, you probably need to set the interpreter.\nSee stdout/stderr for the exact error", "rc": 127, "warnings": ["No python interpreters found for host ubuntu (tried ['python3.10', 'python3.9', 'python3.8', 'python3.7', 'python3.6', 'python3.5', '/usr/bin/python3', '/usr/libexec/platform-python', 'python2.7', 'python2.6', '/usr/bin/python', 'python'])"]}}, "msg": "The following modules failed to execute: ansible.legacy.setup\n"}
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```
Внезапно. CentOS отработал нормально а с Ubuntu скандал из-за недоразумений по питоновскому интерпретатору.

Зайдем посмотрим, что там внутри
```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo docker exec -ti ubuntu bash
root@664eb0600c70:/# which python
root@664eb0600c70:/# which python3
root@664eb0600c70:/# python3.8 --version
bash: python3.8: command not found
root@664eb0600c70:/# python2
bash: python2: command not found
```
Прикольно.  
Смотрим, что у нас в /usr/lib, где, по идее, должен лежать питон, хоть какой-нибудь:
```bash
root@664eb0600c70:/usr/lib# ls
apt  dpkg  init  locale  lsb  mime  os-release  sysctl.d  systemd  terminfo  tmpfiles.d  udev  x86_64-linux-gnu
```
А нет там никакого питона. Сравним для надежности с хостовой системой:
```bash
root@664eb0600c70:/usr/lib# exit
exit
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ ls /usr/lib
apt          environment.d     gold-ld          linux-boot-probes    os-probes    rsyslog              sysusers.d               x86_64-linux-gnu
bfd-plugins  file              grub             locale               os-release   sasl2                tasksel
binfmt.d     gcc               grub-legacy      mime                 packagekit   sftp-server          tc
compat-ld    girepository-1.0  initramfs-tools  modules-load.d       policykit-1  software-properties  tmpfiles.d
dbus-1.0     git-core          jvm              networkd-dispatcher  python2.7    ssl                  ubuntu-release-upgrader
debug        gnupg             kernel           nginx                python3      sudo                 valgrind
dpkg         gnupg1            klibc            openssh              python3.8    sysctl.d             virt-sysprep
eject        gnupg2            linux            os-prober            python3.9    systemd              X11
```
По ходу образ под названием ubuntu:20.04 - это всё-таки очень урезанная убунта.

Ладно, создадим образ убунты с питоном.

[Dockerfile](environment/Dockerfile)
```
FROM ubuntu:20.04

RUN apt update && apt install -y python3.9
```
Собираем:
```bash
sudo docker build -t ubuntu2004python39 .
```
Запускаем посмотреть, что внутри:
```bash
sudo docker run -ti ubuntu2004python39 bash
```
Внутри вроде бы всё теперь хорошо:
```
root@064b39f73575:/# python3.9 --version
Python 3.9.5
root@064b39f73575:/# ls /usr/lib
apt  dpkg  file  init  locale  lsb  mime  os-release  python3  python3.9  ssl  sysctl.d  systemd  terminfo  tmpfiles.d  udev  x86_64-linux-gnu
```
На всякий случай заливаем образ в хаб.

(если не залогинены, логинимся `docker login -u ansakoy`, если залогинены, то ни в коем 
случае не логинимся, ибо обругает и не пустит)

```bash
# Вешаем тег
docker tag ubuntu2004python39 ansakoy/ubuntu2004python39:v0.0.1
# Пушим
docker push ansakoy/ubuntu2004python39:v0.0.1
```
Теперь [образ здесь](https://hub.docker.com/repository/docker/ansakoy/ubuntu2004python39)

Поудаляем все тестовые контейнеры и изменим docker-compose:
```yaml
---
services:
  ubuntu:
    image: ubuntu2004python39
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
И снова запускаем `docker-compose up -d`
```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08$ sudo docker ps
CONTAINER ID   IMAGE                COMMAND            CREATED          STATUS          PORTS     NAMES
01152c9feaae   ubuntu2004python39   "sleep infinity"   19 seconds ago   Up 15 seconds             ubuntu
73195eef5d5a   centos:7             "sleep infinity"   19 seconds ago   Up 15 seconds             centos7
```

И запускаем снова плейбук:
```
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
[WARNING]: Distribution ubuntu 20.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python3.9, since the discovered platform python
interpreter was not present. See https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
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
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
Ну извини, приятель, не совсем по науке тебе питон поставили. Но сработало.

> 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

[deb](https://github.com/ansakoy/devnet08/tree/master/playbook/group_vars/deb)
```yaml
---
  some_fact: "deb default fact"
```
[el](https://github.com/ansakoy/devnet08/tree/master/playbook/group_vars/el)
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
[WARNING]: Distribution ubuntu 20.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python3.9, since the discovered platform python
interpreter was not present. See https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
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
[WARNING]: Distribution ubuntu 20.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python3.9, since the discovered platform python
interpreter was not present. See https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
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
[WARNING]: Collection splunk.es does not support Ansible version 2.12.5
[WARNING]: Collection ibm.qradar does not support Ansible version 2.12.5
[DEPRECATION WARNING]: ansible.netcommon.napalm has been deprecated. See the plugin documentation for more details. This feature will be removed from 
ansible.netcommon in a release after 2022-06-01. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ansible.netcommon.httpapi      Use httpapi to run command on network appliances                                                                       
ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ssh connection                                                               
ansible.netcommon.napalm       Provides persistent connection using NAPALM                                                                            
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol                                                            
ansible.netcommon.network_cli  Use network_cli to run command on network appliances                                                                   
ansible.netcommon.persistent   Use a persistent unix socket for connection                                                                            
community.aws.aws_ssm          execute via AWS Systems Manager                                                                                        
community.docker.docker        Run tasks in docker containers                                                                                         
community.docker.docker_api    Run tasks in docker containers                                                                                         
community.docker.nsenter       execute on host running controller container                                                                           
community.general.chroot       Interact with local chroot                                                                                             
community.general.funcd        Use funcd to connect to target                                                                                         
community.general.iocage       Run tasks in iocage jails                                                                                              
community.general.jail         Run tasks in jails                                                                                                     
community.general.lxc          Run tasks in lxc containers via lxc python library                                                                     
community.general.lxd          Run tasks in lxc containers via lxc CLI                                                                                
community.general.qubes        Interact with an existing QubesOS AppVM                                                                                
community.general.saltstack    Allow ansible to piggyback on salt minions                                                                             
community.general.zone         Run tasks in a zone instance                                                                                           
community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt                                                                                
community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines                                                                             
community.okd.oc               Execute tasks in pods running on OpenShift                                                                             
community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools                                                                             
community.zabbix.httpapi       Use httpapi to run command on network appliances                                                                       
containers.podman.buildah      Interact with an existing buildah container                                                                            
containers.podman.podman       Interact with an existing podman container                                                                             
kubernetes.core.kubectl        Execute tasks in pods running on Kubernetes                                                                            
local                          execute on controller                                                                                                  
paramiko_ssh                   Run tasks via python ssh (paramiko)                                                                                    
psrp                           Run tasks over Microsoft PowerShell Remoting Protocol                                                                  
ssh                            connect via SSH client binary                                                                                          
winrm                          Run tasks over Microsoft's WinRM 
```
Вероятно, имеется в виду `local - execute on controller`?

Вообще доки насчет плагинов для типов подключения [здесь](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#non-ssh-connection-types), 
и они подтверждают: `This connector can be used to deploy the playbook to the control machine itself.`

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
[WARNING]: Distribution ubuntu 20.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python3.9, since the discovered platform python
interpreter was not present. See https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
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

```bash
(devnet08venv) ansakoy@devnet:~/08_1/devnet08/playbook$ sudo ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
[sudo] password for ansakoy: 
Vault password: 

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
fatal: [centos7]: UNREACHABLE! => {"changed": false, "msg": "Failed to create temporary directory.In some cases, you may have been able to authenticate and did not have permissions on the target directory. Consider changing the remote tmp path in ansible.cfg to a path rooted in \"/tmp\", for more error information use -vvv. Failed command was: ( umask 77 && mkdir -p \"` echo ~/.ansible/tmp `\"&& mkdir \"` echo ~/.ansible/tmp/ansible-tmp-1653127715.6477914-1061086-84888347099406 `\" && echo ansible-tmp-1653127715.6477914-1061086-84888347099406=\"` echo ~/.ansible/tmp/ansible-tmp-1653127715.6477914-1061086-84888347099406 `\" ), exited with result 1", "unreachable": true}
fatal: [ubuntu]: UNREACHABLE! => {"changed": false, "msg": "Failed to create temporary directory.In some cases, you may have been able to authenticate and did not have permissions on the target directory. Consider changing the remote tmp path in ansible.cfg to a path rooted in \"/tmp\", for more error information use -vvv. Failed command was: ( umask 77 && mkdir -p \"` echo ~/.ansible/tmp `\"&& mkdir \"` echo ~/.ansible/tmp/ansible-tmp-1653127715.630914-1061087-151389699521304 `\" && echo ansible-tmp-1653127715.630914-1061087-151389699521304=\"` echo ~/.ansible/tmp/ansible-tmp-1653127715.630914-1061087-151389699521304 `\" ), exited with result 1", "unreachable": true}
ok: [localhost]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0 
```
А всё почему? Потому что когда выключаешь контейнеры, надо их потом еще и обратно ведь включить. 
Но т.к. у нас из заданий ниже выяснился источник питонизированной убунты, мы сейчас еще и docker-compose 
подновим.
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
Теперь всё работает и даже не скандалит.

> 4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).

А, вот откуда надо было брать убунту с питоном.

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
Пишем скрипт:
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

