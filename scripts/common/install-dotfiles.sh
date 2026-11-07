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

# Apps with device-specific files link per file instead of per directory,
# so device overlays land next to shared files instead of resolving
# through a directory symlink into common/.
FILE_LEVEL_APPS=(hypr waybar rofi)

is_file_level() {
    local app="$1" a
    for a in "${FILE_LEVEL_APPS[@]}"; do
        if [[ "$a" == "$app" ]]; then
            return 0
        fi
    done
    return 1
}

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

# Replace a stale directory symlink with a real directory so per-file
# links have somewhere to live (the old symlink is kept in the backup).
ensure_real_dir() {
    local dir="$1"
    if [[ -L "$dir" ]]; then
        backup_target "$dir"
        log_warn "Replaced directory symlink with real dir: $dir (backup kept)"
    fi
    mkdir -p "$dir"
}

# Link every regular file under a source tree to the mirrored destination.
link_tree_files() {
    local src_dir="$1"
    local dest_dir="$2"
    local f rel
    ensure_real_dir "$dest_dir"
    while IFS= read -r -d '' f; do
        rel="${f#$src_dir/}"
        link_entry "$f" "$dest_dir/$rel"
    done < <(find "$src_dir" -type f -print0)
}

log_info "Linking shared configs (device: $DEVICE)..."

shopt -s nullglob dotglob
for src in "$COMMON_DIR"/.config/*; do
    app="$(basename "$src")"
    if [[ -d "$src" && ! -L "$src" ]] && is_file_level "$app"; then
        link_tree_files "$src" "$HOME/.config/$app"
    else
        link_entry "$src" "$HOME/.config/$app"
    fi
done
for src in "$COMMON_DIR"/.[!.]*; do
    base="$(basename "$src")"
    [[ "$base" == ".config" ]] && continue
    link_entry "$src" "$HOME/$base"
done

log_info "Linking device overlay: $DEVICE..."

if [[ -d "$DEVICE_DIR/.config" ]]; then
    while IFS= read -r -d '' f; do
        rel="${f#$DEVICE_DIR/.config/}"
        if [[ -d "$f" && ! -L "$f" ]]; then
            ensure_real_dir "$HOME/.config/$rel"
        else
            link_entry "$f" "$HOME/.config/$rel"
        fi
    done < <(find "$DEVICE_DIR/.config" -mindepth 1 -print0 | sort -z)
else
    log_warn "No .config overlay for $DEVICE. Skipping."
fi
shopt -u nullglob dotglob

log_info "Linking device dotfiles: $DEVICE..."

shopt -s nullglob dotglob
for src in "$DEVICE_DIR"/.[!.]*; do
    base="$(basename "$src")"
    [[ "$base" == ".config" || "$base" == "etc" ]] && continue
    link_entry "$src" "$HOME/$base"
done
shopt -u nullglob dotglob

log_info "Bootstrapping local secrets: $DEVICE..."

SECRETS_EXAMPLE="$DEVICE_DIR/.zshrc.secrets.example"
if [[ -f "$HOME/.zshrc.secrets" ]]; then
    log_ok "Skipping: $HOME/.zshrc.secrets exists (local-only, never touched)."
elif [[ -f "$SECRETS_EXAMPLE" ]]; then
    cp "$SECRETS_EXAMPLE" "$HOME/.zshrc.secrets"
    chmod 600 "$HOME/.zshrc.secrets"
    log_warn "Created $HOME/.zshrc.secrets from device example. Fill in real values."
else
    log_warn "No secrets example for $DEVICE. Skipping."
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

log_ok "Dotfiles deployment complete!"
