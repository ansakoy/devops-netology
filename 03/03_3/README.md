# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"
[Источник](https://github.com/netology-code/sysadm-homeworks/tree/master/03-sysadmin-03-os)

### 1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к `cd`.
```
$ strace /bin/bash -c 'cd /tmp'
...
chdir("/tmp")
...
```
**NB**: `strace` выводит данные в stderr.

### 2. Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.
Используем `strace file some_file`, чтобы отследить системные вызовы `file`. Ближе к концу вывода имеется строка 
`openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3`.
До того утилита пытается обратиться по адресам в домашней папке текущего юзера 
(/home/ansakoy/.magic.mgc, /home/ansakoy/.magic), но не находит требуемых файлов. 
Также неудачной оказывается попытка открыть несуществующий файл /etc/magic.mgc. 
Затем происходит успешная попытка прочитать файл /etc/magic, однако в нем не данных - 
есть только комментарий о том, что это локальный файл для команды file и в него можно положить свои 
локальные magic data в формате, расписанном в мануале magic(5). 
Наконец происходит успешное открытие файла /usr/share/misc/magic.mgc.
```
$ strace file some_file 2>&1 | grep magic
strace file some_file 2>&1 | grep magicopenat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3
stat("/home/ansakoy/.magic.mgc", 0x7ffd14daca30) = -1 ENOENT (No such file or directory)
stat("/home/ansakoy/.magic", 0x7ffd14daca30) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
```
### 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
Если файл удален, но остался открытым, взаимодействовать с ним можно через его файловый дескриптор.
```
ps aux | grep <app_name>  # ищем PID приложения
lsof -p <app_PID> | grep deleted  # смотрим список файлов, открытых этим приложением, выбираем удаленный, берем его FD
```
Операции с таким файлом можно производить через `/proc/PID/fd/FD`. Допустим у нас PID = 1826, а FD = 9.
Обнулим его путем копирования в него `/dev/null`
```
cp /dev/null /proc/1826/fd/9
```
Как вариант, можно направить этому дескриптору вывод /dev/null (`cat /dev/null > /proc/1826/fd/9`)

### 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Нет, зомби-процессы не занимают никаких ресурсов.  
Они не занимают RAM, так как они уже отработали, и ОС не выделяет на для них памяти. Тот объем памяти, 
который требуется для их хранения в таблице процессов, пренебрежимо мал.  
CPU они тоже не занимают, так как их работа уже завершена. В выводе `ps aux` можно наблюдать, что значения колонки `%CPU` 
для зомби >0, но это уже не актуальные значения, а исторические, за период работы процесса, сохраненные для 
передачи родительскому процессу.  
IO зомби-процессы тоже не занимают.  
Единственный риск, исходящий от зомби, как гласит [эта статья](https://dzone.com/articles/zombie-processes-a-short-survival-guide), 
состоит в том, что если их слишком много, то они могут заполнить таблицу процессов, у которой есть лимит.
### 5. В iovisor BCC есть утилита `opensnoop`. На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
Смотрим `man opensnoop`:  
Утилита прослеживает системный вызов `open()` и показывает, какие процессы какие файлы пытаются открыть. 
Команда `opensnoop` без аргументов показывает все такие системные вызовы. 
Можно отследить системные вызовы за заданный в секундах промежуток (`-d` - duration).
```
$ sudo opensnoop-bpfcc -d 1
PID    COMM               FD ERR PATH
1      systemd            12   0 /proc/481/cgroup
```
### 6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.
Утилита `uname` выводит информацию о системе. `-a` - вывод всей информации.  
Как указывает `strace uname -a`, утилита запускает системный вызов `uname`.
```
$ strace uname -a
...                     = 0
uname({sysname="Linux", nodename="ubuntu-s-1vcpu-1gb-lon1-01", ...}) = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0x1), ...}) = 0
uname({sysname="Linux", nodename="ubuntu-s-1vcpu-1gb-lon1-01", ...}) = 0
uname({sysname="Linux", nodename="ubuntu-s-1vcpu-1gb-lon1-01", ...}) = 0
...
```
В `man uname` выводится только секция 1. Там есть ссылка на uname(2), однако `man uname.2` сообщает, что такой 
страницы нет. Устанавливаем расширенную версию `sudo apt install manpages-dev` в соответствии с [рекомендацией](https://askubuntu.com/questions/1157912/what-package-provides-system-call-man-pages-on-ubuntu). 
Теперь `man uname.2` с информацией о системном вызове работает.

Цитата:
```
Part of the utsname information is also accessible  via  /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.
```
\*`utsname` - структура описания системы.

Проверяем:
```
$ sudo cat /proc/sys/kernel/version
#99-Ubuntu SMP Thu Sep 23 17:29:00 UTC 2021
$ sudo cat /proc/sys/kernel/ostype
Linux
$ sudo cat /proc/sys/kernel/hostname
ubuntu-s-1vcpu-1gb-lon1-01
$ sudo cat /proc/sys/kernel/osrelease
5.4.0-88-generic
$ sudo cat /proc/sys/kernel/domainname
(none)
```

### 7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
```
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
```
> Есть ли смысл использовать в bash &&, если применить set -e?

В первом случае вторая команда выполняется независимо от результата первой. Во втором случае 
команда выполняется только при условии, что первая отработала успешно, то есть вернула экзит-код 0 (а не 1). 
На основании такого поведения можно было бы предположить, что при наличии `set -e` (скрипт должен прекратить 
работу после первой же операции, выдавшей ошибку) использование `&&` избыточно для прерывания 
выполнения последовательности команд. Тем не менее, этот оператор используется также для оценивания логических 
выражений, например в условиях (if, elif) и при while. Поэтому нельзя сказать, что `&&` в bash никогда нет смысла использовать 
при наличии `set -e`.

**NB**: `test` оценивает заданное выражение (в данном случае - что `/tmp/some_dir` существует и это директория) 
как истинное или ложное. В качестве результата возвращает экзит-код по принципу 1 -> false, 0 -> true 
(что несколько контринтуитивно).
### 8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
* `-e` - прекратить исполнение последовательности команд после первого случая, когда команда отработала 
с ненулевым кодом.  
* `-u` - интерпретировать неназначенные переменные как ошибку. По умолчанию bash при встрече с неназначенной переменной 
считает ее пустой строкой и продолжает работу. Эта опция позволяет изменить это поведение. Например: 
```
$ bash -c 'echo $a_new_variable'

$ bash -c 'set -u ; echo $a_new_variable'
bash: a_new_variable: unbound variable
```
Теперь распечатывается сообщение об ошибке, а неинтерактивный скрипт в таком случае также завершит работу с ненулевым кодом.
* `-x` - распечатывать значения переменных и сокращений всякий раз, когда они встречаются. Помимо развернутых 
значений, выводится также команда, которая произвела действие:
```
$ bash -c 'set -x ; echo {1..5}'
+ echo 1 2 3 4 5
1 2 3 4 5
```
В интерактивном режиме этот вывод может быть избыточным, но при исполнении скрипта это позволяет просматривать, 
какие значения появляются.
* `-o` - добавить дополнительную опцию. В данном случае добавляется `pipefail`, что позволяет выводить значение 
последней команды в пайплайне, которая была обработана с ненулевым кодом. Если все команды в пайплайне 
вернули нулевой код, выводится значение последней команды.

Такой набор опций полезен в скриптах, если нужен дебагинг. В совокупности они позволяют проследить, какие 
именно действия выполняет скрипт в ходе работы и что из этого приводит к ошибке. Если потребности в дебагинге 
нет, то `-x` и `-o pipefail` скорее избыточны.
### 9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).
```
$ ps -o stat
STAT
Ss
R+
```
* `S` - interruptible sleep (waiting for an event to complete) - спящий процесс, который ожидает какого-то события для завершения
* `R` - running or runnable (on run queue) - работающий процесс (или процесс, ожидающий начала работы в очереди)
* `s` - is a session leader - первый процесс в сессии (его `PID` совпадает с его session ID `SID`)
* `+` - is in the foreground process group - не в фоновом режиме

Можно посмотреть подробнее, к каким процессам это относится:
```
$ ps -o pid,sid,stat,command
    PID     SID STAT COMMAND
  31131   31131 Ss   -bash
  31603   31131 R+   ps -o pid,sid,stat,command
```