from libqtile import bar, widget
from one_dark_colorscheme import colors


class VostokConfig:
    def __init__(self):

        self.config_name = "vostok"

        self.autostart_script = f"/home/zander/.config/qtile/{self.config_name}_autostart.sh"

        self.colors = colors

        # where are wallpapers on this system?
        self.wallpapers = "/home/zander/Nextcloud/Wallpapers/current"

        # config for the bar
        self.bar_config = {
            "size": 24,
            "background": colors["background"],
            "opacity": 0,
            "margin": 0,
        }

        self.top_bar = bar.Bar(
            [
                widget.CurrentLayoutIcon(),
                widget.CurrentLayout(),
                widget.Sep(),
                widget.CurrentScreen(active_text="Focused", inactive_text="Not Focused"),
                widget.Sep(),
                widget.GroupBox(),
                widget.Spacer(),
                widget.Prompt(),
                #  widget.Sep(),
                #  widget.Wlan(),
                widget.Sep(),
                widget.KeyboardLayout(foreground=colors["green"]),
                widget.Sep(),
                widget.TextBox("Vol:"),
                widget.PulseVolume(),
                widget.Sep(),
                widget.TextBox("Battery: 0"),
                widget.Battery(battery=0),
                widget.Sep(),
                widget.TextBox("Battery: 1"),
                widget.Battery(battery=1),
                widget.Sep(),
                widget.Clock(format="%A %d %B %Y | %I:%M:%S %p "),
                widget.Sep(),
                widget.Systray(),
            ],
            size=self.bar_config["size"],
            background=self.bar_config["background"],
            opacity=self.bar_config["opacity"],
            margin=self.bar_config["margin"],
        )
