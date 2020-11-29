#!/bin/bash

cd /tmp

chmod 777 /var/lib

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.0.1.linux-amd64.tar.gz
cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/bin
rm -rf node_exporter*


wget https://github.com/wrouesnel/postgres_exporter/releases/download/v0.8.0/postgres_exporter_v0.8.0_linux-amd64.tar.gz
tar -xzf postgres_exporter_v0.8.0_linux-amd64.tar.gz
cp postgres_exporter_v0.8.0_linux-amd64/postgres_exporter /usr/bin
rm -rf postgres_exporter*

wget https://raw.githubusercontent.com/keithf4/pg_bloat_check/master/pg_bloat_check.py
chmod +x pg_bloat_check.py
ln -s /usr/bin/python3 /usr/bin/python
mv pg_bloat_check.py /usr/bin

wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.18.0/blackbox_exporter-0.18.0.linux-amd64.tar.gz
tar -xzf blackbox_exporter-0.18.0.linux-amd64.tar.gz
cp blackbox_exporter-0.18.0.linux-amd64/blackbox_exporter /usr/bin
rm -rf blackbox_exporter-0.18.0.linux-amd64*

mkdir /var/lib/ccp_monitoring_templ

#install -m 0770 -o postgres -g postgres -d /var/lib/ccp_monitoring_templ/node_exporter

git clone https://github.com/CrunchyData/pgmonitor.git
cd /tmp/pgmonitor/exporter
mkdir /etc/systemd/system/node_exporter.service.d
cp node/crunchy-node-exporter-service-el7.conf /etc/systemd/system/node_exporter.service.d/crunchy-node-exporter-service-el7.conf

mkdir /etc/sysconfig
cp node/sysconfig.node_exporter /etc/sysconfig/node_exporter

mkdir -p /etc/postgres_exporter/12
cp crontab.txt /etc/postgres_exporter/12/crontab.txt

mkdir /usr/lib/systemd/system
cp postgres/crunchy-postgres-exporter\@.service /usr/lib/systemd/system/crunchy_postgres_exporter\@.service

cp postgres/sysconfig.postgres_exporter_pg12 /etc/sysconfig/
cp postgres/sysconfig.postgres_exporter_pg12_per_db /etc/sysconfig/
cp postgres/setup_pg12.sql /etc/postgres_exporter/12/ 
cp postgres/queries_*.yml /etc/postgres_exporter/12/
cp postgres/pgbackrest-info.sh /usr/bin/pgbackrest-info.sh

cp blackbox/blackbox_exporter.sysconfig /etc/sysconfig/blackbox_exporter
mkdir /etc/blackbox_exporter
cp blackbox/crunchy-blackbox.yml /etc/blackbox_exporter/

cd /tmp && rm -rf pgmonitor
