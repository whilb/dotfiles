#!/usr/bin/env bash
set -e

install_ctags() {
  echo "[*] Installing ctags..."

  if command -v ctags >/dev/null; then
    echo "[✔] ctags already installed at $(command -v ctags)"
    return
  fi

  case "$(uname -s)" in
    Darwin)
      brew install universal-ctags
      ;;

    Linux)
      if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y universal-ctags || sudo apt install -y exuberant-ctags
      elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy --noconfirm ctags
      elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y ctags
      else
        echo "[!] Unsupported Linux distro"
        exit 1
      fi
      ;;

    *)
      echo "[!] Unsupported platform: $(uname -s)"
      exit 1
      ;;
  esac

  echo "[✔] ctags installed."
}

install_nvim() {
	echo "[*] Checking for Neovim..."

	if command -v nvim >/dev/null; then
		echo "[✔] Neovim is already installed at $(command -v nvim)"
		return
	fi
	echo "[*] Installing Neovim using system package manager..."

	case "$(uname -s)" in
		Linux)
			if [ -f /etc/debian_version ]; then
				sudo apt update
				sudo apt install -y neovim python3-pip
			elif [ -f /etc/arch-release ]; then
				sudo pacman -Sy --noconfirm neovim python3-pip
			elif [ -f /etc/redhat-release ]; then
				sudo dnf install -y neovim python3-pip
			else
				echo "[!] Unsupported Linux distro"
				exit 1
			fi
			;;

		*)
			echo "[!] Unsupported OS: $(uname -s)"
			exit 1
			;;
	esac

        for pkg in pynvim pudb; do
                if ! python3 -c "import ${pkg}" >/dev/null 2>&1; then
                        echo "[*] Installing $pkg..."
                        python3 -m pip install --user "$pkg"
                else
                        echo "[✔] $pkg already installed"
                fi
        done

	echo "[✔] Neovim installed via package manager."
	if ! [ -d ~/.vim/bundle/Vundle.vim ]; then
		git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	fi
	nvim +PluginInstall +qall
}

install_fzf() {
  if [ -d "$HOME/.fzf" ]; then
    echo "[*] fzf already installed."
    return
  fi

  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
}

build_gitui() {
  local bin="$HOME/.local/bin/gitui"

  if [ -x "$bin" ]; then
    echo "[*] gitui already installed at $bin"
    return
  fi

  echo "[*] Building gitui from source..."

  # Make sure Rust is installed
  if ! command -v cargo >/dev/null 2>&1; then
    echo "[!] Rust not found. Please run with --build-extras first to install Rust."
    exit 1
  fi

  export CARGO_INSTALL_ROOT="$HOME/.local"
  cargo install --locked gitui

  echo "[✔] gitui installed to $bin"
}

# install_gitui() {
#   local dest="$HOME/.local/bin/gitui"
#
#   if command -v gitui &>/dev/null; then
#     echo "[*] gitui already installed at $(command -v gitui)"
#     return
#   fi
#
#   echo "[*] Installing gitui from GitHub release..."
#
#   local tmp_dir
#   tmp_dir="$(mktemp -d)"
#   pushd "$tmp_dir" > /dev/null
#
#   # Detect platform
#   local arch os
#   arch="$(uname -m)"
#   case "$arch" in
#     x86_64|amd64) arch="x86_64" ;;
#     aarch64|arm64) arch="aarch64" ;;
#     *) echo "[!] Unsupported arch: $arch" && exit 1 ;;
#   esac
#
#   os="$(uname -s)"
#   case "$os" in
#     Linux) os="linux" ;;
#     Darwin) os="mac" ;;
#     *) echo "[!] Unsupported OS: $os" && exit 1 ;;
#   esac
#
#   echo "[*] Detected platform: $os $arch"
#
#   # Get latest release URL
#   local latest_url
#   latest_url="$(curl -s https://api.github.com/repos/extrawurst/gitui/releases/latest \
#     | grep "browser_download_url" \
#     | grep "${os}_${arch}.*\.tar\.gz" \
#     | cut -d '"' -f 4 | head -n 1)"
#
#   if [[ -z "$latest_url" ]]; then
#     echo "[!] Could not find a matching release asset for $os $arch"
#     exit 1
#   fi
#
#   echo "[*] Downloading: $latest_url"
#   curl -LO "$latest_url"
#
#   local tar_file
#   tar_file="$(basename "$latest_url")"
#   tar -xzf "$tar_file"
#
#   if [ ! -f gitui ]; then
#     echo "[!] gitui binary not found in archive"
#     exit 1
#   fi
#
#   install -m 755 gitui "$dest"
#   echo "[✔] gitui installed to $dest"
#
#   popd > /dev/null
#   rm -rf "$tmp_dir"
# }
