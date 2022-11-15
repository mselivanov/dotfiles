" 1. OS specific

if ($OS == 'Windows_NT')
    set viminfo='10,\"100,:20,%,n$VIM/_viminfo
    set shell=c:\Windows\system32\cmd.exe
    set shellcmdflag=/c
    au GUIEnter * simalt ~x
else
   set shell=/bin/bash
endif

" 2. Generic settings
filetype off
syntax on
set nobackup
set nowritebackup
set noswapfile
set nocompatible " Use Vim defaults (much better!), Vi is for 70's programmers!
set ts=4 " tabstop - how many columns should the cursor move for one tab
set sw=4 " shiftwidth - how many columns should the text be indented
set expandtab " always expands tab to spaces. It is good when peers use different editor.
set wrap " wraps longs lines to screen size
set laststatus=2 " Show the status line even if only one file is being edited
"set statusline=%b\ 0x%Bs
set ruler " Show ruler
set go-=T " Removes the toolbar
" Make command line two lines high
set ch=2

" 3. Plugin setup
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()"

Plug 'doums/darcula'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'arcticicestudio/nord-vim'
call plug#end()

filetype plugin indent on

" 4. Plugin settings
" colorscheme darcula
silent! colorscheme nord 
set termguicolors

" 5. Cursor settings
highlight Cursor guifg=white guibg=grey
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" 6. Working with split windows and tabs
    " 6.1 Working with tabs
    "~~~~~~~~~~~~~~~~~~~~~~~
    "
if version >= 700
    " always enable Vim tabs
    set showtabline=2
    " set tab features just like browser
    " open tab, close tab, next tab, previous tab (just like Chrome and Firefox keyboard shortcuts)
  noremap <C-t> <Esc>:tabnew<CR>
  noremap <C-F4> <Esc>:tabclose<CR>
  noremap <A-Right> <Esc>:tabnext<CR>
  noremap <A-Left> <Esc>:tabprev<CR>
endif

" 6.2 Working with windows 
"~~~~~~~~~~~~~~~~~~~~~~~
" Switch between splits very fast (for multi-file editing) by maximizing target split - http://vim.wikia.com/wiki/VimTip173
noremap <C-J> <C-W>j<C-W>_
noremap <C-K> <C-W>k<C-W>_
noremap <C-H> <C-W>h<C-W>|
noremap <C-L> <C-W>l<C-W>|
noremap <C-=> <C-W>=

" 7 Coc plugin settings 
"~~~~~~~~~~~~~~~~~~~~~~~
" Use Tab/S-Tab for completion navigation
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>
" use <c-space>for trigger completion

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

"~~~~~~~~~~~~~~~~~~~~~~~
