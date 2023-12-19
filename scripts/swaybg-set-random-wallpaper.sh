#!/usr/bin/env bash

# kill any running swaybg process
killall swaybg >/dev/null 2>&1

# TODO: figure out how to query a list of wayland output names so a wallpaper can be set for each

# TODO: should the wallpaper location be an argument?

WALLPAPER_PATH="/home/zander/wallpapers"

# get a random filename from the wallpaper directory
WALLPAPER=$(ls "$WALLPAPER_PATH" | shuf -n 1)

exec swaybg --mode fill --image "$WALLPAPER_PATH/$WALLPAPER" --output '*'
