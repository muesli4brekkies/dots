black="200020"
red="dc322f"
green="209900"
yellow="cccc00"
blue="268bcc"
magenta="d310d3"
cyan="2aaaaa"
white="ffbf00"

default="ffbf00"

bblack="000e0e"
bred="ff0000"
bgreen="209900"
byellow="ffff00"
bblue="00aaff"
bmagenta="ff00d3"
bcyan="00ffff"
bwhite="fdf6e3"


printf "\033]P0$black"    # Black
printf "\033]P1$red"      # Red
printf "\033]P2$green"    # Green
printf "\033]P3$yellow"   # Brown
printf "\033]P4$blue"     # Blue
printf "\033]P5$magenta"  # Magenta
printf "\033]P6$cyan"     # Cyan
printf "\033]P7$default"  # Default
printf "\033]P8$bblack"
printf "\033]P9$bred"
printf "\033]Pa$bgreen"
printf "\033]Pb$byellow"
printf "\033]Pc$bblue"
printf "\033]Pd$bmagenta"
printf "\033]Pe$bcyan"
printf "\033]Pf$bwhite"
