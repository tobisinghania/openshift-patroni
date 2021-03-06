#!/bin/bash

#/fix_permissions_and_start_sshd.sh

#if [[ $UID -ge 10000 ]]; then
#    GID=$(id -g)
#    sed -e "s/^postgres:x:[^:]*:[^:]*:/postgres:x:$UID:$GID:/" /etc/passwd > /tmp/passwd
#    cat /tmp/passwd > /etc/passwd
#    rm /tmp/passwd
#fi

cd /home/postgres

cat > /home/postgres/patroni.yml <<__EOF__
bootstrap:
  dcs:
    postgresql:
      use_pg_rewind: true
  initdb:
  - auth-host: md5
  - auth-local: trust
  - encoding: UTF8
  - locale: en_US.UTF-8
  - data-checksums
  pg_hba:
  - host all all 0.0.0.0/0 md5
  - host replication ${PATRONI_REPLICATION_USERNAME} ${PATRONI_KUBERNETES_POD_IP}/8 md5
restapi:
  connect_address: '${PATRONI_KUBERNETES_POD_IP}:8008'
postgresql:
  connect_address: '${PATRONI_KUBERNETES_POD_IP}:5432'
  authentication:
    superuser:
      password: '${PATRONI_SUPERUSER_PASSWORD}'
    replication:
      password: '${PATRONI_REPLICATION_PASSWORD}'
__EOF__

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD

# Link postgres data directory into the home dir
ln -s /home/postgres_data/pgdata /home/postgres/pgdata

exec /usr/bin/python3 /usr/local/bin/patroni /home/postgres/patroni.yml
