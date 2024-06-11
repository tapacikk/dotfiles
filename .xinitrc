#!/bin/bash
# Statusbar
while true; do
   BAT0=$(cat /sys/class/power_supply/BAT0/capacity)
   BAT1=$(cat /sys/class/power_supply/BAT1/capacity)
   xsetroot -name "BAT0: $BAT0 BAT1: $BAT1 $(date +"%F %R" )"
   sleep 1m
done &



export PATH=$PATH:$HOME/.local/bin
picom --corner-radius 10 -b -c &
setxkbmap -option ctrl:nocaps
wall=$(find -L $HOME/.local/wall -type f | shuf -n1)
wal -c
wal -i $wall
xwallpaper --zoom $wall
exec dwm 
