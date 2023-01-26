#!/bin/bash

docker image build -t doublesharp/mariadb-alpine:10.1 --build-arg MARIADB_VERSION===10.1.41-r0 --build-arg APK_REPO=v3.7 --build-arg ALPINE_TAG=3.7 .
docker image build -t doublesharp/mariadb-alpine:10.2 --build-arg MARIADB_VERSION===10.2.32-r0 --build-arg APK_REPO=v3.8 --build-arg ALPINE_TAG=3.8 .
docker image build -t doublesharp/mariadb-alpine:10.3 --build-arg MARIADB_VERSION===10.3.29-r0 --build-arg APK_REPO=v3.10 .
docker image build -t doublesharp/mariadb-alpine:10.4 --build-arg MARIADB_VERSION===10.4.25-r0 --build-arg APK_REPO=v3.12 .
docker image build -t doublesharp/mariadb-alpine:10.5 --build-arg MARIADB_VERSION===10.5.17-r0 --build-arg APK_REPO=v3.14 .
docker image build -t doublesharp/mariadb-alpine:10.6 --build-arg MARIADB_VERSION===10.6.11-r0 --build-arg APK_REPO=v3.17 .
docker image build -t doublesharp/mariadb-alpine:10 --build-arg MARIADB_VERSION= --build-arg APK_REPO=latest-stable .
docker image build -t doublesharp/mariadb-alpine:latest --build-arg MARIADB_VERSION= --build-arg APK_REPO=latest-stable .
docker image build -t doublesharp/mariadb-alpine:edge --build-arg MARIADB_VERSION= --build-arg APK_REPO=edge .
