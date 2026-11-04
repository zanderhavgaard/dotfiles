#!/usr/bin/env bash
# Waybar custom module: shows whether Mullvad and/or NetBird are connected.
# Outputs waybar JSON: {"text", "tooltip", "class"}

JQ=/usr/bin/jq

# click handlers: `vpn-status.sh toggle-netbird` / `toggle-mullvad`
case "${1:-}" in
  toggle-netbird)
    if netbird status --json 2>/dev/null | $JQ -e '.management.connected == true' >/dev/null; then
      exec netbird down
    else
      exec netbird up
    fi
    ;;
  toggle-mullvad)
    if mullvad status -j 2>/dev/null | $JQ -e '.state == "connected" or .state == "connecting"' >/dev/null; then
      exec mullvad disconnect
    else
      exec mullvad connect
    fi
    ;;
esac

mullvad_state="off"
mullvad_detail=""
if command -v mullvad >/dev/null 2>&1; then
  # fails (non-zero) when the daemon isn't running -> treat as off
  if out=$(mullvad status -j 2>/dev/null); then
    mullvad_state=$(printf '%s' "$out" | $JQ -r '.state // "off"')
    mullvad_detail=$(printf '%s' "$out" | $JQ -r '
      [.details.location.city?, .details.location.country?]
      | map(select(. != null and . != "")) | join(", ")' 2>/dev/null)
  fi
fi

netbird_state="off"
netbird_detail=""
if command -v netbird >/dev/null 2>&1; then
  if out=$(netbird status --json 2>/dev/null); then
    netbird_state=$(printf '%s' "$out" | $JQ -r '
      if .management.connected == true then "connected"
      elif (.daemonStatus // "") != "" then (.daemonStatus | ascii_downcase)
      else "off" end')
    netbird_detail=$(printf '%s' "$out" | $JQ -r '
      "\(.fqdn // "?") \(.netbirdIp // "") peers \(.peers.connected // 0)/\(.peers.total // 0)"')
  fi
fi

parts=()
tooltip=()
class="disconnected"

if [[ $mullvad_state == "connected" ]]; then
  parts+=("Mullvad")
  class="connected"
elif [[ $mullvad_state == "connecting" || $mullvad_state == "disconnecting" ]]; then
  parts+=("Mullvad…")
  class="connecting"
fi
tooltip+=("Mullvad: $mullvad_state${mullvad_detail:+ ($mullvad_detail)}")

if [[ $netbird_state == "connected" ]]; then
  parts+=("NetBird")
  [[ $class != "connected" ]] && class="connected"
elif [[ $netbird_state == "connecting" ]]; then
  parts+=("NetBird…")
  [[ $class == "disconnected" ]] && class="connecting"
fi
tooltip+=("NetBird: $netbird_state${netbird_detail:+ ($netbird_detail)}")

if ((${#parts[@]})); then
  text="$(IFS='+'; echo "${parts[*]}") 󰖂"
else
  text="No VPN 󰦞"
fi

$JQ -cn --arg text "$text" --arg tooltip "$(printf '%s\n' "${tooltip[@]}")" --arg class "$class" \
  '{text: $text, tooltip: ($tooltip | rtrimstr("\n")), class: $class}'
