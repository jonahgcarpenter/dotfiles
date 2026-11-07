#!/bin/bash

set -e

echo -e "${BLUE}--- Starting installation of YAY ---${NC}"
echo ""

sudo pacman -S --needed base-devel git

temp_dir=$(mktemp -d)

trap 'echo "Cleaning up temporary directory..."; rm -rf "$temp_dir"' EXIT

cd "$temp_dir"

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si

echo ""
echo -e "${GREEN}--- YAY has been successfully installed! ---${NC}"
