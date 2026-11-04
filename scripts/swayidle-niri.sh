#!/usr/bin/env bash

# kill any running swayidle processes
killall swayidle >/dev/null 2>&1

swayidle -w \
  timeout 600 '~/dotfiles/scripts/lock.sh' \
  timeout 660 'niri msg action power-off-monitors' \
  resume 'niri msg action power-on-monitors' \
  before-sleep '~/dotfiles/scripts/lock.sh' \
  lock '~/dotfiles/scripts/lock.sh'
