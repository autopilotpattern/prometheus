# Autopilot Pattern Prometheus on Triton

1. [Get a Joyent account](https://my.joyent.com/landing/signup/) and [add your SSH key](https://docs.joyent.com/public-cloud/getting-started).
2. Install [Docker](https://docs.docker.com/docker-for-mac/install/) on your laptop or other environment, as well as the [Joyent Triton CLI](https://www.joyent.com/blog/introducing-the-triton-command-line-tool).
3. [Configure Docker and Docker Compose for use with Joyent.](https://docs.joyent.com/public-cloud/api-access/docker)

Check that everything is configured correctly by running the `setup.sh` script. This will check that your environment is setup correctly and create an `_env` file that includes environment variables with reasonable defaults.

```bash
$ setup.sh
$ vim _env 
```

See the [README](../../README.md) for details on environment variables in `_env`.

Start everything:

```bash
docker-compose -p prometheus up -d
```
