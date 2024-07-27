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
			widget:set_markup(
				string.format('<span color="%s"><span size="150%%">✰</span><span baseline-shift="2pt">~%s</span></span>',
					beautiful.widget.lightYellow, stdout))
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
			widget:set_markup(
				string.format('<span color="%s"><span size="150%%">♫</span><span baseline-shift="2pt">~%s</span></span>',
					beautiful.widget.lightBlue, stdout))
		end
	)
}

-- SSID
widgets.ssid = wibox.widget {
	buttons = wifi_buttons,
	widget  = awful.widget.watch(
		{ awful.util.shell,
			"-c",
			"for f in $(ls /sys/class/net | tr '\\n' ' '); do if [[ -z $(grep -E ^w - <<< $f) ]]; then read etdev <<< $f; else read widev <<< $f; fi; done;if [[ 'up' = $(cat /sys/class/net/$etdev/operstate) ]]; then echo Ethernet; else iw dev $widev link | grep -Po 'Not connected|(?<=(SSID|signal):).+' - | { read ssid; read sig; }; echo \"$ssid\",$(tr -d 'dBm' <<< \"$sig\"); fi"
		},
		5,
		function(widget, stdout)
			local function parse(tab)
				local ssid = tab[1]
				local signal = tonumber(tab[2])
				if ssid == "Ethernet\n" and signal == nil then return { beautiful.widget.green, "Ethernet" } end
				if ssid == "Not connected" and signal == nil then return { beautiful.widget.brightRed, "no connection" } end
				if signal <= -75 then return { beautiful.widget.brightOrange, ssid } end
				if signal <= -66 then return { beautiful.widget.yellow, ssid } end
				return { beautiful.widget.green, ssid }
			end
			local res = parse(split(stdout, "[^,]+"))
			widget:set_markup(string.format('<span color="%s">%s</span>', res[1], res[2]))
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
			local function col_use(use)
				if use >= 80 then return beautiful.widget.brightRed end
				if use >= 60 then return beautiful.widget.orange end
				if use >= 40 then return beautiful.widget.yellow end
				return beautiful.widget.green
			end
			local function col_temp(temp)
				if temp >= 70 then return beautiful.widget.brightRed end
				if temp >= 55 then return beautiful.widget.orange end
				if temp >= 40 then return beautiful.widget.yellow end
				return beautiful.widget.green
			end
			local tab = split(stdout)
			widget:set_markup(
				string.format(
					'<span color="%s">%s%%~</span><span color="%s">%s°C</span>',
					col_use(tonumber(tab[1])),
					string.format("%2d", tab[1]),
					col_temp(tonumber(tab[2])),
					tab[2])
			)
		end
	)
}

-- Battery
widgets.bat = wibox.widget {
	widget = awful.widget.watch(
		{ awful.util.shell,
			"-c",
			string.format("f(){ /bin/cat /sys/class/power_supply/$1;};echo $(f %s/energy_full) $(f %s/energy_now) $(f %s/power_now) $(f %s/status) $(f %s/online)",
				paths.bat,
				paths.bat,
				paths.bat,
				paths.bat,
				paths.ac)
		},
		7,
		function(widget, stdout)
			local function remaining(plugged, now, use)
				if plugged then return "" end
				if use == 0 then use = 1 end
				return "~" ..
					string.format("%02d:%02d",
						math.floor(now / use) % 24,
						math.floor((now / use - math.floor(now / use)) * 60))
			end
			local function get_style(percent, plugged)
				if plugged and percent ~= 100 then return beautiful.bg_normal .. '"color="' .. beautiful.widget.blue end
				if percent < 11 then return beautiful.widget.brightRed .. '"color="' .. beautiful.widget.white end
				if percent < 21 then return beautiful.bg_normal .. '"color="' .. beautiful.widget.orange end
				if percent < 51 then return beautiful.bg_normal .. '"color="' .. beautiful.widget.yellow end
				return beautiful.bg_normal .. '"color="' .. beautiful.widget.green
			end
			local t = split(stdout)
			local full = tonumber(t[1])
			local now = tonumber(t[2])
			local use = tonumber(t[3])
			local plugged = t[4] == "Charging" or t[5] == "1"
			local percent = math.floor(100 * now / full)
			widget:set_markup(string.format('<span background="%s">%s%%%s</span>',
				get_style(percent, plugged),
				percent,
				remaining(plugged, now, use)))
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
				local function has(table, element, i)
					local i = i or 1
					if table[i] == element then return true elseif i < #table then has(table, element, i + 1) else return false end
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
			widget:set_markup(string.format(
				'<span baseline-shift="2pt" color="%s">%s</span><span font-size="x-large">%s</span><span baseline-shift="2pt" color="%s">%s </span><span font-size="x-large">%s</span>',
				getColour(parts[1]),
				parts[1],
				parts[2],
				getColour(parts[3]),
				parts[3],
				parts[4]
			))
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
