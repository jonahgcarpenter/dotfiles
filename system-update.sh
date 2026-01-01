#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}yay could not be found. Please install it to update AUR packages.${NC}"
    echo "You can install it by running: sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
fi

echo -e "\n${GREEN}### Starting Full System Upgrade (Pacman & AUR) ###${NC}"
yay --noconfirm

if ! command -v paccache &> /dev/null; then
    echo -e "${BLUE}paccache could not be found. Installing pacman-contrib...${NC}"
    sudo pacman -S --noconfirm pacman-contrib
fi

echo -e "\n${GREEN}### Cleaning up package cache... ###${NC}"
sudo paccache -r

echo -e "\n${GREEN}### System update and cleanup complete! ###${NC}\n"
