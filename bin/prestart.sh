#!/bin/sh

# setup TLS based on env vars provided via docker run
if [ -n $TLSCA -a -n $TLSCERT -a -n $TLSKEY ]
then
    mkdir -p ${TRITON_CREDS_PATH}
    echo -e "${TRITON_CA}" | tr '#' '\n' > ${TRITON_CREDS_PATH}/ca.pem
    echo -e "${TRITON_CERT}" | tr '#' '\n' > ${TRITON_CREDS_PATH}/cert.pem
    echo -e "${TRITON_KEY}" | tr '#' '\n' > ${TRITON_CREDS_PATH}/key.pem
fi

# create Prometheus config
consul-template -once -consul-addr ${CONSUL}:8500 -template /etc/prometheus/prometheus.yml.ctmpl:/etc/prometheus/prometheus.yml
