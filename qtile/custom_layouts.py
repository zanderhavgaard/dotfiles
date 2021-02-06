from libqtile import layout


def custom_layouts(colors: dict) -> list:
    layout_theme = {
        "border_width": 2,
        "margin": 5,
        "border_focus": colors["blue"],
        "border_normal": colors["black"],
        "single_border_width": 0,
        "single_margin": 0,
    }
    return [
        layout.MonadTall(**layout_theme),
        layout.MonadWide(**layout_theme),
        layout.TreeTab(**layout_theme),
        layout.Max(**layout_theme),
        layout.Floating(**layout_theme),
    ]
    #  more layouts to try out
    #  layout.Stack(num_stacks=2),
    #  layout.Bsp(),
    #  layout.Columns(),
    #  layout.Matrix(),
    #  layout.RatioTile(),
    #  layout.Tile(),
    #  layout.VerticalTile(),
    #  layout.Zoomy(),
