from collections import defaultdict
import os
from os.path import expanduser
import random
import re
import string
import subprocess
import sys
import time
import unittest

from testcases import AutopilotPatternTest, WaitTimeoutError, \
     dump_environment_to_file
import requests


class PrometheusStackTest(AutopilotPatternTest):
    project_name = 'prom'

    def setUp(self):
        if 'COMPOSE_FILE' in os.environ and 'triton' in os.environ['COMPOSE_FILE']:
            account = os.environ['TRITON_ACCOUNT']
            dc = os.environ['TRITON_DC']
            self.consul_cns = 'prometheus-consul.svc.{}.{}.triton.zone'.format(account, dc)
            self.prometheus_cns = 'prometheus.svc.{}.{}.triton.zone'.format(account, dc)
            os.environ['CONSUL'] = self.consul_cns

    def test_prometheus(self):
        self.instrument(self.wait_for_containers,
                        {'prometheus': 1, 'consul': 1}, timeout=300)
        self.instrument(self.wait_for_service, 'prometheus', count=1, timeout=300)

    def wait_for_containers(self, expected={}, timeout=30):
        """
        Waits for all containers to be marked as 'Up' for all services.
        `expected` should be a dict of {"service_name": count}.
        TODO: lower this into the base class implementation.
        """
        svc_regex = re.compile(r'^{}_(\w+)_\d+$'.format(self.project_name))

        def get_service_name(container_name):
            return svc_regex.match(container_name).group(1)

        while timeout > 0:
            containers = self.compose_ps()
            found = defaultdict(int)
            states = []
            for container in containers:
                service = get_service_name(container.name)
                found[service] = found[service] + 1
                states.append(container.state == 'Up')
            if all(states):
                if not expected or found == expected:
                    break
            time.sleep(1)
            timeout -= 1
        else:
            raise WaitTimeoutError("Timed out waiting for containers to start.")

if __name__ == "__main__":
    unittest.main()
