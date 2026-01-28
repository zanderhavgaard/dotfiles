#!/usr/env/bin bash

# kill any running swayidle processes
killall swayidle >/dev/null 2>&1

swayidle -w \
  timeout 600 'swaylock -f -c 000000' \
  timeout 660 'niri msg action power-off-monitors' \
  resume 'niri msg action power-on-monitors' \
  before-sleep 'swaylock -f -c 000000'
