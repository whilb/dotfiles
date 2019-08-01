syntax on
filetype off                  

set encoding=utf-8
set nocompatible         
set nowrap
"set paste
let g:deoplete#enable_at_startup = 1

""" VUNDLE CONFIGURATION 
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim' "Plugin Manager 

Plugin 'junegunn/fzf.vim'
Plugin 'junegunn/fzf'
Plugin 'tpope/vim-obsession'

""" Dev Support
"Plugin 'universal-ctags/ctags' "necessary for linting and suggesting and stuff
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'Townk/vim-autoclose'
Plugin 'neomake/neomake' "linter, replaces syntastic

"Deoplete Specific
Plugin 'Shougo/deoplete.nvim' "auto completion/suggestion
Plugin 'Shougo/vimproc.vim' "async execution library
Plugin 'roxma/vim-hug-neovim-rpc'
Plugin 'roxma/nvim-yarp'

"Visual
Plugin 'scrooloose/nerdtree'
"Plugin 'majutsushi/tagbar'
Plugin 'vim-airline/vim-airline'
"Plugin 'tpope/vim-fugitive' "git wrapper

"python dev
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nvie/vim-flake8'
Plugin 'SkyLeach/pudb.vim'

"Solidity development
Plugin 'tomlion/vim-solidity'

call vundle#end()

filetype plugin indent on
""" END VUNDLE

"let g:powerline_pycmd='py3'


"set rtp+=/home/will/.local/lib/python2.7/site-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256

""" CONFIG SECTION

""" PYTHON SPECIFIC STUFF 7/31/19
let python_highlight_all=1



" Linenumbers
set number
set ruler
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" auto nerdtree when no args
au vimenter * if !argc() | NERDTree | endif

"set leader
let mapleader = "  "

" tab fix
"set tabstop=4
"set shiftwidth=4
"set smarttab
"set expandtab

" status line
set showcmd
"set laststatus=2

" neomake (code linting)
" Full config: when writing or reading a buffer, and on changes in insert and
" " normal mode (after 1s; no delay when writing).
call neomake#configure#automake('nrwi', 250)
autocmd! BufWritePost,BufEnter * Neomake
let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_scss_enabled_makers = ['scss_lint']
let g:neomake_python_enabled_makers = ['flake8'] ", 'pylint', 'python']
let g:neomake_java_enabled_makers = ['javac', 'mvn']
let g:neomake_arduino_enabled_makers = ['gcc']

" <TAB>: completion.

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <expr><TAB><TAB>  pumvisible() ? "\<C-n><CR>" : "\<TAB>"

" arduino dev

let g:arduino_cmd = '/opt/arduino-1.8.8/arduino'
let g:arduino_dir = '/opt/arduino-1.8.8'
let g:arduino_home_dir = "$HOME/aws"
let g:arduino_run_headless = 1
let g:arduino_args = '--verbose-upload'
let g:arduino_serial_cmd = 'cu -l {port} -s {baud}'
let g:arduino_serial_baud = 9600
let g:arduino_auto_baud = 1
let g:arduino_serial_tmux = 'split-window -d'
let g:arduino_serial_port_globs = ['/dev/ttyS*']

map <F5> mzgg=G`z
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

" Quick shortcuts
inoremap II <Esc>I
inoremap AA <Esc>A
inoremap OO <Esc>O
inoremap CC <Esc>C
inoremap SS <Esc>S
inoremap DD <Esc>dd
inoremap UU <Esc>u

" pane navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

