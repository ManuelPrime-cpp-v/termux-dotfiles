#!/usr/bin/env bash
set -e

# Detect the exact folder where this script lives (works from any clone path)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating package repositories..."
pkg update -y && pkg upgrade -y

# Ensure essential tools exist first
pkg install -y git fish micro

# Install packages one by one so one missing/renamed package never breaks the script
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
  echo "==> Installing packages from pkglist.txt..."
  while IFS= read -r pkg_name || [ -n "$pkg_name" ]; do
    # Skip empty lines or comments
    [ -z "$pkg_name" ] && continue
    [[ "$pkg_name" =~ ^# ]] && continue
    pkg install -y "$pkg_name" || echo "Skipped unavailable package: $pkg_name"
  done < "$DOTFILES_DIR/pkglist.txt"
fi

echo "==> Creating target config directories..."
mkdir -p "$HOME/.termux" "$HOME/.config/fish" "$HOME/.config/micro"

# Copy configs only if those folders exist in the repo
if [ -d "$DOTFILES_DIR/.termux" ]; then
  cp -rf "$DOTFILES_DIR/.termux/." "$HOME/.termux/"
fi

if [ -d "$DOTFILES_DIR/.config/fish" ]; then
  cp -rf "$DOTFILES_DIR/.config/fish/." "$HOME/.config/fish/"
fi

if [ -d "$DOTFILES_DIR/.config/micro" ]; then
  cp -rf "$DOTFILES_DIR/.config/micro/." "$HOME/.config/micro/"
fi

# Switch default shell from bash/zsh to fish if chsh and fish are available
if command -v fish >/dev/null 2>&1 && command -v chsh >/dev/null 2>&1; then
  chsh -s fish || true
fi

# Reload Termux UI and extra-keys immediately if supported
if command -v termux-reload-settings >/dev/null 2>&1; then
  termux-reload-settings || true
fi

echo "==> Done! Close and reopen Termux to load your shell and theme."
