#!/bin/bash

# Packages
apt -y update
apt -y upgrade
apt install nala -y
nala install -y xorg libx11-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev libxft-dev libharfbuzz-dev
nala install -y gcc make python3 python3-pip
nala install -y xwallpaper xcompmgr imagemagick 
nala install -y tmux

