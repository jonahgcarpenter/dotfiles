#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/../lib.sh"

USAGE="Usage: docker-setup.sh --device desktop|laptop [--verbose]"
ALLOWED_DEVICES="desktop laptop"
parse_args "$@" || exit 2

log_info "Configuring Docker service (device: $DEVICE)..."

if systemctl is-enabled --quiet docker.service 2>/dev/null; then
    log_ok "docker.service is already enabled. Skipping enable."
else
    run sudo systemctl enable docker.service
fi

if systemctl is-active --quiet docker.service 2>/dev/null; then
    log_ok "docker.service is already running. Skipping start."
else
    run sudo systemctl start docker.service
fi

if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    log_ok "User '$USER' is already in the 'docker' group. Skipping."
else
    run sudo usermod -aG docker "$USER"
    log_warn "User '$USER' added to the 'docker' group. This takes effect after logout."
fi

log_ok "Docker setup complete!"
