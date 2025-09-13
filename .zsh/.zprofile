#!/bin/zsh
## env
export DISTRO=$(awk -F= '/^ID=/ {print $2}' /etc/os-release)
export XAUTHORITY="$HOME"/.Xauthority
() {
	local zfiles=($(find -L .zsh -type f ! -name "*.zcompdump" -printf "%T@ %p\n" | sort -rn | cut -d' ' -f2))
	if ! grep -Eq '\.zwc$' <<< ${zfiles[1]}; then
		for f in $zfiles; do
			if ! grep -Eq '\.zwc$' <<< $f; then
				echo "zcompiling $f"
				zcompile -Uz $f
			fi
		done
	fi
}
