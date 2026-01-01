#!/bin/bash

set -e

aur_packages=(
    'google-chrome'
    'lazydocker'
    'flux-bin'
)

echo "--- Starting YAY package installation ---"
echo ""

echo "--> Installing ${#aur_packages[@]} selected AUR packages without confirmation..."
yay -S --noconfirm "${aur_packages[@]}"

echo ""
echo "--- Unattended YAY package installation complete! ---"
