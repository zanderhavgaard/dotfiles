#!/bin/sh
xrandr \
	--output eDP-1 --primary --mode 1920x1200 --pos 2880x1360 --rotate normal \
	--output DP-1 --off \
	--output HDMI-1 --off \
	--output DP-2 --off \
	--output DP-3 --mode 1920x1200 --pos 2880x160 --rotate normal \
	--output DP-4 --off \
	--output DP-2-1 --off \
	--output DP-2-2 --mode 2560x1440 --pos 1440x0 --rotate right \
	--output DP-2-3 --mode 2560x1440 --pos 0x0 --rotate left
