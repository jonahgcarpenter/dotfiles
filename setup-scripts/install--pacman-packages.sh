#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- List of packages to install ---
# You can easily add or remove packages from this list.
# Just edit the lines between the parentheses.
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
)

# --- Script Execution ---
echo "--- Starting package installation script ---"
echo ""

# Install all packages listed in the array above
# The 'sudo' command will prompt for your password once.
# "${packages_to_install[@]}" expands the array into a space-separated list.
echo "--> Installing ${#packages_to_install[@]} selected packages..."
sudo pacman -S --noconfirm --needed "${packages_to_install[@]}" $(pacman -Sgq nerd-fonts)

echo ""
echo "--- All specified packages have been installed successfully! ---"
