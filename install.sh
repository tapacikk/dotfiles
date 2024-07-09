#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Packages
apt -y update
apt -y upgrade
apt install nala -y
#nala install -y xorg libx11-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev libxft-dev libharfbuzz-dev libxrandr-dev
#nala install -y gcc make python3 python3-pip libimlib2-dev
#nala install -y xwallpaper xcompmgr imagemagick 
#nala install -y tmux lynx iwd evince qutebrowser mpv stow libjs-pdf
#nala install -y fonts-recommended fonts-jetbrains-mono pulseaudio popple-utils xinput

# Intallation from list, see https://askubuntu.com/questions/9135/how-to-backup-settings-and-list-of-installed-packages
apt-key add $SCRIPT_DIR/Repo.keys
cp -R $SCRIPT_DIR/sources.list* /etc/apt
apt-get install dselect
dselect update
dpkg --set-selections < $SCRIPT_DIR/Package.list
apt-get dselect-upgrade -y


