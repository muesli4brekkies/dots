local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")

-- PATHS. Make sure these are correct if stuff breaks
local paths = {
	bat = "BAT0",
	ac = "ADP1",
	wifi = "wlp0s20f3",
}

local function split(stdout, patt)
	if patt == nil then patt = "%S+" end
	local tbl = {}
	for s in stdout:gmatch(patt) do
		table.insert(tbl, s)
	end
	return tbl
end

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Buttons
local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == awful.client.focus then
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
		awful.spawn("pavucontrol", {
			floating  = true,
			placement = awful.placement.top_right,
		})
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
		if awful.client.focus then
			awful.client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if awful.client.focus then
			awful.client.focus:toggle_tag(t)
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
		{ awful.util.shell, "-c", "echo $((100 * $(brightnessctl g) / $(brightnessctl m)))%" },
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
		{ awful.util.shell,
			"-c",
			"if [[ $(ls /sys/class/net | grep en) ]];then echo Ethernet; else echo -n $(iw dev " .. paths.wifi .. " link | perl -p -e 's/(|dBm)\\n/,\\n/g' | grep -Po 'Not connected|(?<=(SSID|signal):).+' -); fi" },
		5,
		function(widget, stdout)
			local function parse(tab)
				local ssid = tab[1]
				local signal = tonumber(tab[2])
				if ssid == "Ethernet" then return { beautiful.widget.green, "Ethernet" } end
				if ssid == "Not connected" and signal == nil then return { beautiful.widget.brightRed, "no connection" } end
				if signal <= -75 then return { beautiful.widget.brightOrange, ssid } end
				if signal <= -66 then return { beautiful.widget.yellow, ssid } end
				return { beautiful.widget.green, ssid }
			end
			local res = parse(split(stdout, "[^,]+"))
			widget:set_markup('<span color="' .. res[1] .. '">' ..
				res[2] ..
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
			local t = split(stdout)
			use = tonumber(t[1])
			temp = tonumber(t[2])

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
				string.format("%2d", use) ..
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
			"f(){ /bin/cat /sys/class/power_supply/$1;};echo $(f " ..
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
		7,
		function(widget, stdout)
			local t = split(stdout)
			local full = tonumber(t[1])
			local now = tonumber(t[2])
			local use = tonumber(t[3])
			local status = t[4] == "Charging"
			local isplug = t[5] == "1"
			if use == 0 then use = 1 end
			local percent   = math.floor(100 * now / full)
			local remaining = "~" ..
				string.format("%02d:%02d",
					math.floor(now / use) % 24,
					math.floor((now / use - math.floor(now / use)) * 60))
			local bg        = beautiful.bg_normal
			local colour    = beautiful.widget.yellow
			if isplug or status then
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
			local function getColour(str)
				local function has(table, element)
					for _, value in pairs(table) do
						if value == element then return true end
					end
					return false
				end
				if has({ "Mon", "Jan", "Aug" }, str) then return beautiful.widget.red end
				if has({ "Tue", "Feb", "Sep" }, str) then return beautiful.widget.orange end
				if has({ "Wed", "Mar", "Oct" }, str) then return beautiful.widget.yellow end
				if has({ "Wed", "Apr", "Nov" }, str) then return beautiful.widget.green end
				if has({ "Fri", "May", "Dec" }, str) then return beautiful.widget.blue end
				if has({ "Sat", "Jun" }, str) then return beautiful.widget.indigo end
				return beautiful.widget.violet
			end

			local parts = split(stdout)
			widget:set_markup('<span baseline-shift="2pt" color="' .. getColour(parts[1]) .. '">' ..
				parts[1] ..
				'</span><span font-size="x-large">' ..
				parts[2] ..
				'</span><span baseline-shift="2pt" color="' .. getColour(parts[3]) .. '">' ..
				parts[3] ..
				' </span><span font-size="x-large">' ..
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
