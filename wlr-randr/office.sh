#!/usr/bin/env bash

wlr-randr \
	--output eDP-1 --pos 2560,1440 --preferred --scale 1.0 \
	--output DP-3 --pos 0,0 --preferred --scale 1.0 \
	--output DP-4 --pos 2560,0 --preferred --scale 1.0

# TODO: does not work ... dock issue?
# wlr-randr \
# 	--output eDP-1 --pos 2560,2160 --preferred --scale 1.0 \
# 	--output DP-7 --pos 0,0 --mode 3840x2160@59.939999 --scale 1.5 \
# 	--output DP-8 --pos 3840,0 --mode 3840x2160@59.939999 --scale 1.5
