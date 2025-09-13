## nope out if not interactive
[[ $- != *i* ]] && return
## Options
setopt extendedglob nomatch notify PROMPT_SUBST APPEND_HISTORY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY
unsetopt beep LIST_BEEP
# / delimits words
WORDCHARS=${WORDCHARS/\//}
## History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
## Loading
# load custom functions
fpath+=("$ZDOTDIR/zfuncs")
for f in "$ZDOTDIR"/zfuncs/*~*.zwc; do autoload -Uz "$f"(:t); done
autoload -Uz compinit 
autoload -Uz vcs_info
autoload -U edit-command-line
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
# completion
zstyle :compinstall filename $ZDOTDIR/.zshrc
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
compinit
# git for prompt
precmd() { vcs_info }
zstyle ':vcs_info:git:*' format '%b '
## Bindings
# vim stuff
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
# edit command line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey '^xe' edit-command-line
# Up/down searches history
bindkey "^[[A" up-line-or-beginning-search 
bindkey "^[[B" down-line-or-beginning-search 
# Tab complete 
zstyle ':completion:*' file-sort modification
# Delete key
bindkey "^[[3~" delete-char
## Plugins
case $DISTRO in
	gentoo)
		source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
		source /usr/share/zsh/site-functions/zsh-autosuggestions.zsh
	;;
	arch)
		source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	;;
	debian)
		source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
		source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	;;
esac
## Prompt
. $ZDOTDIR/prompt
## Aliases
# doas <=> sudo
unalias sudo doas 2>/dev/null; command -v sudo >/dev/null && alias doas="sudo" || alias sudo="doas"
# 1=cd ../ 2=cd ../../ etc
for i in {1..5}; do alias $i="cd `printf %.0s../ {1..$i}`"; done      
# Mistake mitigation
alias rm="rm -vI" cp="cp -iv" mv="mv -i"
# Noisy rsync
alias rsync="rsync -v"
# Pretty
command -v lsd >/dev/null && alias ls="lsd" l="lsd -lah"
alias grep="grep --color=auto" diff="diff --color=auto"
# Ez startX
alias x="~/.local/bin/utils gui"
# exits
alias :q="exit" quit="exit"
# Achtung
alias achtung="echo -e \\\a" alert="echo -e \\\a"
# kitty ssh hack
[ $TERM = xterm-kitty ] && alias ssh="kitten ssh"
# hardened kernel steam hack
alias steam="sudo sysctl kernel.unprivileged_userns_clone=1 && steam"
