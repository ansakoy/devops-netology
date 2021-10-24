# Задание 2.1

Отредактирован в соответствии с [заданием 2.1](https://github.com/netology-code/sysadm-homeworks/tree/devsys10/02-git-01-vcs)

## Задание 2.1.4
> В файле README.md опишите своими словами какие файлы будут проигнорированы в будущем благодаря добавленному .gitignore

По итогам заданий 2.1.2 и 2.1.3 в репозитории появилось два файла .gitignore.
* Пустой файл `.gitignore` в первом уровне иерархии (он пока не дает никаких инструкций по игнорированию)
* Файл `terraform/Terraform.gitignore`, в который были скопировано содержание 
[образца](https://github.com/github/gitignore/blob/master/Terraform.gitignore). В соответствии с 
заданными правилами, будут игнорироваться следущие файлы:
  * все файлы, находящиеся в каталогах, имеющих название `.terraform/`
  * файлы с расширением .tfstate или содержащие в названии `.tfstate.`
  * файл под названием `crash.log`
  * файлы с расширением `.tfvars`
  * файлы `override.tf` и `override.tf.json`, а также все файлы, оканчивающиеся 
  на `_override.tf` или `_override.tf.json`.
  * файл с расширением `.terraformrc` и файл `terraform.rc`.