#!/bin/bash

set -e

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
    'usbutils'
    'dnsutils'
    'imagemagick'
    'luarocks'
    'yazi'
    'ffmpeg'
    '7zip'
    'jq'
    'poppler'
    'fd'
    'ripgrep'
    'fzf'
    'zoxide'
    'resvg'
)

echo "--- Starting package installation script ---"
echo ""

echo "--> Installing ${#packages_to_install[@]} selected packages..."
sudo pacman -S --noconfirm --needed "${packages_to_install[@]}" $(pacman -Sgq nerd-fonts)

echo "--> Installing Oh My Zsh and setting Zsh as default shell..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s /usr/bin/zsh $USER
echo ""

echo ""
echo "--- All specified packages have been installed successfully! ---"
