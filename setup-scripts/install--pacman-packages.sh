#!/bin/bash

set -e

# --- List of packages to install ---
packages_to_install=(
    'btop'
    'waybar'
    'rofi'
    'solaar'
    'liquidctl'
    'discord'
    'kubectl'
    'hyprpaper'
    'ly'
    'nvim'
    'tmux'
    'zsh'
    'pavucontrol'
    'npm'
    'unzip'
    'k9s'
    'gimp'
)

# --- Script Execution ---
echo "--- Starting package installation script ---"
echo ""

# Install all packages listed in the array above
echo "--> Installing ${#packages_to_install[@]} selected packages..."
sudo pacman -S --noconfirm --needed "${packages_to_install[@]}" $(pacman -Sgq nerd-fonts)

echo ""
echo "--- All specified packages have been installed successfully! ---"
