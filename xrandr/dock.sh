#!/bin/bash

xrandr \
    --output DP2-1 --mode 1920x1080 --rate 60 --primary --left-of eDP1 \
    --output DP2-3 --mode 1920x1080 --rate 60 --left-of DP2-1
