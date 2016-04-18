# Autopilot Pattern Prometheus

This repo is an extension of the official [Prometheus.io](https://prometheus.io) Docker image, designed to be self-operating according to the [Autopilot Pattern](http://autopilotpattern.io/). This application demonstrates support for configuring Prometheus to be used as a metrics collector for applications using the [ContainerPilot telemetry endpoint](https://www.joyent.com/blog/containerpilot-telemetry).

[![DockerPulls](https://img.shields.io/docker/pulls/autopilotpattern/prometheus.svg)](https://registry.hub.docker.com/u/autopilotpattern/prometheus/)
[![DockerStars](https://img.shields.io/docker/stars/autopilotpattern/prometheus.svg)](https://registry.hub.docker.com/u/autopilotpattern/prometheus/)
[![ImageLayers](https://badge.imagelayers.io/autopilotpattern/prometheus:latest.svg)](https://imagelayers.io/?images=autopilotpattern/prometheus:latest)
[![Join the chat at https://gitter.im/autopilotpattern/prometheus](https://badges.gitter.im/autopilotpattern/prometheus.svg)](https://gitter.im/autopilotpattern/prometheus)

### Using Prometheus with Containerbuddy

The Dockerfile provided uses Containerbuddy in the Prometheus container to populate (and keep updated) the Prometheus configuration file with a list of targets.

For targets, Containerbuddy supports a Prometheus-compatible telemetry endpoint. If a `telemetry` option is provided, Containerbuddy will expose a Prometheus HTTP client interface that can be used to scrape performance telemetry. The telemetry interface is advertised as a service to the discovery service similar to services configured via the Containerbuddy `services` block. Each sensor for the telemetry service will run periodically and record values in the [Prometheus client library](https://github.com/prometheus/client_golang). A Prometheus server can then make HTTP requests to the telemetry endpoint.

### Run it!

1. [Get a Joyent account](https://my.joyent.com/landing/signup/) and [add your SSH key](https://docs.joyent.com/public-cloud/getting-started).
1. Install the [Docker Toolbox](https://docs.docker.com/installation/mac/) (including `docker` and `docker-compose`) on your laptop or other environment, as well as the [Joyent Triton CLI](https://www.joyent.com/blog/introducing-the-triton-command-line-tool) (`triton` replaces our old `sdc-*` CLI tools).
1. [Configure Docker and Docker Compose for use with Joyent.](https://docs.joyent.com/public-cloud/api-access/docker)

Check that everything is configured correctly by running `./setup.sh`. This will check that your environment is setup correctly and will create an `_env` file that includes injecting an environment variable for the Consul hostname into the Prometheus container so we can take advantage of [Triton Container Name Service (CNS)](https://www.joyent.com/blog/introducing-triton-container-name-service).

```bash
$ docker-compose up -d
Creating prometheus_prometheus_1
Creating prometheus_consul_1

$ docker-compose ps
Name                         Command           State    Ports
--------------------------------------------------------------------------------
prometheus_consul_1          /bin/start -server    Up   53/tcp, 53/udp,
                             -bootst ...                8300/tcp, 8301/tcp,
                                                        8301/udp, 8302/tcp,
                                                        8302/udp, 8400/tcp,
                                                        0.0.0.0:8500->8500/tcp
prometheus_prometheus_1      /bin/containerbuddy   Up   0.0.0.0:9090->9090/tcp
                             /bin/prometheus...
```


Once you have Prometheus running you should be able to check its current status by making an HTTP request to its own telemetry endpoint:


```bash
# pipe it to less because there's a lot of data!
$ curl "http://$(triton ip prometheus_prometheus_1):9090/telemetry" | less
```
