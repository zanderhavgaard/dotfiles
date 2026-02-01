#!/usr/bin/env bash

# add background systemd units as dependencies of niri-session
#
# Note that the mako and waybar units are provided by the packages
# the rest are symlinked from this directory via the systemd symlink script
#
# NOTE:
# some of these apps might have autostart entries,
# which should remove in order to avoid starting them twice, in these locations:
# * ~/.config/autostart/
# * /etc/xdg/autostart/

systemctl --user daemon-reload
systemctl --user add-wants niri.service mako.service
systemctl --user add-wants niri.service waybar.service
systemctl --user add-wants niri.service kanshi.service
systemctl --user add-wants niri.service swww.service
systemctl --user add-wants niri.service swayidle.service
