#! /bin/bash

# Customize postgresql.conf

sbMem=128MB
ecSize=128MB

if [ -d /sys/fs/cgroup/memory ]
then
  cid=$(grep docker /proc/self/cgroup | cut -f3 -d\: | uniq)
  totalMem=$(cat /sys/fs/cgroup/memory${cid}/memory.limit_in_bytes)
  sbMem="$((totalMem / 4000))kB"
  ecSize="$((totalMem / 2000))kB"
fi

fieldsAlt="listen_addresses\|shared_buffers\|effective_cache_size\|log_min_duration_statement\|log_line_prefix\|standard_conforming_strings"

sed --in-place "/^[[:space:]]*\($fieldsAlt\)\>/d" "$PGDATA/postgresql.conf"

cat <<EOS >> "$PGDATA/postgresql.conf"
listen_addresses            = '*'
shared_buffers              = $sbMem
effective_cache_size        = $ecSize
log_min_duration_statement  = 1000
log_line_prefix             = '< %m:%h >'
standard_conforming_strings = off
EOS
