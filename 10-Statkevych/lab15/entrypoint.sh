#!/bin/sh
set -ex

CONTAINER_NAME="$1"
CWD=$(pwd)

mkdir -p cert

docker run \
    -v"${CWD}/cert":/cert \
    "${CONTAINER_NAME}" \
    'gencert.sh'

docker run \
    -v"${CWD}/cert":/cert \
    -v"${CWD}/usr/local/http":/usr/local/http \
    -v"${CWD}/usr/home/http":/usr/home/http \
    -v"${CWD}/config":/config \
    -p8080:8080 \
    -p8088:8088 \
    "${CONTAINER_NAME}" \
    nginx -c /config/nginx.conf
