#!/usr/bin/env bash

bat0="/sys/class/power_supply/BAT0"
bat1="/sys/class/power_supply/BAT1"
ac="/sys/class/power_supply/AC/online"

energy_now=0
energy_full=0
status=""

for bat in "$bat0" "$bat1"; do
  if [ -d "$bat" ]; then
    now=$(<"$bat/energy_now")
    full=$(<"$bat/energy_full")
    bat_status=$(<"$bat/status")

    energy_now=$((energy_now + now))
    energy_full=$((energy_full + full))

    if [ "$bat_status" = "Charging" ]; then
      status="charging"
    elif [ "$bat_status" = "Discharging" ] && [ "$status" != "charging" ]; then
      status="discharging"
    fi
  fi
done

if [ "$energy_full" -eq 0 ]; then
  echo '{"text":"bat ?", "tooltip":"No battery data", "class":"critical"}'
  exit 0
fi

percent=$((energy_now * 100 / energy_full))

plugged=0
if [ -r "$ac" ]; then
  plugged=$(<"$ac")
fi

icon="󰁹"
class="good"

if [ "$plugged" = "1" ]; then
  icon=""
  class="charging"
elif [ "$percent" -le 15 ]; then
  icon="󰁺"
  class="critical"
elif [ "$percent" -le 30 ]; then
  icon="󰁼"
  class="warning"
fi

tooltip="Internal: $(<"$bat0/capacity")% $(<"$bat0/status")\\nExternal: $(<"$bat1/capacity")% $(<"$bat1/status")"

printf '{"text":"%s%% %s","tooltip":"%s","class":"%s"}\n' "$percent" "$icon" "$tooltip" "$class"
