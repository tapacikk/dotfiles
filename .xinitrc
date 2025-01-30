#!/bin/bash
# Statusbar
while true; do
   BAT0=$(cat /sys/class/power_supply/BAT0/capacity)
   BAT1=$(cat /sys/class/power_supply/BAT1/capacity)
   if ps -C cmus > /dev/null; then
       CMUSDATA=$(cmus-remote -Q)
       ARTIST=$(echo "$CMUSDATA" | grep -w '^tag artist' | awk '{gsub("tag artist ", "");print}')
       TRACK=$(echo "$CMUSDATA" | grep -w '^tag title' | awk '{gsub("tag title ", "");print}')
       STATUS=$(echo "$CMUSDATA" | grep -w '^status' | awk '{gsub("status ", "");print}')
       if [ "$STATUS" = "playing" ]; then
            STATUS=">"
           else
            STATUS=
       fi
       MUSIC="$STATUS [$ARTIST][$TRACK]"\
    else
       MUSIC=
    fi
   if ps -C iwd > /dev/null; then
    connected_network="[󰤨 $(iwctl station wlan0 show | grep "Connected network " | cut  -d" " -f19)]"
       if ps -C openconnect > /dev/null; then
            connected_network="[󰤨 $connected_network\(chemvpn\)]"
       fi
    connected_network=$connected_network
   else
    connected_network=
   fi
   xsetroot -name "$connected_network[$BAT0%/$BAT1%]$(date '+[%a,%d-%b][%I:%M]')"
   sleep 1
done &


export PATH=$PATH:$HOME/.local/bin
xcompmgr &
wal -c
wal -i $HOME/.local/wall
xwallpaper $wall
exec dwm 
