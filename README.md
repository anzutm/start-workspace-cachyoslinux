# Start Workspace — CachyOS / KDE Plasma

Bash scripts to automatically launch (`start-workspace`) and stop (`stop-workspace`) a daily multi-desktop workspace on **CachyOS** with **KDE Plasma 6 (Wayland)**, complete with automatic window placement across Virtual Desktops 1–3 using **KWin Scripting** via `qdbus6`.

## Features

- **Idempotent launching**: checks running processes with `pgrep -f` so already-open applications are not launched again.
- **Wayland-native window placement**: uses KWin Scripting (`org.kde.kwin.Scripting`) to move windows to Virtual Desktops 1, 2, or 3 by `resourceClass` / `resourceName`, then switches focus back to Desktop 1.
- **Graceful & forced shutdown**: `stop-workspace` first closes windows cleanly via `c.closeWindow()` in KWin, then terminates any remaining background processes (or force-kills them with `-f`/`--force`).
- **Desktop notifications**: sends status updates via `notify-send` once the workspace is started or stopped.

## Virtual Desktop Layout

Make sure KDE Plasma has at least **3 Virtual Desktops** configured for automatic window placement to work properly.

| Desktop | Category | Apps in `start-workspace` |
| :--- | :--- | :--- |
| **Desktop 1** | Coding & Notes | Antigravity IDE (`glass-dock-widget`), Ptyxis Terminal, GNOME Text Editor (`Cachyos Gnome Command.md`), Nautilus / Dolphin |
| **Desktop 2** | Entertainment & Web | Chromium Browser, AniBase (`AniBase v1.5.5`) |
| **Desktop 3** | System, Utilities & Gaming | Twintail Launcher (Flatpak `app.twintaillauncher.ttl`), Omen Space (`omen-gui`) |

> **Note:** `stop-workspace` also handles closing additional targets such as Brave Browser (`brave-browser`), Wuthering Waves (`client-win64-shipping.exe`), and Resources Monitor (`org.gnome.Resources` / `resources`).

## Requirements

- **OS / Desktop**: CachyOS (or another Linux distro) running KDE Plasma 6 (Wayland)
- **System utilities**:
  - `bash`, `pgrep` / `pkill` (`procps-ng`)
  - `qdbus6` (`qt6-tools`) for KWin Scripting and Virtual Desktop switching
  - `notify-send` (`libnotify`, optional for desktop notifications)
  - `flatpak` (optional, for Twintail Launcher)

## Installation

Clone this repository and ensure both scripts are executable:

```bash
git clone https://github.com/anzutm/start-workspace-cachyoslinux.git
cd start-workspace-cachyoslinux
chmod +x start-workspace stop-workspace
```

(Optional) Symlink them into `~/.local/bin` to run them from anywhere:

```bash
mkdir -p ~/.local/bin
ln -sf "$(pwd)/start-workspace" ~/.local/bin/start-workspace
ln -sf "$(pwd)/stop-workspace" ~/.local/bin/stop-workspace
```

## Usage

### Start Workspace

```bash
./start-workspace
```

Or if symlinked to `~/.local/bin`:

```bash
start-workspace
```

### Stop Workspace

```bash
./stop-workspace [OPTIONS]
```

Available options:

| Option | Description |
| :--- | :--- |
| `-a`, `--all` | Also close the Ptyxis terminal window |
| `-f`, `--force` | Force-kill unresponsive processes (`pkill -9 -f`) |
| `-h`, `--help` | Show help message |

Examples:

```bash
# Close all workspace apps while keeping Ptyxis open
./stop-workspace

# Close all workspace apps including Ptyxis
./stop-workspace --all

# Force-kill all workspace processes including Ptyxis
./stop-workspace -a -f
```

## Customization

Edit the paths, process patterns, and window rules directly inside each script:

- **[`start-workspace`](start-workspace)**: update the `launch_if_not_running` arguments (such as your IDE workspace path, markdown notes, or local binaries) and the `rules` object inside `organize_windows()` to map `resourceClass` / `resourceName` values to desktop indices (`0` = Desktop 1, `1` = Desktop 2, `2` = Desktop 3).
- **[`stop-workspace`](stop-workspace)**: update the `targets` array in the KWin script and the `close_proc` calls to match the applications you want to stop.
