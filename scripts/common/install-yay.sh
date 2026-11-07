#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: install-yay.sh --device desktop|laptop [--verbose]"
ALLOWED_DEVICES="desktop laptop"
parse_args "$@" || exit 2

log_info "Installing yay (device: $DEVICE)..."

if command -v yay >/dev/null 2>&1; then
    log_ok "yay is already installed. Skipping."
    exit 0
fi

run sudo pacman -S --noconfirm --needed base-devel git

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

run git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
cd "$temp_dir/yay"
run makepkg -si --noconfirm --needed

log_ok "yay has been successfully installed!"
