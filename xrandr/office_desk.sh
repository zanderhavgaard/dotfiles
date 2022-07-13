#!/bin/sh
xrandr \
	--output eDP1 --off \
	--output DP2-3 --mode 2560x1440 --rate 30 \
	--output DP2-1 --mode 1920x1080 --rate 30 --left-of DP2-3
