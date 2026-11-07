#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: fingerprint.sh --device laptop [--verbose]"
ALLOWED_DEVICES="laptop"
parse_args "$@" || exit 2

log_info "Configuring fingerprint services..."

run sudo systemctl enable --now python3-validity
run sudo systemctl enable --now open-fprintd
run sudo systemctl enable open-fprintd-resume open-fprintd-suspend

enrolled=0
if command -v fprintd-list >/dev/null 2>&1 && fprintd-list "$USER" 2>/dev/null | grep -q .; then
    enrolled=1
    log_ok "Fingerprint already enrolled. Skipping enrollment prompt."
fi

if [[ $enrolled -eq 0 ]]; then
    answer=""
    read -r -p "Enroll fingerprint now? [y/N] " answer || true
    case "$answer" in
        [yY]|[yY][eE][sS])
            log_info "Launching enrollment (follow the sensor prompts)..."
            fprintd-enroll
            ;;
        *)
            log_warn "Skipped fingerprint enrollment."
            ;;
    esac
fi

PAM_FILE="/etc/pam.d/ly"
log_info "Configuring $PAM_FILE..."

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

cat > "$tmpfile" <<'EOL'
#%PAM-1.0

auth       sufficient   pam_unix.so
auth       sufficient   pam_fprintd.so
auth       include      login
-auth      optional     pam_gnome_keyring.so
-auth      optional     pam_kwallet5.so

account    include      login

password   include      login
-password  optional     pam_gnome_keyring.so use_authtok

-session   optional     pam_systemd.so       class=greeter
-session   optional     pam_elogind.so
session    include      login
-session   optional     pam_gnome_keyring.so auto_start
-session   optional     pam_kwallet5.so      auto_start
EOL

if [[ -f "$PAM_FILE" ]] && cmp -s "$tmpfile" "$PAM_FILE"; then
    log_ok "$PAM_FILE already up to date. Skipping."
else
    if [[ -f "$PAM_FILE" && ! -f "$PAM_FILE.bak" ]]; then
        run sudo cp "$PAM_FILE" "$PAM_FILE.bak"
    elif [[ -f "$PAM_FILE.bak" ]]; then
        log_warn "Backup $PAM_FILE.bak already exists. Reusing it."
    fi
    run sudo tee "$PAM_FILE" > /dev/null < "$tmpfile"
    log_ok "$PAM_FILE configured."
fi

HYPRLOCK_PAM="/etc/pam.d/hyprlock"
log_info "Configuring $HYPRLOCK_PAM..."

hypr_tmp=$(mktemp)
trap 'rm -f "$tmpfile" "$hypr_tmp"' EXIT

cat > "$hypr_tmp" <<'EOL'
#%PAM-1.0

# 1. Try Fingerprint first. 'sufficient' means if this succeeds, unlock immediately.
auth       sufficient   pam_fprintd.so

# 2. If fingerprint fails (or is ignored), fall back to system password.
auth       include      system-auth

# Standard authentication includes
account    include      system-auth
password   include      system-auth
session    include      system-auth
EOL

if [[ -f "$HYPRLOCK_PAM" ]] && cmp -s "$hypr_tmp" "$HYPRLOCK_PAM"; then
    log_ok "$HYPRLOCK_PAM already up to date. Skipping."
else
    if [[ -f "$HYPRLOCK_PAM" && ! -f "$HYPRLOCK_PAM.bak" ]]; then
        run sudo cp "$HYPRLOCK_PAM" "$HYPRLOCK_PAM.bak"
    elif [[ -f "$HYPRLOCK_PAM.bak" ]]; then
        log_warn "Backup $HYPRLOCK_PAM.bak already exists. Reusing it."
    fi
    run sudo tee "$HYPRLOCK_PAM" > /dev/null < "$hypr_tmp"
    log_ok "$HYPRLOCK_PAM configured."
fi

log_ok "Fingerprint setup complete!"
