#!/bin/bash

sudo apt -y update
sudo apt -y upgrade
sudo apt install nala -y
sudo nala install -y xorg libx11-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev
sudo nala install -y gcc make python3 python3-pip

