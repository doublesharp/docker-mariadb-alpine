FROM alpine:latest

ENV LC_ALL=en_GB.UTF-8
ENV GOSU_VERSION=1.12

# add gosu
RUN apk update && \
  apk add vim && apk add wget && \
  set -x \
  && apk add --no-cache --virtual .gosu-deps \
  dpkg \
  gnupg \
  openssl \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apk del .gosu-deps

RUN mkdir /docker-entrypoint-initdb.d && \
  apk update && \
  apk -U upgrade && \
  apk add --no-cache mariadb mariadb-client && \
  apk add --no-cache tzdata && \
  apk add --no-cache bash && \
  # clean up
  rm -rf /var/cache/apk/*

# comment out a few problematic configuration values
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/my.cnf && \
  sed -i  's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf && \
  # don't reverse lookup hostnames, they are usually another container
  sed -i '/^\[mysqld]$/a skip-host-cache\nskip-name-resolve' /etc/my.cnf && \
  # always run as user mysql
  sed -i '/^\[mysqld]$/a user=mysql' /etc/my.cnf && \
  # allow custom configurations
  echo -e '\n!includedir /etc/mysql/conf.d/' >> /etc/my.cnf && \
  mkdir -p /etc/mysql/conf.d/ && \
  mkdir -p /run/mysqld && \
  chown mysql.mysql /run/mysqld

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["docker-entrypoint.sh"]

# Default arguments passed to ENTRYPOINT if no arguments are passed when starting container
CMD ["mysqld"]