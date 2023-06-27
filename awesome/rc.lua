--
--  ______                                                         __      __
-- /\  _  \                                                       /\ \  __/\ \  /'\_/`\
-- \ \ \L\ \  __  __  __     __    ____    ___     ___ ___      __\ \ \/\ \ \ \/\      \
--  \ \  __ \/\ \/\ \/\ \  /'__`\ /',__\  / __`\ /' __` __`\  /'__`\ \ \ \ \ \ \ \ \__\ \
--   \ \ \/\ \ \ \_/ \_/ \/\  __//\__, `\/\ \L\ \/\ \/\ \/\ \/\  __/\ \ \_/ \_\ \ \ \_/\ \
--    \ \_\ \_\ \___x___/'\ \____\/\____/\ \____/\ \_\ \_\ \_\ \____\\ `\___x___/\ \_\\ \_\
--     \/_/\/_/\/__//__/   \/____/\/___/  \/___/  \/_/\/_/\/_/\/____/ '\/__//__/  \/_/ \/_/
--
--                         ___
--                       /'___\ __
--    ___    ___     ___ /\ \__//\_\     __
--  /'___\ / __`\ /' _ `\ \ ,__\/\ \  /'_ `\
-- /\ \__//\ \L\ \/\ \/\ \ \ \_/\ \ \/\ \L\ \
-- \ \____\ \____/\ \_\ \_\ \_\  \ \_\ \____ \
--  \/____/\/___/  \/_/\/_/\/_/   \/_/\/___L\ \
--                                      /\____/
--                                      \_/__/
--
-- by @zanderhavgaard ~ https://github.com/zanderhavgaard/dotfiles
-- based on awesome templates from https://github.com/lcpz/awesome-copycats
-- requires both lain and vicious to be installed
-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local vicious = require("vicious")
-- local menubar       = require("menubar")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi = require("beautiful.xresources").apply_dpi

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{
-- setup system specific configs

-- read the hostname
hostname = io.popen("uname -n"):read()

-- defaults
startup_cmds = {}
wallpaper_path = ""

-- load system specific options
if hostname == "nostromo" then
	wallpaper_path = "/home/zander/Nextcloud/Wallpapers/current"
	startup_cmds = {
		"feh --randomize --bg-scale " .. wallpaper_path,
		"picom --config /home/zander/dotfiles/picom/picom.conf",
		"bash /home/zander/dotfiles/i3lock/start_i3lock.sh",
		"nm-applet",
		"volumeicon",
		"nextcloud",
		"/opt/piavpn/bin/pia-client",
		"caffeine",
		"bash /home/zander/.profile",
	}
elseif hostname == "vostok" then
	wallpaper_path = "/home/zander/Nextcloud/Wallpapers/current"
	startup_cmds = {
		"feh --randomize --bg-scale " .. wallpaper_path,
		"picom --config /home/zander/dotfiles/picom/picom.conf",
		"bash /home/zander/dotfiles/i3lock/start_i3lock.sh",
		"nm-applet",
		"volumeicon",
		"nextcloud",
		"/opt/piavpn/bin/pia-client",
		"caffeine",
	}
elseif hostname == "phobos" then
	wallpaper_path = "/home/zander/Nextcloud/Wallpapers/current"
	startup_cmds = {
		"feh --randomize --bg-scale " .. wallpaper_path,
		"picom --config /home/zander/dotfiles/picom/picom.conf",
		"bash /home/zander/dotfiles/i3lock/start_i3lock.sh",
		"nm-applet",
		"volumeicon",
		"nextcloud",
		"/opt/piavpn/bin/pia-client",
		"caffeine",
	}
elseif hostname == "sulaco" then
	wallpaper_path = "/home/zander/Nextcloud/Wallpapers/current"
	startup_cmds = {
		"feh --randomize --bg-scale " .. wallpaper_path,
		"picom --config /home/zander/dotfiles/picom/picom.conf",
		"bash /home/zander/dotfiles/i3lock/start_i3lock.sh",
		"nm-applet",
		"volumeicon",
		"nextcloud",
		"caffeine",
	}
elseif hostname == "narcissus" then
	wallpaper_path = "/home/zander/wallpaper/walls"
	startup_cmds = {
		"feh --randomize --bg-scale " .. wallpaper_path,
		"picom --config /home/zander/dotfiles/picom/picom.conf",
		"bash /home/zander/dotfiles/i3lock/start_i3lock.sh",
		"nm-applet",
		"volumeicon",
		"caffeine",
	}
elseif hostname == "prometheus" then
	wallpaper_path = "/home/zander/wallpaper/walls"
	startup_cmds = {
		"feh --randomize --bg-scale /home/zander/wallpaper/walls",
		"picom --config /home/zander/dotfiles/picom/picom.conf",
		"bash /home/zander/dotfiles/i3lock/start_i3lock.sh",
		"nm-applet",
		"volumeicon",
		"caffeine",
		"bash /home/zander/.profile",
	}
end

-- }}}

