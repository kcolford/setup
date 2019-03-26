#!/bin/bash
set -euo pipefail

#keybase login kcolford

cp sshkey.pub ~/.ssh/
cp -n /dev/null ~/.ssh/sshkey || true
chmod 600 ~/.ssh/sshkey
keybase pgp decrypt < sshkey.enc > ~/.ssh/sshkey
