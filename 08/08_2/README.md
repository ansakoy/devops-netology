# Домашнее задание к занятию "08.02 Работа с Playbook"
[Источник](https://raw.githubusercontent.com/netology-code/mnt-homeworks/MNT-13/08-ansible-02-playbook/README.md)

Дисклеймер: на эту версию указывает [версия в ветке MNT-7](https://github.com/netology-code/mnt-homeworks/tree/MNT-7/08-ansible-02-playbook), 
на которую указал куратор как на актуальную.

## Подготовка к выполнению

> 1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.

Создадим [новый](https://github.com/ansakoy/devnet082) под задачу

> 2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

[Есть](https://github.com/ansakoy/devnet082/tree/master/playbook)

> 3. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

Судя по плейбуку, предполагается только один хост, который развернем через docker-compose:
```yaml
---
services:
  ubuntu:
    image: centos:7
    container_name: clickhouse-01
    restart: on-failure
    command:
      - sleep
      - infinity
```

## Основная часть

> 1. Приготовьте свой собственный inventory файл `prod.yml`.

Каков хост, таков и файл:
```yaml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_connection: docker
```

> 2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).

Фрагмент плейбука:
```yaml
- name: Install vector
  hosts: clickhouse
  handlers:
    - name: Start vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.x86_64.rpm"
        dest: "./vector-{{ vector_version }}.rpm"
        mode: 0644
      notify: Start vector service
```

> 3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.

> 4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

```yaml
- name: Install vector
  hosts: clickhouse
  handlers:
    - name: Start vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.x86_64.rpm"
        dest: "./vector-{{ vector_version }}.rpm"
        mode: 0644
      notify: Start vector service
    - name: Install vector packages
      become: true
      ansible.builtin.yum:
        name:
          - vector-{{ vector_version }}.rpm
    - name: Flush handlers to restart vector
      ansible.builtin.meta: flush_handlers
```
Flush тут для надежности. Были большие проблемы с запуском clickhouse через просто notify. Заодно 
и вектору перепало.

> 5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

По итогам правок:
```yaml
---
- name: Install Clickhouse
  hosts: clickhouse
  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - name: Mess with clickhouse distrib
      block:
        - name: Get clickhouse distrib
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.noarch.rpm"
            dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
            mode: 0644
          with_items: "{{ clickhouse_packages }}"
      rescue:
        - name: Get clickhouse distrib (rescue)
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-{{ clickhouse_version }}.x86_64.rpm"
            dest: "./clickhouse-common-static-{{ clickhouse_version }}.rpm"
            mode: 0644
    - name: Install clickhouse packages
      become: true
      ansible.builtin.yum:
        name:
          - clickhouse-common-static-{{ clickhouse_version }}.rpm
          - clickhouse-client-{{ clickhouse_version }}.rpm
          - clickhouse-server-{{ clickhouse_version }}.rpm
      notify: Start clickhouse service
    - name: Flush handlers to restart clickhouse
      ansible.builtin.meta: flush_handlers
    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      become: true
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc !=82
      changed_when: create_db.rc == 0

- name: Install vector
  hosts: clickhouse
  handlers:
    - name: Start vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.x86_64.rpm"
        dest: "./vector-{{ vector_version }}.rpm"
        mode: 0644
      notify: Start vector service
    - name: Install vector packages
      become: true
      ansible.builtin.yum:
        name:
          - vector-{{ vector_version }}.rpm
    - name: Flush handlers to restart vector
      ansible.builtin.meta: flush_handlers
```
И вроде бы всё
```
(venv) ansakoy@devnet:~/08_2/playbook$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
```

> 6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

В реальной жизни работает:

С --check вроде бы всё в пределах ожиданий:
```bash
(devnet08venv) ansakoy@devnet:~/08_2/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] *******************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib (rescue)] ******************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] **********************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "module_stderr": "/bin/sh: sudo: command not found\n", "module_stdout": "", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 127}

PLAY RECAP **********************************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0  
```
Закономерно падает на том, что файлов нет.

> 7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

Дисклеймер: т.к. устанавливаю в контейнер (и не хочу создавать специальный образ), добавляю 
в сценарий еще один плей - установку sudo на centos7.
```bash
(devnet08venv) ansakoy@devnet:~/08_2/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Setup] ********************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Install sudo] *************************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install Clickhouse] *******************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib (rescue)] ******************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] **********************************************************************************************************
changed: [clickhouse-01]

TASK [Flush handlers to restart clickhouse] *************************************************************************************************

RUNNING HANDLER [Start clickhouse service] **************************************************************************************************
changed: [clickhouse-01]

TASK [Create database] **********************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install vector] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] *******************************************************************************************************************
changed: [clickhouse-01]

TASK [Install vector packages] **************************************************************************************************************
changed: [clickhouse-01]

TASK [Flush handlers to restart vector] *****************************************************************************************************

RUNNING HANDLER [Start vector service] ******************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service vector: host"}

NO MORE HOSTS LEFT **************************************************************************************************************************

PLAY RECAP **********************************************************************************************************************************
clickhouse-01              : ok=10   changed=7    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0
```

> 8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

Вполне:
```bash
(devnet08venv) ansakoy@devnet:~/08_2/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Setup] ********************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Install sudo] *************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Clickhouse] *******************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "size": 246310036, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib (rescue)] ******************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] **********************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers to restart clickhouse] *************************************************************************************************

TASK [Create database] **********************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install vector] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] *******************************************************************************************************************
ok: [clickhouse-01]

TASK [Install vector packages] **************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers to restart vector] *****************************************************************************************************

PLAY RECAP **********************************************************************************************************************************
clickhouse-01              : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0 
```

> 9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

https://github.com/ansakoy/devnet082/blob/master/README.md

> 10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

https://github.com/ansakoy/devnet082/releases/tag/08-ansible-02-playbook

