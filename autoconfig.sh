#!/bin/bash

grub() {
    printf "${CYAN}configuring grub${NC}\n"
    sudo cp -f grub /etc/default/grub
    sudo update-grub
    printf "${GREEN}done${NC}\n"
}

tmux() {
    printf "${CYAN}configuring tmux${NC}\n"
	if [ ! -d "$TMUX_DIR" ];
	then
		mkdir ~/.config/tmux
	fi
	cp -f tmux.conf ~/.config/tmux/tmux.conf
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	printf "${RED}now you can press 'prefix-I' (default prefix is ctrl-b) to install plugins${NC}"
    printf "${GREEN}done${NC}\n"
}

workspace() {
    printf "${CYAN}configuring workspace "$1"${NC}\n"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$1  "['<Alt>$1']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$1  "['<Alt><Shift>$1']"
    printf "${GREEN}done${NC}\n"
}

workspaces() {
    printf "${CYAN}enabling workspaces${NC}\n"
	for i in {1..10}
	do
		printf "${CYAN}enabling workspace $i${NC}\n"
		gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i  "['<Alt>$((i % 10))']"
	done
    printf "${GREEN}done${NC}\n"
}

disable_workspaces() {
    printf "${CYAN}disabling workspaces${NC}\n"
	for i in {1..10}
	do
		gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-"$i"  "[]"
	done
    printf "${GREEN}done${NC}\n"
}

alacritty() {
    printf "${CYAN}configuring alacritty${NC}\n"
	if [ ! -d "$ALACRITTY_DIR" ];
	then
		mkdir ~/.config/alacritty
	fi
    cp -f alacritty.toml ~/.config/alacritty/alacritty.toml
    printf "${GREEN}done${NC}\n"
}

RED='\033[0;31m'
NC='\033[0m' 
CYAN='\033[0;36m'
GREEN='\033[0;32m'

TMUX_DIR=$HOME/.config/tmux/
ALACRITTY_DIR=$HOME/.config/alacritty/

if [ -z $1 ]
then
    grub
    tmux
	workspace 5
	alacritty
    exit
fi

for config in "$1"
do
    case $config in
	grub)
	    grub
	    ;;
	tmux)
	    tmux
	    ;;
	workspace)
	    workspace $2
	    ;;
	workspaces)
		workspaces
		;;
	disable_workspaces)
		disable_workspaces
		;;
	alacritty)
	    alacritty
	    ;;
	*)
	    printf "${RED}wrong config parameter${NC}\n"
	    ;;
    esac
done
