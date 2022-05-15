# syntax=docker/dockerfile:1
FROM centos:7

RUN groupadd elastic \
    && useradd -g elastic elastic \
    && mkdir -p /var/lib/data \
    && chown elastic:elastic /var/lib/data \
    && mkdir -p /var/lib/snapshots \
    && chown elastic:elastic /var/lib/snapshots \
    && yum -y install wget && yum clean all


# Вообще это всё должно устанавливаться через wget:
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.3-linux-x86_64.tar.gz
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.3-linux-x86_64.tar.gz.sha512
# Но т.к. буржуи перекрыли доступ из России (возвращает 403), пришлось скачать через VPN и положить
# на сервер руками

COPY elasticsearch-7.17.3-linux-x86_64.tar.gz /home/elastic/elasticsearch-7.17.3-linux-x86_64.tar.gz
COPY elasticsearch-7.17.3-linux-x86_64.tar.gz.sha512 /home/elastic/elasticsearch-7.17.3-linux-x86_64.tar.gz.sha512

USER elastic

RUN cd /home/elastic && tar -xzf elasticsearch-7.17.3-linux-x86_64.tar.gz

COPY elasticsearch.yml /home/elastic/elasticsearch-7.17.3/config/

EXPOSE 9200
EXPOSE 9300

ENV ES_USER=elastic
ENV ES_GROUP=elastic
ENV ES_HOME=/elasticsearch-7.17.3

CMD ["/home/elastic/elasticsearch-7.17.3/bin/elasticsearch"]