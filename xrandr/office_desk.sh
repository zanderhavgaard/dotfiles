#!/bin/sh
xrandr \
	--output eDP1 --off \
	--output DP2-3 --primary --auto \
	--output DP1 --auto --left-of DP2-3
