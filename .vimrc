syntax on
filetype off                  

set encoding=utf-8
set nocompatible         
set nowrap
let g:deoplete#enable_at_startup = 1

""" VUNDLE CONFIGURATION 
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim' "Plugin Manager 

Plugin 'junegunn/fzf.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/goyo.vim'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-surround'

""" Dev Support
Plugin 'universal-ctags/ctags'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'Townk/vim-autoclose'
Plugin 'neomake/neomake' "linter, replaces syntastic
Plugin 'APZelos/blamer.nvim'

"Deoplete Specific
Plugin 'Shougo/deoplete.nvim' "auto completion/suggestion
Plugin 'Shougo/vimproc.vim' "async execution library
Plugin 'roxma/vim-hug-neovim-rpc'
Plugin 'roxma/nvim-yarp'

"Visual
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-airline/vim-airline'
Plugin 'jaredgorski/spacecamp'

"python dev
Plugin 'nvie/vim-flake8'
Plugin 'vim-python/python-syntax' "fstring
Plugin 'SkyLeach/pudb.vim'
Plugin 'Vimjas/vim-python-pep8-indent'
Plugin 'jupyter-vim/jupyter-vim'
Plugin 'github/copilot.vim'

"Solidity development
Plugin 'tomlion/vim-solidity'

call vundle#end()

filetype plugin indent on

set laststatus=2
set t_Co=256

""" CONFIG SECTION

set expandtab
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType java setlocal shiftwidth=2 tabstop=2
autocmd FileType c setlocal shiftwidth=2 tabstop=2

let g:python_highlight_all=1
imap <F5> <Esc>:w<CR>:!clear;python %<CR>
let g:python3_host_prog = '/usr/bin/python3'

colorscheme spacecamp

"blamer
let g:blamer_enabled = 1


" Linenumbers
set number
set ruler
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
set relativenumber

" auto nerdtree when no args
au vimenter * if !argc() | NERDTree | endif

"set leader
"let mapleader = " "

" status line
set showcmd

" neomake (code linting)
" Full config: when writing or reading a buffer, and on changes in insert and
" " normal mode (after 1s; no delay when writing).
call neomake#configure#automake('nrwi', 250)
autocmd! BufWritePost,BufEnter * Neomake
let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_python_enabled_makers = ['flake8'] ", 'pylint', 'python']
let g:neomake_java_enabled_makers = ['javac']
let g:neomake_arduino_enabled_makers = ['gcc']

" <TAB>: completion.

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <expr><TAB><TAB>  pumvisible() ? "\<C-n><CR>" : "\<TAB>"


"map <F5> mzgg=G`z
"set term=screen-256color

" quick exit insert mode
inoremap jk <Esc>
inoremap jj <Esc>

" This is the default extra key bindings
let g:fzf_action = {
			\ 'ctrl-t': 'tab split',
			\ 'ctrl-x': 'split',
			\ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
let g:fzf_layout = { 'down': '~40%' }

" In Neovim, you can set up fzf window using a Vim command
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_layout = { 'window': '-tabnew' }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
			\ { 'fg':      ['fg', 'Normal'],
			\ 'bg':      ['bg', 'Normal'],
			\ 'hl':      ['fg', 'Comment'],
			\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
			\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
			\ 'hl+':     ['fg', 'Statement'],
			\ 'info':    ['fg', 'PreProc'],
			\ 'prompt':  ['fg', 'Conditional'],
			\ 'pointer': ['fg', 'Exception'],
			\ 'marker':  ['fg', 'Keyword'],
			\ 'spinner': ['fg', 'Label'],
			\ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

nnoremap fs :vs<CR> :Files<CR>
nnoremap sf :Files<CR>

nnoremap cp :Copilot enable<CR>
nnoremap cpd :Copilot disable<CR>
let g:copilot_enabled = 0

" pane navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

if filereadable(expand("~/.config/nvim/cscope_maps.vim"))
  source ~/.config/nvim/cscope_maps.vim
endif
