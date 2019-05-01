#!/bin/bash
set -euo pipefail

ansible-playbook -b -c local -l `hostname`, local.yml
