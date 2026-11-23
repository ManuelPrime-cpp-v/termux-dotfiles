# NewTermux Dotfiles & Environment Backup

Portable configuration repository and automated bootstrap installer for **NewTermux** (`v2.0.1` / `v2.0.2+`) and Termux forks on Android.

This repository preserves the visual layout, keyboard shortcuts, shell prompt, editor configuration, and installed package list so the entire terminal environment can be restored cleanly on any new Android device—whether starting from `bash`, `zsh`, or `fish`.

---

## Repository Structure

```text
termux-dotfiles/
├── .termux/
│   ├── termux.properties      # Black UI theme, custom 2-row extra-keys bar & popup bindings
│   ├── font.ttf               # Custom Nerd Font / terminal typeface for Tide prompt glyphs
│   └── shell                  # Default shell symlink pointing to fish
├── .config/
│   ├── fish/
│   │   ├── config.fish        # Main Fish shell startup configuration
│   │   └── functions/         # Custom functions & Tide prompt theme definitions
│   └── micro/
│       └── bindings.json      # Custom keybindings & settings for the micro terminal editor
├── pkglist.txt                # Sorted snapshot of all installed Termux packages
├── install.sh                 # Universal, cross-shell bootstrap & restore script
├── .gitignore                 # Excludes transient editor backups, buffers, and temp files
└── README.md                  # Full setup, usage, maintenance, and recovery documentation
```

---

## Key Features Included

### 1. Terminal UI & Custom Extra-Keys Layout (`.termux/termux.properties`)
* **True Black UI (`use-black-ui = true`)**: Eliminates light/gray borders for a seamless dark terminal look on OLED screens.
* **Two-Row Custom Extra-Keys Bar**: Configured with primary keys and long-press/swipe-up popup alternatives:
  * **Row 1**: `ESC` (`F1`), `TAB` (`BACKTAB`), `CTRL` (`ALT`), `|` (`~`), `{` (`}`), `[` (`]`), `(` (`)`)
  * **Row 2**: `LEFT` (`HOME`), `DOWN` (`PGDN`), `UP` (`PGUP`), `RIGHT` (`END`)
* **Custom Font (`font.ttf`)**: Ensures powerline dividers, Git branch icons, and status symbols render cleanly without missing-glyph boxes.

### 2. Fish Shell & Tide Prompt (`.config/fish/`)
* **Interactive `fish` environment** with greeting disabled (`fish_greeting ""`) for an instant, clutter-free startup.
* **Tide Prompt Theme**: Displays working directory path, active Git branch and untracked/dirty status counters, command exit codes (`x 1`, `x 127`), execution duration, and right-aligned timestamps.

### 3. Terminal Editor Setup (`.config/micro/`)
* Configures **`micro`** as the primary terminal text editor with custom keybindings (`bindings.json`).
* Temporary editor swap/backup and buffer history directories (`.config/micro/backups/` and `.config/micro/buffers/`) are excluded via `.gitignore` so repository history stays clean.

### 4. Universal Bootstrap Installer (`install.sh`)
* **Location-Independent**: Uses `#!/usr/bin/env bash` and dynamically resolves its own directory (`DOTFILES_DIR`) regardless of where the repo is cloned or what `$PREFIX` path the Termux fork uses.
* **Resilient Package Restoration**: Reads `pkglist.txt` line-by-line and skips unavailable/renamed packages rather than aborting the entire install.
* **Shell-Agnostic**: Works when launched from `bash`, `zsh`, or `fish`, automatically creating missing `~/.termux`, `~/.config/fish`, and `~/.config/micro` directories, switching the default login shell to `fish` via `chsh -s fish`, and reloading UI settings via `termux-reload-settings`.

---

## Quick Restore on a New Device

### Option A: Automated Dotfiles Restore (Any Device)
Works on both rooted and non-rooted devices starting from a fresh Termux / NewTermux install:

1. **Install `git` and clone this repository:**
   ```sh
   pkg update -y && pkg install -y git
   git clone git@github.com:ManuelPrime-cpp-v/termux-dotfiles.git ~/dotfiles
   ```
   *(If cloning via HTTPS instead of SSH on a secondary device, use `git clone https://github.com/ManuelPrime-cpp-v/termux-dotfiles.git ~/dotfiles` with a GitHub Personal Access Token.)*

2. **Run the universal installer:**
   ```sh
   bash ~/dotfiles/install.sh
   ```

3. **Restart the app:**
   Force-close and reopen NewTermux so the `fish` shell, Tide prompt, custom font, and extra-keys bar initialize together.

---

### Option B: Full `home` + `usr` Tarball Migration (Rooted Devices Only)
GitHub stores lightweight configuration files and package lists, not multi-gigabyte compiled binaries. If migrating between two **rooted** Android devices with the same CPU architecture (`arm64-v8a`) and you want to avoid re-downloading/compiling everything:

1. **Create a compressed archive on the source device:**
   ```sh
   su -c "cd /data/data/com.termux/files && tar -zcf /sdcard/newtermux-backup.tar.gz home usr"
   ```

2. **Initialize NewTermux on the target device:**
   Install the matching NewTermux APK, open it once so Android creates `/data/data/com.termux/files` and assigns its app UID, then force-stop the app.

3. **Extract and restore ownership + SELinux contexts:**
   ```sh
   su
   cd /data/data/com.termux/files
   rm -rf home usr
   tar -zxf /sdcard/newtermux-backup.tar.gz
   UID_GID=$(stat -c "%u:%g" /data/data/com.termux)
   chown -R "$UID_GID" /data/data/com.termux/files
   restorecon -RF /data/data/com.termux/files
   ```

---

## Keeping This Repository Updated

Whenever you tweak `.termux`, `fish`, `micro`, or install new packages, sync your changes back to GitHub:

```fish
cp -r ~/.termux/* ~/dotfiles/.termux/ 2>/dev/null; true
cp -r ~/.config/fish/* ~/dotfiles/.config/fish/ 2>/dev/null; true
cp -r ~/.config/micro/* ~/dotfiles/.config/micro/ 2>/dev/null; true
pkg list-installed 2>/dev/null | cut -d'/' -f1 | sort -u > ~/dotfiles/pkglist.txt

cd ~/dotfiles
git add .
git commit -m "Update NewTermux configs and package list"
git push
```

### Tagging Major App Milestones
To bookmark a specific NewTermux release state (such as `v2.0.2`):

```fish
git tag -a v2.0.2 -m "Baseline setup for NewTermux 2.0.2"
git push origin v2.0.2
```

---

## Root (`ReSukiSU`) Notes & Best Practices

* **Running root tools (`btop`, etc.):** `su` resets `PATH` to Android system directories (`/system/bin/sh`), so Termux binaries return `inaccessible or not found` unless `$PREFIX/bin` is passed inline:
  ```fish
  su -c "PATH=$PREFIX/bin:\$PATH btop"
  ```
* **Updating NewTermux APKs:** Always install newer APKs directly **over** the existing version rather than uninstalling first—uninstalling deletes `/data/data/com.termux`. After an in-place APK update, verify `su -c "id"` returns `uid=0(root)`; if needed, toggle superuser permissions off and back on inside **ReSukiSU**.
* **Avoid Soft Reboots After Module/App Updates:** When updating filesystem mount modules (such as Hybrid Mount) or root managers in ReSukiSU, always perform a **full device reboot** rather than a soft restart so `/data/app` package mounts stay synchronized with Android's `PackageManager`.
* 
