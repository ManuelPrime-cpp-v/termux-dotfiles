#!/data/data/com.termux/files/usr/bin/bash
set -e
DOTFILES_DIR="$HOME/dotfiles"
pkg update -y && pkg upgrade -y
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
  xargs pkg install -y < "$DOTFILES_DIR/pkglist.txt" || true
fi
mkdir -p "$HOME/.termux" "$HOME/.config/fish" "$HOME/.config/micro"
cp -rf "$DOTFILES_DIR/.termux/." "$HOME/.termux/"
cp -rf "$DOTFILES_DIR/.config/fish/." "$HOME/.config/fish/"
cp -rf "$DOTFILES_DIR/.config/micro/." "$HOME/.config/micro/"
command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings
echo "Dotfiles restored."
