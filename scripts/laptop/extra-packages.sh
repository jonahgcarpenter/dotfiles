#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: extra-packages.sh --device laptop [--verbose]"
ALLOWED_DEVICES="laptop"
parse_args "$@" || exit 2

pacman_packages=(
    'tlp'
    'brightnessctl'
    'bluez'
    'bluez-utils'
    'bluetui'
    'fwupd'
)

aur_packages=(
    'python-validity'
)

filtered=()
for p in "${pacman_packages[@]:-}"; do
    [[ -n "$p" ]] && filtered+=("$p")
done
pacman_packages=("${filtered[@]:-}")

filtered=()
for p in "${aur_packages[@]:-}"; do
    [[ -n "$p" ]] && filtered+=("$p")
done
aur_packages=("${filtered[@]:-}")

if ! command -v yay >/dev/null 2>&1; then
    log_error "yay is required but not installed. Run install-yay.sh first."
    exit 1
fi

log_info "Installing laptop pacman packages..."
run sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

if [[ ${#aur_packages[@]} -gt 0 ]]; then
    log_info "Installing laptop AUR packages..."
    run yay -S --noconfirm --needed "${aur_packages[@]}"
else
    log_ok "No laptop AUR packages to install. Skipping."
fi

log_ok "Laptop extra packages installed successfully!"
