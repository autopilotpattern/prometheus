FROM alpine:3.4

# The official Promtheus base image has no package manager so rather than
# artisanally hand-rolling curl and the rest of our stack we'll just use
# Alpine so we can use `docker build`.

RUN apk add --update curl


# Add Prometheus. alas, the Prometheus developers provide no checksum
RUN set -ex \
    && export PROM_VER=1.5.2 \
    && export prom=prometheus-${PROM_VER}.linux-amd64 \
    && curl -Lso /tmp/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/${prom}.tar.gz \
    && tar zxf /tmp/prometheus.tar.gz -C /tmp \
    && mkdir /etc/prometheus /usr/share/prometheus \
    && mv /tmp/${prom}/prometheus /bin/prometheus \
    && mv /tmp/${prom}/promtool /bin/promtool \
    && mv /tmp/${prom}/prometheus.yml /etc/prometheus/ \
    && mv /tmp/${prom}/consoles /usr/share/prometheus/consoles \
    && mv /tmp/${prom}/console_libraries /usr/share/prometheus/console_libraries \
    && ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ \
    && rm /tmp/prometheus.tar.gz


# Add Containerpilot
# Releases at https://github.com/joyent/containerpilot/releases
ENV CONTAINERPILOT_VER 2.7.3
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN set -ex \
    && export CONTAINERPILOT_CHECKSUM=2511fdfed9c6826481a9048e8d34158e1d7728bf \
    && curl -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Add ContainerPilot configuration
COPY etc/containerpilot.json /etc
ENV CONTAINERPILOT file:///etc/containerpilot.json


# Install Consul
# Releases at https://releases.hashicorp.com/consul
RUN set -ex \
    && export CONSUL_VERSION=0.7.5 \
    && export CONSUL_CHECKSUM=40ce7175535551882ecdff21fdd276cef6eaab96be8a8260e0599fadb6f1f5b8 \
    && curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    # Create empty directories for Consul config and data \
    && mkdir -p /etc/consul \
    && mkdir -p /var/lib/consul


# Install Consul template
# Releases at https://releases.hashicorp.com/consul-template/
RUN set -ex \
    && export CONSUL_TEMPLATE_VERSION=0.18.0 \
    && export CONSUL_TEMPLATE_CHECKSUM=f7adf1f879389e7f4e881d63ef3b84bce5bc6e073eb7a64940785d32c997bc4b \
    && curl --retry 7 --fail -Lso /tmp/consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_TEMPLATE_CHECKSUM}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && rm /tmp/consul-template.zip


# Add Prometheus config template
# ref https://prometheus.io/docs/operating/configuration/
# for details on building your own config
COPY etc/prometheus.yml.ctmpl /etc/prometheus/prometheus.yml.ctmpl
COPY bin /bin


# Override the entrypoint to include ContainerPilot
WORKDIR /prometheus
ENTRYPOINT ["/usr/local/bin/containerpilot"]
CMD ["/bin/prometheus" ,\
     "-config.file=/etc/prometheus/prometheus.yml", \
     "-storage.local.path=/prometheus", \
     "-web.console.libraries=/etc/prometheus/console_libraries", \
     "-web.console.templates=/etc/prometheus/consoles"]
