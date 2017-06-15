FROM alpine:3.6

# The official Prometheus base image has no package manager so rather than
# artisanally hand-rolling curl and the rest of our stack we'll just use
# Alpine so we can use `docker build`.

RUN apk add --update curl

# add Prometheus. alas, the Prometheus developers provide no checksum
RUN export PROM_VERSION=1.7.1 \
    && export PROM_CHECKSUM=4779d5cf08c50ed368a57b102ab3895e5e830d6b355ca4bfecf718a034a164e0 \
    && export prom=prometheus-${PROM_VERSION}.linux-amd64 \
    && curl -Lso /tmp/${prom}.tar.gz https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/${prom}.tar.gz \
    && echo "${PROM_CHECKSUM}  /tmp/${prom}.tar.gz" | sha256sum -c \
    && tar zxf /tmp/${prom}.tar.gz -C /tmp \
    && mkdir /etc/prometheus /usr/share/prometheus \
    && mv /tmp/${prom}/prometheus /bin/prometheus \
    && mv /tmp/${prom}/promtool /bin/promtool \
    && mv /tmp/${prom}/prometheus.yml /etc/prometheus/ \
    && mv /tmp/${prom}/consoles /usr/share/prometheus/consoles \
    && mv /tmp/${prom}/console_libraries /usr/share/prometheus/console_libraries \
    && ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ \
    && rm /tmp/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# get consul-template
RUN curl -Lso /tmp/consul-template_0.14.0_linux_amd64.zip https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip \
    && echo "7c70ea5f230a70c809333e75fdcff2f6f1e838f29cfb872e1420a63cdf7f3a78  /tmp/consul-template_0.14.0_linux_amd64.zip" | sha256sum -c \
    && unzip /tmp/consul-template_0.14.0_linux_amd64.zip \
    && mv consul-template /bin \
    && rm /tmp/consul-template_0.14.0_linux_amd64.zip

# get consul-agent
RUN export CONSUL_VERSION=0.7.0 \
    && export CONSUL_CHECKSUM=b350591af10d7d23514ebaa0565638539900cdb3aaa048f077217c4c46653dd8 \
    && curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && mkdir /config

# Add Containerpilot and set its configuration
ENV CONTAINERPILOT_VERSION 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json

RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c \
    && export archive=containerpilot-${CONTAINERPILOT_VERSION}.tar.gz \
    && curl -Lso /tmp/${archive} \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/${archive}" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/${archive}" | sha1sum -c \
    && tar zxf /tmp/${archive} -C /usr/local/bin \
    && rm /tmp/${archive}

# Add Containerpilot configuration
COPY etc/containerpilot.json /etc
ENV CONTAINERPILOT /etc/containerpilot.json

# Add Prometheus config template
# ref https://prometheus.io/docs/operating/configuration/
# for details on building your own config
COPY etc/prometheus.yml.ctmpl /etc/prometheus/prometheus.yml.ctmpl

# Override the entrypoint to include Containerpilot
WORKDIR /prometheus
ENTRYPOINT []
CMD ["/usr/local/bin/containerpilot"]
