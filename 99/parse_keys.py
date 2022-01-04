#!/usr/bin/python3

"""
Костыльный скрипт. В норме нужно использовать API, а не CLI, но хотелось попробовать через CLI, а парсить
текст башем не хотелось
"""

import os


def process_init_keys(source_file: str, storage_path: str) -> None:
    """
    Extract init vault keys, place them into separate files
    """
    # Create storage for keys if not exists
    if not os.path.isdir(storage_path):
        os.makedirs(storage_path)

    # Create individual files for all keys
    with open(source_file, 'r', encoding='utf-8') as handler:
        for line in handler.readlines():
            entries = line.split()
            if entries:
                if entries[0] == 'Unseal':
                    fname = os.path.join(storage_path, f'unseal{entries[2][0]}')
                    with open(fname, 'w', encoding='utf-8') as key_hand:
                        key_hand.write(entries[-1])
                elif entries[0] == 'Initial':
                    fname = os.path.join(storage_path, 'root_key')
                    with open(fname, 'w', encoding='utf-8') as key_hand:
                        key_hand.write(entries[-1])


if __name__ == '__main__':
    from sys import argv
    process_init_keys(argv[1], argv[2])