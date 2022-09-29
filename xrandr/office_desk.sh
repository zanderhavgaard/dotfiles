#!/bin/sh
xrandr \
	--output eDP-1 --primary --mode 1920x1200 --pos 4480x240 --rotate normal \
	--output DP-2-3 --mode 1920x1200 --pos 0x0 --rotate normal \
	--output DP-2-2 --mode 2560x1440 --pos 1920x0 --rotate normal
