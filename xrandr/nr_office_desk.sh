#!/bin/sh
xrandr \
    --output eDP1 --primary --mode 1920x1080 --pos 4000x435 --rotate normal \
    --output DP1 --mode 2560x1440 --pos 0x0 --rotate left \
    --output HDMI2 --mode 2560x1440 --pos 1440x435 --rotate normal
