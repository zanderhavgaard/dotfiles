#!/usr/bin/env bash

wallpaper_path="$HOME/wallpapers"
wallpaper=$(ls ${wallpaper_path} | shuf -n 1)
awww img --transition-type any "${wallpaper_path}/$wallpaper"
