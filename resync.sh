#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"/config
find ~/bin/ -maxdepth 1 -type f -executable ! -name '*~' -exec install {} ./bin/ \;
find . -type f -exec cp -a ~/{} {} \;
