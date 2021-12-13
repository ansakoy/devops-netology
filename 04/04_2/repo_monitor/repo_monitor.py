"""
Скрипт позволяет узнать, какие файлы модифицированы в репозитории относительно локальных изменений
Указывать полные пути к файлам относительно репозитория
"""
import os

import environ
from git import Repo

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# FIXME: Вспомогательный путь добавлен, потому что модуль находится внутри большого проекта.
#  В норме он должен быть вынесен в отдельный проект, чтобы BASE_DIR была лично его.
PROJ_DIR = os.path.join(BASE_DIR, '04', '04_2', 'repo_monitor')

env = environ.Env(
    GIT_REPO=(str, BASE_DIR),
)

environ.Env.read_env(os.path.join(PROJ_DIR, ".env"))

GIT_REPO_PATH = env("GIT_REPO")


def list_files(report: str, seq: list, repo_path=None):
    """
    Добавить в отчет перечень файлов
    """
    if repo_path:
        git_path = repo_path
    else:
        git_path = GIT_REPO_PATH
    for mfile in seq:
        report += f"\n----> {os.path.join(git_path, mfile)}"
    return report


def get_local_modifications(repo_path=None):
    """
    Собрать отчет о локальных изменениях в репозитории
    """
    git_repo = Repo(GIT_REPO_PATH)
    git_path = GIT_REPO_PATH
    if repo_path:
        git_path = repo_path
        git_repo = Repo(repo_path)
    staged_files = [
        os.path.join(git_path, fname)
        for fname in git_repo.git.diff(name_only=True, staged=True).split('\n') if len(fname)
    ]
    modified_files = [
        os.path.join(git_path, fname)
        for fname in git_repo.git.diff(name_only=True).split('\n') if len(fname)
    ]
    untracked_files = [os.path.join(git_path, fname) for fname in git_repo.untracked_files]
    report = f"Репозиторий: {git_path}\nТекущая ветка: {git_repo.active_branch}"
    if staged_files:
        report += f"\n\nДобавлены в индекс, но не отправлены в коммит:"
        report = list_files(report, staged_files)
    if modified_files:
        report += f"\n\nИзмененные файлы:"
        report = list_files(report, modified_files)
    if untracked_files:
        report += f"\n\nНе добавлены в индекс:"
        report = list_files(report, untracked_files)
    if not staged_files and not modified_files and not untracked_files:
        report += f"\n\nВ этой ветке изменений нет"
    print(report)


if __name__ == '__main__':
    get_local_modifications()