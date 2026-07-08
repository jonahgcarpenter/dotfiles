#!/usr/bin/env bash

interval=2
count=0
dry_run=0
log="$PWD/battery-drain-$(date +%F-%H%M%S).log"

usage() {
  printf 'Usage: %s [--dry-run] [--interval seconds] [--count samples]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --interval)
      interval="$2"
      shift 2
      ;;
    --count)
      count="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

if ! [[ "$interval" =~ ^[0-9]+$ ]] || [ "$interval" -lt 1 ]; then
  echo "Error: --interval must be a positive integer" >&2
  exit 1
fi

if ! [[ "$count" =~ ^[0-9]+$ ]]; then
  echo "Error: --count must be a non-negative integer" >&2
  exit 1
fi

write_sample() {
  {
    echo "===== $(date --iso-8601=seconds) ====="

    for bat in BAT0 BAT1; do
      base="/sys/class/power_supply/$bat"

      if [ -d "$base" ]; then
        echo "[$bat]"
        for f in status capacity energy_now energy_full power_now voltage_now current_now charge_now charge_full; do
          if [ -r "$base/$f" ]; then
            printf "%s=" "$f"
            cat "$base/$f"
          fi
        done
      fi
    done

    if [ -d /sys/class/power_supply/AC ]; then
      echo "[AC]"
      cat /sys/class/power_supply/AC/online 2>/dev/null
    elif [ -d /sys/class/power_supply/ACAD ]; then
      echo "[ACAD]"
      cat /sys/class/power_supply/ACAD/online 2>/dev/null
    fi

    echo
  }
}

if [ "$dry_run" -eq 1 ]; then
  echo "Dry run: printing battery samples every ${interval}s"
  if [ "$count" -eq 0 ]; then
    echo "Press Ctrl+C to stop."
  fi
else
  echo "Logging to: $log"
  echo "Started: $(date --iso-8601=seconds)" >> "$log"
  echo "Interval: ${interval}s" >> "$log"
fi

samples=0

while true; do
  if [ "$dry_run" -eq 1 ]; then
    write_sample
  else
    write_sample >> "$log"
    sync
  fi

  samples=$((samples + 1))
  if [ "$count" -gt 0 ] && [ "$samples" -ge "$count" ]; then
    break
  fi

  sleep "$interval"
done