-- {{{ Autostart windowless processes
-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

-- the commands to be run on startup
run_once(startup_cmds) -- entries must be separated by commas
-- }}}

-- {{{ Variable definitions

-- choose which theme to use
local theme = "zh"

-- names for each workspace // "tag:
awful.util.tagnames = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

-- setup some default programs
local terminal = "alacritty"
local editor = "nvim"
local editor_cmd = terminal .. " -e " .. editor

-- tell awful to use the right terminal emulator
awful.util.terminal = terminal

-- setup key strings to avoid ambguity and confusion...
local modkey = "Mod4"
local altkey = "Mod1"
local shiftkey = "Shift"
local controlkey = "Control"
local spacekey = "space"
local tabkey = "Tab"
local leftkey = "Left"
local rightkey = "Right"
local downkey = "Down"
local upkey = "Up"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.floating,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,

	-- more layouts from the lain package
	-- lain.layout.cascade,
	-- lain.layout.cascade.tile,
	lain.layout.centerwork,
	-- lain.layout.centerwork.horizontal,
	-- lain.layout.termfair,
	-- lain.layout.termfair.center,
}
-- lain layout config
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = dpi(2)
lain.layout.cascade.tile.offset_y = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

awful.util.taglist_buttons = my_table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

awful.util.tasklist_buttons = my_table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			-- c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({}, 2, function(c)
		c:kill()
	end),
	awful.button({}, 3, function()
		local instance = nil

		return function()
			if instance and instance.wibox.visible then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ theme = { width = dpi(250) } })
			end
		end
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

-- setup theme
beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), theme))
-- }}}

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
	local only_one = #s.tiled_clients == 1
	for _, c in pairs(s.clients) do
		if only_one and not c.floating or c.maximized then
			c.border_width = 0
		else
			c.border_width = beautiful.border_width
		end
	end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
