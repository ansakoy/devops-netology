[Установить docker engine на Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
```
# Удалить старые версии, если есть 
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install packages to allow apt to use a repository over HTTPS
sudo apt update
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Use the following command to set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install the latest version of Docker Engine and containerd
sudo apt update  # ВАЖНО, ЕЩЕ РАЗ
sudo apt install docker-ce docker-ce-cli containerd.io

# Verify that Docker Engine is installed correctly by running the hello-world image
sudo docker run hello-world

# This command downloads a test image and runs it in a container. When the container runs, it prints a message and exits

# Check version
docker -v
```
[Install docker compose ubuntu](https://docs.docker.com/compose/install/)
```
# Download the current stable release of Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose

# CHeck version
docker-compose --version
```

[Install command completion](https://docs.docker.com/compose/completion/)
```
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose
```

## Run docker compose
```
sudo docker-compose up -d
```

## Setup DB
```
# Connect to container
sudo docker exec -it psql12alpine bash

su - postgres
psql

create user "test-admin-user" with password 'test';
create database test_db lc_collate 'ru_RU.UTF-8' lc_ctype 'ru_RU.UTF-8' owner "test-admin-user" template template0;
\c test_db
```

```sql
create table orders (
	id serial primary key,
	наименование varchar(250),
	цена integer
);

create table clients (
    id serial primary key,
    фамилия varchar(250),
    "страна проживания" varchar(250),
    заказ integer,
    constraint fk_orders
        foreign key(заказ)
            references orders(id)
);

create index idx_country_of_residence on clients("страна проживания");

grant all
on all tables
in schema "public"
to "test-admin-user";

create user "test-simple-user" with password 'tests';

grant select, insert, update, delete
on all tables
in schema public
to "test-simple-user";

select * 
from information_schema.table_privileges
where grantee like 'test%';

insert into orders ("наименование", "цена")
values
  ('Шоколад', 10),
  ('Принтер', 3000),
  ('Книга', 500),
  ('Монитор', 7000),
  ('Гитара', 4000);

insert into clients ("фамилия", "страна проживания")
values
  ('Иванов Иван Иванович', 'USA'),
  ('Петров Петр Петрович', 'Canada'),
  ('Иоганн Себастьян Бах', 'Japan'),
  ('Ронни Джеймс Дио', 'Russia'),
  ('Ritchie Blackmore', 'Russia');

update clients set "заказ" = (select id from orders where "наименование" = 'Книга') where "фамилия" = 'Иванов Иван Иванович';
```
```
sudo docker ps
sudo docker stop <cont_name>
sudo docker rm <cont_name>
sudo docker volume ls
docker volume rm <volume_name>
```