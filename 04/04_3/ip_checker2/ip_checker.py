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
import yaml

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

IP_HISTORY_FILE = os.path.join(BASE_DIR, 'ip_history.json')
LOG_FILE = os.path.join(BASE_DIR, 'ip_availability.log')

CURRENT_STATE = os.path.join(BASE_DIR, 'current_state')


def load_json(source: str):
    with open(source, 'r', encoding="utf-8") as handler:
        return json.load(handler)


def dump_json(input: (dict, list), json_file: str):
    with open(json_file, 'w', encoding='utf-8') as handler:
        json.dump(input, handler, ensure_ascii=False, indent=2)


def dump_yaml(input: (dict, list), yaml_file: str):
    with open(yaml_file, 'w', encoding='utf-8') as handler:
        yaml.dump(input, handler)


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




