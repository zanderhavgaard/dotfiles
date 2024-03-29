--[[
    @zanderhavgaard's theme
    based on multicolor theme from github.com/lcpz
    requires both lain and vicious to be installed
--]]
local gears = require("gears")
local lain = require("lain")
local vicious = require("vicious")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme = {}
-- set some colors
theme.white = "#efefef"
theme.black = "#141A1F"
theme.black_alt = "#1A2128"
theme.grey_alt = "#6B859E"
theme.grey = "#A6B5CB"
theme.blue_alt = "#3890E9"
theme.blue = "#7DBEFF"
theme.purple_alt = "#A359ED"
theme.purple = "#CB96FF"
theme.red_alt = "#EC5252"
theme.red = "#FF9191"
theme.orange_alt = "#C97016"
theme.orange = "#EDA55D"
theme.green_alt = "#5DA713"
theme.green = "#9ACD68"
theme.cyan_alt = "#13AFAF"
theme.cyan = "#6ECFCF"
theme.dark_grey = "#282C36"
theme.background = theme.black
theme.transparent = "alpha"
-- custom vars
theme.bar_background = theme.dark_grey
theme.bar_foreground = theme.white
theme.bar_height = dpi(25)
-- configure theme
theme.confdir = os.getenv("HOME") .. "/.config/awesome/themes/zh"
-- theme.font = "Mononoki Nerd Font 12"
theme.font = "Hack Nerd Font 12"
theme.menu_bg_normal = theme.dark_grey
theme.menu_bg_focus = theme.dark_grey
theme.fg_normal = theme.white
theme.bg_normal = theme.dark_grey
theme.border_normal = theme.black_alt
theme.fg_focus = theme.blue
theme.bg_focus = theme.dark_grey
theme.border_focus = theme.blue
theme.fg_urgent = theme.black
theme.bg_urgent = theme.red
theme.fg_minimize = theme.white
theme.border_width = dpi(2)
theme.border_marked = theme.cyan
theme.menu_border_width = 0
theme.menu_width = dpi(130)
theme.menu_submenu_icon = theme.confdir .. "/icons/submenu.png"
theme.menu_fg_normal = theme.white
theme.menu_fg_focus = theme.blue
theme.menu_bg_normal = theme.dark_grey
theme.menu_bg_focus = theme.dark_grey
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.useless_gap = 5
theme.gap_single_client = false
-- taglist
theme.taglist_fg_focus = theme.black
theme.taglist_bg_focus = theme.blue
theme.taglist_fg_occupied = theme.white
theme.taglist_bg_occupied = theme.dark_grey
theme.taglist_fg_empty = theme.grey_alt
theme.taglist_bg_empty = theme.dark_grey
theme.taglist_fg_urgent = theme.black
theme.taglist_bg_urgent = theme.red
-- bar icons
theme.awesome_icon = theme.confdir .. "/icons/awesome.png"
theme.widget_temp = theme.confdir .. "/icons/temp.png"
theme.widget_uptime = theme.confdir .. "/icons/ac.png"
theme.widget_cpu = theme.confdir .. "/icons/cpu.png"
theme.widget_weather = theme.confdir .. "/icons/dish.png"
theme.widget_fs = theme.confdir .. "/icons/fs.png"
theme.widget_mem = theme.confdir .. "/icons/mem.png"
theme.widget_note = theme.confdir .. "/icons/note.png"
theme.widget_note_on = theme.confdir .. "/icons/note_on.png"
theme.widget_netdown = theme.confdir .. "/icons/net_down.png"
theme.widget_netup = theme.confdir .. "/icons/net_up.png"
theme.widget_mail = theme.confdir .. "/icons/mail.png"
theme.widget_batt = theme.confdir .. "/icons/bat.png"
theme.widget_clock = theme.confdir .. "/icons/clock.png"
theme.widget_vol = theme.confdir .. "/icons/spkr.png"
-- theme.taglist_squares_sel                       = theme.confdir .. "/icons/squaref.png"
-- theme.taglist_squares_unsel                     = theme.confdir .. "/icons/square.png"
-- layout icons
theme.layout_tile = theme.confdir .. "/icons/tile.png"
theme.layout_tilegaps = theme.confdir .. "/icons/tilegaps.png"
theme.layout_tileleft = theme.confdir .. "/icons/tileleft.png"
theme.layout_tilebottom = theme.confdir .. "/icons/tilebottom.png"
theme.layout_tiletop = theme.confdir .. "/icons/tiletop.png"
theme.layout_fairv = theme.confdir .. "/icons/fairv.png"
theme.layout_fairh = theme.confdir .. "/icons/fairh.png"
theme.layout_spiral = theme.confdir .. "/icons/spiral.png"
theme.layout_dwindle = theme.confdir .. "/icons/dwindle.png"
theme.layout_max = theme.confdir .. "/icons/max.png"
theme.layout_fullscreen = theme.confdir .. "/icons/fullscreen.png"
theme.layout_magnifier = theme.confdir .. "/icons/magnifier.png"
theme.layout_floating = theme.confdir .. "/icons/floating.png"

