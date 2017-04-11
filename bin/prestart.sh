#!/bin/sh

# setup TLS based on env vars provided via docker run
if [ -n $TLSCA -a -n $TLSCERT -a -n $TLSKEY ]
then
    mkdir -p ${DOCKER_CERT_PATH}
    echo -e "${TLSCA}" > ${DOCKER_CERT_PATH}/ca.pem
    echo -e "${TLSCERT}" > ${DOCKER_CERT_PATH}/cert.pem
    echo -e "${TLSKEY}" > ${DOCKER_CERT_PATH}/key.pem
fi

# create Prometheus config
consul-template -once -consul ${CONSUL}:8500 -template /etc/prometheus/prometheus.yml.ctmpl:/etc/prometheus/prometheus.yml
