# Dotfiles

<img width="744" height="372" alt="image" src="https://github.com/user-attachments/assets/c374d366-0ba9-4fc0-82b1-633e38839ead" />

## Boot Windows From Rofi

The power menu includes **Boot Windows**, with a local Windows logo and a
confirmation screen. It uses UEFI `BootNext` for a single Windows boot without
changing the permanent boot order, so Arch remains the default.

The normal dotfiles installation copies the menu and helper sources to
`~/.config/rofi`. Privileged setup is deliberately opt-in: the shared menu is
deployed to both desktop and laptop, but the helper is specific to this Windows
installation. Without the helper installed, selecting Windows displays an error.

### One-Time Setup

Requires UEFI boot, `efibootmgr`, `sudo`, and systemd. The package installation
script includes `efibootmgr`. Before installing on another machine, inspect
`efibootmgr -v` and update `desktop/.config/rofi/boot-windows.conf`
(entry number, GPT partition UUID, and loader path) as appropriate:

- `boot-windows.conf`: Windows entry `0000`, GPT partition UUID
  `b2f3f5b5-7a66-430a-bacf-c1f619ddf768`, and loader path
  `\EFI\MICROSOFT\BOOT\BOOTMGFW.EFI`. Both the entry match and `--bootnext`
  argument must use the correct entry number.
- `boot-windows-once.sudoers`: the authorized username is `fragsap`.

From the repository root, run:

```bash
sudo bash desktop/.config/rofi/install-boot-windows.sh
```

Alternatively, after deploying the dotfiles:

```bash
sudo bash ~/.config/rofi/install-boot-windows.sh
```

The installer validates the scripts and sudoers syntax, installs a root-owned
helper at `/usr/local/sbin/boot-windows-once`, and grants password-free access
only to that helper with no arguments through `/etc/sudoers.d/boot-windows-once`.
Installation does not change boot settings or reboot. Re-run the installer after
updating the helper or rule; copying dotfiles alone does not update system files.

Choosing **Boot Windows** and confirming will set `BootNext` and immediately
request a reboot. The helper checks the Windows EFI identity first and does not
reboot if setting `BootNext` fails. If the reboot request fails afterward, Windows
remains selected for the next boot; `sudo efibootmgr --delete-bootnext` cancels it.

### Safe Menu Check

```bash
bash desktop/.config/rofi/power-menu.sh --dry-run --choose windows
```

This prints the confirmation menu without modifying boot settings or rebooting.

### Remove Privileged Access

```bash
sudo rm /etc/sudoers.d/boot-windows-once /usr/local/sbin/boot-windows-once
```

To hide Windows on a machine that does not use it, launch the menu with
`--choices shutdown/reboot/suspend/hibernate/logout/lockscreen`.
