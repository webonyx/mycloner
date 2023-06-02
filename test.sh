#!/usr/bin/env bash

docker pull webonyx/mycloner:latest
docker run --rm --name db-cloner \
  -e DB_HOST=host.docker.internal \
  -e DB_USER=root \
  -e DB_NAME=test \
  -e CLONE_DB_NAME=test-clone \
  webonyx/mycloner:latest

