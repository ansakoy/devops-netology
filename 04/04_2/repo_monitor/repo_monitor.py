"""
Скрипт позволяет узнать, какие файлы модифицированы в репозитории относительно локальных изменений
Указывать полные пути к файлам относительно репозитория
"""
import os

import environ
from git import Repo

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

env = environ.Env(
    GIT_REPO=(str, BASE_DIR),
)

environ.Env.read_env(os.path.join(BASE_DIR, ".env"))

GIT_REPO_PATH = env("GIT_REPO")

REPO = Repo(GIT_REPO_PATH)


def list_files(report: str, seq: list):
    """
    Добавить в отчет перечень файлов
    """
    for mfile in seq:
        report += f"\n----> {os.path.join(GIT_REPO_PATH, mfile)}"
    return report


def get_local_modifications():
    """
    Собрать отчет о локальных изменениях в репозитории
    """
    staged_files = [os.path.join(BASE_DIR, fname) for fname in REPO.git.diff(name_only=True, staged=True).split('\n')]
    modified_files = [os.path.join(BASE_DIR, fname) for fname in REPO.git.diff(name_only=True).split('\n')]
    untracked_files = [os.path.join(BASE_DIR, fname) for fname in REPO.untracked_files]
    report = f"Репозиторий: {GIT_REPO_PATH}\nТекущая ветка: {REPO.active_branch}"
    if staged_files:
        report += f"\n\nДобавлены в индекс, но не отправлены в коммит:"
        report = list_files(report, staged_files)
    if modified_files:
        report += f"\n\nИзмененные файлы:"
        report = list_files(report, modified_files)
    if untracked_files:
        report += f"\n\nНе добавлены в индекс:"
        report = list_files(report, untracked_files)
    print(report)


if __name__ == '__main__':
    get_local_modifications()