#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: install-boot-windows.sh --device desktop [--verbose] [--entry XXXX] [--dry-run]"
ALLOWED_DEVICES="desktop"
ENTRY_OVERRIDE=""
DRY_RUN=0
EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --entry)
            [[ $# -lt 2 ]] && { log_error "--entry requires a value"; exit 2; }
            ENTRY_OVERRIDE="$2"
            shift 2
            ;;
        --entry=*)
            ENTRY_OVERRIDE="${1#--entry=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done
parse_args "${EXTRA_ARGS[@]:-}" || exit 2

if [[ -n "$ENTRY_OVERRIDE" && ! "$ENTRY_OVERRIDE" =~ ^[0-9A-Fa-f]{4}$ ]]; then
    log_error "--entry must be a 4-digit hex boot number, got: $ENTRY_OVERRIDE"
    exit 2
fi

HELPER_DEST="/usr/local/sbin/boot-windows-once"
SUDOERS_DEST="/etc/sudoers.d/boot-windows-once"
SVG_DEST="$HOME/.config/rofi/windows.svg"

log_info "Detecting Windows Boot Manager entry..."

entries=$(efibootmgr -v 2>/dev/null || sudo efibootmgr -v)
found_entries=()
found_puuids=()
found_loaders=()
while IFS= read -r line; do
    if [[ "$line" =~ ^Boot([0-9A-Fa-f]{4})\*.*Windows\ Boot\ Manager ]]; then
        entry="${BASH_REMATCH[1]}"
        if [[ -n "$ENTRY_OVERRIDE" && "$entry" != "$ENTRY_OVERRIDE" ]]; then
            continue
        fi
        puuid=""
        loader=""
        if [[ "$line" =~ HD\(1,GPT,([0-9A-Fa-f-]{36}), ]]; then
            puuid="${BASH_REMATCH[1]}"
        fi
        if [[ "$line" =~ \\[A-Za-z0-9_\\-]+\.EFI ]]; then
            loader="${BASH_REMATCH[0]}"
        fi
        if [[ -z "$puuid" || -z "$loader" ]]; then
            log_error "Could not parse identity for entry $entry: $line"
            exit 1
        fi
        found_entries+=("$entry")
        found_puuids+=("$puuid")
        found_loaders+=("$loader")
    fi
done <<< "$entries"

if [[ -n "$ENTRY_OVERRIDE" && ${#found_entries[@]} -eq 0 ]]; then
    log_error "No Windows Boot Manager entry $ENTRY_OVERRIDE found."
    exit 1
fi
if [[ ${#found_entries[@]} -eq 0 ]]; then
    log_ok "No Windows installation detected. Skipping."
    exit 0
fi
if [[ ${#found_entries[@]} -gt 1 ]]; then
    log_error "Multiple Windows entries found, disambiguate with --entry:"
    for e in "${found_entries[@]}"; do
        log_error " - $e"
    done
    exit 1
fi

ENTRY="${found_entries[0]}"
PARTUUID="${found_puuids[0]}"
LOADER="${found_loaders[0]}"
log_info "Found Windows entry $ENTRY (PARTUUID $PARTUUID, loader $LOADER)."

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat > "$tmpdir/boot-windows-once" <<'EOF'
#!/bin/bash
set -euo pipefail
export LC_ALL=C

if (( $# != 0 )); then
    printf '%s\n' 'This helper does not accept arguments.' >&2
    exit 1
fi
if (( EUID != 0 )); then
    printf '%s\n' 'This helper must run as root.' >&2
    exit 1
fi

entries=$(/usr/bin/efibootmgr)
windows_entry=
while IFS= read -r line; do
    if [[ $line == "Boot@@ENTRY@@* Windows Boot Manager"* ]]; then
        windows_entry=$line
    fi
done <<< "$entries"
if [[ $windows_entry != *"HD(1,GPT,@@PARTUUID@@,"* ||
      $windows_entry != *'@@LOADER@@'* ]]; then
    printf '%s\n' 'Windows EFI entry has changed; refusing to modify boot settings.' >&2
    exit 1
fi

# BootNext is consumed once by firmware; the permanent BootOrder is untouched.
/usr/bin/efibootmgr --bootnext "@@ENTRY@@"
if ! /usr/bin/systemctl reboot; then
    printf '%s\n' 'Reboot failed. Windows is still selected for the next boot.' >&2
    exit 1
fi
EOF

loader_esc=${LOADER//\\/\\\\}
loader_esc=${loader_esc//&/\\&}
sed -i -e "s/@@ENTRY@@/$ENTRY/g" -e "s/@@PARTUUID@@/$PARTUUID/g" -e "s|@@LOADER@@|$loader_esc|g" "$tmpdir/boot-windows-once"
bash -n "$tmpdir/boot-windows-once"

cat > "$tmpdir/boot-windows-once.sudoers" <<EOF
$(id -un) ALL=(root) NOPASSWD: $HELPER_DEST ""
EOF
visudo -cf "$tmpdir/boot-windows-once.sudoers"

cat > "$tmpdir/windows.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <path fill="#ffffff" d="M3 3h12v12H3zM17 3h12v12H17zM3 17h12v12H3zM17 17h12v12H17z"/>
</svg>
EOF

install_file() {
    local src="$1" dest="$2" mode="$3" use_sudo="$4"
    if [[ "$use_sudo" == "sudo" ]]; then
        if [[ -f "$dest" ]] && sudo cmp -s "$src" "$dest"; then
            log_ok "Skipping (already installed): $dest"
            return 0
        fi
        if [[ $DRY_RUN -eq 1 ]]; then
            log_info "Would install: $dest (mode $mode)"
            return 0
        fi
        sudo install -o root -g root -m "$mode" "$src" "$dest"
    else
        if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
            log_ok "Skipping (already installed): $dest"
            return 0
        fi
        if [[ $DRY_RUN -eq 1 ]]; then
            log_info "Would install: $dest (mode $mode)"
            return 0
        fi
        mkdir -p "$(dirname "$dest")"
        install -m "$mode" "$src" "$dest"
    fi
    log_ok "Installed: $dest"
}

if [[ $DRY_RUN -eq 1 ]]; then
    log_info "Dry run: no changes made."
fi
install_file "$tmpdir/boot-windows-once" "$HELPER_DEST" "0755" "sudo"
install_file "$tmpdir/boot-windows-once.sudoers" "$SUDOERS_DEST" "0440" "sudo"
if [[ $DRY_RUN -eq 0 ]]; then
    sudo visudo -cf "$SUDOERS_DEST"
fi
install_file "$tmpdir/windows.svg" "$SVG_DEST" "0644" ""

log_ok "Windows menu action installed. No boot settings changed; no reboot requested."
