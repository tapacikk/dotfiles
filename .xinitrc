xcompmgr &
xrandr --output Virtual-1 --mode 640x480
wall=$(find -L $HOME/.local/wall -type f | shuf -n1)
wal -c
wal -i $wall
xwallpaper --zoom $wall
export PATH=$PATH:$HOME/.local/bin
exec dwm 
