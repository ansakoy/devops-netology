# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"
[Источник](https://github.com/netology-code/sysadm-homeworks/tree/devsys10/03-sysadmin-07-net)
### 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
Linux
```
$ ip -c -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
eth0             UP             7e:f5:88:b9:dd:be <BROADCAST,MULTICAST,UP,LOWER_UP> 
eth1             UP             8e:73:07:92:90:7a <BROADCAST,MULTICAST,UP,LOWER_UP> 
```
```
$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 7e:f5:88:b9:dd:be brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 8e:73:07:92:90:7a brd ff:ff:ff:ff:ff:ff
```
Также
```
$ sudo apt install net-tools
$ ifconfig -a
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 159.89.28.118  netmask 255.255.240.0  broadcast 159.89.31.255
        inet6 fe80::7cf5:88ff:feb9:ddbe  prefixlen 64  scopeid 0x20<link>
        ether 7e:f5:88:b9:dd:be  txqueuelen 1000  (Ethernet)
        RX packets 1130  bytes 2853370 (2.8 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 875  bytes 100823 (100.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.114.0.3  netmask 255.255.240.0  broadcast 10.114.15.255
        inet6 fe80::8c73:7ff:fe92:907a  prefixlen 64  scopeid 0x20<link>
        ether 8e:73:07:92:90:7a  txqueuelen 1000  (Ethernet)
        RX packets 11  bytes 846 (846.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 12  bytes 936 (936.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 164  bytes 14200 (14.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 164  bytes 14200 (14.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Для Windows советуют `netsh interface ipv4 show interfaces` и `ipconfig /all`. Проверить не могу, 
нет  Windows.
### 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
```
$ sudo apt update
$ sudo apt install lldpd
$ sudo lldpctl
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
$ 
```
(у VPS соседей нет)
```
$ sudo systemctl enable lldpd && sudo systemctl start lldpd
Synchronizing state of lldpd.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable lldpd
```
### 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.
Технология: VLAN  
Пакет в Linux: vlan  
[Инструкции](https://wiki.ubuntu.com/vlan)

```
$ sudo apt install vlan
$ sudo modprobe 8021q  # Загрузить модуль 8021q в kernel
$ sudo ip link add link eth1 name eth1.10 type vlan id 10  # Создаем новый интерфейс, входящий в VLAN с id 10
```
Другой вариант: `sudo vconfig add eth1 10` - устарел, лучше не использовать
```
$ sudo ip addr add 10.0.0.1/24 dev eth1.10  # Дать новому интерфейсу адрес
$ sudo ip link set up eth1.10  # Включить новый интерфейс
```
Для перманентного добавления интерфейса создается конфиг, используемый при загрузки системы. 
Файл с конфигами VLAN находится по адресу `/etc/network/interfaces`
```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
```
Пример конфига для интерфейса выше:
```
auto eth1.10
iface eth1.10 inet static
    address 10.0.0.1
    netmask 255.255.255.0
    vlan-raw-device eth1
```

### 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.
[Источник](https://en.wikipedia.org/wiki/Link_aggregation)
Смысл агрегации интерфейсов в том, чтобы получить дополнительные возможности - например, 
увеличить пропускную способность так, чтобы она была выше возможностей индивидуальных физических интерфейсов.  
В Linux используются два типа агрегации интерфейсов - bonding и team.  
Метод [Bonding](https://www.kernel.org/doc/Documentation/networking/bonding.txt) работает за счет связывания двух и более физически интерфейсов в единый логический 
интерфейс. Работает на уровне ядра.
Team представляет собой альтернативное решение. Главное отличие от бондинга в том, что драйвер Team 
содержит в ядре только базовый код, а все надстройки запускаются в пользовательской части системы 
в демоне teamd.  
Опции бондинга:
* Round-robin (balance-rr) - опция по умолчанию. Передача пакетов происходит последовательно 
от первого доступного контроллера к последнему. Позволяет балансировать нагрузку.
* Active-backup (active-backup) - активен только один контроллер. Если он выходит из строя, 
активируется другой.
* XOR (balance-xor) - передача пакетов зависит от источника и точки назначения.
* Broadcast (broadcast) - передача пакетов идет через все сетевые интерфейсы.
* IEEE 802.3ad Dynamic link aggregation (802.3ad, LACP) - создаются агрегированные группы с одинаковой 
скоростью и настройками.
* Adaptive transmit load balancing (balance-tlb) - Исходящий трафик распределяется в соответствии с 
с нагрузкой на текущий момент на каждый сетевой интерфейс. Входящий трафик принимается одним 
интерфейсом, назначенным на эту роль. Если он выходит из строя, назначается другой.
* Adaptive load balancing (balance-alb) - При получении пакетов нагрузка балансируется в соответствии с 
протоколом ARP (Address Resolution Protocol).

У team похожие режимы:
* broadcast: передает данные через все порты
* roundrobin: передает данные через все порты по очереди
* activebackup: передает данные через один активный порт, остальные в запасе
* loadbalance: передает данные через все порты с допустимой нагрузкой (Berkeley Packet Filter, BPF)
* random: передает данные через порт, выбранный случайным образом
* lacp: использует протокол 802.3ad, LACP.

Пример конфига c дефолтной опцией:
```
auto bond0
iface bond0 inet static
	address 192.168.1.150
	netmask 255.255.255.0	
	gateway 192.168.1.1
	dns-nameservers 192.168.1.1 8.8.8.8
	dns-search domain.local
		slaves eth0 eth1
		bond_mode 0
		bond-miimon 100
		bond_downdelay 200
		bond_updelay 200
``` 

### 5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
```
$ sudo apt install ipcalc
```
Под маской /29 6 IP адресов
```
$ ipcalc 192.168.1.1/29
Address:   192.168.1.1          11000000.10101000.00000001.00000 001
Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
=>
Network:   192.168.1.0/29       11000000.10101000.00000001.00000 000
HostMin:   192.168.1.1          11000000.10101000.00000001.00000 001
HostMax:   192.168.1.6          11000000.10101000.00000001.00000 110
Broadcast: 192.168.1.7          11000000.10101000.00000001.00000 111
Hosts/Net: 6                     Class C, Private Internet
```
Из сети с маской /24 можно получить 30 /29 подсетей
```
$ ipcalc -s 29 192.168.1.1/24
Address:   192.168.1.1          11000000.10101000.00000001. 00000001
Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
Wildcard:  0.0.0.255            00000000.00000000.00000000. 11111111
=>
Network:   192.168.1.0/24       11000000.10101000.00000001. 00000000
HostMin:   192.168.1.1          11000000.10101000.00000001. 00000001
HostMax:   192.168.1.254        11000000.10101000.00000001. 11111110
Broadcast: 192.168.1.255        11000000.10101000.00000001. 11111111
Hosts/Net: 254                   Class C, Private Internet

1. Requested size: 29 hosts
Netmask:   255.255.255.224 = 27 11111111.11111111.11111111.111 00000
Network:   192.168.1.0/27       11000000.10101000.00000001.000 00000
HostMin:   192.168.1.1          11000000.10101000.00000001.000 00001
HostMax:   192.168.1.30         11000000.10101000.00000001.000 11110
Broadcast: 192.168.1.31         11000000.10101000.00000001.000 11111
Hosts/Net: 30                    Class C, Private Internet

Needed size:  32 addresses.
Used network: 192.168.1.0/27
Unused:
192.168.1.32/27
192.168.1.64/26
192.168.1.128/25
```
Несколько примеров /29 подсетей внутри сети 10.10.10.0/24
```
10.10.10.0/29
10.10.10.8/29
10.10.10.16/29
```
### 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.
```
100.64.0.0/26
```
### 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
Проверить таблицу:  
В Windows, говорят, `arp -a`.  
В Linux:
```
$ arp
Address                  HWtype  HWaddress           Flags Mask            Iface
_gateway                 ether   fe:00:00:00:01:01   C                     eth0
```
Очистить ARP кэш полностью:
```
sudo ip -s -s neigh flush all
```
Удалить из ARP таблицы только один нужный IP:
```
arp -d <host>
```