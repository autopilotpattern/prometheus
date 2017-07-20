# Autopilot Pattern Prometheus on Triton

1. [Get a Joyent account](https://my.joyent.com/landing/signup/) and [add your SSH key](https://docs.joyent.com/public-cloud/getting-started).
2. Install [Docker](https://docs.docker.com/docker-for-mac/install/) on your laptop or other environment, as well as the [Joyent Triton CLI](https://www.joyent.com/blog/introducing-the-triton-command-line-tool).
3. Install the [Triton Docker CLI helper](https://github.com/joyent/triton-docker-cli).

Check that everything is configured correctly by running the `setup.sh` script. This will check that your environment is setup correctly and create an `_env` file that includes environment variables with reasonable defaults, if not, run `eval "$(triton env)"`.

```bash
$ setup.sh
$ vim _env
```

See the [README](../../README.md) for details on environment variables in `_env`.

Start everything:

```bash
triton-compose up -d
```
