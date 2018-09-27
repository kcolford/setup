#!/bin/bash
set -euo pipefail

cp -r "$(dirname "$0")"/config/. ~/.
chmod -R og-rwx ~/.gnupg
