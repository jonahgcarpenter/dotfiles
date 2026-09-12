#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin

if (( EUID != 0 )); then
    printf '%s\n' 'Run this installer with sudo.' >&2
    exit 1
fi
source_dir=$(dirname -- "$(readlink -f -- "$0")")
bash -n "$source_dir/boot-windows-once"
visudo -cf "$source_dir/boot-windows-once.sudoers"
install -o root -g root -m 0755 "$source_dir/boot-windows-once" /usr/local/sbin/boot-windows-once
install -o root -g root -m 0440 "$source_dir/boot-windows-once.sudoers" /etc/sudoers.d/boot-windows-once
visudo -cf /etc/sudoers.d/boot-windows-once
printf '%s\n' 'Windows menu action installed. No boot settings changed; no reboot requested.'
