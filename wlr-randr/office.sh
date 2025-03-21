#!/usr/bin/env bash

# wlr-randr \
#   --output eDP-1 --pos 2560,1440 --preferred --scale 1.0 \
#   --output DP-7 --pos 0,0 --preferred --scale 1.0 \
#   --output DP-8 --pos 2560,0 --preferred --scale 1.0

wlr-randr \
  --output DP-7 --pos 0,0 --preferred --scale 1.0 --transform 270 \
  --output DP-8 --pos 1440,0 --preferred --scale 1.0 \
  --output eDP-1 --pos 1440,1440 --preferred --scale 1.0

# restart swww-daemon
killall swww-daemon
riverctl spawn 'swww-daemon --format xrgb'
