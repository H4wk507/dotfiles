set nocompatible
set history=1000

filetype on
filetype plugin indent on
syntax on

set shiftwidth=4
set shiftround
set tabstop=4
set softtabstop=4
set expandtab

set relativenumber
set number

set ignorecase
set smartcase
set incsearch

set autoindent
set autochdir
autocmd FileType json setlocal ts=2 sts=2 sw=2

function GitDiff()
    :silent write
    :silent execute '!git diff --color=always -- ' . expand('%:p') . ' | less --RAW-CONTROL-CHARS'
    :redraw!
endfunction

nnoremap <leader>gd :call GitDiff()<cr>
nnoremap <F9> :Black<CR>
noremap <Leader>y "+y
noremap <Leader>p "+p
let g:airline_theme='onedark'
let g:black_linelength="79"

" Install vimplug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Vim plugins
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ambv/black'

call plug#end()
