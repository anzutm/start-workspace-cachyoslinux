# Start Workspace — CachyOS / KDE Plasma

Bash scripts to set up (`setup-workspace`), automatically launch (`start-workspace`), and stop (`stop-workspace`) a daily multi-desktop workspace on **CachyOS** with **KDE Plasma 6 (Wayland)**, complete with automatic window placement across Virtual Desktops using **KWin Scripting** via `qdbus6`.

## Features

- **Terminal Setup Wizard & CLI (`setup-workspace`)**: initialize configuration, add/remove workspace apps, install CLI symlinks to `~/.local/bin`, verify dependencies (`doctor`), and create missing KDE Virtual Desktops directly from the terminal.
- **Idempotent launching**: checks running processes with `pgrep -f` so already-open applications are not launched again.
- **Wayland-native window placement**: uses KWin Scripting (`org.kde.kwin.Scripting`) to move windows to their assigned Virtual Desktops by `resourceClass` / `resourceName`, then switches focus back to Desktop 1.
- **Graceful & forced shutdown**: `stop-workspace` first closes windows cleanly via `c.closeWindow()` in KWin, then terminates any remaining background processes (or force-kills them with `-f`/`--force`).
- **Desktop notifications**: sends status updates via `notify-send` once the workspace is started or stopped.

## Default Virtual Desktop Layout

Make sure KDE Plasma has at least **3 Virtual Desktops** configured (or run `./setup-workspace ensure-desktops`).

| Desktop | Category | Apps in Default Setup |
| :--- | :--- | :--- |
| **Desktop 1** | Coding & Notes | Antigravity IDE (`glass-dock-widget`), Ptyxis Terminal, GNOME Text Editor (`Cachyos Gnome Command.md`), Nautilus / Dolphin |
| **Desktop 2** | Entertainment & Web | Chromium Browser, AniBase (`AniBase v1.5.5`) |
| **Desktop 3** | System, Utilities & Gaming | Twintail Launcher (Flatpak `app.twintaillauncher.ttl`), Omen Space (`omen-gui`) |

> **Note:** `stop-workspace` also handles closing additional targets such as Brave Browser (`brave-browser`), Wuthering Waves (`client-win64-shipping.exe`), and Resources Monitor (`org.gnome.Resources` / `resources`).

## Requirements

- **OS / Desktop**: CachyOS (or another Linux distro) running KDE Plasma 6 (Wayland)
- **System utilities**:
  - `bash`, `pgrep` / `pkill` (`procps-ng`)
  - `qdbus6` (`qt6-tools`) for KWin Scripting and Virtual Desktop management
  - `notify-send` (`libnotify`, optional for desktop notifications)
  - `flatpak` (optional, for Flatpak apps)

## Installation & Terminal Setup

Clone this repository and run `setup-workspace`:

```bash
git clone https://github.com/anzutm/start-workspace-cachyoslinux.git
cd start-workspace-cachyoslinux
chmod +x setup-workspace start-workspace stop-workspace
./setup-workspace
```

Or run the one-step setup commands directly:

```bash
./setup-workspace init       # Create ~/.config/start-workspace/workspace.conf
./setup-workspace install    # Symlink scripts into ~/.local/bin
./setup-workspace doctor     # Check tools, KWin, Virtual Desktops, and app paths
```

## Usage

### Terminal Setup (`setup-workspace`)

Run `./setup-workspace` with no arguments to open the interactive terminal menu, or use CLI subcommands:

| Command | Description |
| :--- | :--- |
| `setup-workspace` | Open interactive setup menu |
| `setup-workspace init [--force]` | Create default `workspace.conf` |
| `setup-workspace list` | List all configured apps per desktop |
| `setup-workspace add [OPTIONS]` | Add an app (interactive or via flags) |
| `setup-workspace remove [INDEX]` | Remove an app entry by number |
| `setup-workspace install` | Symlink scripts into `~/.local/bin` |
| `setup-workspace uninstall` | Remove symlinks from `~/.local/bin` |
| `setup-workspace doctor` | Verify dependencies, KWin D-Bus, and paths |
| `setup-workspace ensure-desktops` | Create KDE Virtual Desktops to match config |
| `setup-workspace reset [--yes]` | Reset `workspace.conf` back to defaults |

Example adding an app via CLI:

```bash
setup-workspace add --desktop 2 --name "Firefox" --pattern firefox --classes firefox --cmd firefox
```

### Start Workspace

```bash
start-workspace
```

### Stop Workspace

```bash
stop-workspace [OPTIONS]
```

Available options:

| Option | Description |
| :--- | :--- |
| `-a`, `--all` | Also close `keep_open` apps (such as Ptyxis terminal) |
| `-f`, `--force` | Force-kill unresponsive processes (`pkill -9 -f`) |
| `-h`, `--help` | Show help message |

Examples:

```bash
# Close workspace apps while keeping Ptyxis open
stop-workspace

# Close all workspace apps including Ptyxis
stop-workspace --all

# Force-kill all workspace processes including Ptyxis
stop-workspace -a -f
```

## Configuration File (`workspace.conf`)

When initialized via `setup-workspace`, your configuration is stored at `~/.config/start-workspace/workspace.conf` using a pipe-delimited format:

```text
DESKTOP|NAME|PROC_PATTERN|WINDOW_CLASSES|FLAGS|COMMAND
```

- **`DESKTOP`**: 1-based Virtual Desktop number (`0` for `close_only` entries in `stop-workspace`).
- **`NAME`**: Display name.
- **`PROC_PATTERN`**: Pattern passed to `pgrep -f` / `pkill -f`.
- **`WINDOW_CLASSES`**: Comma-separated KWin `resourceClass` / `resourceName` values.
- **`FLAGS`**: Optional comma-separated flags (`keep_open`, `flatpak`, `check_cmd`, `check_arg1`, `close_only`).
- **`COMMAND`**: Command used to launch the app.

If `~/.config/start-workspace/workspace.conf` does not exist, `start-workspace` and `stop-workspace` fall back to their built-in defaults.
