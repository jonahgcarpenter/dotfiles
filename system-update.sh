#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\n${BLUE}### Starting Full System Upgrade (Pacman & AUR) ###${NC}"
yay --noconfirm

echo -e "\n${BLUE}### Cleaning up package cache... ###${NC}"
sudo paccache -r

echo -e "\n${GREEN}### System update and cleanup complete! ###${NC}\n"
