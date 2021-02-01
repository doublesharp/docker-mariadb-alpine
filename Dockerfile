FROM alpine:latest

# ARG MARIADB_VERSION=10.1.41
# ARG APK_REPO=v3.8

# ARG MARIADB_VERSION=10.2.32
# ARG APK_REPO=3.9

# ARG MARIADB_VERSION=10.3.25
# ARG APK_REPO=3.10

# ARG MARIADB_VERSION=10.4.15
# ARG APK_REPO=3.12

ARG MARIADB_VERSION=10.5.8
ARG APK_REPO=3.13

ENV LC_ALL=en_GB.UTF-8 \
  MARIADB_VERSION=${MARIADB_VERSION}

VOLUME /var/lib/mysql

EXPOSE 3306

RUN set -x && \
  # get-apk-version.sh && \
  # install mariadb and dependencies
  echo "http://dl-cdn.alpinelinux.org/alpine/v${APK_REPO}/main" >> /etc/apk/repositories && \
  apk update && \
  apk -U upgrade && \
  apk add --no-cache --virtual .mariadb-deps \
  mariadb==${MARIADB_VERSION}-r0 \
  mariadb-client==${MARIADB_VERSION}-r0 \
  tzdata \
  bash \
  su-exec \
  && \
  rm -rf /var/cache/apk/* && \
  # comment out a few problematic configuration values
  sed -Ei 's/^(bind-address|log)/#&/' /etc/my.cnf && \
  sed -i  's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf && \
  # don't reverse lookup hostnames, they are usually another container
  sed -i '/^\[mysqld]$/a skip-host-cache\nskip-name-resolve' /etc/my.cnf && \
  # always run as user mysql
  sed -i '/^\[mysqld]$/a user=mysql' /etc/my.cnf && \
  # allow custom configurations
  echo -e '\n!includedir /etc/mysql/conf.d/' >> /etc/my.cnf && \
  mkdir -p /run/mysqld && \
  mkdir -p /etc/mysql/conf.d/ && \
  # load initialization scripts
  mkdir -p /docker-entrypoint-initdb.d && \
  chown mysql.mysql /run/mysqld

COPY rootfs/usr/local/bin/* /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

# Default arguments passed to ENTRYPOINT if no arguments are passed when starting container
CMD ["mysqld"]