filetype plugin indent on
syntax on

set number
set relativenumber
set ruler
set wildmenu
set splitbelow
set splitright

set undodir=~/.vim/undo
set undofile
set directory=~/.vim/swapfiles//
set viminfo+=n~/.vim/viminfo

if $TERM == 'linux'
	set background=dark
	colorscheme pablo
else
	colorscheme ron
endif

nnoremap j  gj
nnoremap k  gk
