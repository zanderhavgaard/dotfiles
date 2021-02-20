--[[

     @zanderhavgaard's theme
     based on multicolor theme from github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
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
theme.bar_background                            = theme.dark_grey
theme.bar_foreground                            = theme.white
theme.bar_height                                = dpi(25)
-- configure theme
theme.confdir                                   = os.getenv("HOME") .. "/.config/awesome/themes/zh"
theme.font                                      = "Mononoki Nerd Font 12"
theme.menu_bg_normal                            = theme.black
theme.menu_bg_focus                             = theme.black
theme.bg_normal                                 = theme.black
theme.bg_focus                                  = theme.black
theme.bg_urgent                                 = theme.black
theme.fg_normal                                 = theme.grey
theme.fg_focus                                  = theme.blue
theme.fg_urgent                                 = theme.red
theme.fg_minimize                               = theme.white
theme.border_width                              = dpi(2)
theme.border_normal                             = theme.black_alt
theme.border_focus                              = theme.blue
theme.border_marked                             = theme.cyan
theme.menu_border_width                         = 0
theme.menu_width                                = dpi(130)
theme.menu_submenu_icon                         = theme.confdir .. "/icons/submenu.png"
theme.menu_fg_normal                            = theme.grey
theme.menu_fg_focus                             = theme.blue
theme.menu_bg_normal                            = theme.black_alt
theme.menu_bg_focus                             = theme.black_alt
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 5
theme.gap_single_client                         = false
-- taglist
theme.taglist_fg_focus                          = theme.black
theme.taglist_bg_focus                          = theme.blue_alt
theme.taglist_fg_urgent                         = theme.black
theme.taglist_bg_urgent                         = theme.red
theme.taglist_fg_occupied                       = theme.black
theme.taglist_bg_occupied                       = theme.blue
theme.taglist_fg_empty                          = theme.white
theme.taglist_bg_empty                          = theme.blue
-- bar icons
theme.awesome_icon                              = theme.confdir .. "/icons/awesome.png"
theme.widget_temp                               = theme.confdir .. "/icons/temp.png"
theme.widget_uptime                             = theme.confdir .. "/icons/ac.png"
theme.widget_cpu                                = theme.confdir .. "/icons/cpu.png"
theme.widget_weather                            = theme.confdir .. "/icons/dish.png"
theme.widget_fs                                 = theme.confdir .. "/icons/fs.png"
theme.widget_mem                                = theme.confdir .. "/icons/mem.png"
theme.widget_note                               = theme.confdir .. "/icons/note.png"
theme.widget_note_on                            = theme.confdir .. "/icons/note_on.png"
theme.widget_netdown                            = theme.confdir .. "/icons/net_down.png"
theme.widget_netup                              = theme.confdir .. "/icons/net_up.png"
theme.widget_mail                               = theme.confdir .. "/icons/mail.png"
theme.widget_batt                               = theme.confdir .. "/icons/bat.png"
theme.widget_clock                              = theme.confdir .. "/icons/clock.png"
theme.widget_vol                                = theme.confdir .. "/icons/spkr.png"
-- theme.taglist_squares_sel                       = theme.confdir .. "/icons/squaref.png"
-- theme.taglist_squares_unsel                     = theme.confdir .. "/icons/square.png"
-- layout icons
theme.layout_tile                               = theme.confdir .. "/icons/tile.png"
theme.layout_tilegaps                           = theme.confdir .. "/icons/tilegaps.png"
theme.layout_tileleft                           = theme.confdir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.confdir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.confdir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.confdir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.confdir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.confdir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.confdir .. "/icons/dwindle.png"
theme.layout_max                                = theme.confdir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.confdir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.confdir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.confdir .. "/icons/floating.png"

local markup = lain.util.markup
local separators = lain.util.separators

-- function to create pwerline arrow
local arrow_left = separators.arrow_left
local arrow_right = separators.arrow_right

-- Textclock
os.setlocale(os.getenv("LANG")) -- to localize the clock

-- TODO padding instead of <space> between widgets?
local time_date = wibox.widget.textclock(markup(theme.dark_grey, "  %A %d %B "))
time_date.font = theme.font

-- Calendar
-- theme.cal = lain.widget.cal({
    -- attach_to = { mytextclock },
    -- notification_preset = {
        -- font = "Terminus 10",
        -- fg   = theme.fg_normal,
        -- bg   = theme.bg_normal
    -- }
-- })

local time_clock = wibox.widget.textclock(markup(theme.dark_grey, "  %H:%M "))
time_clock.font = theme.font

-- Weather
theme.weather = lain.widget.weather({
    city_id = 2618425, -- placeholder (London)
    notification_preset = { font = "Terminus 10", fg = theme.fg_normal },
    weather_na_markup = markup.fontfg(theme.font, theme.dark_grey, "N/A "),
    settings = function()
        descr = weather_now["weather"][1]["description"]:lower()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  Copenhagen: " .. descr .. " @ " .. units .. "°C "))
    end
})

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

-- CPU
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  " .. cpu_now.usage .. "% "))
    end
})

