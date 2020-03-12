#!/bin/sh
xrandr \
    --output DisplayPort-0 --primary --mode 2560x1440 --pos 1440x1080 --rotate normal \
    --output DisplayPort-1 --mode 2560x1440 --pos 0x520 --rotate right \
    --output DisplayPort-2 --mode 1920x1080 --pos 1440x0 --rotate normal --output HDMI-A-0 --off
