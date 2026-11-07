#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${BLUE}### Starting Full System Upgrade (Pacman & AUR) ###${NC}"
yay --noconfirm

echo -e "\n${BLUE}### Secure Boot check (sbctl + GRUB) ###${NC}"
if command -v sbctl >/dev/null 2>&1 && sudo sbctl status 2>/dev/null | grep -q "Installed:.*✓"; then
  if ! sudo sbctl verify; then
    echo -e "${YELLOW}Unsigned binaries found — re-signing known files...${NC}"
    sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
    sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
    sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
    sudo sbctl sign -s /boot/vmlinuz-linux
  fi

  # Only nag when grub was actually upgraded today
  if grep -E "^\[.*\] \[ALPM\] upgraded grub " /var/log/pacman.log 2>/dev/null | tail -1 | grep -q "$(date +%F)"; then
    echo -e "${YELLOW}grub package was upgraded — reinstall to ESP with SB flags:${NC}"
    echo '  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable --recheck --disable-shim-lock --modules="all_video bli boot chain configfile efibootnext efi_gop efifwsetup ext2 fat font gettext gfxmenu gfxterm gzio linux loadenv normal part_gpt part_msdos search search_fs_uuid search_fs_file search_label terminal test video video_bochs video_cirrus video_fb echo"'
    echo '  sudo grub-mkconfig -o /boot/grub/grub.cfg'
    echo '  sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI; sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi; sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi'
  fi

  sudo sbctl verify
  sudo sbctl status | grep -E 'Installed|Secure Boot|Setup Mode'
else
  echo -e "${BLUE}Skipping Secure Boot check (sbctl not enrolled on this host)${NC}"
fi

echo -e "\n${BLUE}### Cleaning up package cache... ###${NC}"
sudo paccache -r

echo -e "\n${GREEN}### System update and cleanup complete! ###${NC}\n"
