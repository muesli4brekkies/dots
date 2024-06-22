local beautiful = require("beautiful")
local wibox = require("wibox")
local vicious = require("vicious")
local gears = require("gears")
local awful = require("awful")


beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Buttons
local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal(
				"request::activate",
				"tasklist",
				{ raise = true }
			)
		end
	end),
	awful.button({}, 2, function(c) c:kill() end),

	awful.button({}, 3, function(c)
		c.maximized = not c.maximized
		c:raise()
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end))

local audio_buttons = gears.table.join(
	awful.button({}, 1, function()
		awful.util.spawn("pavucontrol-qt")
	end),
	awful.button({}, 3, function()
		awful.util.spawn("pactl set-sink-mute 0 toggle")
	end),
	awful.button({}, 4, function()
		awful.util.spawn("pactl set-sink-volume 0 +1%")
	end),
	awful.button({}, 5, function()
		awful.util.spawn("pactl set-sink-volume 0 -1%")
	end))

local wifi_buttons = gears.table.join(
	awful.button({}, 1, function()
		awful.util.spawn("kitty -e bash -c 'nmcli d w l;zsh'")
	end))

local brightness_buttons = gears.table.join(
	awful.button({}, 2, function()
		--awful.util.spawn("brightnessctl set 1")
		awful.util.spawn("brightnessctl set 1")
	end),
	awful.button({}, 4, function()
		awful.util.spawn("brightnessctl set +5%")
		--awful.util.spawn("brightnessctl set +1%")
	end),
	awful.button({}, 5, function()
		awful.util.spawn("brightnessctl set 5%-")
		--awful.util.spawn("brightnessctl set 1%-")
	end))

local cpu_buttons = gears.table.join(
	awful.button({}, 1, function()
		awful.util.spawn("kitty -e btop")
	end))


-- {{{ Wibar

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t) t:view_only() end),
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
	awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)



-- CUSTOM WIDGETS

local widgets = {}
-- Brightness Icon
widgets.bricon = wibox.widget {
	buttons = brightness_buttons,
	markup  = '<span color="#bdaf4f" size="150%" >✰</span>',
	widget  = wibox.widget.textbox,
}

-- Brightness data
widgets.brightnesswidget = wibox.widget {
	buttons = brightness_buttons,
	widget  = wibox.widget.textbox,
}

vicious.register(widgets.brightnesswidget, vicious.widgets.custom,
	function(widget, tab)
		return ('<span color="#bdaf4f">~%s%%</span>'):format(tab.bri)
	end,
	2)

-- Audio Icon
widgets.audcon = wibox.widget {
	buttons = audio_buttons,
	markup  = '<span color="#6cb7bd" size="150%" >♫</span>',
	widget  = wibox.widget.textbox,
}

-- Audio indicator
widgets.audiowidget = wibox.widget {
	buttons = audio_buttons,
	widget  = wibox.widget.textbox,
}

vicious.register(widgets.audiowidget, vicious.widgets.custom,
	function(widget, tab)
		return ('<span color="#6cb7bd">~%s</span>'):format(tab.vol)
	end, 2)



-- SSID
widgets.ssidwidget = wibox.widget {
	buttons = wifi_buttons,
	widget  = wibox.widget.textbox()
}

vicious.register(widgets.ssidwidget, vicious.widgets.wifiiw,
	function(wargs, winfo)
		ssid = winfo["{ssid}"]
		if ssid == 'N/A' then
			colour = beautiful.widget.brightRed
			ssid = "WLAN DOWN"
		elseif winfo["{linp}"] <= 33 then
			colour = beautiful.widget.brightOrange
		elseif winfo["{linp}"] <= 66 then
			colour = beautiful.widget.yellow
		else
			colour = beautiful.widget.green
		end
		return ('<span color="' .. colour .. '">' .. ssid .. '</span>')
	end, 5, "wlp0s20f3")

-- CPU Use	
widgets.cpuwidget = wibox.widget {
	buttons = cpu_buttons,
	widget  = wibox.widget.textbox()
}
vicious.register(widgets.cpuwidget, vicious.widgets.cpu,
	function(widget, args)
		use = args[1]
		if use >= 80 then
			u_col = beautiful.widget.brightRed
		elseif use >= 60 then
			u_col = beautiful.widget.brightOrange
		elseif use >= 40 then
			u_col = beautiful.widget.yellow
		else
			u_col = beautiful.widget.green
		end
		cpu_temp_dat = io.open('/sys/class/thermal/thermal_zone6/temp')
		temp = math.floor((cpu_temp_dat:read() / 1000))
		cpu_temp_dat:close()
		if temp >= 70 then
			t_col = beautiful.widget.brightRed
		elseif temp >= 55 then
			t_col = beautiful.widget.brightOrange
		elseif temp >= 40 then
			t_col = beautiful.widget.yellow
		else
			t_col = beautiful.widget.green
		end
		return '<span color="' .. u_col .. '">' .. use .. '%~</span><span color="' .. t_col .. '">' .. temp ..
		'°C</span>'
	end, 3)

-- Battery
widgets.batwidget = wibox.widget {
	widget = wibox.widget.textbox()
}

vicious.register(widgets.batwidget, vicious.widgets.custom,
	function(widget, tab)
		bg = beautiful.bg_normal
		percent = tab.bat.perc
		status = tab.bat.stat
		if status == '+' or status == "=" then
			colour = beautiful.widget.green
		elseif percent <= 10 then
			colour = beautiful.widget.white
			bg = beautiful.widget.brightRed
		elseif percent <= 20 then
			colour = beautiful.widget.brightOrange
		else
			colour = beautiful.widget.yellow
		end
		return ('<span background="' .. bg .. '"color="' .. colour .. '">' .. percent .. status .. '</span>')
	end, 13)

-- Time and Date

widgets.datewidget = wibox.widget {
	widget = wibox.widget.textbox(),
}
vicious.register(widgets.datewidget, vicious.widgets.custom,
	function(widget, tab)
		date = tab.dat
		parts = {}
		for w in date:gmatch("%S+") do table.insert(parts, w) end
		day = parts[1]
		mon = parts[3]

		function getColour(str)
			if str == "Mon" or str == "Jan" or str == "Aug" then
				return beautiful.widget.red
			elseif str == "Tue" or str == "Feb" or str == "Sep" then
				return beautiful.widget.orange
			elseif str == "Wed" or str == "Mar" or str == "Oct" then
				return beautiful.widget.yellow
			elseif str == "Thu" or str == "Apr" or str == "Nov" then
				return beautiful.widget.green
			elseif str == "Fri" or str == "May" or str == "Dec" then
				return beautiful.widget.blue
			elseif str == "Sat" or str == "Jun" then
				return beautiful.widget.indigo
			else
				return beautiful.widget.violet
			end

			colTab = {
				beautiful.widget.red,
				beautiful.widget.orange,
				beautiful.widget.yellow,
				beautiful.widget.green,
				beautiful.widget.blue,
				beautiful.widget.indigo,
				beautiful.widget.violet,
			}
			return colTab[index]
		end

		daycol = getColour(day)
		moncol = getColour(mon)
		return ('<span baseline-shift="2pt" color="' .. daycol .. '">' .. parts[1] .. '</span><span font-size="x-large">' .. parts[2] .. '</span><span baseline-shift="2pt" color="' .. moncol .. '">' .. parts[3] .. '</span><span font-size="x-large"> ' .. parts[4] .. '</span>')
	end, 1)


-- Spacer
widgets.spacer = wibox.widget {
	widget = wibox.widget.textbox,
	markup = ' ',
}

-- /CUSTOM WIDGETS

return widgets
