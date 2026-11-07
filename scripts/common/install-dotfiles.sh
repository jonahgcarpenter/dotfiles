#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: install-dotfiles.sh --device desktop|laptop [--verbose]"
ALLOWED_DEVICES="desktop laptop"
parse_args "$@" || exit 2

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_DIR="$REPO_ROOT/common"
DEVICE_DIR="$REPO_ROOT/$DEVICE"

if [[ ! -d "$COMMON_DIR/.config" ]]; then
    log_error "Missing directory: $COMMON_DIR/.config"
    exit 1
fi
if [[ ! -d "$DEVICE_DIR" ]]; then
    log_error "Missing device directory: $DEVICE_DIR"
    exit 1
fi

BACKUP_BASE="$HOME/.dotfiles_backup"
BACKUP_DIR=""

backup_target() {
    local dest="$1"
    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$BACKUP_BASE/$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        log_warn "Backing up replaced files to $BACKUP_DIR"
    fi
    local rel="${dest#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dest" "$BACKUP_DIR/$rel"
}

link_entry() {
    local src="$1"
    local dest="$2"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        log_ok "Skipping (already linked): $dest"
        return 0
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        backup_target "$dest"
        log_warn "Replaced: $dest (backup kept)"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    log_ok "Linked: $dest -> $src"
}

log_info "Linking shared configs (device: $DEVICE)..."

shopt -s nullglob dotglob
for src in "$COMMON_DIR"/.config/*; do
    link_entry "$src" "$HOME/.config/$(basename "$src")"
done
for src in "$COMMON_DIR"/.[!.]*; do
    base="$(basename "$src")"
    [[ "$base" == ".config" ]] && continue
    link_entry "$src" "$HOME/$base"
done

log_info "Linking device overlay: $DEVICE..."

if [[ -d "$DEVICE_DIR/.config" ]]; then
    for src in "$DEVICE_DIR"/.config/*; do
        link_entry "$src" "$HOME/.config/$(basename "$src")"
    done
else
    log_warn "No .config overlay for $DEVICE. Skipping."
fi

LY_SRC="$DEVICE_DIR/etc/ly/config.ini"
LY_DEST="/etc/ly/config.ini"
if [[ -f "$LY_SRC" ]]; then
    if [[ -L "$LY_DEST" && "$(readlink "$LY_DEST")" == "$LY_SRC" ]]; then
        log_ok "Skipping (already linked): $LY_DEST"
    else
        if [[ -e "$LY_DEST" && ! -L "$LY_DEST" ]]; then
            log_warn "Backing up $LY_DEST to $LY_DEST.bak.$(date +%Y%m%d-%H%M%S)"
            sudo cp -a "$LY_DEST" "$LY_DEST.bak.$(date +%Y%m%d-%H%M%S)"
            sudo rm -f "$LY_DEST"
        elif [[ -L "$LY_DEST" ]]; then
            sudo rm -f "$LY_DEST"
        fi
        sudo mkdir -p "$(dirname "$LY_DEST")"
        sudo ln -s "$LY_SRC" "$LY_DEST"
        log_ok "Linked: $LY_DEST -> $LY_SRC"
    fi
else
    log_warn "No ly config for $DEVICE at $LY_SRC. Skipping."
fi
shopt -u nullglob dotglob

log_ok "Dotfiles deployment complete!"
