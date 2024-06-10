#!/bin/bash
# Statusbar
while true; do
   BAT0=$(cat /sys/class/power_supply/BAT0/capacity)
   BAT1=$(cat /sys/class/power_supply/BAT1/capacity)
   xsetroot -name "BAT0: $BAT0 BAT1: $BAT1 $(date +"%F %R" )"
   sleep 1m
done &



export PATH=$PATH:$HOME/.local/bin
xcompmgr &
nohup mons -a -x $HOME/.local/bin/monhandler.sh > /dev/null 2>&1 &
setxkbmap -option ctrl:nocaps
wall=$(find -L $HOME/.local/wall -type f | shuf -n1)
wal -c
wal -i $wall
xwallpaper --zoom $wall
exec dwm 
