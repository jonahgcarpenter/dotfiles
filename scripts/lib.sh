#!/bin/bash
# Shared helpers for dotfiles setup scripts. Source-only; do not execute.
# shellcheck disable=SC2034

if [[ -z "${NO_COLOR:-}" && -t 1 ]]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    NC=''
fi

DEVICE=""
VERBOSE=0

usage() {
    printf '%s\n' "${USAGE:-Usage: $(basename "$0") --device desktop|laptop [--verbose]}"
}

log_info() {
    printf "${BLUE}[ INFO ] %s${NC}\n" "$*"
}

log_ok() {
    printf "${GREEN}[  OK  ] %s${NC}\n" "$*"
}

log_warn() {
    printf "${YELLOW}[ WARN ] %s${NC}\n" "$*"
}

log_error() {
    printf "${RED}[ ERROR ] %s${NC}\n" "$*" >&2
}

# Run a command quietly unless --verbose was given. On failure the
# captured output is printed so errors are never swallowed.
run() {
    if [[ "${VERBOSE:-0}" -eq 1 ]]; then
        "$@"
        return $?
    fi
    local output status
    output=$("$@" 2>&1)
    status=$?
    if [[ $status -ne 0 ]]; then
        printf '%s\n' "$output" >&2
    fi
    return $status
}

# Parse --device (required), --verbose, --help. Expects ALLOWED_DEVICES
# (space-separated) and USAGE to be set by the caller. Returns 2 on error.
parse_args() {
    DEVICE=""
    VERBOSE=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --device)
                if [[ $# -lt 2 ]]; then
                    log_error "--device requires a value (desktop|laptop)"
                    usage >&2
                    return 2
                fi
                DEVICE="$2"
                shift 2
                ;;
            --device=*)
                DEVICE="${1#--device=}"
                shift
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                usage >&2
                return 2
                ;;
        esac
    done
    if [[ -z "$DEVICE" ]]; then
        log_error "--device is required (--device desktop|laptop)"
        usage >&2
        return 2
    fi
    case "$DEVICE" in
        desktop|laptop) ;;
        *)
            log_error "Invalid --device '$DEVICE' (expected desktop|laptop)"
            usage >&2
            return 2
            ;;
    esac
    if [[ -n "${ALLOWED_DEVICES:-}" ]]; then
        local ok=0 d
        for d in $ALLOWED_DEVICES; do
            if [[ "$d" == "$DEVICE" ]]; then
                ok=1
                break
            fi
        done
        if [[ $ok -eq 0 ]]; then
            log_error "This script does not support --device $DEVICE (allowed: $ALLOWED_DEVICES)"
            return 2
        fi
    fi
    return 0
}
