#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: system-update.sh --device desktop|laptop [--verbose]"
ALLOWED_DEVICES="desktop laptop"
parse_args "$@" || exit 2

log_info "Starting full system upgrade (Pacman & AUR)..."
run yay --noconfirm

log_info "Secure Boot check (sbctl + GRUB)..."
if command -v sbctl >/dev/null 2>&1 && sudo sbctl status 2>/dev/null | grep -q "Installed:.*✓"; then
    if ! sudo sbctl verify; then
        log_warn "Unsigned binaries found - re-signing known files..."
        run sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
        run sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
        run sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
        run sudo sbctl sign -s /boot/vmlinuz-linux
    else
        log_ok "All binaries verified."
    fi

    if grep -E "^\[.*\] \[ALPM\] upgraded grub " /var/log/pacman.log 2>/dev/null | tail -1 | grep -q "$(date +%F)"; then
        log_warn "grub package was upgraded - reinstall to ESP with SB flags:"
        log_info '  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable --recheck --disable-shim-lock --modules="all_video bli boot chain configfile efibootnext efi_gop efifwsetup ext2 fat font gettext gfxmenu gfxterm gzio linux loadenv normal part_gpt part_msdos search search_fs_uuid search_fs_file search_label terminal test video video_bochs video_cirrus video_fb echo"'
        log_info '  sudo grub-mkconfig -o /boot/grub/grub.cfg'
        log_info '  sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI; sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi; sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi'
    fi

    run sudo sbctl verify
    run sudo sbctl status | grep -E 'Installed|Secure Boot|Setup Mode'
else
    log_warn "Skipping Secure Boot check (sbctl not enrolled on this host)."
fi

log_info "Cleaning up package cache..."
run sudo paccache -r

log_ok "System update and cleanup complete!"
