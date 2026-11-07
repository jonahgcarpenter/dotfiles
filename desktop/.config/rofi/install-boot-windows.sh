#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin

if (( EUID != 0 )); then
    printf '%s\n' 'Run this installer with sudo.' >&2
    exit 1
fi
source_dir=$(dirname -- "$(readlink -f -- "$0")")

conf="$source_dir/boot-windows.conf"
if [[ ! -f "$conf" ]]; then
    printf '%s\n' 'No boot-windows.conf next to this installer; nothing to install.' >&2
    exit 1
fi

bash -n "$source_dir/boot-windows-once"
bash -n "$conf"
(
    # shellcheck disable=SC1090
    source "$conf"
    : "${ENTRY:?ENTRY is not set in boot-windows.conf}"
    : "${PARTUUID:?PARTUUID is not set in boot-windows.conf}"
    : "${LOADER:?LOADER is not set in boot-windows.conf}"
    if [[ ! $ENTRY =~ ^[0-9A-Fa-f]{4}$ ]]; then
        printf '%s\n' "ENTRY must be a 4-digit hex boot number, got: $ENTRY" >&2
        exit 1
    fi
    if [[ ! $PARTUUID =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$ ]]; then
        printf '%s\n' "PARTUUID is not a UUID, got: $PARTUUID" >&2
        exit 1
    fi
)
visudo -cf "$source_dir/boot-windows-once.sudoers"
install -o root -g root -m 0755 "$source_dir/boot-windows-once" /usr/local/sbin/boot-windows-once
install -o root -g root -m 0440 "$source_dir/boot-windows-once.sudoers" /etc/sudoers.d/boot-windows-once
visudo -cf /etc/sudoers.d/boot-windows-once
printf '%s\n' 'Windows menu action installed. No boot settings changed; no reboot requested.'
