##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

FROM zerodowntime/centos:7.6.1810

ARG CASSANDRA_VERSION
ARG CASSANDRA_PACKAGE_VERSION="$CASSANDRA_VERSION-1"

RUN yum -y install \
      java-1.8.0 \
      https://archive.apache.org/dist/cassandra/redhat/22x/cassandra-$CASSANDRA_PACKAGE_VERSION.noarch.rpm \
      https://archive.apache.org/dist/cassandra/redhat/22x/cassandra-tools-$CASSANDRA_PACKAGE_VERSION.noarch.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum /var/tmp/* /tmp/*

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

COPY liveness-probe.sh    /opt/
COPY readiness-probe.sh   /opt/

ENTRYPOINT ["/docker-entrypoint.sh"]
