#!/bin/bash
set -euo pipefail

sudo -v
ansible-playbook -b -c local -l `hostname`, local.yml
