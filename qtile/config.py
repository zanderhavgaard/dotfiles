# Copyright (c) 2020 @zanderhavgaard ~ https://github.com/zanderhavgaard/dotfiles
# Based on the awesomw work of the qtile developers: https://github.com/qtile/qtile
#
#        __         ___
#       /\ \__  __ /\_ \
#     __\ \ ,_\/\_\\//\ \      __
#   /'__`\ \ \/\/\ \ \ \ \   /'__`\
#  /\ \L\ \ \ \_\ \ \ \_\ \_/\  __/
#  \ \___, \ \__\\ \_\/\____\ \____\
#   \/___/\ \/__/ \/_/\/____/\/____/
#        \ \_\
#         \/_/

# qtile imports
from typing import List  # noqa: F401
from libqtile import hook, bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Screen
from libqtile.lazy import lazy

# imports
import socket
import os
import subprocess

# custom imports
import utils
from vostok_config import VostokConfig
from nostromo_config import NostromoConfig
from custom_layouts import custom_layouts

# get the hostname to load specific configuration
host = socket.gethostname()

# create config
if host == "vostok":
    config = VostokConfig()
elif host == "nostromo":
    config = NostromoConfig()
elif host == "sulaco":
    pass
elif host == "prometheus":
    pass


@hook.subscribe.startup_once
def autostart():
    # autostart background applications
    # will only run initial startup
    subprocess.call(config.autostart_script)


# create layouts
layouts = custom_layouts(colors=config.colors)

# set defaults for widgets
widget_defaults = config.widget_defaults
extension_defaults = widget_defaults.copy()


num_monitors = utils.get_number_connected_monitors()
print("num_monitors", num_monitors)

# setup screens
screens = [Screen(top=config.create_top_bar()) for i in range(0, num_monitors)]

# setup modifier keys to avoud ambiguity
key_super = "mod4"
key_alt = "mod1"
key_control = "control"
key_shift = "shift"
key_return = "Return"
key_space = "space"
key_tab = "Tab"

# window management
keys = [
    # Switch between windows in current stack pane
    Key([key_super], "h", lazy.layout.left(), desc="Move focus left in stack pane"),
    Key([key_super], "k", lazy.layout.up(), desc="Move focus down in stack pane"),
    Key([key_super], "j", lazy.layout.down(), desc="Move focus up in stack pane"),
    Key([key_super], "l", lazy.layout.right(), desc="Move focus right in stack pane"),
    # Move windows up or down in current stack
    Key([key_super, key_shift], "h", lazy.layout.shuffle_left(), desc="Move window right in current stack "),
    Key([key_super, key_shift], "k", lazy.layout.shuffle_up(), desc="Move window up in current stack "),
    Key([key_super, key_shift], "j", lazy.layout.shuffle_down(), desc="Move window down in current stack "),
    Key([key_super, key_shift], "l", lazy.layout.shuffle_right(), desc="Move window left in current stack "),
    # increase/decrease size of master
    Key(
        [key_super, key_alt],
        "h",
        lazy.layout.grow(),
        lazy.layout.increase_nmaster(),
        desc="Expand window (MonadTall), increase number in master pane (Tile)",
    ),
    Key(
        [key_super, key_alt],
        "l",
        lazy.layout.shrink(),
        lazy.layout.decrease_nmaster(),
        desc="Shrink window (MonadTall), decrease number in master pane (Tile)",
    ),
    # normalize window size
    Key([key_super], "n", lazy.layout.normalize()),
    # toggle focus on selected window
    Key([key_super], "f", lazy.window.toggle_fullscreen()),
    # toggle floating/tiled for windows
    Key([key_super], "t", lazy.window.toggle_floating()),
    # Switch window focus to other pane(s) of stack
    Key([key_super], key_space, lazy.layout.next(), desc="Switch window focus to other pane(s) of stack"),
    # Swap panes of split stack
    #  Key([key_super, key_shift], key_space, lazy.layout.rotate(), desc="Swap panes of split stack"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    #  Key(
    #  [key_super, key_shift],
    #  key_return,
    #  lazy.layout.toggle_split(),
    #  desc="Toggle between split and unsplit sides of stack",
    #  ),
    # cycle back and forth using tab between group
    Key([key_super], key_tab, lazy.screen.next_group()),
    Key([key_super, key_shift], key_tab, lazy.screen.prev_group()),
    # cycle through layouts
    Key([key_super], "a", lazy.next_layout(), desc="next layouts"),
    Key([key_super, key_shift], "a", lazy.prev_layout(), desc="previous layouts"),
    # close current window
    Key([key_super, key_shift], "q", lazy.window.kill(), desc="Kill focused window"),
]

# manage qtile lifecycle
keys.extend(
    [
        # restart qtile
        Key([key_super, key_shift], "r", lazy.restart(), desc="Restart qtile"),
        # quit qtile to console
        Key([key_super, key_shift, "control"], "q", lazy.shutdown(), desc="Shutdown qtile"),
    ]
)

#  media / brightness keys
keys.extend(
    [
        Key([], "XF86AudioMute", lazy.spawn("amixer set Master toggle")),
        Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset Master '2%-'")),
        Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset Master '2%+'")),
        Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 20")),
        Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 20")),
        Key([], "XF86KbdBrightnessUp", lazy.spawn("xbacklight -inc 20")),
        Key([], "XF86KbdBrightnessDown", lazy.spawn("xbacklight -dec 20")),
    ]
)

# what terminal to use
terminal = "alacritty"
# what application launcher to use
launcher = "rofi -show drun ~/dotfiles/rofi/config"
# TODO fix
# command to cycle new set of wallpapers
cycle_wallpaper = f"feh --randomize --bg -scale {config.wallpapers}"

# launch applications
keys.extend(
    [
        # Launch terminal
        Key([key_super], key_return, lazy.spawn(terminal), desc="Launch terminal"),
        # launch applications
        Key([key_super], "d", lazy.spawn(launcher)),
        # cycle wallpaper
        Key([key_super, key_shift, key_control], key_space, lazy.spawn(cycle_wallpaper)),
    ]
)

# create groups (workspaces)
groups = [Group(i) for i in "1234567890"]

# per group keybinds
for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key([key_super], i.name, lazy.group[i.name].toscreen(), desc="Switch to group {}".format(i.name)),
            # mod1 + shift + letter of group = switch to & move focused window to group
            #  Key(
            #  [key_super, key_shift],
            #  i.name,
            #  lazy.window.togroup(i.name, switch_group=True),
            #  desc="Switch to & move focused window to group {}".format(i.name),
            #  ),
            # Or, use below if you prefer not to switch to that group.
            # mod1 + shift + letter of group = move focused window to group
            Key(
                [key_super, key_shift],
                i.name,
                lazy.window.togroup(i.name),
                desc="move focused window to group {}".format(i.name),
            ),
        ]
    )


# Drag floating layouts.
mouse = [
    Drag([key_super], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([key_super], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([key_super], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        {"wmclass": "confirm"},
        {"wmclass": "dialog"},
        {"wmclass": "download"},
        {"wmclass": "error"},
        {"wmclass": "file_progress"},
        {"wmclass": "notification"},
        {"wmclass": "splash"},
        {"wmclass": "toolbar"},
        {"wmclass": "confirmreset"},  # gitk
        {"wmclass": "makebranch"},  # gitk
        {"wmclass": "maketag"},  # gitk
        {"wname": "branchdialog"},  # gitk
        {"wname": "pinentry"},  # GPG key password entry
        {"wmclass": "ssh-askpass"},  # ssh-askpass
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
