#!/usr/bin/env bash
# Lock the session with the quickshell lock screen (quickshell/lock/).
#
# Waits (up to 3s) for niri to confirm the lock, so `swayidle -w ... before-sleep`
# can't let the laptop suspend with the desktop still showing.
# Falls back to swaylock if quickshell isn't answering.

if qs ipc call lock lock >/dev/null 2>&1; then
  for _ in $(seq 30); do
    [[ $(qs ipc call lock isSecure 2>/dev/null) == true ]] && exit 0
    sleep 0.1
  done
fi

exec swaylock -f -c 16161D
