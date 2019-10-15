FROM ubuntu:eoan

ENV FILEBEAT_VERSION 7.4.0

# aliyun mirror
COPY ./sources-aliyun.list /etc/apt/sources.list

COPY ./filebeat-${FILEBEAT_VERSION}-amd64.deb /filebeat-${FILEBEAT_VERSION}-amd64.deb

RUN set -x && \
  apt-get update && \
  dpkg -i /filebeat-${FILEBEAT_VERSION}-amd64.deb && rm /filebeat-${FILEBEAT_VERSION}-amd64.deb && \
  apt-get autoremove -y && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### configure Filebeat
# CA cert
RUN mkdir -p /etc/pki/tls/certs
ADD logstash-beats.crt /etc/pki/tls/certs/logstash-beats.crt

# create template based on filebeat version (assumption: it is the same version as elasticsearch version)
RUN filebeat export template --es.version ${FILEBEAT_VERSION} > /etc/filebeat/filebeat.template.json

ADD ./start.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT  ["/docker-entrypoint.sh"]
