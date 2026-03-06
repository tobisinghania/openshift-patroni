#!/bin/bash

# Update the nss_wrapper passwd file with the actual runtime UID.
# LD_PRELOAD and NSS_WRAPPER_* are already set via Dockerfile ENV,
# so all processes (including oc exec) use nss_wrapper automatically.
uid=$(id -u)
gid=$(id -g)
sed "/^${uid}:/d; /^postgres:/d" /etc/passwd > "$NSS_WRAPPER_PASSWD"
printf 'postgres:x:%s:%s:PostgreSQL:/home/postgres:/bin/bash\n' "$uid" "$gid" >> "$NSS_WRAPPER_PASSWD"

/run/start_sshd.sh

if [ -n "$@" ]; then
  bash -c "$@"
else
  /run/entrypoint.sh
fi  
