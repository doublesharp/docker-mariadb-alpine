ARG ALPINE_TAG=latest

FROM alpine:${ALPINE_TAG}

ARG MARIADB_VERSION=
ARG APK_REPO=edge
ARG WITH_SERVER_UTILS=

ENV LC_ALL=en_US.UTF-8 \
  MARIADB_VERSION=${MARIADB_VERSION}

VOLUME /var/lib/mysql

EXPOSE 3306

RUN set -xe; \
  # check to see if we need to install server utils
  export SERVER_UTILS=$(if [ -n "${WITH_SERVER_UTILS}" ]; then echo "mariadb-server-utils${MARIADB_VERSION}"; else echo ""; fi); \
  # install mariadb and dependencies
  echo "http://dl-cdn.alpinelinux.org/alpine/${APK_REPO}/main" > /etc/apk/repositories; \
  apk update; \
  apk -U upgrade; \
  apk add --no-cache --virtual .mariadb-deps \
  mariadb${MARIADB_VERSION} \
  mariadb-client${MARIADB_VERSION} \
  ${SERVER_UTILS} \ 
  tzdata \
  bash \
  su-exec \
  ; \
  rm -rf /var/cache/apk/*; \
  # create /etc/my.cnf if missing
  if [ ! -f /etc/my.cnf ]; then \
  cp /etc/mysql/my.cnf /etc; \
  fi; \
  # create /etc/my.cnf.d/ if missing
  if [ ! -d /etc/my.cnf.d ]; then \
  mkdir -p /etc/my.cnf.d; \
  if [ ! -d /usr/share/mariadb ]; then \
  # older versions use this path
  cp /usr/share/mysql/my-large.cnf /etc/my.cnf.d/mariadb-server.cnf; \
  else \
  # newer vesions use this path
  cp /usr/share/mariadb/my-large.cnf /etc/my.cnf.d/mariadb-server.cnf; \
  fi; \
  echo -e '\n!includedir /etc/my.cnf.d/' >> /etc/my.cnf;\
  fi; \
  # comment out a few problematic configuration values
  sed -Ei 's/^(bind-address|log)/#&/' /etc/my.cnf; \
  sed -i  's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf; \
  # don't reverse lookup hostnames, they are usually another container
  sed -i '/^\[mysqld]$/a skip-host-cache\nskip-name-resolve' /etc/my.cnf; \
  # always run as user mysql
  sed -i '/^\[mysqld]$/a user=mysql' /etc/my.cnf; \
  # allow custom configurations
  echo -e '\n!includedir /etc/mysql/conf.d/' >> /etc/my.cnf; \
  mkdir -p /run/mysqld; \
  mkdir -p /etc/mysql/conf.d/; \
  # load initialization scripts
  mkdir -p /docker-entrypoint-initdb.d; \
  chown mysql.mysql /run/mysqld;

COPY rootfs/usr/local/bin/* /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

# Default arguments passed to ENTRYPOINT if no arguments are passed when starting container
CMD ["mysqld"]