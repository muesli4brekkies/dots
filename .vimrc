" compatibility
set term=kitty

" options
set showcmd
set number
set linebreak

" plugins
syntax on

" colour
if $TERM != "linux"
	set termguicolors
	colorscheme catppuccin_mocha
endif
""macros
"yank/paste all to/from clipboard
let @y = 'ggvG$"+yy'
let @p = '"+p'
