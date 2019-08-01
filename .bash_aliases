alias ai='arduino-cli'

alias cd='pushd'
alias cd.='popd'
alias cdd='cd ~'

alias open='cmd.exe /C start $1'
alias cpass=copypass
function copypass() {
	pass $1 | clip.exe
}
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
