-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

function os.capture(cmd)
  local handle = assert(io.popen(cmd, 'r'))
  local output = assert(handle:read('*a'))
  handle:close()
  return string.gsub(
    string.gsub(output, '^%s+', ''),
    '%s+$',
    ''
  ):gmatch("[^\r\n]+")
end

local modkey = "Mod4"
local keys = {}

-- Mouse bindings
keys.mouse = {
  root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
  ))
}

-- Key bindings
local globalkeys = gears.table.join(

-- Touchpad Toggle
  awful.key({}, "XF86TouchpadToggle",
    function()
      awful.util.spawn("/home/muesli/.config/awesome/touchpadtoggle.sh")
    end),


  -- Flameshot screenshots
  awful.key({ modkey, "Shift" }, "s",
    function()
      awful.util.spawn("flameshot gui")
    end),

  awful.key({}, "Print",
    function()
      awful.util.spawn("flameshot full")
    end),


  -- Brightness
  awful.key({}, "XF86MonBrightnessDown", function()
    awful.util.spawn("brightnessctl set 1%-")
  end),

  awful.key({}, "XF86MonBrightnessUp", function()
    awful.util.spawn("brightnessctl set +1%")
  end),


  -- Vol and mute
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.util.spawn("pactl set-sink-volume 0 +5%")
  end),

  awful.key({}, "XF86AudioLowerVolume", function()
    awful.util.spawn("pactl set-sink-volume 0 -5%")
  end),

  awful.key({}, "XF86AudioMute", function()
    awful.util.spawn("pactl set-sink-mute 0 toggle")
  end),

  awful.key({}, "XF86AudioMicMute", function()
    awful.util.spawn("pactl set-source-mute 0 toggle")
  end),


  -- Calculator
  awful.key({}, "XF86Calculator", function()
    awful.util.spawn("kcalc")
  end),


  -- Screen switch
  awful.key({ modkey }, "p", function()
    local outstr = ""
    for line in os.capture("xrandr") do
      if line:byte(1) == 32 then goto continue end -- ignore lines starting with spaces
      local screen = line:sub(line:find("%S+"))
      if line:find(" connected ") then
        outstr = outstr .. "xrandr --output " .. screen .. " --auto" .. "&"
      else
        outstr = outstr .. "xrandr --output " .. screen .. " --off" .. "&"
      end
      ::continue::
    end
    os.execute(outstr)
  end),


  -- Touchpad Toggle
  awful.key({ "Mod1" }, "space", function()
    local function getid()
      for line in os.capture("xinput list") do
        if line:find("Touchpad") then
          local i, j = line:find("id=%d+")
          return line:sub(i + 3, j)
        end
      end
    end

    local function toggle(id)
      for line in os.capture("xinput list-props " .. id) do
        if line:match("Device Enabled") then
          if line:find("1$") then
            awful.util.spawn("xinput disable " .. id)
            awful.util.spawn("dunstify 'Touchpad disabled' ")
          else
            awful.util.spawn("xinput enable " .. id)
            awful.util.spawn("dunstify 'Touchpad enabled' ")
          end
          return
        end
      end
    end

    toggle(getid())
  end),


  -- Alt + Escape = CapsLock
  awful.key({ "Mod1" }, "Escape", function()
    awful.util.spawn("xdotool key Caps_Lock")
  end),


  -- Lock
  awful.key({ modkey }, "Escape", function()
    awful.util.spawn("xscreensaver-command -activate")
  end),


  -- show awesome hints
  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),


  -- show awesome menu
  awful.key({ modkey, }, "w", function() mymainmenu:show() end,
    { description = "show main menu", group = "awesome" }),


  -- switch focus
  awful.key({ modkey, }, "Up",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),

  awful.key({ modkey, }, "Down",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),

  awful.key({ modkey, }, "j",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),

  awful.key({ modkey, }, "k",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),

  awful.key({ modkey, }, "Tab",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),

  awful.key({ modkey, }, "`",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),

  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "focus urgent client", group = "client" }),


  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "Down", function() awful.client.swap.byidx(1) end,
    { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "Up", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
    { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
    { description = "focus the previous screen", group = "screen" }),


  -- Launch Terminal
  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey, }, "t", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey, }, "KP_Enter", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),


  -- Restart/Quit Awesome
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    { description = "reload awesome", group = "awesome" }),

  awful.key({ modkey, "Shift" }, "q", awesome.quit,
    { description = "quit awesome", group = "awesome" }),


  -- Adjust horizontal tiling
  awful.key({ modkey, }, "Right", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey, }, "Left", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),


  -- Shift tiles between columns
  awful.key({ modkey, "Shift" }, "Left", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "Right", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "decrease the number of master clients", group = "layout" }),


  -- Adjust number of columns
  awful.key({ modkey, "Control" }, "Left", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "Right", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),


  -- Prompt
  awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
    { description = "run prompt", group = "launcher" }),


  -- dmenu
  awful.key({ modkey }, "d", function() menubar.show() end,
    { description = "show the menubar", group = "launcher" }),


  -- Un-minimise
  awful.key({ modkey, }, "x",
    function()
      local c = awful.client.restore()
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", { raise = true }
        )
      end
    end,
    { description = "restore minimized", group = "client" }),

  awful.key({ modkey, }, "m",
    function()
      local c = awful.client.restore()
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", { raise = true }
        )
      end
    end,
    { description = "restore minimized", group = "client" })
)

keys.clientkeys = gears.table.join(

-- kill client
  awful.key({ modkey, }, "q", function(c) c:kill() end,
    { description = "close", group = "client" }),


  -- minimise
  awful.key({ modkey, }, "n",
    function(c)
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),

  awful.key({ modkey, }, "c",
    function(c)
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),


  -- fullscreen client
  awful.key({ modkey, }, "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),


  -- float tile
  awful.key({ modkey, "Shift" }, "f", awful.client.floating.toggle,
    { description = "toggle floating", group = "client" }),


  -- keep on top
  awful.key({ modkey, "Control" }, "f", function(c) c.ontop = not c.ontop end,
    { description = "toggle keep on top", group = "client" }),


  -- make master client
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    { description = "move to master", group = "client" }),


  -- move to other screen
  awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
    { description = "move to screen", group = "client" }),


  -- toggle maximise
  awful.key({ modkey, }, "e",
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    { description = "(un)maximize", group = "client" }),

  awful.key({ modkey, "Control" }, "e",
    function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end,
    { description = "(un)maximize vertically", group = "client" }),

  awful.key({ modkey, "Shift" }, "e",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end,
    { description = "(un)maximize horizontally", group = "client" })
)

-- Bind 1-3 keys to desktop tags.
for i = 1, 3 do
  globalkeys = gears.table.join(globalkeys,

    -- Switch to tag
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" }),


    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" }),


    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" }),


    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

-- move and resize floating client
keys.clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey, "Shift" }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

keys.all = globalkeys

return keys
