from libqtile import bar, widget
from one_dark_colorscheme import colors


class VostokConfig:
    def __init__(self):

        self.config_name = "vostok"

        self.autostart_script = f"/home/zander/.config/qtile/{self.config_name}_autostart.sh"

        self.colors = colors

        self.font = "Mononoki Nerd Font"

        # where are wallpapers on this system?
        self.wallpapers = "/home/zander/Nextcloud/Wallpapers/current"

        # config for the bar
        self.bar_config = {
            "size": 24,
            "background": colors["background"],
            "opacity": 0,
            "margin": 0,
        }

        self.widget_defaults = {"font": self.font, "fontsize": 12, "padding": 10}

    def create_top_bar(self) -> bar.Bar:
        battery_config = {
            "charge_char": "",
            "discharge_char": "",
            "empty_char": " ",
        }

        _bar = bar.Bar(
            [
                widget.CurrentLayoutIcon(),
                widget.CurrentLayout(),
                widget.Sep(),
                widget.GroupBox(padding=5),
                widget.Spacer(),
                widget.Prompt(),
                #  widget.Sep(),
                #  widget.Wlan(),
                widget.KeyboardLayout(),
                widget.PulseVolume(),
                widget.Battery(**battery_config, format="int {char} {percent:2.0%}", battery=0),
                widget.Battery(**battery_config, format="ext {char} {percent:2.0%}", battery=1),
                widget.Clock(format=" %A %d %B %Y"),
                widget.Clock(format=" %I:%M:%S %p"),
                widget.QuickExit(default_text="[ exit ]"),
                widget.Sep(),
                widget.Systray(),
            ],
            size=self.bar_config["size"],
            background=self.bar_config["background"],
            opacity=self.bar_config["opacity"],
            margin=self.bar_config["margin"],
        )

        return _bar
