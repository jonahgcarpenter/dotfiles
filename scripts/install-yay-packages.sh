#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- List of AUR packages to install ---
aur_packages=(
    'google-chrome'
    'lazydocker'
)

# --- Script Execution ---
echo "--- Starting YAY package installation ---"
echo ""

# Install all packages using the --noconfirm flag
echo "--> Installing ${#aur_packages[@]} selected AUR packages without confirmation..."
yay -S --noconfirm "${aur_packages[@]}"

echo ""
echo "--- Unattended YAY package installation complete! ---"