-- if phobos, account for the lower resolution screen
if hostname == "phobos" then
	theme.bar_height = dpi(18)
	theme.font = "Hack Nerd Font 10"
end

local markup = lain.util.markup
local separators = lain.util.separators
local blank_seperator = wibox.widget.textbox("   ")

-- local terminal_button = awful.widget.textbox({
-- markup = "foo",
-- buttons = {
-- 	awful.button({}, 1, nil, function()
-- 		print("Mouse was clicked")
-- 		awful.spawn("alacritty")
-- 	end),
-- },
-- })

local terminal_button = wibox.widget({
	markup = "  ",
	halign = "center",
	valign = "center",
	widget = wibox.widget.textbox,
	font = theme.font,
	fg = theme.fg_normal,
	bg = theme.bg_normal,
})
terminal_button:connect_signal("button::press", function()
	awful.spawn("alacritty")
end)

-- Textclock
os.setlocale(os.getenv("LANG")) -- to localize the clock

-- TODO padding instead of <space> between widgets?
local time_date = wibox.widget.textclock(markup(theme.blue, "  %A %d %B "))
time_date.font = theme.font

-- Calendar widget shown on hover over date
theme.cal = lain.widget.cal({
	attach_to = { time_date },
	notification_preset = {
		font = theme.font,
		fg = theme.fg_normal,
		bg = theme.bg_normal,
	},
})

local time_clock = wibox.widget.textclock(markup(theme.cyan, "  %H:%M "))
time_clock.font = theme.font

-- Weather
-- old weather
-- theme.weather = lain.widget.weather({
-- city_id = 2618425, -- Copenhagen
-- notification_preset = { font = theme.font, fg = theme.fg_normal },
-- weather_na_markup = markup.fontfg(theme.font, theme.dark_grey, "N/A "),
-- settings = function()
-- descr = weather_now["weather"][1]["description"]:lower()
-- units = math.floor(weather_now["main"]["temp"])
-- widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  " .. units .. "°C " .. descr .. " "))
-- end
-- })

-- exec = echo " $(curl -s 'v2n.wttr.in/copenhagen?format=%l:+%C+%t')"
-- format-prefix = "   "

local weather_widget = awful.widget.watch("bash /home/zander/dotfiles/scripts/weather.sh", 5, function(widget, stdout)
	widget:set_markup(markup.fontfg(theme.font, theme.red, stdout))
end)

-- / fs
--[[ commented because it needs Gio/Glib >= 2.54
theme.fs = lain.widget.fs({
    notification_preset = { font = "Terminus 10", fg = theme.fg_normal },
    settings  = function()
        widget:set_markup(markup.fontfg(theme.font, "#80d9d8", string.format("%.1f", fs_now["/"].used) .. "% "))
    end
})
--]]
-- show off awesomewm
local awesome_icon = wibox.widget.imagebox(theme.awesome_icon)

-- Coretemp
-- local temp = lain.widget.temp({
-- settings = function()
-- widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, " " .. coretemp_now .. "°C "))
-- end
-- })

