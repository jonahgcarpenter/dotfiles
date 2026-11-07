#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: install-packages.sh --device desktop|laptop [--verbose]"
ALLOWED_DEVICES="desktop laptop"
parse_args "$@" || exit 2

pacman_packages=(
    'docker-buildx'
    'spotify-launcher'
    'btop'
    'waybar'
    'rofi'
    'efibootmgr'
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
    'hyprlock'
    'hypridle'
    'usbutils'
    'dnsutils'
    'luarocks'
    'ffmpeg'
    'poppler'
    'ripgrep'
    'pacman-contrib'
    'websocat'
    'opencode'
    'tree-sitter-cli'
    'ethtool'
    'github-cli'
)

aur_packages=(
    'google-chrome'
    'lazydocker'
    'flux-bin'
)

if ! command -v yay >/dev/null 2>&1; then
    log_error "yay is required but not installed. Run install-yay.sh first."
    exit 1
fi

log_info "Installing ${#pacman_packages[@]} pacman packages..."
mapfile -t font_pkgs < <(pacman -Sgq nerd-fonts)
run sudo pacman -S --noconfirm --needed "${pacman_packages[@]}" "${font_pkgs[@]}"

if [[ ${#aur_packages[@]} -gt 0 ]]; then
    log_info "Installing ${#aur_packages[@]} AUR packages..."
    run yay -S --noconfirm --needed "${aur_packages[@]}"
else
    log_ok "No AUR packages to install. Skipping."
fi

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_ok "Oh My Zsh is already installed. Skipping."
else
    log_info "Installing Oh My Zsh..."
    run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [[ "${SHELL:-}" == "/usr/bin/zsh" ]]; then
    log_ok "Default shell is already zsh. Skipping chsh."
else
    log_info "Setting zsh as default shell..."
    run sudo chsh -s /usr/bin/zsh "$USER"
fi

log_ok "All shared packages have been installed successfully!"