-- Coretemp
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, " " .. coretemp_now .. "°C "))
    end
})

-- Battery
-- internal
local battery0 = lain.widget.bat({
    battery = "BAT0",
    settings = function()
        local battery_name = "int"
        local battery_status = "?"
        if bat_now.status == "N/A" then
            battery_status = "unknown"
        elseif bat_now.status == "Discharging" then
            battery_status = " " .. bat_now.perc .. "%"
        elseif bat_now.status == "Charging" then
            battery_status = "ﮣ " .. bat_now.perc .. "%"
        elseif bat_now.status == "Full" then
            battery_status = "  " .. bat_now.perc .. "%"
        end
        battery_status = battery_name .. " " .. battery_status
        widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, " " .. battery_status .. " "))
    end
})
-- external
local battery1 = lain.widget.bat({
    battery = "BAT1",
    settings = function()
        local battery_name = "ext"
        local battery_status = "?"
        if bat_now.status == "N/A" then
            battery_status = "unknown"
        elseif bat_now.status == "Discharging" then
            battery_status = " " .. bat_now.perc .. "%"
        elseif bat_now.status == "Charging" then
            battery_status = "ﮣ " .. bat_now.perc .. "%"
        elseif bat_now.status == "Full" then
            battery_status = "  " .. bat_now.perc .. "%"
        end
        battery_status = battery_name .. " " .. battery_status
        widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, " " .. battery_status .. " "))
    end
})

-- ALSA volume
theme.volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, " 婢 "))
        else
            widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  " .. volume_now.level .. "% "))
        end
    end
})

-- MEM
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.dark_grey, "  " .. mem_now.used .. "M "))
    end
})

