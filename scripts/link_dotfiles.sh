#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link_dotfile() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"

  # Resolve absolute path of source
  local resolved_src
  resolved_src="$(realpath "$src")"

  # Expand ~ manually for dest
  eval dest="$dest"

  if [ -L "$dest" ]; then
    local current_target
    current_target="$(realpath "$dest")"
    if [ "$current_target" = "$resolved_src" ]; then
      echo "[✔] $dest already correctly linked"
      return
    else
      echo "[~] $dest is a symlink to $current_target — replacing with $resolved_src"
      rm "$dest"
    fi
  elif [ -e "$dest" ]; then
    local backup="${dest}.bak.1"
    echo "[!] $dest exists (not a symlink) — backing up to $backup"
    mv "$dest" "$backup"
  fi

  echo "[*] Linking $resolved_src -> $dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$resolved_src" "$dest"
}


link_dotfiles() {
	link_dotfile .bashrc ~/.bashrc
	link_dotfile .bash_aliases ~/.bash_aliases
	link_dotfile .bash_profile ~/.bash_profile

	link_dotfile .tmux.conf ~/.tmux.conf
	link_dotfile .dircolors ~/.dircolors

	mkdir -pv ~/.config/nvim
	link_dotfile .vimrc ~/.config/nvim/init.vim
}
