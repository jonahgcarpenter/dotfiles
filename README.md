# Dotfiles

<img width="744" height="372" alt="image" src="https://github.com/user-attachments/assets/c374d366-0ba9-4fc0-82b1-633e38839ead" />

## Boot Windows From Rofi

The power menu includes **Boot Windows**, with a local Windows logo and a
confirmation screen. It uses UEFI `BootNext` for a single Windows boot without
changing the permanent boot order, so Arch remains the default.

The shared menu (`power-menu.sh`, `config.rasi`) is deployed to both desktop
and laptop. Everything Windows-specific is generated and installed on desktop
only: the helper is specific to the detected Windows installation. Without the
helper installed, selecting Windows displays an error.

### Automatic Setup (desktop)

`setup.sh --device desktop` runs the installer automatically, or run it
directly from the repository root:

```bash
bash scripts/desktop/install-boot-windows.sh --device desktop
```

Requires UEFI boot, `efibootmgr`, `sudo`, and systemd. The package installation
script includes `efibootmgr`. The installer detects the Windows Boot Manager
entry with `efibootmgr -v`:

* exactly one entry → generates and installs the helper, sudoers rule, and
  logo. No boot settings change, no reboot.
* none → skips cleanly (laptops and non-dual-boot machines stay untouched).
* multiple → errors out; re-run with `--entry XXXX` to disambiguate.

The installer validates syntax, installs a root-owned helper at
`/usr/local/sbin/boot-windows-once`, and grants password-free access only to
that helper with no arguments through `/etc/sudoers.d/boot-windows-once`.
Re-run after firmware or disk changes; the helper re-verifies the Windows EFI
identity on every use and refuses to act if it changed.

Choosing **Boot Windows** and confirming will set `BootNext` and immediately
request a reboot. The helper checks the Windows EFI identity first and does not
reboot if setting `BootNext` fails. If the reboot request fails afterward, Windows
remains selected for the next boot; `sudo efibootmgr --delete-bootnext` cancels it.

### Safe Menu Check

```bash
bash common/.config/rofi/power-menu.sh --dry-run --choose windows
```

This prints the confirmation menu without modifying boot settings or rebooting.

### Remove Privileged Access

```bash
sudo rm /etc/sudoers.d/boot-windows-once /usr/local/sbin/boot-windows-once
```

To hide Windows on a machine that does not use it, launch the menu with
`--choices shutdown/reboot/suspend/hibernate/logout/lockscreen`.
