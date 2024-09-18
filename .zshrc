alias :q="exit"
bindkey -v
export EDITOR=vim
alias gs="git status"
alias :e="vi"
alias t="tmux set status"
export PATH=$PATH:~/.local/bin
alias l="ls -lht"


if [ -e /home/taras/.nix-profile/etc/profile.d/nix.sh ]; then . /home/taras/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
