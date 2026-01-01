#!/bin/bash

set -e

echo "--- Starting installation of YAY ---"
echo ""

sudo pacman -S --needed base-devel git

temp_dir=$(mktemp -d)

trap 'echo "Cleaning up temporary directory..."; rm -rf "$temp_dir"' EXIT

cd "$temp_dir"

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si

echo ""
echo "--- YAY has been successfully installed! ---"
