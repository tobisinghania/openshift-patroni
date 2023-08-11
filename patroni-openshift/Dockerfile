FROM tsdc/postgres:15.3
MAINTAINER Tobias Singhania

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-cache depends patroni | sed -n -e 's/.* Depends: \(python3-.\+\)$/\1/p' \
            | grep -Ev '^python3-(sphinx|etcd|consul|kazoo|kubernetes)' \
            | xargs apt-get install -y vim systemd curl wget ssh  rsync gnupg2 lsb-release jq locales git python3-pip python3-wheel \
    && apt-get update \
    && apt-get install -y pgbackrest \
    ## Make sure we have a en_US.UTF-8 locale available
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && pip3 install setuptools \
    && pip3 install 'git+https://github.com/zalando/patroni.git#egg=patroni[kubernetes]' \
    # Clean up
    && apt-get remove -y python3-pip python3-wheel \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /root/.cache
    #&& rm percona-release_latest.$(lsb_release -sc)_all.deb

ADD entrypoint.sh /run/
ADD init.sh /run/
ADD start_sshd.sh /run/
ADD install_pg_monitor.sh /
ADD start_monitoring.sh /run/

# Install pgbackrest
#COPY pgbackrest /usr/bin/pgbackrest
RUN mkdir -p -m 777 /var/log/pgbackrest \
     && chown postgres:postgres /var/log/pgbackrest \
     && mkdir -p /etc/pgbackrest \
     && mkdir -p /etc/pgbackrest/conf.d \
     && touch /etc/pgbackrest/pgbackrest.conf \
     && chmod 640 /etc/pgbackrest/pgbackrest.conf \
     && chown postgres:postgres /etc/pgbackrest/pgbackrest.conf


EXPOSE 5432 8008 2222
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 EDITOR=/usr/bin/editor
ENV HOME=/home/postgres
ENV SSHD_CONF_DIR=/home/postgres/ssh_config_template
ENV START_SSHD=false
ENV ENABLE_NODE_EXPORTER=false
ENV ENABLE_BLACKBOX_EXPORTER=false
ENV ENABLE_PER_DB_EXPORTER=false
ENV ENABLE_ALL_DB_EXPORTER=false

RUN /install_pg_monitor.sh && rm /install_pg_monitor.sh
 
COPY ssh /ssh_conf_template
ADD ssh/ssh_config /etc/ssh/ssh_config
RUN chmod 777 /ssh_conf_template
USER postgres
WORKDIR /home/postgres

 
ENTRYPOINT ["/run/init.sh"]

CMD ["/run/entrypoint.sh"]
