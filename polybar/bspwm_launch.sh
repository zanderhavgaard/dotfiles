#!/usr/bin/env sh

# More info : https://github.com/jaagr/polybar/wiki

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

desktop=$(echo $DESKTOP_SESSION)
count=$(xrandr --query | grep " connected" | cut -d" " -f1 | wc -l)

config="/home/zander/.config/polybar/config"
if [ $(cat /etc/hostname) = "sulaco" ] ; then
    config="/home/zander/.config/polybar/config-sulaco"
if [ $(cat /etc/hostname) = "prometheus" ] ; then
    config="/home/zander/.config/polybar/config-sulaco"
elif [ $(cat /etc/hostname) = "nostromo" ] ; then
    config="/home/zander/.config/polybar/config-nostromo"
fi

# display top bar on all monitors
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload bspwm-top-bar -c "$config" &
done
# display bottom bar on one monitor only
polybar --reload bspwm-bottom-bar -c "$config" &