end)
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join( -- show keybindings help
	awful.key({ modkey, shiftkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	-- TODO not sure what this does?
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
	-- By direction client focus
	awful.key({ modkey }, "j", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus down", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus up", group = "client" }),
	awful.key({ modkey }, "h", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus left", group = "client" }),
	awful.key({ modkey }, "l", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus right", group = "client" }),
	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, {
		description = "swap with next client by index",
		group = "client",
	}),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, {
		description = "swap with previous client by index",
		group = "client",
	}),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, {
		description = "focus the previous screen",
		group = "screen",
	}),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	-- Tag browsing super + tab
	awful.key({ modkey }, "Tab", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey, "Shift" }, "Tab", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	-- resize layout
	awful.key({ modkey, altkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, {
		description = "increase master width factor",
		group = "layout",
	}),
	awful.key({ modkey, altkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, {
		description = "decrease master width factor",
		group = "layout",
	}),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, {
		description = "increase the number of master clients",
		group = "layout",
	}),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, {
		description = "decrease the number of master clients",
		group = "layout",
	}),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, {
		description = "increase the number of columns",
		group = "layout",
	}),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, {
		description = "decrease the number of columns",
		group = "layout",
	}),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),
	-- launch terminal
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, {
		description = "open a terminal",
		group = "launcher",
	}), -- restart awesomewm
	awful.key({ modkey, shiftkey }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	-- quit awesomewm
	awful.key({ modkey, controlkey, shiftkey }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	-- cycle wallpaper
	awful.key({ modkey, shiftkey, controlkey }, spacekey, function()
		awful.spawn("feh --randomize --bg-fill " .. wallpaper_path)
	end, { description = "cycle wallpaper", group = "launcher" }),
	-- lauch programs with rofi
	awful.key({ modkey }, "d", function()
		awful.spawn("rofi -show drun ~/dotfiles/rofi/config", { tag = mouse.screen.selected_tag })
	end, { description = "use rofi to launch applications", group = "launcher" }),
	-- lock the screen
	awful.key({ modkey, shiftkey, controlkey }, "l", function()
		awful.spawn("i3lock -c 282C36")
	end, {
		description = "lock the screen",
		group = "launcher",
	}), -- switch keyboard language
	awful.key({ modkey, shiftkey, controlkey }, "d", function()
		awful.spawn("setxkbmap dk")
	end, { description = "switch to dk keyboard", group = "launcher" }),
	awful.key({ modkey, shiftkey, controlkey }, "u", function()
		awful.spawn("setxkbmap us")
	end, {
		description = "switch to us keyboard",
		group = "launcher",
	}), -- screen brightness {{{
	awful.key({ modkey, shiftkey, controlkey }, "s", function()
		awful.spawn("flameshot gui")
	end, {
		description = "take screenshot with flameshot",
		group = "launcher",
	}), -- increase brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("xbacklight -inc 1")
	end, { description = "increase brightness", group = "media controls" }),
	-- decrease brightness
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("xbacklight -dec 1")
	end, {
		description = "decrease brightness",
		group = "media controls",
	}), -- }}}
	-- media contols {{{
	-- play/pause
	awful.key({ modkey, controlkey }, spacekey, function()
		awful.spawn("playerctl play-pause")
	end, { description = "play/pause music", group = "media contols" }),
	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("playerctl play-pause")
	end, {
		description = "play/pause music",
		group = "media contols",
	}), -- next track
	awful.key({ modkey, controlkey }, rightkey, function()
		awful.spawn("playerctl next")
	end, { description = "next track", group = "media contols" }),
	awful.key({}, "XF86AudioNext", function()
		awful.spawn("playerctl next")
	end, {
		description = "next track",
		group = "media contols",
	}), -- previous track
	awful.key({ modkey, controlkey }, leftkey, function()
		awful.spawn("playerctl previous")
	end, { description = "previous track", group = "media contols" }),
	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("playerctl previous")
	end, {
		description = "previous track",
		group = "media contols",
	}), -- increase volume
	awful.key({ modkey, controlkey }, upkey, function()
		awful.spawn("amixer sset Master '2%+'")
	end, { description = "increase up", group = "media contols" }),
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("amixer sset Master '2%+'")
	end, { description = "increase up", group = "media contols" }),
	-- decrease volume
	awful.key({ modkey, controlkey }, downkey, function()
		awful.spawn("amixer sset Master '2%-'")
	end, { description = "decrease volume", group = "media contols" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("amixer sset Master '2%-'")
	end, { description = "decrease volume", group = "media contols" }),
	-- toggle audio mute
	awful.key({}, "XF86AudioMute", function()
		awful.spawn("amixer set Master toggle")
	end, { description = "toggle mute", group = "media controls" }),
	-- toggle mic mute
	awful.key({}, "XF86AudioMicMute", function()
		awful.spawn("amixer set Capture toggle")
	end, { description = "toggle mute", group = "media controls" }) -- }}}
)

clientkeys = my_table.join( -- toggle fullscreen
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }), -- quit window
	awful.key({ modkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }), -- toggle floating
	awful.key({ modkey }, "s", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	-- cycle window through monitors
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	-- toggle maximize / "monocle" for window
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	-- toggle maximize for window, but only vertially in a stack
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	-- toggle maximize horizontally in a stack
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = my_table.join(
		globalkeys, -- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view), -- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle), -- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, descr_move), -- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			size_hints_honor = false,
			maximized_horizontal = false,
			maximized_vertical = false,
			maximized = false,
		},
	}, -- Titlebars
	{
		rule_any = { type = { "dialog", "normal" } },
		properties = { titlebars_enabled = false },
	}, -- Set Firefox to always map on the first tag on screen 1.
	{
		rule = { class = "Firefox" },
		properties = { screen = 1, tag = awful.util.tagnames[1] },
	},
	{
		rule = { class = "Gimp", role = "gimp-image-window" },
		properties = { maximized = true },
	},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = vi_focus })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}
