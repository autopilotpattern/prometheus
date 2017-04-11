#!/bin/sh
set -e

if [ -f "${DOCKER_CERT_PATH}/ca.pem" ]
then
    export TLSCA_PATH="${DOCKER_CERT_PATH}/ca.pem"
    export TLSKEY_PATH="${DOCKER_CERT_PATH}/key.pem"
    export TLSCERT_PATH="${DOCKER_CERT_PATH}/cert.pem"
fi

/usr/local/bin/containerpilot /bin/prometheus \
     -config.file=/etc/prometheus/prometheus.yml \
     -storage.local.path=/prometheus \
     -web.console.libraries=/etc/prometheus/console_libraries \
     -web.console.templates=/etc/prometheus/consoles
