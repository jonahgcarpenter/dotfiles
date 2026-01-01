#!/bin/bash

set -e

pacman_packages=(
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

aur_packages=(
    'google-chrome'
    'lazydocker'
    'flux-bin'
)

echo "--> Installing ${#pacman_packages[@]} selected packages..."
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}" $(pacman -Sgq nerd-fonts)

echo "--> Installing ${#aur_packages[@]} selected AUR packages without confirmation..."
yay -S --noconfirm "${aur_packages[@]}"

echo "--> Installing Oh My Zsh and setting Zsh as default shell..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s /usr/bin/zsh $USER
echo ""

echo ""
echo "--- All global packages have been installed successfully! ---"
