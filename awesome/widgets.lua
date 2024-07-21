local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

-- PATHS. Make sure these are correct if stuff breaks
local paths = {
	bat = "BAT0",
	ac = "ADP1",
	wifi = "wlp0s20f3",
}


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
		awful.util.spawn("pavucontrol")
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
		awful.util.spawn("brightnessctl set 1%")
	end),
	awful.button({}, 4, function()
		awful.util.spawn("brightnessctl set +1%")
	end),
	awful.button({}, 5, function()
		awful.util.spawn("brightnessctl set 1%-")
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
-- Brightness
widgets.brightness = wibox.widget {
	buttons = brightness_buttons,
	widget  = awful.widget.watch(
		{ awful.util.shell, "-c", "echo $((($(brightnessctl g)) * 100/($(brightnessctl m))))%" },
		3,
		function(widget, stdout)
			widget:set_markup('<span color="#bdaf4f" size="150%" >✰</span><span baseline-shift="2pt" color="#bdaf4f">~' ..
				stdout .. '</span>')
		end
	)
}

-- Audio
widgets.audio = wibox.widget {
	buttons = audio_buttons,
	widget  = awful.widget.watch(
		"pamixer --get-volume-human",
		2,
		function(widget, stdout)
			widget:set_markup('<span color="#6cb7bd" size="150%" >♫</span><span baseline-shift="2pt" color="#6cb7bd">~' ..
				stdout .. '</span>')
		end
	)
}

-- SSID
widgets.ssid = wibox.widget {
	buttons = wifi_buttons,
	widget  = awful.widget.watch(
		{ awful.util.shell, "-c", "echo $(iw dev " .. paths.wifi .. " link | grep -Po '((?<=SSID: )\\w+|Not connected)') $(iw dev " .. paths.wifi .. " link | grep -Po '(?<=signal: )-\\d+')" },
		5,
		function(widget, stdout)
			local ssid
			local signal
			local colour
			if stdout:find("Not connected.") then
				ssid = stdout
				colour = beautiful.widget.brightRed
			else
				for s in stdout:gmatch("%S+") do
					if ssid == nil then
						ssid = s or "no connection"
					else
						signal = tonumber(s) or -999
					end
				end
				if signal <= -75 then
					colour = beautiful.widget.brightOrange
				elseif signal <= -66 then
					colour = beautiful.widget.yellow
				else
					colour = beautiful.widget.green
				end
			end
			widget:set_markup('<span color="' .. colour .. '">' ..
				ssid ..
				'</span>')
		end
	)
}

-- CPU Use	
widgets.cpu = wibox.widget {
	buttons = cpu_buttons,
	widget  = awful.widget.watch(
		"/home/muesli/.config/awesome/cpustat.sh",
		3,
		function(widget, stdout)
			local use, temp
			for n in stdout:gmatch("%S+") do
				if use == nil then
					use = tonumber(n) or 0
				else
					temp = tonumber(n) or 999
				end
			end
			local u_col, t_col
			if use >= 80 then
				u_col = beautiful.widget.brightRed
			elseif use >= 60 then
				u_col = beautiful.widget.brightOrange
			elseif use >= 40 then
				u_col = beautiful.widget.yellow
			else
				u_col = beautiful.widget.green
			end
			if temp >= 70 then
				t_col = beautiful.widget.brightRed
			elseif temp >= 55 then
				t_col = beautiful.widget.brightOrange
			elseif temp >= 40 then
				t_col = beautiful.widget.yellow
			else
				t_col = beautiful.widget.green
			end
			widget:set_markup(
				'<span color="' .. u_col .. '">' ..
				use ..
				'%~</span><span color="' .. t_col .. '">' ..
				temp ..
				'°C</span>')
		end
	)
}

-- Battery
widgets.bat = wibox.widget {
	widget = awful.widget.watch(
		{ awful.util.shell,
			"-c",
			"f(){ path=/sys/class/power_supply/;/bin/cat $path$1;};echo $(f " ..
			paths.bat ..
			"/energy_full) $(f " ..
			paths.bat ..
			"/energy_now) $(f " ..
			paths.bat ..
			"/power_now) $(f " ..
			paths.bat ..
			"/status) $(f " ..
			paths.ac ..
			"/online)" },
		5,
		function(widget, stdout)
			local full, now, use, status, isplug
			for n in stdout:gmatch("%S+") do
				if full == nil then
					full = tonumber(n) or 0
				elseif now == nil then
					now = tonumber(n) or 1
				elseif use == nil then
					use = tonumber(n) or 0
				elseif status == nil then
					isplug = n == "1" or false
				elseif isplug == nil then
					isplug = n == "1" or false
				end
			end
			local percent   = math.floor(100 * now / full)
			local remaining = "~" ..
				string.format("%02d:%02d", math.floor(now / use), math.floor((now / use - math.floor(now / use)) * 60))
			local bg        = beautiful.bg_normal
			local colour    = beautiful.widget.yellow
			if isplug or status == "Charging" then
				colour = beautiful.widget.green
				remaining = ""
			elseif percent <= 10 then
				colour = beautiful.widget.white
				bg = beautiful.widget.brightRed
			elseif percent <= 20 then
				colour = beautiful.widget.brightOrange
			end
			widget:set_markup('<span background="' .. bg .. '"color="' .. colour .. '">' ..
				percent .. "%" ..
				remaining ..
				'</span>')
		end
	)
}

-- Time and Date
widgets.date = wibox.widget {
	widget = awful.widget.watch(
		"date '+%a %d %b %H:%M'",
		10,
		function(widget, stdout)
			local parts = {}
			for w in stdout:gmatch("%S+") do table.insert(parts, w) end

			local function getColour(str)
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
			end

			widget:set_markup('<span baseline-shift="2pt" color="' .. getColour(parts[1]) .. '">' ..
				parts[1] ..
				'</span><span font-size="x-large">' ..
				parts[2] ..
				'</span><span baseline-shift="2pt" color="' .. getColour(parts[3]) .. '">' ..
				parts[3] ..
				'</span><span font-size="x-large"> ' ..
				parts[4] ..
				'</span>')
		end
	),
}

-- Spacer
widgets.spacer = wibox.widget {
	widget = wibox.widget.textbox,
	markup = ' ',
}

-- /CUSTOM WIDGETS

return widgets