-- Battery
local covenant_battery0 = lain.widget.bat({
	battery = "BAT0",
	settings = function()
		local battery_status = "?"
		if bat_now.status == "N/A" then
			battery_status = "unknown "
		elseif bat_now.status == "Discharging" then
			battery_status = ""
		elseif bat_now.status == "Charging" then
			battery_status = "󰢝 "
		elseif bat_now.status == "Full" then
			battery_status = " "
		end
		battery_status = bat_now.perc .. "% " .. battery_status
		widget:set_markup(markup.fontfg(theme.font, theme.blue_alt, " bat: " .. battery_status .. " "))
	end,
})
local sulaco_battery0 = lain.widget.bat({
	battery = "BAT0",
	settings = function()
		local battery_status = "?"
		if bat_now.status == "N/A" then
			battery_status = "unknown "
		elseif bat_now.status == "Discharging" then
			battery_status = ""
		elseif bat_now.status == "Charging" then
			battery_status = "󰢝 "
		elseif bat_now.status == "Full" then
			battery_status = " "
		end
		battery_status = bat_now.perc .. "% " .. battery_status
		widget:set_markup(markup.fontfg(theme.font, theme.blue_alt, " bat: " .. battery_status .. " "))
	end,
})
-- internal
local vostok_battery0 = lain.widget.bat({
	timeout = 5,
	battery = "BAT0",
	settings = function()
		local battery_name = "int"
		local battery_status = ""
		if bat_now.status == "N/A" then
			battery_status = "unknown "
		elseif bat_now.status == "Discharging" then
			battery_status = ""
		elseif bat_now.status == "Charging" then
			battery_status = "󰢝 "
		elseif bat_now.status == "Full" then
			battery_status = " "
		end
		battery_status = battery_name .. " " .. bat_now.perc .. "%" .. battery_status
		widget:set_markup(markup.fontfg(theme.font, theme.blue_alt, " " .. battery_status .. " "))
	end,
})
-- external
local vostok_battery1 = lain.widget.bat({
	timeout = 5,
	battery = "BAT1",
	settings = function()
		local battery_name = "ext"
		local battery_status = ""
		if bat_now.status == "N/A" then
			battery_status = "unknown "
		elseif bat_now.status == "Discharging" then
			battery_status = ""
		elseif bat_now.status == "Charging" then
			battery_status = "󰢝 "
		elseif bat_now.status == "Full" then
			battery_status = "  "
		end
		battery_status = battery_name .. " " .. bat_now.perc .. "%" .. battery_status
		widget:set_markup(markup.fontfg(theme.font, theme.cyan, " " .. battery_status .. " "))
	end,
})

-- ALSA volume
theme.volume = lain.widget.alsa({
	settings = function()
		if volume_now.status == "off" then
			widget:set_markup(markup.fontfg(theme.font, theme.purple, " 󰖁 "))
		else
			widget:set_markup(markup.fontfg(theme.font, theme.purple, "  " .. volume_now.level .. "% "))
		end
	end,
})

-- CPU
-- local cpu = lain.widget.cpu({
-- settings = function()
-- widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  " .. cpu_now.usage .. "% "))
-- end
-- })
-- MEM
-- local memory = lain.widget.mem({
-- settings = function()
-- widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  " .. mem_now.used .. "M "))
-- end
-- })

keeb_widget = {
	{
		{
			font = theme.font,
			text = "  ",
			widget = wibox.widget.textbox,
		},
		{
			font = theme.font,
			widget = awful.widget.keyboardlayout,
		},
		layout = wibox.layout.fixed.horizontal,
	},
	widget = wibox.container.background,
	fg = theme.orange,
}

local media_widget = awful.widget.watch("bash /home/zander/dotfiles/scripts/sp_status.sh", 5, function(widget, stdout)
	widget:set_markup(markup.fontfg(theme.font, theme.green, " " .. stdout))
end)

local kernel_widget = wibox.widget.textbox()
awful.spawn.easy_async("bash /home/zander/dotfiles/scripts/print_osicon_kernel.sh", function(output)
	-- prometheus runs Manjaro, the others are Arch
	if hostname == "prometheus" then
		kernel_text = "  " .. output .. " "
	else
		kernel_text = "  " .. output .. " "
	end
	kernel_widget.markup = markup.fontfg(theme.font, theme.blue, kernel_text)
end)

-- wifi widget
local vostok_wifi_widget = wibox.widget.textbox()
vicious.register(vostok_wifi_widget, vicious.widgets.wifi, function(widget, args)
	local wifi_text = ""
	if args["{link}"] == 0 then
		wifi_text = "󰖪 "
	else
		wifi_text = "󰖩 " .. args["{ssid}"]
	end
	return markup.fontfg(theme.font, theme.green, " " .. wifi_text .. " ")
end, 10, "wlp4s0")

