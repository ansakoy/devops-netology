from repo_monitor import get_local_modifications


def launch_from_cli(*args):
    if not args[0][1]:
        print("Не указан путь к нужному репозиторию")
        return
    repo_address = args[0][1]
    get_local_modifications(repo_path=repo_address)


if __name__ == '__main__':
    from sys import argv
    launch_from_cli(argv)


