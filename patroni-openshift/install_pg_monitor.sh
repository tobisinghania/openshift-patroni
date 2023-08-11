#!/bin/bash

set -e

cd /tmp

chmod 777 /var/lib

version=1.5.0
wget https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.linux-amd64.tar.gz
tar -xzf node_exporter-${version}.linux-amd64.tar.gz
cp node_exporter-${version}.linux-amd64/node_exporter /usr/bin
rm -rf node_exporter*

version=0.11.1
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v${version}/postgres_exporter-${version}.linux-amd64.tar.gz
tar -xzf postgres_exporter-${version}.linux-amd64.tar.gz
cp postgres_exporter-${version}.linux-amd64/postgres_exporter /usr/bin
rm -rf postgres_exporter*

wget https://raw.githubusercontent.com/keithf4/pg_bloat_check/master/pg_bloat_check.py
chmod +x pg_bloat_check.py
ln -s /usr/bin/python3 /usr/bin/python
mv pg_bloat_check.py /usr/bin

version=0.23.0
wget https://github.com/prometheus/blackbox_exporter/releases/download/v${version}/blackbox_exporter-${version}.linux-amd64.tar.gz
tar -xzf blackbox_exporter-${version}.linux-amd64.tar.gz
cp blackbox_exporter-${version}.linux-amd64/blackbox_exporter /usr/bin
rm -rf blackbox_exporter-${version}.linux-amd64*

mkdir /var/lib/ccp_monitoring_templ

#install -m 0770 -o postgres -g postgres -d /var/lib/ccp_monitoring_templ/node_exporter

git clone https://github.com/CrunchyData/pgmonitor.git
cd /tmp/pgmonitor
mkdir /etc/systemd/system/node_exporter.service.d
cp node_exporter/linux/crunchy-node-exporter-service-rhel.conf /etc/systemd/system/node_exporter.service.d/crunchy-node-exporter-service-rhel.conf

mkdir -p /etc/sysconfig/node_exporter
cp node_exporter/linux/sysconfig.node_exporter /etc/sysconfig/node_exporter

mkdir -p /etc/postgres_exporter/15
cp postgres_exporter/linux/crontab.txt /etc/postgres_exporter/15/crontab.txt

mkdir -p /usr/lib/systemd/system
cp postgres_exporter/linux/crunchy-postgres-exporter\@.service /usr/lib/systemd/system/crunchy_postgres_exporter\@.service

cp postgres_exporter/linux/pg15/sysconfig.postgres_exporter_pg15 /etc/sysconfig/
cp postgres_exporter/linux/pg15/sysconfig.postgres_exporter_pg15_per_db /etc/sysconfig/
cp postgres_exporter/linux/pgbackrest-info.sh /usr/bin/pgbackrest-info.sh
cp postgres_exporter/linux/queries_*.yml /etc/postgres_exporter/15/
cp postgres_exporter/common/pg15/setup.sql /etc/postgres_exporter/15/
cp postgres_exporter/common/pg15/queries_*.yml /etc/postgres_exporter/15/
cp postgres_exporter/common/queries_*.yml /etc/postgres_exporter/15/

cp blackbox_exporter/common/blackbox_exporter.sysconfig /etc/sysconfig/blackbox_exporter
mkdir /etc/blackbox_exporter
cp blackbox_exporter/common/crunchy-blackbox.yml /etc/blackbox_exporter/

cd /tmp && rm -rf pgmonitor
