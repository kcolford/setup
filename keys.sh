#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

gpg --import gpg.key

keyname=id_rsa
cp $keyname.pub ~/.ssh/
cp -n /dev/null ~/.ssh/$keyname || true
chmod 600 ~/.ssh/$keyname
gpg -d < $keyname.asc > ~/.ssh/$keyname

cd ~
[ -d .password-store ] || git clone git@github.com:kcolford/.password-store
pass git pull
