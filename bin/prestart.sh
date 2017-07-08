#!/bin/bash

# Do we have env vars for Triton discovery?
# Copy creds from env vars to files on disk
if [ -n ${!TRITON_CREDS_PATH} ] \
    && [ -n ${!TRITON_CA} ] \
    && [ -n ${!TRITON_CERT} ] \
    && [ -n ${!TRITON_KEY} ]
then
    mkdir -p ${TRITON_CREDS_PATH}
    echo -e "${TRITON_CA}" | tr '#' '\n' > ${TRITON_CREDS_PATH}/ca.pem
    echo -e "${TRITON_CERT}" | tr '#' '\n' > ${TRITON_CREDS_PATH}/cert.pem
    echo -e "${TRITON_KEY}" | tr '#' '\n' > ${TRITON_CREDS_PATH}/key.pem
fi

# Are we on Triton? Do we _not_ have a user-defined DC?
# Set the DC automatically from mdata
if [ -n ${TRITON_DC} ] \
    && [ -f "/native/usr/sbin/mdata-get" ]
then
    export TRITON_DC=$(/native/usr/sbin/mdata-get sdc:datacenter_name)
fi

# Create Prometheus config
consul-template -once -consul-addr ${CONSUL}:8500 -template /etc/prometheus/prometheus.yml.ctmpl:/etc/prometheus/prometheus.yml
