#!/bin/bash

TMPDIR=/tmp/vieb
mkdir -p $TMPDIR
pushd $TMPDIR
wget $(curl -s https://api.github.com/repos/Jelmerro/Vieb/releases/latest \
  | grep browser_download_url \
  | grep amd64.deb \
  | cut -d '"' -f 4) -O vieb_latest.deb

sudo apt install ./vieb_latest.deb
popd
rm -rf $TMPDIR
