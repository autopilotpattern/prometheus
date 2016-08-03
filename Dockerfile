FROM prom/prometheus:0.17.0
# We're starting with the official base image, which is Alpine w/ glibc and
# has WORKDIR set to /prometheus. We'll override the entrypoint and command

RUN apk add --update curl

# get consul-template
RUN curl -Lso /tmp/consul-template_0.14.0_linux_amd64.zip https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip \
    && echo "7c70ea5f230a70c809333e75fdcff2f6f1e838f29cfb872e1420a63cdf7f3a78" /tmp/consul-template_0.14.0_linux_amd64.zip \
    && unzip /tmp/consul-template_0.14.0_linux_amd64.zip \
    && mv consul-template /bin

# get Containerbuddy release
ENV CONTAINERBUDDY_VERSION 1.4.0-rc1
RUN export CB_SHA1=8d7c21c8c79c082ec47e956a219cd58206592c83 \
    && curl -Lso /tmp/containerbuddy.tar.gz \
         "https://github.com/joyent/containerbuddy/releases/download/${CONTAINERBUDDY_VERSION}/containerbuddy-${CONTAINERBUDDY_VERSION}.tar.gz" \
    && echo "${CB_SHA1}  /tmp/containerbuddy.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerbuddy.tar.gz -C /bin \
    && rm /tmp/containerbuddy.tar.gz

# Add Containerbuddy configuration
COPY etc/containerbuddy.json /etc
ENV CONTAINERBUDDY file:///etc/containerbuddy.json

# Add Prometheus config template
# ref https://prometheus.io/docs/operating/configuration/
# for details on building your own config
COPY etc/prometheus.yml.ctmpl /etc/prometheus/prometheus.yml.ctmpl

# Override the entrypoint to include Containerbuddy
ENTRYPOINT []
CMD ["/bin/containerbuddy", \
     "/bin/prometheus", \
     "-config.file=/etc/prometheus/prometheus.yml", \
     "-storage.local.path=/prometheus", \
     "-web.console.libraries=/etc/prometheus/console_libraries", \
     "-web.console.templates=/etc/prometheus/consoles" ]
