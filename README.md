# dotfiles
Yes, I now have a linux computer

This repo is supposed to be cloned directly to $HOME

Here there are dotfiles for:
* vim
* dwm
* dmenu
* st
* zsh

## Don't forget:

1. hid\_apple rule in modprobe: (/etc/modprobe.d/hid\_apple.conf)
```
sudo echo "options hid_apple swap_opt_cmd=1" > /etc/modprobe.d/hid\_apple.conf
sudo update-initramfs -u
sudo modprobe -r hid_apple; sudo modprobe hid_apple
```


