#!/bin/bash

# Packages
sudo apt -y update
sudo apt -y upgrade
sudo apt install nala -y
echo -e "1,2\nY" | sudo nala fetch
sudo nala install -y xorg libx11-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev libxft-dev libharfbuzz-dev
sudo nala install -y gcc make python3 python3-pip
sudo nala install -y xwallpaper xcompmgr imagemagick 
sudo nala install -y tmux

# compiling
pushd .local/src/
pushd dwm
make clean install 
popd
pushd st
make clean install 
popd
pushd dmenu
make clean install
popd
popd


