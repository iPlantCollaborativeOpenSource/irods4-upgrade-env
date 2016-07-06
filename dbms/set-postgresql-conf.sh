#! /bin/bash

# Customize postgresql.conf

sbMem=128MB
mwMem=16MB
ecSize=128MB


if [ -d /sys/fs/cgroup/memory ]
then
  cid=$(grep docker /proc/self/cgroup | cut -f3 -d: | uniq)
  totalMem=$(cat /sys/fs/cgroup/memory"$cid"/memory.limit_in_bytes)
  sbMem="$((totalMem / 4000))"kB
  mwMem="$((totalMem / 100000))"kB
  ecSize="$((totalMem / 2000))"kB
fi

sed --in-place "{
                  /listen_addresses/d
                  /max_connections/d
                  /shared_buffers/d
                  /work_mem/d
                  /maintenance_work_mem/d
                  /effective_cache_size/d
                  /log_min_duration_statement/d
                  /log_line_prefix/d
                  /standard_conforming_strings/d
                }" \
    "$PGDATA"/postgresql.conf

cat <<EOS >> "$PGDATA"/postgresql.conf
listen_addresses            = '*'
max_connections             = 1500
shared_buffers              = $sbMem
work_mem                    = 32MB
maintenance_work_mem        = $mwMem
effective_cache_size        = $ecSize
log_min_duration_statement  = 1000
log_line_prefix             = '< %m %r >'
standard_conforming_strings = off
EOS
