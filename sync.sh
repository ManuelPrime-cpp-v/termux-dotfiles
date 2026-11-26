#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$DOTFILES_DIR/.termux" "$DOTFILES_DIR/.config/fish" "$DOTFILES_DIR/.config/micro"

if [ -d "$HOME/.termux" ]; then
  cp -rf "$HOME/.termux/." "$DOTFILES_DIR/.termux/"
fi

if [ -d "$HOME/.config/fish" ]; then
  cp -rf "$HOME/.config/fish/." "$DOTFILES_DIR/.config/fish/"
fi

if [ -d "$HOME/.config/micro" ]; then
  cp -rf "$HOME/.config/micro/." "$DOTFILES_DIR/.config/micro/"
  rm -rf "$DOTFILES_DIR/.config/micro/backups" "$DOTFILES_DIR/.config/micro/buffers"
fi

if command -v pkg >/dev/null 2>&1; then
  pkg list-installed 2>/dev/null | cut -d'/' -f1 | sort -u > "$DOTFILES_DIR/pkglist.txt"
fi

cd "$DOTFILES_DIR"
git add .

if git diff --cached --quiet; then
  echo "==> No changes to commit."
else
  MSG="${1:-Sync dotfiles and package list on $(date '+