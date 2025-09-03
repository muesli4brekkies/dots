#!/bin/zsh
## env
export DISTRO=$(awk -F= '/^ID=/ {print $2}' /etc/os-release)
export EDITOR=/usr/bin/vim
export XAUTHORITY="$HOME"/.Xauthority
export QT_QPA_PLATFORM=wayland
if ! grep -q "zfuncs" <<< "$fpath"; then
	find -L "$HOME"/.zsh -type f ! -name '*.zwc' -exec zsh -c 'zcompile -Uz {}' \;
fi
