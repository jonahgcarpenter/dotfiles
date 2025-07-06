#!/bin/bash

# A simple script to update a full Arch Linux system.
# This includes official repository packages (pacman) and AUR packages (yay).

# --- Color Codes ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Check for yay ---
# The script will not run if yay is not installed.
if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}yay could not be found. Please install it to update AUR packages.${NC}"
    echo "You can install it by running: sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
fi

# --- Main Update Process ---
echo -e "\n${GREEN}### Starting Full System Upgrade (Pacman & AUR) ###${NC}"
yay --noconfirm

# --- Check for paccache ---
if ! command -v paccache &> /dev/null; then
    echo -e "${BLUE}paccache could not be found. Installing pacman-contrib...${NC}"
    sudo pacman -S --noconfirm pacman-contrib
fi

# --- Cleanup ---
# 'paccache -r' safely removes all cached versions of packages except for the
# three most recent versions.
echo -e "\n${GREEN}### Cleaning up package cache... ###${NC}"
sudo paccache -r

echo -e "\n${GREEN}### System update and cleanup complete! ###${NC}\n"
