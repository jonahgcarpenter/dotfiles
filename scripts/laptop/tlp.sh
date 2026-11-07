#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: tlp.sh --device laptop [--verbose]"
ALLOWED_DEVICES="laptop"
parse_args "$@" || exit 2

log_info "Configuring TLP battery thresholds..."

TARGET_CONFIG="/etc/tlp.conf"

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

cat > "$tmpfile" <<EOF
# BAT0: Internal battery
# Battery charge level below which charging will begin.
START_CHARGE_THRESH_BAT0=85
# Battery charge level above which charging will stop.
STOP_CHARGE_THRESH_BAT0=95

# BAT1: External battery
# Battery charge level below which charging will begin.
START_CHARGE_THRESH_BAT1=85
# Battery charge level above which charging will stop.
STOP_CHARGE_THRESH_BAT1=95
EOF

if [[ -f "$TARGET_CONFIG" ]] && cmp -s "$tmpfile" "$TARGET_CONFIG"; then
    log_ok "TLP config already up to date. Skipping write."
else
    run sudo tee "$TARGET_CONFIG" > /dev/null < "$tmpfile"
    log_ok "TLP config updated."
fi

if systemctl is-enabled --quiet tlp.service 2>/dev/null; then
    log_ok "tlp.service is already enabled. Skipping enable."
else
    run sudo systemctl enable tlp.service
fi

run sudo systemctl start tlp.service

log_ok "Battery thresholds configured!"
