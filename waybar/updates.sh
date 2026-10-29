#!/usr/bin/env bash
# Waybar custom module: count of pending pacman updates (via checkupdates,
# which syncs a private db copy and never touches the real one).
# Hidden when nothing is pending. Outputs waybar JSON.

list=$(checkupdates 2>/dev/null)
n=$(printf '%s' "$list" | grep -c .)

if (( n == 0 )); then
  jq -cn '{text: "", tooltip: "System is up to date", class: "none"}'
else
  jq -cn --arg text "$n 󰏔" --arg tooltip "$list" '{text: $text, tooltip: $tooltip, class: "pending"}'
fi