local phobos_wifi_widget = wibox.widget.textbox()
vicious.register(phobos_wifi_widget, vicious.widgets.wifi, function(widget, args)
	local wifi_text = ""
	if args["{link}"] == 0 then
		wifi_text = "󰖪 "
	else
		wifi_text = "󰖩 " .. args["{ssid}"]
	end
	return markup.fontfg(theme.font, theme.green, " " .. wifi_text .. " ")
end, 10, "wlp3s0")

local sulaco_wifi_widget = wibox.widget.textbox()
vicious.register(vostok_wifi_widget, vicious.widgets.wifi, function(widget, args)
	local wifi_text = ""
	if args["{link}"] == 0 then
		wifi_text = "󰖪 "
	else
		wifi_text = "󰖩 " .. args["{ssid}"]
	end
	return markup.fontfg(theme.font, theme.green, " " .. wifi_text .. " ")
end, 10, "wlp0s20f3")

-- ethernet widget
local vostok_eth_widget = wibox.widget.textbox()
vicious.register(vostok_eth_widget, vicious.widgets.net, function(widget, args)
	local eth_text = ""
	if args["{ip}"] == nil then
		wifi_text = "󰖪 "
	else
		wifi_text = "󰖩 " .. args["{ssid}"]
	end
	return markup.fontfg(theme.font, theme.red, " " .. eth_text .. " ")
end, 10, "enp0s31f6")

local sulaco_eth_widget = wibox.widget.textbox()
vicious.register(vostok_eth_widget, vicious.widgets.net, function(widget, args)
	local eth_text = ""
	if args["{ip}"] == nil then
		eth_text = "󰈂"
	else
		eth_text = "󰈁 " .. args["{ip}"]
	end
	return markup.fontfg(theme.font, theme.red, " " .. eth_text .. " ")
end, 10, "enp0s31f6")

local covenant_dock_eth_widget = wibox.widget.textbox()
vicious.register(vostok_eth_widget, vicious.widgets.net, function(widget, args)
	local eth_text = ""
	if args["{ip}"] == nil then
		eth_text = "󰈂"
	else
		eth_text = "󰈁 " .. args["{ip}"]
	end
	return markup.fontfg(theme.font, theme.red, " " .. eth_text .. " ")
end, 10, "enp5s0u2u4")

-- setup the actual bar
function theme.at_screen_connect(s)
	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.suit.tile)

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(my_table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		height = theme.bar_height,
		bg = theme.bar_background,
		fg = theme.bar_foreground,
	})

	-- Add widgets to the wibox
	--
	-- create system specific bar
	if hostname == "nostromo" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				weather_widget,
				keeb_widget,
				theme.volume.widget,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	elseif hostname == "prometheus" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				weather_widget,
				keeb_widget,
				theme.volume.widget,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	elseif hostname == "phobos" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				keeb_widget,
				theme.volume.widget,
				vostok_eth_widget,
				phobos_wifi_widget,
				vostok_battery0,
				vostok_battery1,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	elseif hostname == "vostok" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				weather_widget,
				keeb_widget,
				theme.volume.widget,
				vostok_eth_widget,
				vostok_wifi_widget,
				vostok_battery0,
				vostok_battery1,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	elseif hostname == "sulaco" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				weather_widget,
				keeb_widget,
				theme.volume.widget,
				vostok_eth_widget,
				vostok_wifi_widget,
				sulaco_battery0,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	elseif hostname == "covenant" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				weather_widget,
				keeb_widget,
				theme.volume.widget,
				vostok_eth_widget,
				covenant_dock_eth_widget,
				vostok_wifi_widget,
				covenant_battery0,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	elseif hostname == "orion" then
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			-- use expanad = "none" for right,middle,left layout
			-- expand = "none",
			{
				-- Left widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytaglist,
				blank_seperator,
				s.mylayoutbox,
			},
			--s.mytasklist, -- Middle widget
			{
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				layout = wibox.layout.fixed.horizontal,
				time_clock,
				time_date,
				media_widget,
				weather_widget,
				keeb_widget,
				theme.volume.widget,
				vostok_eth_widget,
				covenant_dock_eth_widget,
				vostok_wifi_widget,
				covenant_battery0,
				kernel_widget,
				blank_seperator,
				awesome_icon,
				terminal_button,
				blank_seperator,
				wibox.widget.systray(),
			},
		})
	end
end

return theme
