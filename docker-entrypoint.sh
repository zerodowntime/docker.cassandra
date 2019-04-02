#!/bin/bash -e

# MAX_HEAP_SIZE # max(min(1/2 ram, 1024MB), min(1/4 ram, 8GB))

if [ -z ${MAX_HEAP_SIZE+x} ]; then
  system_memory_in_mb=$(free -m | awk '/:/ {print $2;exit}')
  memory_limit_in_bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
  memory_limit_in_mb=$(( $memory_limit_in_bytes / 1024 / 1024 ))
  if [ "$memory_limit_in_mb" -gt "$system_memory_in_mb" ]; then
    memory_limit_in_mb="$system_memory_in_mb"
  fi
  half_system_memory_in_mb=$(( $memory_limit_in_mb / 2 ))
  if [ "$half_system_memory_in_mb" -gt "1024" ]; then
      half_system_memory_in_mb="1024"
  fi
  quarter_system_memory_in_mb=$(( $memory_limit_in_mb / 4 ))
  if [ "$quarter_system_memory_in_mb" -gt "8192" ]; then
      quarter_system_memory_in_mb="8192"
  fi
  if [ "$half_system_memory_in_mb" -gt "$quarter_system_memory_in_mb" ]; then
      max_heap_size_in_mb="$half_system_memory_in_mb"
  else
      max_heap_size_in_mb="$quarter_system_memory_in_mb"
  fi
  export MAX_HEAP_SIZE="${max_heap_size_in_mb}M"
fi

# HEAP_NEWSIZE # Young gen: min(max_sensible_per_modern_cpu_core * num_cores, 1/4 * heap size)
if [ -z ${HEAP_NEWSIZE+x} ]; then
  export HEAP_NEWSIZE="400M"
fi

if [ -z ${CASSANDRA_LISTEN_ADDRESS+x} ]; then
  CASSANDRA_LISTEN_ADDRESS=$(hostname -I | cut -d' ' -f1)
  export CASSANDRA_LISTEN_ADDRESS
fi

if [ -n "$CASSANDRA_DC_DISCOVERY_URL" ]; then
  CASSANDRA_DC=$(curl --connect-timeout 5 "$CASSANDRA_DC_DISCOVERY_URL")
  export CASSANDRA_DC
fi

# CASSANDRA_RACK_DISCOVERY_URL=http://169.254.169.254/latest/meta-data/placement/availability-zone
if [ -n "$CASSANDRA_RACK_DISCOVERY_URL" ]; then
  CASSANDRA_RACK=$(curl --connect-timeout 5 "$CASSANDRA_RACK_DISCOVERY_URL")
  export CASSANDRA_RACK
fi

confd -onetime -log-level debug || exit 2

ulimit -l 65000  # memlock
ulimit -n 100000  # nofile
ulimit -u 32768  # nproc
# ulimit -A 65000  # as

# fix for kubernetes
install -d -o cassandra -g cassandra -m 755 /var/lib/cassandra/{commitlog,data,hints,saved_caches}

exec su-exec cassandra /usr/sbin/cassandra -f
