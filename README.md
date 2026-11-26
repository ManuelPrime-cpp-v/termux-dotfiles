# NewTermux Dotfiles & Environment Backup

Portable configuration repository, automated sync toolkit, and cross-shell bootstrap installer for **NewTermux** (`v2.0.1` / `v2.0.2+`) and Termux forks on Android.

This repository preserves the visual layout, keyboard shortcuts, shell prompt, editor configuration, Android Share-menu handlers, and installed package list so the entire terminal environment can be restored and maintained cleanly on any Android device—whether starting from `bash`, `zsh`, or `fish`.

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
│   │   ├── config.fish        # Device-aware Fish startup config, helpers & pkglist hook
│   │   └── functions/         # Custom functions & Tide prompt theme definitions
│   └── micro/
│       └── bindings.json      # Custom keybindings & settings for the micro terminal editor
├── bin/
│   ├── termux-url-opener      # Android Share-menu URL handler (mpv / yt-dlp)
│   └── termux-file-editor     # Android Share-menu file handler (micro)
├── pkglist.txt                # Sorted snapshot of all installed Termux packages
├── install.sh                 # Universal, cross-shell bootstrap & restore script
├── sync.sh                    # One-command snapshot, package-list sync & Git push script
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

### 2. Device-Aware Fish Shell & Built-In Helpers (`.config/fish/config.fish`)
* **Clean Interactive Startup**: Disables `fish_greeting` and loads Termux-specific tooling only when running inside Termux/NewTermux (`TERMUX_VERSION` or `/data/data/com.termux`), keeping the repo compatible with desktop Linux Fish setups.
* **Tide Prompt Theme**: Displays working directory path, active Git branch and untracked/dirty status counters, command exit codes (`x 1`, `x 127`), execution duration, and right-aligned timestamps.
* **`dotsync [message]`**: Snapshots updated `.termux`, `fish`, `micro`, and `pkglist.txt` files and pushes them to GitHub in one command.
* **`rsu <command>`**: Runs root commands via `su -c` with `$PREFIX/bin` injected into `PATH` so Termux binaries (such as `btop`) execute cleanly under root.
* **Auto-Updating `pkg` Wrapper**: Automatically refreshes `~/dotfiles/pkglist.txt` whenever `pkg install`, `pkg uninstall`, `pkg upgrade`, or `pkg up` succeeds.

### 3. Terminal Editor Setup (`.config/micro/`)
* Configures **`micro`** as the primary terminal text editor (`EDITOR` / `VISUAL`) with custom keybindings (`bindings.json`).
* Excludes temporary swap/backup and buffer history directories (`.config/micro/backups/` and `.config/micro/buffers/`) via `.gitignore` and `sync.sh`.

### 4. Android Share-Menu Handlers (`bin/`)
* **`bin/termux-url-opener`**: Triggered when sharing a URL from Android to NewTermux; plays media links directly with `mpv` (or falls back to `yt-dlp`).
* **`bin/termux-file-editor`**: Triggered when sharing a file from Android to NewTermux; opens the shared file directly in `micro`.

### 5. Universal Bootstrapper (`install.sh`) & One-Command Sync (`sync.sh`)
* **Location-Independent (`install.sh`)**: Uses `#!/usr/bin/env bash` and resolves its own directory (`DOTFILES_DIR`) dynamically regardless of clone location or `$PREFIX` path.
* **Resilient Package Restoration**: Reads `pkglist.txt` line-by-line and skips unavailable/renamed packages rather than aborting the entire install.
* **Shell-Agnostic**: Works from `bash`, `zsh`, or `fish`, creates `~/.termux`, `~/.config/fish`, `~/.config/micro`, and `~/bin`, installs share-menu hooks, switches the default shell to `fish` via `chsh -s fish`, and reloads settings via `termux-reload-settings`.
* **Smart Sync (`sync.sh`)**: Copies live configs into the repo, strips transient `micro` backups, updates `pkglist.txt`, and skips empty commits when no files changed.

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
   Force-close and reopen NewTermux so the `fish` shell, Tide prompt, custom font, extra-keys bar, and `config.fish` helpers initialize together.

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

Run `dotsync` inside Fish (or `bash ~/dotfiles/sync.sh` from any shell) whenever you tweak `.termux`, `fish`, `micro`, or install new packages:

```fish
dotsync
# Or with a custom commit message:
dotsync "Update Fish helpers and keybindings"
```

### Tagging Major App Milestones
To bookmark a specific NewTermux release state (such as `v2.0.2`):

```fish
git tag -a v2.0.2 -m "Baseline setup for NewTermux 2.0.2"
git push origin v2.0.2
```

---

## Root (`ReSukiSU`) Notes & Best Practices

* **Running root tools (`btop`, etc.):** `su` resets `PATH` to Android system directories (`/system/bin/sh`). Use the built-in `rsu` helper (or pass `$PREFIX/bin` inline):
  ```fish
  rsu btop
  ```
* **Updating NewTermux APKs:** Always install newer APKs directly **over** the existing version rather than uninstalling first—uninstalling deletes `/data/data/com.termux`. After an in-place APK update, verify `rsu id` returns `uid=0(root)`; if needed, toggle superuser permissions off and back on inside **ReSukiSU**.
* **Avoid Soft Reboots After Module/App Updates:** When updating filesystem mount modules (such as Hybrid Mount) or root managers in ReSukiSU, always perform a **full device reboot** rather than a soft restart so `/data/app` package mounts stay synchronized with Android's `PackageManager`.
