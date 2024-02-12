#!/bin/bash

docker image build -t doublesharp/mariadb-alpine:10.2 --build-arg MARIADB_VERSION===10.2.32-r0 --build-arg APK_REPO=v3.8 --build-arg ALPINE_TAG=3.8 .