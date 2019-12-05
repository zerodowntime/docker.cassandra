##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

FROM zerodowntime/openjdk:1.8.0-centos7.7.1908

ARG CASSANDRA_VERSION="3.11.4"
ARG CASSANDRA_PACKAGE_VERSION="$CASSANDRA_VERSION-1"

RUN yum -y install \
      https://archive.apache.org/dist/cassandra/redhat/311x/cassandra-$CASSANDRA_PACKAGE_VERSION.noarch.rpm \
      https://archive.apache.org/dist/cassandra/redhat/311x/cassandra-tools-$CASSANDRA_PACKAGE_VERSION.noarch.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum /var/tmp/* /tmp/*

RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq

VOLUME /var/lib/cassandra
VOLUME /var/log/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

COPY confd/ /etc/confd
COPY docker-entrypoint.sh /

COPY post-start.sh        /opt/
COPY pre-stop.sh          /opt/
COPY liveness-probe.sh    /opt/
COPY readiness-probe.sh   /opt/

ENTRYPOINT ["/docker-entrypoint.sh"]
