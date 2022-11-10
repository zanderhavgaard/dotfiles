#!/bin/sh
xrandr \
	--output eDP-1 --primary --mode 1920x1200 --pos 3760x1320 --rotate normal \
	--output DP-1 --off \
	--output HDMI-1 --off \
	--output DP-2 --off \
	--output DP-3 --mode 1920x1080 --pos 3760x240 --rotate normal \
	--output DP-4 --off \
	--output DP-2-1 --off \
	--output DP-2-2 --mode 2560x1440 --pos 1200x240 --rotate normal \
	--output DP-2-3 --mode 1920x1200 --pos 0x0 --rotate right
