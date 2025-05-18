#!/bin/bash

xrandr \
    --output DP2-1 --mode 1920x1080 --rate 30 --primary --left-of eDP1 \
    --output DP2-3 --mode 1920x1080 --rate 30 --left-of DP2-1
