#!/bin/bash

set -e

pacman_packages=(
    'tlp'
    'brightnessctl'
)

aur_packages=(
    'python-validity'
)

echo -e "${BLUE}--- Starting extra package installation ---${NC}"
echo ""

echo -e "${BLUE}Installing ${#pacman_packages[@]} selected pacman packages...${NC}"
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

echo -e "${BLUE}Installing ${#aur_packages[@]} selected AUR packages...${NC}"
yay -S --noconfirm "${aur_packages[@]}"

echo ""
echo -e "${GREEN}--- Extra packages have been installed successfully! ---${NC}"
