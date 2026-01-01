#!/bin/bash

set -e

TARGET_CONFIG="/etc/tlp.conf"

cat <<EOF | sudo tee "$TARGET_CONFIG" > /dev/null
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

sudo systemctl enable --now tlp.service

sudo tlp start

echo "Done! Battery thresholds updated."
