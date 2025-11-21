#!/usr/bin/env bash
set -euo pipefail

install_build_essentials() {
  echo "[*] Installing build tools (compiler, make, etc.)..."

  case "$(uname -s)" in
    Linux)
      if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y build-essential pkg-config libssl-dev curl cmake perl python3 python3-pip python3-flake8
      elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy --noconfirm base-devel pkgconf openssl cmake perl python3 python3-pip python3-flake8
      elif [ -f /etc/redhat-release ]; then
        # Works for RHEL, Fedora, CentOS
	# Try group install if supported
	if dnf group list | grep -q "Development Tools"; then
	  sudo dnf group install -y "Development Tools"
	else
	  # Fallback: install individual dev packages
	  sudo dnf install -y gcc gcc-c++ make automake autoconf kernel-devel
	fi

	# Always install pkgconf and OpenSSL headers
	sudo dnf install -y pkgconf-pkg-config openssl-devel curl cmake perl python3 python3-pip python3-flake8
        # ^ maybe broken, havent tested

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

  echo "[✔] Build tools installed."
}

install_build_extras() {
  echo "[*] Installing extra tools (ninja, gdb, clang, etc.)..."

  case "$(uname -s)" in
    Darwin)
      brew install ninja gdb lldb clang ripgrep
      ;;

    Linux)
      if [ -f /etc/debian_version ]; then
        sudo apt install -y ninja-build gdb clang lldb ripgrep
      elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy --noconfirm ninja gdb clang lldb ripgrep
      elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y ninja-build gdb clang lldb ripgrep
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

  # Install Rust (if not already installed)
  if ! command -v cargo >/dev/null 2>&1; then
    echo "[*] Installing Rust toolchain..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
    source $HOME/.cargo/env
  else
    echo "[*] Rust already installed at $(which cargo)"
  fi


  echo "[✔] Extra build tools installed."
}
