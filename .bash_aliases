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
