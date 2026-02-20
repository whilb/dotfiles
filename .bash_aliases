alias cdd='cd ~'
alias lh='ls -a'
alias lsdev='cmd.exe /C mode'
alias ll='ls -alrhF'
alias dir='ll | less'

alias lsl=list_sorted
list_sorted() {
	# List directories
	ls $* | grep "^d";
	# List regular files
	ls $* | grep "^-";
	# List everything else (e.g. symbolic links)
	ls $* | grep -v -E "^d|^-|^total"
}


alias modvim='vim ~/.vimrc'

alias vim='nvim'
alias bat="batcat"
alias fixruff="git diff dev... --name-only --diff-filter=d -- '*.py' | xargs ruff check --fix"
alias checkpyright="git diff dev... --name-only --diff-filter=d -- '*.py' | xargs pyright --level error"
