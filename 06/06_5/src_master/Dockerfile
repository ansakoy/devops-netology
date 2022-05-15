# syntax=docker/dockerfile:1
FROM elasticsearch:7.17.3
COPY elasticsearch.yml /usr/share/elasticsearch/config/
RUN mkdir -p /var/lib/data && chmod 777 /var/lib/data && mkdir -p /var/lib/snapshots && chmod 777 /var/lib/snapshots
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]