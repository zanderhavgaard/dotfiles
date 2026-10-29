#!/usr/bin/env bash
# Waybar custom module: TLP power profile, power source, charge thresholds, fan.
# Read-only; everything comes from sysfs so no root is needed.
# Outputs waybar JSON: {"text", "tooltip", "class"}

profile=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo unknown)
if [[ $(cat /sys/class/power_supply/AC/online 2>/dev/null) == 1 ]]; then
  source=AC
else
  source=BAT
fi

case $profile in
  performance) icon="󱓞" ;;
  balanced)    icon="󰗕" ;;
  low-power)   icon="󰌪" ;;
  *)           icon="󱐋" ;;
esac

start=$(cat /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null)
end=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null)
fan=""
for d in /sys/class/hwmon/hwmon*; do
  [[ $(cat "$d/name" 2>/dev/null) == thinkpad && -r $d/fan1_input ]] && { fan=$(cat "$d/fan1_input"); break; }
done

tooltip="TLP: $profile ($source)"
[[ -n $start && -n $end ]] && tooltip+=$'\n'"Charge thresholds: ${start}–${end}%"
[[ -n $fan && $fan != 0 ]] && tooltip+=$'\n'"Fan: ${fan} rpm"

jq -cn --arg text "$icon" --arg tooltip "$tooltip" --arg class "$profile" \
  '{text: $text, tooltip: $tooltip, class: $class}'
