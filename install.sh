#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating package repositories..."
pkg update -y && pkg upgrade -y
pkg install -y git fish micro

if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
  echo "==> Installing packages from pkglist.txt..."
  while IFS= read -r pkg_name || [ -n "$pkg_name" ]; do
    [ -z "$pkg_name" ] && continue
    [[ "$pkg_name" =~ ^# ]] && continue
    pkg install -y "$pkg_name" || echo "Skipped unavailable package: $pkg_name"
  done < "$DOTFILES_DIR/pkglist.txt"
fi

echo "==> Creating target directories..."
mkdir -p "$HOME/.termux" "$HOME/.config/fish" "$HOME/.config/micro" "$HOME/bin"

[ -d "$DOTFILES_DIR/.termux" ] && cp -rf "$DOTFILES_DIR/.termux/." "$HOME/.termux/"
[ -d "$DOTFILES_DIR/.config/fish" ] && cp -rf "$DOTFILES_DIR/.config/fish/." "$HOME/.config/fish/"
[ -d "$DOTFILES_DIR/.config/micro" ] && cp -rf "$DOTFILES_DIR/.config/micro/." "$HOME/.config/micro/"

# Install Android Share-menu hooks into ~/bin
if [ -d "$DOTFILES_DIR/bin" ]; then
  cp -rf "$DOTFILES_DIR/bin/." "$HOME/bin/"
  chmod +x "$HOME/bin/"* 2>/dev/null || true
fi

if command -v fish >/dev/null 2>&1 && command -v chsh >/dev/null 2>&1; then
  chsh -s fish || true
fi

if command -v termux-reload-settings >/dev/null 2>&1; then
  termux-reload-settings || true
fi

echo "==> Done! Close and reopen Termux to load your shell and theme."
