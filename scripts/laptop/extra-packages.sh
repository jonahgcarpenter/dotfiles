#!/bin/bash

set -e

pacman_packages=(
    'tlp'
)

echo "--- Starting pacman package installation ---"
echo ""

echo "--> Installing ${#pacman_packages[@]} selected pacman packages..."
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

aur_packages=(
    'python-validity'
)

echo "--- Starting YAY package installation ---"
echo ""

echo "--> Installing ${#aur_packages[@]} selected AUR packages..."
yay -S --noconfirm "${aur_packages[@]}"

echo ""
echo "--- Extra packages have been installed successfully! ---"
