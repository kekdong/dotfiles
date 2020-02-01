"""""""""""""""""""""""""""""""""""""""""""""""""""
" For Vundle 
""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle.
Plugin 'VundleVim/Vundle.vim'


" for solarized theme
Plugin 'altercation/vim-colors-solarized'
" for vim-airline theme
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

Plugin 'tpope/vim-fugitive'
Plugin 'davidhalter/jedi-vim'
Plugin 'scrooloose/nerdtree'

call vundle#end()
filetype plugin indent on

" Colors
colorscheme solarized
syntax enable           " enalbe syntax processing
set background=dark
" for airline color
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1

" Space & Tabs & Indent
set tabstop=4           " number of visual space per TAB
set softtabstop=4       " number of spaces in tab when editing
set shiftwidth=4        " 
set expandtab           " tabs are spaces 
set smartindent
set autoindent

" UI
set number              " show line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
set scrolloff=3         " Keep 3 context lines above and below the cursor
set ruler               " show the cursor position all the time

" Searching
set incsearch           " search as characters are entered
set hlsearch            " highlight matches

" Movement
" move vertically by visual line
nnoremap j gj
nnoremap k gk
" move to beginning/end of line
"nnoremap B ^
"nnoremap E $
" " $/^ doesn't do anything
"nnoremap $ <nop>
"nnoremap ^ <nop>
" highlight last inserted text
nnoremap gV `[v`]
" usuful backspace in line first 
set backspace=start,indent,eol

inoremap jk <esc>       " jk is excape

