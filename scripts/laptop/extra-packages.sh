#!/bin/bash

set -e

pacman_packages=(
    'tlp'
)

aur_packages=(
    'python-validity'
)

echo "--- Starting extra package installation ---"
echo ""

echo "--> Installing ${#pacman_packages[@]} selected pacman packages..."
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

echo "--> Installing ${#aur_packages[@]} selected AUR packages..."
yay -S --noconfirm "${aur_packages[@]}"

echo ""
echo "--- Extra packages have been installed successfully! ---"
