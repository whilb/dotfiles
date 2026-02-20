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
Plugin 'neovim/nvim-lspconfig'

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
" Plugin 'tomlion/vim-solidity'

Plugin 'google/vim-jsonnet'

Plugin 'google/vim-maktaba'
Plugin 'bazelbuild/vim-bazel'

Plugin 'stevearc/conform.nvim'

call vundle#end()
" --- Buildifier / Conform Configuration ---

lua << EOF
require("conform").setup({
  formatters_by_ft = {
    bzl = { "buildifier" },
    python = { "black" },
    jsonnet = { "jsonnetfmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "never",
  },
-- format_on_save = false,
})

vim.filetype.add({
  extension = {
    bzl = "bzl",
    bazel = "bzl",
    py = "python",
    jsonnet = "jsonnet",
    libsonnet = "jsonnet",
  },
  filename = {
    ["BUILD"] = "bzl",
    ["WORKSPACE"] = "bzl",
    ["MODULE.bazel"] = "bzl",
  },
})
--vim.g.gutentags_enabled = 0
EOF

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
let g:jsonnet_fmt_on_save = 0


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

let g:gutentags_cache_dir = expand('~/.cache/tags')
let g:gutentags_ctags_extra_args = ['--links=no']
" Prevent gutentags from indexing massive build/vendor directories
let g:gutentags_ctags_exclude = [
      \ 'bazel-*',
      \ '*.git',
      \ 'node_modules',
      \ '.venv',
      \ 'venv',
      \ '__pycache__',
      \ 'dist',
      \ 'build',
      \ '*.git', '*.svg', '*.hg',
      \ '*/tests/*',
      \ 'build',
      \ 'dist',
      \ '*sites/*/files/*',
      \ 'bin',
      \ 'node_modules',
      \ 'bower_components',
      \ 'cache',
      \ 'compiled',
      \ 'docs',
      \ 'example',
      \ 'bundle',
      \ 'vendor',
      \ '*.md',
      \ '*-lock.json',
      \ '*.lock',
      \ 'bundle.js',
      \ 'build.js',
      \ '.*rc*',
      \ '*.json',
      \ '*.min.*',
      \ '*.map',
      \ '*.bak',
      \ '*.zip',
      \ '*.pyc',
      \ '*.class',
      \ '*.sln',
      \ '*.Master',
      \ '*.csproj',
      \ '*.tmp',
      \ '*.csproj.user',
      \ '*.cache',
      \ '*.pdb',
      \ 'tags*',
      \ 'cscope.*',
      \ '*.css',
      \ '*.less',
      \ '*.scss',
      \ '*.exe', '*.dll',
      \ '*.mp3', '*.ogg', '*.flac',
      \ '*.swp', '*.swo',
      \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
      \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
      \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
      \ '.venv',
      \ 'venv',
      \ '__pycache__',
      \ ]

if filereadable(expand("~/.config/nvim/cscope_maps.vim"))
  source ~/.config/nvim/cscope_maps.vim
endif
