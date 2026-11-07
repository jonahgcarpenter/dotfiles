#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: fix-gpu-sleep.sh --device desktop [--verbose]"
ALLOWED_DEVICES="desktop"
parse_args "$@" || exit 2

PARAM="nvidia.NVreg_PreserveVideoMemoryAllocations=1"
GRUB_FILE="/etc/default/grub"

log_info "Checking NVIDIA sleep fix..."

if [[ ! -f "$GRUB_FILE" ]]; then
    log_error "GRUB config not found: $GRUB_FILE"
    exit 1
fi

changed=0
if grep -qF "$PARAM" "$GRUB_FILE"; then
    log_ok "Kernel parameter already present. Skipping edit."
else
    log_info "Adding kernel parameter to $GRUB_FILE..."
    if [[ ! -f "$GRUB_FILE.bak" ]]; then
        run sudo cp "$GRUB_FILE" "$GRUB_FILE.bak"
    else
        log_warn "Backup $GRUB_FILE.bak already exists. Reusing it."
    fi
    run sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$PARAM /" "$GRUB_FILE"
    changed=1
fi

if [[ $changed -eq 1 ]]; then
    log_info "Updating GRUB configuration..."
    run sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    log_ok "GRUB config unchanged. Skipping grub-mkconfig."
fi

log_info "Enabling NVIDIA sleep services..."
run sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume

log_ok "NVIDIA sleep fix complete!"
