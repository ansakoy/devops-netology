https://github.com/netology-code/mnt-homeworks/tree/MNT-7/08-ansible-02-playbook
https://github.com/ansakoy/devnet082

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
    image: pycontribs/ubuntu
    container_name: ubuntu
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

```
ansakoy@devnet:~/08_2$ sudo docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS         PORTS                                             NAMES
ffdb1c244818   centos:7                  "sleep infinity"         11 seconds ago   Up 7 seconds                                                     centos7click

```

> 2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).

> 3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.

> 4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

> 5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Включаем ансибл и убеждаемся, что он у нас есть в окружении, потому что пользуемся мы питоновским 
виртуальным окружением.
```
ansakoy@devnet:~/08_2$ . ~/venv/bin/activate
(venv) ansakoy@devnet:~/08_2$ pip freeze
ansible==5.4.0
ansible-core==2.12.3
cffi==1.15.0
cryptography==36.0.1
Jinja2==3.0.3
MarkupSafe==2.1.0
packaging==21.3
pkg_resources==0.0.0
pycparser==2.21
pyparsing==3.0.7
PyYAML==6.0
resolvelib==0.5.4
```

```
(venv) ansakoy@devnet:~/08_2/playbook$ ansible-lint site.yml
-bash: ansible-lint: command not found
```
Упс
```
(venv) ansakoy@devnet:~/08_2/playbook$ pip install ansible-lint
```
После установки:
```
(venv) ansakoy@devnet:~/08_2/playbook$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 1 violation(s) that are fatal
syntax-check: Ansible syntax check failed.
site.yml:1 ERROR! We were unable to read either as JSON nor YAML, these are the errors we got from each:
JSON: Expecting value: line 1 column 1 (char 0)

Syntax Error while loading YAML.
  mapping values are not allowed in this context

The error appears to be in '/home/ansakoy/08_2/playbook/site.yml': line 46, column 32, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

    - name: Get vector distrib
        ansible.builtin.get_url:
                               ^ here



Finished with 1 failure(s), 0 warning(s) on 1 files.
```
Ну да, индентация поехала.
```
(venv) ansakoy@devnet:~/08_2/playbook$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 4 violation(s) that are fatal
unnamed-task: All tasks should be named.
site.yml:11 Task/Handler: block/always/rescue 

risky-file-permissions: File permissions unset or incorrect.
site.yml:12 Task/Handler: Get clickhouse distrib

risky-file-permissions: File permissions unset or incorrect.
site.yml:18 Task/Handler: Get clickhouse distrib

risky-file-permissions: File permissions unset or incorrect.
site.yml:45 Task/Handler: Get vector distrib

You can skip specific rules or tags by adding them to your configuration file:
# .config/ansible-lint.yml
warn_list:  # or 'skip_list' to silence them completely
  - experimental  # all rules tagged as experimental
  - unnamed-task  # All tasks should be named.

Finished with 1 failure(s), 3 warning(s) on 1 files.
```
По итогам правок:
```
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
        - name: Get clickhouse distrib
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
    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
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
```
И вроде бы всё
```
(venv) ansakoy@devnet:~/08_2/playbook$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
```
