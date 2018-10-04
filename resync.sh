#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"/config
find . -type f -exec cp -a -T ~/{} {} \;
