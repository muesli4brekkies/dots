-- My Theme


local theme_assets = require("beautiful.theme_assets")


-- BASICS
local theme                 = {}
theme.fontsize              = 10
theme.fontname              = "IBM Plex Mono Bold "
theme.font                  = theme.fontname .. theme.fontsize
theme.bg_normal             = "#38161f"
theme.bg_focus              = "#621534"
theme.bg_urgent             = "#aa4400"
theme.bg_minimize           = "#222222"
theme.bg_systray            = theme.bg_normal

theme.fg_focus              = "#02d7f2"
theme.fg_urgent             = "#000000"
theme.fg_normal             = "#008c99"
theme.fg_minimize           = "#888888"

theme.useless_gap           = 0
theme.border_width          = 0
theme.border_normal         = "#5e5e5e"
theme.border_focus          = theme.bg_focus
theme.border_marked         = "#eeeeec"

theme.wibar_fg              = "#008c99"
theme.wibar_bg              = "#38161f"
theme.tasklist_disable_icon = "true"
theme.tasklist_align        = "center"

theme.widget                = {
    brightRed    = "#ff0000",
    red          = "#801313",
    brightOrange = "#fa8c05",
    orange       = "#995706",
    yellow       = "#ab8f05",
    green        = "#4a8a4b",
    blue         = "#5eacb5",
    indigo       = "#6e5eb5",
    violet       = "#ab5eb5",
    white        = "#ffffff",
}


theme.awesome_icon          = "/home/muesli/.config/awesome/archmenulogo.png"

-- Generate taglist squares:
local taglist_square_size   = theme.fontsize / 2
theme.taglist_squares_sel   = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_focus
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Variables set for theming notifications:
theme.notification_font     = theme.fontname .. theme.fontsize * 2
theme.notification_bg       = theme.bg_focus
theme.notification_fg       = theme.fg_focus


-- MISC
theme.wallpaper       = "/usr/share/backgrounds/wallpaper.jpg"
theme.taglist_squares = "true"
theme.menu_height     = theme.fontsize * 2
theme.menu_width      = theme.menu_height * 5.5

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80