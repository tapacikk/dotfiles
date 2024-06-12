#!/bin/bash
# Statusbar
while true; do
   BAT0=$(cat /sys/class/power_supply/BAT0/capacity)
   BAT1=$(cat /sys/class/power_supply/BAT1/capacity)
   if ps -C cmus > /dev/null; then
       CMUSDATA=$(cmus-remote -Q)
       ARTIST=$(echo "$CMUSDATA" | grep -w '^tag artist' | awk '{gsub("tag artist ", "");print}')
       TRACK=$(echo "$CMUSDATA" | grep -w '^tag title' | awk '{gsub("tag title ", "");print}')
       POSITION=$(echo "$CMUSDATA" | grep -w '^position' | awk '{gsub("position ", "");print}')
       DURATION=$(echo "$CMUSDATA" | grep -w '^duration' | awk '{gsub("duration ", "");print}')
       STATUS=$(echo "$CMUSDATA" | grep -w '^status' | awk '{gsub("status ", "");print}')
       SHUFFLE=$(echo "$CMUSDATA" | grep -w '^set shuffle' | awk '{gsub("set shuffle ", "");print}')
       if [ "$STATUS" = "playing" ]; then
	STATUS="PLA"
       else
	STATUS="PAU"
       fi
       if [ "$SHUFFLE" = "true" ]; then
	SHUFFLE=" S"
       else
	SHUFFLE=""
       fi
       MUSIC="$STATUS [$ARTIST][$TRACK]"
    else
       MUSIC=
    fi
   xsetroot -name "$MUSIC | $BAT0% | $BAT1% | $(date +"%F %R" )"
   sleep 1
done &


export PATH=$PATH:$HOME/.local/bin
xcompmgr &
mons -a &
setxkbmap -option ctrl:nocaps
wall=$(find -L $HOME/.local/wall -type f | shuf -n1)
wal -c
wal -i $wall
xwallpaper --zoom $wall
exec dwm 
