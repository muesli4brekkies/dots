## Environment
# paths 
export PATH="$PATH:/$HOME/.cargo/bin"

## Shell
# duellj prompt stolen from omz
PROMPT=$'%{\e[0;34m%}%B┌─[%b%{\e[0m%}%{\e[1;32m%}%n%{\e[1;34m%}@%{\e[0m%}%{\e[0;36m%}%m%{\e[0;34m%}%B]%b%{\e[0m%} - %b%{\e[0;34m%}%B[%b%{\e[1;37m%}%~%{\e[0;34m%}%B]%b%{\e[0m%} - %{\e[0;34m%}%B[%b%{\e[0;33m%}%!%{\e[0;34m%}%B]%b%{\e[0m%}
%{\e[0;34m%}%B└─%B[%{\e[1;35m%}$%{\e[0;34m%}%B]%{\e[0m%}%b '
RPROMPT='[%*]'
PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '

# History 
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999

histopts=("APPEND_HISTORY" "SHARE_HISTORY" "HIST_EXPIRE_DUPS_FIRST" "EXTENDED_HISTORY")
for o in $histopts; do setopt $o ; done
unset histopts

autoload -Uz select-word-style
select-word-style bash

# Up/down searches history
autoload -U compinit && compinit
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search 
bindkey "^[[B" down-line-or-beginning-search 

# Tab complete 
zstyle ':completion:*' file-sort modification

# No tab beeps
unsetopt LIST_BEEP

## Aliases
# 1=cd ../ 2=cd ../../ etc
for i in {1..5}; do alias $i="cd `printf %.0s../ {1..$i}`"; done      

# Mistake mitigation
# Safer rm
alias rm="rm -vI"
# Safer cp
alias cp="cp -iv"
# Safer mv
alias mv="mv -i"
# Noisy rsync
alias rsync="rsync -rv"

# Config
# Kitty SSH fix
alias kssh="kitty +kitten ssh"
# Pretty ls
alias ls='ls --color="always"'
alias ll="ls -lah"

# Niceties
# Arch update
alias cleanandupdate="sudo reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist; sudo pacman -Syu ; sudo pacman -Qtdq | sudo pacman -Rns -; sudo paccache -vvrk1 "
# Ez startX
alias x="startx"
# Vim term exit
alias :q="exit"
# Achtung
alias alert="echo -e '\a'"
# BitBurner
alias bb="code ~/git/js_ts/butbirner-scripts & npm start --prefix ~/git/js_ts/butbirner-scripts & npm start --prefix ~/git/js_ts/bitburner-src && pkill -P $$"
# Copy file to clipboard
alias clip="xclip -sel c <"

## Plugins
plugins=("syntax-highlighting" "autosuggestions")
zsh_plugin_dir="/usr/share/zsh/plugins/"
for plugin in $plugins; do source ${zsh_plugin_dir}zsh-$plugin/zsh-$plugin.zsh; done
unset zsh_plugin_dir plugins
