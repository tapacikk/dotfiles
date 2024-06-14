# dotfiles Yes, I now have a linux computer

This repo is supposed to be cloned to some git-controlled (obviously) directory and then stowed

Here there are dotfiles for:
* vim
* dwm
* dmenu
* st
* zsh
* mutt

## Don't forget:

1. hid\_apple rule in modprobe: (/etc/modprobe.d/hid\_apple.conf)
```
sudo echo "options hid_apple swap_opt_cmd=1" > /etc/modprobe.d/hid\_apple.conf
sudo update-initramfs -u
sudo modprobe -r hid_apple; sudo modprobe hid_apple
```

### You need to stow this directory:
```
cd /dot
stow -t /home/taras -d . .local --adopt
stow -t /home/taras -d . .config --adopt
stow -t /home/taras -d . . --adopt
```
### This setup expects you to have pass w/ following password names (for e-mail):
* xbopoctt@gmail.com
* xbopoctt@icloud.com
* ucla\_client\_id
* ucla\_client\_secret
Also, set up a token w/ oama

### Locking
put the following in /etc/systemd/system/slock@.service:

```
[Unit]
Description=Lock X session using slock for user %i
Before=sleep.target

[Service]
User=%i
Environment=DISPLAY=:0
ExecStartPre=/usr/bin/xset dpms force suspend
ExecStart=/home/taras/.local/bin/slock

[Install]
WantedBy=sleep.target
```

