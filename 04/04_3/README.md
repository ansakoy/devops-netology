# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"
[Источник](https://github.com/netology-code/sysadm-homeworks/tree/devsys10/04-script-03-yaml)

### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис
  
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
"""
Получение IP веб-сервисов по доменному имени
Вывод информации в stdout в виде: <URL сервиса> - <его IP>
Проверка доступности текущего IP с записью результата в лог
Сравнение текущего IP сервиса c его IP из предыдущей проверки
В случае изменения вывод в stdout сообщения в формате: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>
"""
import datetime
import json
import os
import socket
import subprocess
import yaml  # Добавлено для 04-3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

IP_HISTORY_FILE = os.path.join(BASE_DIR, 'ip_history.json')
LOG_FILE = os.path.join(BASE_DIR, 'ip_availability.log')

# Добавлено для 04-3
CURRENT_STATE = os.path.join(BASE_DIR, 'current_state')


def load_json(source: str):
    with open(source, 'r', encoding="utf-8") as handler:
        return json.load(handler)


def dump_json(input: (dict, list), json_file: str):
    with open(json_file, 'w', encoding='utf-8') as handler:
        json.dump(input, handler, ensure_ascii=False, indent=2)

# Добавлено для 04-3
def dump_yaml(input: (dict, list), yaml_file: str):
    with open(yaml_file, 'w', encoding='utf-8') as handler:
        yaml.dump(input, handler)


# Добавлено для 04-3
def write_more_useless_files(addresses: dict) -> None:
    """
    Write data to yet another json and also yaml files
    """
    if not addresses:
        return
    result = {key: addresses[key][-1] for key in addresses}
    dump_json(result, f'{CURRENT_STATE}.json')

    # Извращенное преобразование для приведение формата к тому, что указано в задании
    result = [{key: result[key]} for key in result]
    dump_yaml(result, f'{CURRENT_STATE}.yml')


def process_history(name: str, current_ip: str, output: str, addresses: dict):
    ips = addresses.get(name, list())
    old_new = None
    if ips and ips[-1] != current_ip:
        old_new = ips[-1], current_ip
        addresses[name].append(current_ip)
    elif not ips:
        addresses[name] = [current_ip]
    dump_json(addresses, output)

    # Добавлено для 04-3
    write_more_useless_files(addresses)
    return old_new


def check_connection(ip_address: str):
    with open(os.devnull, 'w') as dev_null:
        try:
            subprocess.check_call(
                ['ping', '-c', '3', ip_address],
                stdout=dev_null,
                stderr=dev_null,
            )
            result = 'up'
        except subprocess.CalledProcessError:
            result = 'down'
        with open(LOG_FILE, 'a', encoding='utf-8') as handler:
            handler.write(f"{datetime.datetime.utcnow()} - {ip_address} - {result}\n")


def process_name(name: str):
    try:
        ip_address = socket.gethostbyname(name)
        print(f"{name} - {ip_address}")
    except socket.gaierror:
        print(f"Некорректное доменное имя: {name}")
        return
    check_connection(ip_address)

    try:
        urls = load_json(IP_HISTORY_FILE)
    except FileNotFoundError:
        urls = dict()
    old_new = process_history(
        name=name,
        current_ip=ip_address,
        output=IP_HISTORY_FILE,
        addresses=urls,
    )
    if old_new:
        print(f"[ERROR] {name} IP mismatch: {old_new[0]} {old_new[1]}")
    print("\n")


def launch(*args):
    for arg in args[0][1:]:
        process_name(arg)


if __name__ == '__main__':
    from sys import argv

    launch(argv)
```

### Вывод скрипта при запуске при тестировании:
```
(dnvenv) ansakoy ~/Documents/Courses/netology/devops-netology % python 04/04_3/ip_checker2/ip_checker.py drive.google.com mail.google.com google.com
drive.google.com - 64.233.165.194


mail.google.com - 64.233.162.18


google.com - 64.233.164.100
[ERROR] google.com IP mismatch: 108.177.14.102 64.233.164.100
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
  "mail.google.com": "64.233.162.18",
  "drive.google.com": "64.233.165.194",
  "google.com": "64.233.164.100"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
- mail.google.com: 64.233.162.18
- drive.google.com: 64.233.165.194
- google.com: 64.233.164.100
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
???
```

### Пример работы скрипта:
???