-- setup the actual bar
function theme.at_screen_connect(s)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.suit.tile)

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = theme.bar_height, bg = theme.bar_background, fg = theme.bar_foreground })

    -- Add widgets to the wibox
    --
    -- create system specific bar
    if hostname == "nostromo" then
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            -- use expanad = "none" for right,middle,left layout
            -- expand = "none",
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                awesome_icon,
                -- ugly hacky spacers using invisble arrows...
                -- TODO do this more elegantly...
                arrow_right(theme.dark_grey, theme.dark_grey),
                s.mylayoutbox,
                arrow_right(theme.dark_grey, theme.dark_grey),
                arrow_right(theme.dark_grey, theme.blue),
                s.mytaglist,
                arrow_right(theme.blue, theme.dark_grey),
            },
            --s.mytasklist, -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                arrow_left(theme.dark_grey, theme.blue),
                wibox.container.background(time_clock, theme.blue),
                arrow_left(theme.blue, theme.green),
                wibox.container.background(time_date, theme.green),
                arrow_left(theme.green, theme.red),
                wibox.container.background(theme.weather.widget, theme.red),
                arrow_left(theme.red, theme.purple),
                wibox.container.background(theme.volume.widget, theme.purple),
                arrow_left(theme.purple, theme.cyan),
                wibox.container.background(memory.widget, theme.cyan),
                arrow_left(theme.cyan, theme.orange),
                wibox.container.background(cpu.widget, theme.orange),
                arrow_left(theme.orange, theme.black),
                wibox.widget.systray(),
            },
        }

    elseif hostname == "vostok" then
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            -- use expanad = "none" for right,middle,left layout
            -- expand = "none",
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                awesome_icon,
                -- ugly hacky spacers using invisble arrows...
                -- TODO do this more elegantly...
                arrow_right(theme.dark_grey, theme.dark_grey),
                s.mylayoutbox,
                arrow_right(theme.dark_grey, theme.dark_grey),
                arrow_right(theme.dark_grey, theme.blue),
                s.mytaglist,
                arrow_right(theme.blue, theme.dark_grey),
            },
            --s.mytasklist, -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                arrow_left(theme.dark_grey, theme.blue),
                wibox.container.background(time_clock, theme.blue),
                arrow_left(theme.blue, theme.green),
                wibox.container.background(time_date, theme.green),
                arrow_left(theme.green, theme.red),
                wibox.container.background(theme.weather.widget, theme.red),
                arrow_left(theme.red, theme.purple),
                wibox.container.background(theme.volume.widget, theme.purple),
                arrow_left(theme.purple, theme.cyan),
                wibox.container.background(memory.widget, theme.cyan),
                arrow_left(theme.cyan, theme.orange),
                wibox.container.background(cpu.widget, theme.orange),
                arrow_left(theme.orange, theme.blue),
                wibox.container.background(battery0.widget, theme.blue),
                arrow_left(theme.blue, theme.green),
                wibox.container.background(battery1.widget, theme.green),
                arrow_left(theme.green, theme.black),
                wibox.widget.systray(),
            },
        }

    elseif hostname == "sulaco" then
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            -- use expanad = "none" for right,middle,left layout
            -- expand = "none",
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                awesome_icon,
                -- ugly hacky spacers using invisble arrows...
                -- TODO do this more elegantly...
                arrow_right(theme.dark_grey, theme.dark_grey),
                s.mylayoutbox,
                arrow_right(theme.dark_grey, theme.dark_grey),
                arrow_right(theme.dark_grey, theme.blue),
                s.mytaglist,
                arrow_right(theme.blue, theme.dark_grey),
            },
            --s.mytasklist, -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                arrow_left(theme.dark_grey, theme.blue),
                wibox.container.background(time_clock, theme.blue),
                arrow_left(theme.blue, theme.green),
                wibox.container.background(time_date, theme.green),
                arrow_left(theme.green, theme.red),
                wibox.container.background(theme.weather.widget, theme.red),
                arrow_left(theme.red, theme.purple),
                wibox.container.background(theme.volume.widget, theme.purple),
                arrow_left(theme.purple, theme.cyan),
                wibox.container.background(memory.widget, theme.cyan),
                arrow_left(theme.cyan, theme.orange),
                wibox.container.background(cpu.widget, theme.orange),
                arrow_left(theme.orange, theme.blue),
                wibox.container.background(battery0.widget, theme.blue),
                arrow_left(theme.blue, theme.green),
                wibox.container.background(battery1.widget, theme.green),
                arrow_left(theme.green, theme.black),
                wibox.widget.systray(),
            },
        }

    elseif hostname == "prometheus" then
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            -- use expanad = "none" for right,middle,left layout
            -- expand = "none",
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                awesome_icon,
                -- ugly hacky spacers using invisble arrows...
                -- TODO do this more elegantly...
                arrow_right(theme.dark_grey, theme.dark_grey),
                s.mylayoutbox,
                arrow_right(theme.dark_grey, theme.dark_grey),
                arrow_right(theme.dark_grey, theme.blue),
                s.mytaglist,
                arrow_right(theme.blue, theme.dark_grey),
            },
            --s.mytasklist, -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                arrow_left(theme.dark_grey, theme.blue),
                wibox.container.background(time_clock, theme.blue),
                arrow_left(theme.blue, theme.green),
                wibox.container.background(time_date, theme.green),
                arrow_left(theme.green, theme.red),
                wibox.container.background(theme.weather.widget, theme.red),
                arrow_left(theme.red, theme.purple),
                wibox.container.background(theme.volume.widget, theme.purple),
                arrow_left(theme.purple, theme.cyan),
                wibox.container.background(memory.widget, theme.cyan),
                arrow_left(theme.cyan, theme.orange),
                wibox.container.background(cpu.widget, theme.orange),
                arrow_left(theme.orange, theme.black),
                wibox.widget.systray(),
            },
        }
    end

end

return theme






    -- s.mytaglist = awful.widget.taglist({
            -- screen = s,
            -- filter = awful.widget.taglist.filter.all,
            -- buttons = awful.util.taglist_buttons,
            -- style = {
                -- shape = gears.shape.powerline,
            -- },
            -- layout   = {
                -- spacing = -12,
                -- spacing_widget = {
                    -- color  = theme.white,
                    -- shape  = gears.shape.powerline,
                    -- widget = wibox.widget.separator,
                -- },
                -- layout  = wibox.layout.fixed.horizontal
            -- },
            -- widget_template = {
                -- {
                    -- {
                        -- {
                            -- {
                                -- id     = 'index_role',
                                -- widget = wibox.widget.textbox,
                            -- },
                            -- margins = 4,
                            -- widget  = wibox.container.margin,
                        -- },
                        -- bg     = '#dddddd',
                        -- shape  = gears.shape.circle,
                        -- widget = wibox.container.background,
                    -- },
                    -- {
                        -- {
                            -- id     = 'icon_role',
                            -- widget = wibox.widget.imagebox,
                        -- },
                        -- margins = 2,
                        -- widget  = wibox.container.margin,
                    -- },
                    -- {
                        -- id     = 'text_role',
                        -- widget = wibox.widget.textbox,
                    -- },
                    -- layout = wibox.layout.fixed.horizontal,
                -- },
                -- left  = 18,
                -- right = 18,
                -- widget = wibox.container.margin
            -- },
        -- })
