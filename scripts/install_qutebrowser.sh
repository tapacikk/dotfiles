#!/bin/bash



# Root check
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[FAIL]\033[0m This script must be run as root."
    exit 1
fi

mkdir -p /opt/qutebrowser
mkdir -p /opt/qutebrowser/latest
pushd /opt/qutebrowser/latest
git clone https://github.com/qutebrowser/qutebrowser.git .
python3 scripts/mkvenv.py
popd

