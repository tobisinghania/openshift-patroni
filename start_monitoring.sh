#!/bin/bash

if [ ! -d "/var/lib/ccp_monitoring" ]; then 
	cp -r /var/lib/ccp_monitoring_templ /var/lib/ccp_monitoring
	install -m 0700 -d /var/lib/ccp_monitoring/node_exporter
fi	


if [ $ENABLE_NODE_EXPORTER = true  ]; then
	echo "Starting node exporter"  
	source /etc/sysconfig/node_exporter/sysconfig.node_exporter
	/usr/bin/node_exporter $OPT & disown
fi
  
if [ $ENABLE_BLACKBOX_EXPORTER = true  ]; then
	echo "Starting blackbox exporter"
	source /etc/sysconfig/blackbox_exporter
	/usr/bin/blackbox_exporter $OPT & disown
fi

export DATA_SOURCE_NAME='user=ccp_monitoring host=/var/run/postgresql sslmode=disable'

if [ $ENABLE_PER_DB_EXPORTER = true  ]; then
	echo "Starting per-db exporter"
	source /etc/sysconfig/sysconfig.postgres_exporter_pg15_per_db
	cat $QUERY_FILE_LIST | sed -e "s/#PGBACKREST_INFO_THROTTLE_MINUTES#/${PGBACKREST_INFO_THROTTLE_MINUTES}/g" -e "s/#PG_STAT_STATEMENTS_LIMIT#/${PG_STAT_STATEMENTS_LIMIT}/g" > /tmp/query_perdb.yml

	/usr/bin/postgres_exporter --web.listen-address=0.0.0.0:9188 --extend.query-path=/tmp/query_perdb.yml --disable-default-metrics --disable-settings-metrics & disown
fi


if [ $ENABLE_ALL_DB_EXPORTER = true  ]; then
   	echo "Starting all-db exporter"
	source /etc/sysconfig/sysconfig.postgres_exporter_pg15
	cat $QUERY_FILE_LIST | sed -e "s/#PGBACKREST_INFO_THROTTLE_MINUTES#/${PGBACKREST_INFO_THROTTLE_MINUTES}/g" -e "s/#PG_STAT_STATEMENTS_LIMIT#/${PG_STAT_STATEMENTS_LIMIT}/g" > /tmp/queries.yml

	/usr/bin/postgres_exporter --web.listen-address=0.0.0.0:9187 --extend.query-path=/tmp/queries.yml --disable-default-metrics --disable-settings-metrics & disown
fi


