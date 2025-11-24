#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"

# --- FLAGS ---
INSTALL_BUILD_TOOLS=false
INSTALL_BUILD_EXTRAS=false
INSTALL_DOTFILES=false
INSTALL_EXTRAS=false
INSTALL_PACKAGES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dotfiles) INSTALL_DOTFILES=true ;;
    --packages) INSTALL_PACKAGES=true ;;
    --extras)   INSTALL_EXTRAS=true ;;
    --build-tools) INSTALL_BUILD_TOOLS=true ;;
    --build-extras) INSTALL_BUILD_EXTRAS=true ;;
    --help|-h)
      echo "Usage: ./install.sh [--dotfiles] [--packages] [--build-tools] [--build-extras] [--extras]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# --- INCLUDE SCRIPTS ---
source "$DOTFILES_DIR/scripts/link_dotfiles.sh"
source "$DOTFILES_DIR/scripts/install_build_essentials.sh"
source "$DOTFILES_DIR/scripts/install_packages.sh"


# --- RUN ---
echo "[*] Starting installation..."

if $INSTALL_BUILD_TOOLS; then
	install_build_essentials
fi

if $INSTALL_BUILD_EXTRAS; then
	install_build_extras
fi

set +e
if $INSTALL_DOTFILES; then
  link_dotfiles
fi
set -e

if $INSTALL_PACKAGES; then
  install_fzf
  build_gitui
  install_extras

  # nvim
  install_ctags
  install_nvim
fi

echo "[✔] All done."

