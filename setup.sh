#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$REPO_ROOT/scripts/lib.sh"

USAGE="Usage: setup.sh --device desktop|laptop [--verbose]"
ALLOWED_DEVICES="desktop laptop"
parse_args "$@" || exit 2

log_info "Device selected: $DEVICE"

scripts_to_run=(
    "$REPO_ROOT/scripts/common/install-yay.sh"
    "$REPO_ROOT/scripts/common/install-packages.sh"
    "$REPO_ROOT/scripts/common/install-dotfiles.sh"
    "$REPO_ROOT/scripts/common/docker-setup.sh"
)

shopt -s nullglob
device_scripts=("$REPO_ROOT/scripts/$DEVICE"/*.sh)
shopt -u nullglob

if [[ ${#device_scripts[@]} -gt 0 ]]; then
    log_ok "Found ${#device_scripts[@]} device script(s) in scripts/$DEVICE."
    # Sort for deterministic order.
    IFS=$'\n' device_scripts=($(printf '%s\n' "${device_scripts[@]}" | sort))
    unset IFS
    scripts_to_run+=("${device_scripts[@]}")
else
    log_warn "No scripts found in scripts/$DEVICE. Proceeding with shared scripts only."
fi

log_info "The following scripts will be executed:"
for s in "${scripts_to_run[@]}"; do
    log_info " - ${s#$REPO_ROOT/}"
done

failures=()
for script in "${scripts_to_run[@]}"; do
    if [[ ! -f "$script" ]]; then
        log_error "File not found: $script"
        failures+=("$script (missing)")
        continue
    fi
    log_info "Running: ${script#$REPO_ROOT/}"
    if [[ $VERBOSE -eq 1 ]]; then
        if bash "$script" --device "$DEVICE" --verbose; then
            log_ok "Finished: ${script#$REPO_ROOT/}"
        else
            log_error "Failed: ${script#$REPO_ROOT/}"
            failures+=("$script")
        fi
    else
        if bash "$script" --device "$DEVICE"; then
            log_ok "Finished: ${script#$REPO_ROOT/}"
        else
            log_error "Failed: ${script#$REPO_ROOT/}"
            failures+=("$script")
        fi
    fi
done

if [[ ${#failures[@]} -gt 0 ]]; then
    log_error "Setup complete with ${#failures[@]} failure(s):"
    for f in "${failures[@]}"; do
        log_error " - ${f#$REPO_ROOT/}"
    done
    exit 1
fi

log_ok "Setup process complete!"
log_info "Ensure to reboot to finish setup."
