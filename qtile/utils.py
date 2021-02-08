from Xlib import display


def get_number_connected_monitors() -> int:
    x_display = display.Display()
    x_screen = x_display.screen()
    x_screen_root = x_screen.root
    res = x_screen_root.xrandr_get_screen_resources()._data

    # Dynamic multiscreen! (Thanks XRandr)
    num_monitors = 0
    for output in res["outputs"]:
        mon = x_display.xrandr_get_output_info(output, res["config_timestamp"])._data
        if mon["num_preferred"]:
            num_monitors += 1

    return num_monitors
