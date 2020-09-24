#!/usr/bin/env sh

# More info : https://github.com/jaagr/polybar/wiki

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

desktop=$(echo $DESKTOP_SESSION)
count=$(xrandr --query | grep " connected" | cut -d" " -f1 | wc -l)

if type "xrandr" > /dev/null; then
    # use sulaco specific bar
    if [ $(cat /etc/hostname) = "sulaco" ] ; then
        # top bar on all monitors
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload bspwm-top-bar -c ~/.config/polybar/config-sulaco &
        done
        # bottom bar only on laptop screen
        polybar --reload bspwm-bottom-bar -c ~/.config/polybar/config-sulaco &
    # for all other systems, use generic
    else
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload bspwm-top-bar -c ~/.config/polybar/config &
        done
        polybar --reload bspwm-bottom-bar -c ~/.config/polybar/config &
    fi
else
    polybar --reload bspwm-bar -c ~/.config/polybar/config &
fi
