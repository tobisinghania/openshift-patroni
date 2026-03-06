# syntax=docker/dockerfile:1
FROM tsdc/postgres:15.3-v2 as builder
MAINTAINER Tobias Singhania

RUN apt-get update -y
RUN apt-get install -y python3-pip postgresql-server-dev-15
RUN pip3 install pgxnclient
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential              \
        ca-certificates curl         \
        libzstd-dev                  \
        liblz4-dev                   \
        libreadline-dev              \
        zlib1g-dev                   \
        clang-11 llvm-11-dev         \
        postgresql-server-dev-15    \
    && rm -rf /var/lib/apt/lists/*      

RUN pgxn install temporal_tables
RUN pgxn install pg_repack
RUN pgxn install vector

FROM tsdc/postgres:15.3-v2

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-cache depends patroni | sed -n -e 's/.* Depends: \(python3-.\+\)$/\1/p' \
            | grep -Ev '^python3-(sphinx|etcd|consul|kazoo|kubernetes)' \
            | xargs apt-get install -y vim systemd curl wget ssh  rsync gnupg2 lsb-release jq locales git python3-pip python3-wheel \
    && apt-get update \
    && apt-get install -y pgbackrest \
    ## Make sure we have a en_US.UTF-8 locale available \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && pip3 install setuptools \
    && pip3 install patroni[kubernetes]==3.3.6 \
    && echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/timescaledb.list \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add - \
    && apt update && apt-get install -y timescaledb-2-postgresql-15 timescaledb-tools \


    # Clean up
    && apt-get remove -y python3-pip python3-wheel \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /root/.cache
    #&& rm percona-release_latest.$(lsb_release -sc)_all.deb


ARG PG_MAJOR=15
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/       /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/bin/       /usr/lib/postgresql/${PG_MAJOR}/bin/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/ /usr/share/postgresql/${PG_MAJOR}/extension/

ADD entrypoint.sh /run/
ADD init.sh /run/
ADD start_sshd.sh /run/
ADD install_pg_monitor.sh /
ADD start_monitoring.sh /run/

# Install pgbackrest
#COPY pgbackrest /usr/bin/pgbackrest
RUN mkdir -p -m 775 /var/log/pgbackrest \
     && chown postgres:0 /var/log/pgbackrest \
     && mkdir -p /etc/pgbackrest \
     && mkdir -p /etc/pgbackrest/conf.d \
     && touch /etc/pgbackrest/pgbackrest.conf \
     && chmod 660 /etc/pgbackrest/pgbackrest.conf \
     && chown postgres:0 /etc/pgbackrest/pgbackrest.conf


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

# Set up nss_wrapper globally so all processes (including oc exec) see the
# correct postgres user. Init.sh updates /tmp/passwd with the runtime UID.
RUN cp /etc/passwd /tmp/passwd \
    && cp /etc/group /tmp/group \
    && chmod g=u /tmp/passwd /tmp/group \
    && ln -sf "$(find /usr/lib -name 'libnss_wrapper.so' -print -quit)" /usr/lib/libnss_wrapper.so
ENV LD_PRELOAD=/usr/lib/libnss_wrapper.so \
    NSS_WRAPPER_PASSWD=/tmp/passwd \
    NSS_WRAPPER_GROUP=/tmp/group

USER postgres
WORKDIR /home/postgres

ENTRYPOINT ["/run/init.sh"]

CMD ["/run/entrypoint.sh"]
