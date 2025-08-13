#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[FAIL]\033[0m This script must be run as root."
    exit 1
fi
mkdir -p /opt/qutebrowser
mkdir -p /opt/qutebrowser/src
pushd /opt/qutebrowser/src
    git clone https://github.com/qutebrowser/qutebrowser.git .
    python3 -m venv /opt/qutebrowser/3.5.1
    python3 scripts/mkvenv.py --venv-dir /opt/qutebrowser/3.5.1
    pushd /opt/qutebrowser
        ln -s 3.5.1 latest
    popd
popd
chown -R taras:taras /opt/qutebrowser

