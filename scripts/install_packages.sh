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
        else
                echo "[*] Installing Neovim from github..."
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
                sudo rm -rf /opt/nvim-linux-x86_64
                sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

                case "$(uname -s)" in
                        # TODO maybe not install pip here lol
                        Linux)
                        if [ -f /etc/debian_version ]; then
                                sudo apt update
                                sudo apt install -y python3-pip
                        elif [ -f /etc/arch-release ]; then
                                sudo pacman -Sy --noconfirm python3-pip
                        elif [ -f /etc/redhat-release ]; then
                                sudo dnf install -y python3-pip
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

        for pkg in pynvim pudb; do
                if ! python3 -c "import ${pkg}" >/dev/null 2>&1; then
                        echo "[*] Installing $pkg..."
                        python3 -m pip install --user --break-system-packages "$pkg"
                else
                        echo "[✔] $pkg already installed"
                fi
        done

        if command -v buildifier >/dev/null; then
                echo "[✔] buildifier already installed at $(command -v buildifier)"
        else
                echo "[*] Installing buildifier..."
                go install github.com/bazelbuild/buildtools/buildifier@latest
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
                                sudo apt install -y tmux tree htop btop bat

                                # Docker image inspection tool
                                DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
                                curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
                                sudo apt install ./dive_${DIVE_VERSION}_linux_amd64.deb
                                rm -f dive*.deb
                        elif [ -f /etc/arch-release ]; then
                                sudo pacman -Sy --noconfirm tmux dive tree htop btop bat
                        elif [ -f /etc/redhat-release ]; then
                                sudo dnf install -y tmux tree htop btop bat

                                # Docker image inspection tool
                                DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
                                curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm"
                                rpm -i dive_${DIVE_VERSION}_linux_amd64.rpm
                                rm -f dive*.rpm
                        else
                                echo "[!] Unsupported Linux distro"
                                exit 1
                        fi
                        if command -v delta >/dev/null 2>&1; then
                                echo "[✔] delta already installed at $(command -v delta)"
                        else
                                echo "[*] Installing delta..."
                                DELTA_RELEASE=https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz
                                DELTA_SHA=99607c43238e11a77fe90a914d8c2d64961aff84b60b8186c1b5691b39955b0f

                                curl -fLO $DELTA_RELEASE
                                echo "${DELTA_SHA}  delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz" | sha256sum -c -
                                tar -xzf delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz
                                mv delta-0.18.2-x86_64-unknown-linux-gnu/delta ~/.local/bin
                                rm -rf delta-0.18.2-x86_64-unknown-linux-gnu*

                                git config --global core.pager delta
                                git config --global interactive.diffFilter 'delta --color-only'
                                git config --global delta.navigate true
                                git config --global merge.conflictStyle zdiff3
                                # TODO .gitconfig
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

install_antigravity() {
        echo "[*] Installing Antigravity repository..."
        if [ -f /etc/apt/sources.list.d/antigravity.list ]; then
                echo "[✔] Antigravity repository already installed."
        else
                case "$(uname -s)" in
                        Linux)
                                if [ -f /etc/debian_version ]; then
                                        sudo mkdir -p /etc/apt/keyrings
                                        curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
                                                sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
                                        echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
                                                sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
                                        sudo apt update
                                        # if antigravity not installed install it
                                        if ! dpkg -s antigravity >/dev/null 2>&1; then
                                                sudo apt install -y antigravity
                                        fi
                                elif [ -f /etc/redhat-release ]; then
                                        sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
                                        sudo dnf makecache
                                        # if antigravity not installed install it
                                        if ! rpm -q antigravity >/dev/null 2>&1; then
                                                sudo dnf install -y antigravity
                                        fi
                                else
                                        echo "[!] Unsupported Linux distro for Antigravity repo"
                                        exit 1
                                fi
                                ;;
                        *)
                                echo "[!] Unsupported OS for Antigravity repo: $(uname -s)"
                                exit 1
                                ;;
                esac
        fi
}
