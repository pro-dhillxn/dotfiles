#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stowing packages..."
cd "$DOTFILES_DIR"
stow bash broot nvim starship tmux yazi

echo "Adding source line to ~/.bashrc..."
SOURCE_LINE='[[ -f ~/.config/bash/rc ]] && source ~/.config/bash/rc'
grep -qxF "$SOURCE_LINE" ~/.bashrc \
  || echo "$SOURCE_LINE" >> ~/.bashrc

echo "Done! Restart your shell or run: source ~/.bashrc"
