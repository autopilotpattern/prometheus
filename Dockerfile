FROM alpine:3.4

# The official Promtheus base image has no package manager so rather than
# artisanally hand-rolling curl and the rest of our stack we'll just use
# Alpine so we can use `docker build`.

RUN apk add --update curl

# add Prometheus. alas, the Prometheus developers provide no checksum
RUN export prom=prometheus-1.3.0.linux-amd64 \
    && curl -Lso /tmp/${prom}.tar.gz https://github.com/prometheus/prometheus/releases/download/v1.3.0/${prom}.tar.gz \
    && tar zxf /tmp/${prom}.tar.gz -C /tmp \
    && mkdir /etc/prometheus /usr/share/prometheus \
    && mv /tmp/${prom}/prometheus /bin/prometheus \
    && mv /tmp/${prom}/promtool /bin/promtool \
    && mv /tmp/${prom}/prometheus.yml /etc/prometheus/ \
    && mv /tmp/${prom}/consoles /usr/share/prometheus/consoles \
    && mv /tmp/${prom}/console_libraries /usr/share/prometheus/console_libraries \
    && ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ \
    && rm /tmp/prometheus-1.3.0.linux-amd64.tar.gz

# get consul-template
RUN curl -Lso /tmp/consul-template_0.14.0_linux_amd64.zip https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip \
    && echo "7c70ea5f230a70c809333e75fdcff2f6f1e838f29cfb872e1420a63cdf7f3a78" /tmp/consul-template_0.14.0_linux_amd64.zip \
    && unzip /tmp/consul-template_0.14.0_linux_amd64.zip \
    && mv consul-template /bin \
    && rm /tmp/consul-template_0.14.0_linux_amd64.zip

# Add Containerpilot and set its configuration
ENV CONTAINERPILOT_VERSION 2.4.4
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN export CONTAINERPILOT_CHECKSUM=6194ee482dae95844046266dcec2150655ef80e9 \
    && export archive=containerpilot-${CONTAINERPILOT_VERSION}.tar.gz \
    && curl -Lso /tmp/${archive} \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/${archive}" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/${archive}" | sha1sum -c \
    && tar zxf /tmp/${archive} -C /usr/local/bin \
    && rm /tmp/${archive}

# Add Containerpilot configuration
COPY etc/containerpilot.json /etc
ENV CONTAINERPILOT file:///etc/containerpilot.json

# Add Prometheus config template
# ref https://prometheus.io/docs/operating/configuration/
# for details on building your own config
COPY etc/prometheus.yml.ctmpl /etc/prometheus/prometheus.yml.ctmpl

# Override the entrypoint to include Containerpilot
WORKDIR /prometheus
ENTRYPOINT []
CMD ["/usr/local/bin/containerpilot", \
     "/bin/prometheus", \
     "-config.file=/etc/prometheus/prometheus.yml", \
     "-storage.local.path=/prometheus", \
     "-web.console.libraries=/etc/prometheus/console_libraries", \
     "-web.console.templates=/etc/prometheus/consoles" ]
