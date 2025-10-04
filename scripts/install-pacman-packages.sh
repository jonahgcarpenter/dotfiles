#!/bin/bash

set -e

# --- List of packages to install ---
packages_to_install=(
    'spotify-launcher'
    'btop'
    'waybar'
    'rofi'
    'solaar'
    'wl-clipboard'
    'discord'
    'kubectl'
    'hyprpaper'
    'nvim'
    'tmux'
    'zsh'
    'pavucontrol'
    'npm'
    'unzip'
    'k9s'
    'gimp'
    'kustomize'
    'kubeseal'
    'docker'
    'docker-compose'
    'dbeaver'
    'terraform'
    'ansible-core'
    'talosctl'
    'helm'
    'swaylock'
)

# --- Script Execution ---
echo "--- Starting package installation script ---"
echo ""

# Install all packages listed in the array above
echo "--> Installing ${#packages_to_install[@]} selected packages..."
sudo pacman -S --noconfirm --needed "${packages_to_install[@]}" $(pacman -Sgq nerd-fonts)

# Install Oh My Zsh non-interactively
# Sets as default shell
echo "--> Installing Oh My Zsh and setting Zsh as default shell..."
# The --unattended flag ensures the script runs automatically without prompts.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo ""

echo ""
echo "--- All specified packages have been installed successfully! ---"
