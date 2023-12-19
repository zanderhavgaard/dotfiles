#!/usr/bin/env bash

# kill any running swayidle processes
killall swayidle >/dev/null 2>&1

swayidle -w \
	timeout 600 'swaylock -f -c 000000' \
	before-sleep 'swaylock -f -c 000000'

# swayidle -w \
# 	timeout 300 'swaylock -f -c 000000' \
# 	timeout 600 'swaymsg "output * power off"' \
# 	resume 'swaymsg "output * power on"' \
# 	before-sleep 'swaylock -f -c 000000'
