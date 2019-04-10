#!/bin/bash
set -euo pipefail

#keybase login kcolford

keybase pgp export -s | gpg --import

keyname=id_rsa
cp $keyname.pub ~/.ssh/
cp -n /dev/null ~/.ssh/$keyname || true
chmod 600 ~/.ssh/$keyname
gpg < $keyname.enc > ~/.ssh/$keyname
