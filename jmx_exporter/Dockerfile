ARG CASSANDRA_VERSION="3.11.4"

FROM zerodowntime/cassandra:${CASSANDRA_VERSION}

RUN curl -L \
  https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar \
  -o /opt/jmx_prometheus_javaagent-0.12.0.jar \
  && ln -s jmx_prometheus_javaagent-0.12.0.jar /opt/jmx_prometheus_javaagent.jar

RUN echo 'JVM_OPTS="$JVM_OPTS -javaagent:/opt/jmx_prometheus_javaagent.jar=5556:/opt/jmx_exporter-cassandra.yml"' >> /etc/cassandra/conf/cassandra-env.sh

COPY jmx_exporter-cassandra.yml /opt/

EXPOSE 5556
