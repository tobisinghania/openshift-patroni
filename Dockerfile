FROM postgres:11
MAINTAINER Alexander Kukushkin <alexander.kukushkin@zalando.de>

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-cache depends patroni | sed -n -e 's/.* Depends: \(python3-.\+\)$/\1/p' \
            | grep -Ev '^python3-(sphinx|etcd|consul|kazoo|kubernetes)' \
            | xargs apt-get install -y vim-tiny curl wget ssh  rsync gnupg2 lsb-release jq locales git python3-pip python3-wheel \
    && wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb \
    && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb \
    && apt-get update \
    && apt-get install -y pmm2-client \
    ## Make sure we have a en_US.UTF-8 locale available
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && pip3 install setuptools \
    && pip3 install 'git+https://github.com/zalando/patroni.git#egg=patroni[kubernetes]' \
    && PGHOME=/home/postgres \
    && mkdir -p $PGHOME \
    && chown postgres $PGHOME \
    && sed -i "s|/var/lib/postgresql.*|$PGHOME:/bin/bash|" /etc/passwd \
    # Set permissions for OpenShift
    && chmod 775 $PGHOME \
    && chmod 664 /etc/passwd \
    # Clean up
    && apt-get remove -y git python3-pip python3-wheel \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /root/.cache \
    && rm percona-release_latest.$(lsb_release -sc)_all.deb

ADD entrypoint.sh /

COPY percona-postgresql-12.4-r25ff747-buster-x86_64-bundle.tar /tmp/percona

# Install pgbackrest
COPY pgbackrest /usr/bin/pgbackrest
RUN mkdir -p -m 770 /var/log/pgbackrest \
     && chown postgres:postgres /var/log/pgbackrest \
     && mkdir -p /etc/pgbackrest \
     && mkdir -p /etc/pgbackrest/conf.d \
     && touch /etc/pgbackrest/pgbackrest.conf \
     && chmod 640 /etc/pgbackrest/pgbackrest.conf \
     && chown postgres:postgres /etc/pgbackrest/pgbackrest.conf
COPY ssh /home/postgres/ssh
RUN chown -R postgres /home/postgres/ssh


EXPOSE 5432 8008 2222
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 EDITOR=/usr/bin/editor
USER postgres
WORKDIR /home/postgres
 
ENTRYPOINT /usr/sbin/sshd -f /home/postgres/ssh/sshd_config && bash
 
CMD ["/bin/bash", "/entrypoint.sh"]
