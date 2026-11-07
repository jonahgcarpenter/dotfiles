# Dotfiles — Technical Documentation

Single-branch repo serving two machines (`desktop`, `laptop`). Everything
deploys as **symlinks** into `$HOME` (plus one system path), so edits in the
repo take effect live. Nothing is ever copied.

## Repository Layout

```
common/                 Shared everything. Mirrors $HOME:
  .config/<app>/         → ~/.config/<app>   (btop, hypr, k9s, kitty, nvim,
                                               rofi, waybar, yay, opencode)
  .zshrc, .tmux.conf,
  .gitconfig             → ~/<same>
  .zshrc.local           (does NOT exist here; see device overlays)
desktop/ / laptop/      Device overlays. Same $HOME-relative mirroring, plus:
  etc/ly/config.ini      → /etc/ly/config.ini (via sudo symlink)
  .zshrc.local           → ~/.zshrc.local
  .zshrc.secrets.example Bootstrap template for ~/.zshrc.secrets (planned)
scripts/
  lib.sh                 Shared: arg parsing, colored logging, run() wrapper.
                         Sourced by every script; never executed directly.
  common/                Runs on both devices (yay, packages, dotfiles, docker,
                         system-update).
  desktop/ / laptop/     Runs only on that device. Every file must accept
                         --device (hard-fails on the wrong one).
wallpapers/             Referenced by absolute repo path from hyprpaper.conf.
setup.sh                Entry point. Requires --device, fans out to scripts.
```

## Deployment Model (`scripts/common/install-dotfiles.sh`)

* Resolves the repo root from its own location; never depends on CWD.
* Links `common/.config/*` → `~/.config/*`, `common/.[!.]*` → `~/*`,
  then overlays `$DEVICE/.config/*`, `$DEVICE/.[!.]*`, and
  `$DEVICE/etc/ly/config.ini` → `/etc/ly/config.ini` (sudo).
* **Granularity:** `hypr`, `waybar`, `rofi`, `opencode` link **per file**
  (see `FILE_LEVEL_APPS`) so device files land next to shared ones instead
  of resolving through a directory symlink. Everything else links per
  directory.
* **Idempotent:** a target already pointing at the right source is skipped.
  Anything else (file, dir, stale symlink) is moved to
  `~/.dotfiles_backup/<timestamp>/` preserving its `$HOME`-relative path,
  then replaced. System files get a timestamped `.bak` next to the original.
* **Secrets:** if `~/.zshrc.secrets` exists it is never touched. If missing
  and the device ships a `.zshrc.secrets.example`, it is copied (mode 600,
  never linked) as a starting point.
* Verification: run twice — the second run must print only `Skipping`.
  Sandbox pattern: `HOME=/tmp/fake bash scripts/common/install-dotfiles.sh
  --device <d>` with sudo stubbed; never test against a live `$HOME`.

## Script Conventions

* Every script: `set -euo pipefail`, sources `scripts/lib.sh`, accepts
  `--device desktop|laptop` (**required**, exit 2 when missing/invalid),
  optional `--verbose` and `--help`.
* Device-specific scripts (`scripts/desktop/*`, `scripts/laptop/*`) accept
  only their device and exit 2 otherwise.
* Logging via `log_info`/`log_ok`/`log_warn`/`log_error` (blue/green/yellow/
  red, auto-disabled without a TTY or with `NO_COLOR`). Default is quiet:
  wrap tool calls in `run()` so raw output appears only with `--verbose`
  (or on failure, when the captured output is printed).
* `setup.sh` runs `scripts/common/*` in fixed order, then `scripts/$DEVICE/*`
  sorted, passing `--device` (and `--verbose`) through. It runs **all** scripts
  and reports failures at the end (exit 1 if any failed) rather than stopping.
* Everything must be re-runnable: guard with `command -v`, `systemctl
  is-enabled/is-active`, checksum-compare before writing (`cmp -s`), back up
  exactly once (never overwrite an existing `.bak`), regenerate derived
  configs only when inputs changed.

## Per-App Device Splits

Shared base in `common/`, deltas in device profiles. The mechanism depends on
what the consumer supports:

| App | Base | Device mechanism |
|---|---|---|
| hyprland | `hyprland.lua` requires `host.active` | `desktop\|laptop/.config/hypr/host/active.lua` (monitors, devices, keybinds) |
| waybar | `config` with `"include": ["device.jsonc"]` | `device.jsonc` per device: full `modules-right` + device-only blocks (desktop `custom/gpu`, laptop `battery`); laptop `custom/power` passes `--choices` without `windows` |
| rofi | `power-menu.sh`, `config.rasi` shared | No rofi-side split. Windows visibility is controlled by the launcher's `--choices` (see Boot Windows below) |
| zsh | `common/.zshrc` sources `~/.zshrc.local`, then `~/.zshrc.secrets` | `.zshrc.local` per device (aliases, PATH); API var *names* declared empty in common, *values* only in local secrets (never committed; `.gitignore`d) |
| ly | None (INI has no include mechanism) | Full per-device copies; only 2 lines differ (`allow_empty_password`, `vi_default_mode`) |
| opencode | `opencode.json` linked per file | `cli.json` stays tracked and linked; app writes will dirty git status — accepted, revert or commit deliberately |

Rules of thumb: prefer base + sourced/included overlay; duplicate whole files
only when the consumer has no include mechanism (ly) or the file is a genuine
pin/state file kept deliberately (`lazy-lock.json` stays committed — commit
updates after `:Lazy` updates to keep machines in sync).

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

- exactly one entry → generates and installs the helper, sudoers rule, and
  logo. No boot settings change, no reboot.
- none → skips cleanly (laptops and non-dual-boot machines stay untouched).
- multiple → errors out; re-run with `--entry XXXX` to disambiguate.

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

## Adding Things

* **New shared config:** add under `common/` mirroring its `$HOME` path. Apps
  needing per-file granularity go in `FILE_LEVEL_APPS`.
* **New device-specific bit:** prefer an overlay the consumer includes over a
  full-file copy; add a sandbox check that every referenced module/file
  resolves on both devices.
* **New script:** place in `scripts/common/` or `scripts/<device>/`, follow
  Script Conventions (parse via `lib.sh`, idempotent, `run()`-wrapped tools),
  `chmod +x`, verify with `bash -n` (and `zsh -n` for zsh files).
* **Never commit:** real secret values, `~/.zshrc.secrets`, machine-generated
  state that isn't a deliberate pin. Check `git status` after running any app
  that writes through a symlink.

## Pre-Deploy Checklist (per machine)

1. `git status` clean or knowingly dirty; `git stash`/commit work in progress.
2. Migrate live-only customizations (aliases, keys, theme dirs) into the repo
   or local-only files — the linker shelves whatever it replaces into
   `~/.dotfiles_backup/<timestamp>/`, it does not merge.
3. Run the linker for that device, re-run to confirm all-`Skipping`.
4. Spot-check `readlink` on key targets; restart bars/shells (running apps keep
   in-memory config until reloaded).
