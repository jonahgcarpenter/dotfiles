#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: extra-packages.sh --device desktop [--verbose]"
ALLOWED_DEVICES="desktop"
parse_args "$@" || exit 2

pacman_packages=(
    'nvidia-container-toolkit'
    'sbctl'
    'sbsigntools'
    'efibootmgr'
)

aur_packages=()

# Drop accidental empty entries so 'yay -S' never receives a blank arg.
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

log_info "Installing desktop pacman packages..."
run sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

if [[ ${#aur_packages[@]} -gt 0 ]]; then
    log_info "Installing desktop AUR packages..."
    run yay -S --noconfirm --needed "${aur_packages[@]}"
else
    log_ok "No desktop AUR packages to install. Skipping."
fi

log_ok "Desktop extra packages installed successfully!"
