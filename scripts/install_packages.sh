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

        for pkg in pynvim pudb; do
                if ! python3 -c "import ${pkg}" >/dev/null 2>&1; then
                        echo "[*] Installing $pkg..."
                        python3 -m pip install --user --break-system-packages "$pkg"
                else
                        echo "[✔] $pkg already installed"
                fi
        done

	if command -v nvim >/dev/null; then
		echo "[✔] Neovim is already installed at $(command -v nvim)"
        else
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
        fi

	echo "[✔] Neovim installed via package manager."
	if ! [ -d ~/.vim/bundle/Vundle.vim ]; then
		git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	fi
	nvim +PluginInstall +qall
        nvim +UpdateRemotePlugins +qall
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

install_extras() {
  echo "[*] Installing additional packages (tmux, etc)"

  # rip macosx you were a good system
  case "$(uname -s)" in
    Linux)
      if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y tmux tree htop btop

        # Docker image inspection tool
        DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
        sudo apt install ./dive_${DIVE_VERSION}_linux_amd64.deb
        rm -f dive*.deb
      elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy --noconfirm tmux dive tree htop btop
      elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y tmux tree htop btop

        # Docker image inspection tool
        DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm"
        rpm -i dive_${DIVE_VERSION}_linux_amd64.rpm
        rm -f dive*.rpm
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

  if [ ! -d ~/.tmux/plugins/tpm ]; then
          git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  echo "[✔] Additional packages installed."
}

install_nodejs_nvm() {
        if ! command -v nvm >/dev/null 2>&1; then
                echo "Installing nvm"
                # Download and install nvm:
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
                # in lieu of restarting the shell
                \. "$HOME/.nvm/nvm.sh"

                # Download and install Node.js:
                nvm install 24

                # Verify the Node.js version:
                node -v # Should print "v24.11.1".

                # Verify npm version:
                npm -v # Should print "11.6.2".
        fi
}
