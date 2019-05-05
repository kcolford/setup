#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
sudo -v
ansible localhost -b -c local -m setup -m include_role -a name="$1"
