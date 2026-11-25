# Start Workspace — CachyOS / KDE Plasma

GUI and Bash scripts to set up (`setup-workspace-gui` / `setup-workspace`), automatically launch (`start-workspace`), and stop (`stop-workspace`) a daily multi-desktop workspace on **CachyOS** with **KDE Plasma 6 (Wayland)**, complete with automatic window placement across Virtual Desktops using **KWin Scripting** via `qdbus6`.

## Features

- **Native KDE Plasma / PyQt6 GUI (`setup-workspace-gui`)**: visually add, edit, remove, and reorder apps, **pick installed apps** from your system menu, **pick open KWin windows** to auto-fill `resourceClass`, toggle login autostart, load presets, and test launching/stopping your workspace.
- **Terminal Setup Wizard & CLI (`setup-workspace`)**: auto-detects installed apps (`init --preset auto|minimal|personal`), manages entries from the terminal, installs CLI & App Launcher shortcuts, checks system dependencies (`doctor`), and creates missing KDE Virtual Desktops.
- **Idempotent launching**: checks running processes with `pgrep -f` so already-open applications are not launched again.
- **Wayland-native window placement**: uses KWin Scripting (`org.kde.kwin.Scripting`) to move windows to their assigned Virtual Desktops by `resourceClass` / `resourceName`, then switches focus back to Desktop 1.
- **Graceful & forced shutdown**: `stop-workspace` first closes windows cleanly via `c.closeWindow()` in KWin, then terminates any remaining background processes (or force-kills them with `-f`/`--force`).
- **Desktop notifications**: sends status updates via `notify-send` once the workspace is started or stopped.

## Default Virtual Desktop Layout

Make sure KDE Plasma has at least **3 Virtual Desktops** configured (or click **Ensure Desktops** in the GUI / run `./setup-workspace ensure-desktops`). When initialized with the default `auto` preset, setup detects which editors, terminals, file managers, browsers, and utilities are installed on your system:

| Desktop | Category | Example Apps |
| :--- | :--- | :--- |
| **Desktop 1** | Coding & Notes | Antigravity IDE / VS Code / VSCodium / Zed, Ptyxis / Konsole / Kitty / Alacritty, GNOME Text Editor / Kate, Nautilus / Dolphin / Thunar |
| **Desktop 2** | Entertainment & Web | Chromium / Firefox / Brave / Chrome / Zen Browser |
| **Desktop 3** | System, Utilities & Gaming | Steam / Lutris / Flatpak launchers, System Monitor / Resources |

## Requirements

- **OS / Desktop**: CachyOS (or another Linux distro) running KDE Plasma 6 (Wayland)
- **System utilities**:
  - `bash`, `pgrep` / `pkill` (`procps-ng`)
  - `qdbus6` (`qt6-tools`) for KWin Scripting and Virtual Desktop management
  - `python-pyqt6` (for the `setup-workspace-gui` desktop interface)
  - `python-gobject` (optional, for listing open KWin windows; otherwise falls back to click-to-pick)
  - `notify-send` (`libnotify`, optional for desktop notifications)
  - `flatpak` (optional, for Flatpak apps)

## Installation & Setup

Clone this repository and open the GUI (or install it into your KDE Application Launcher):

```bash
git clone https://github.com/anzutm/start-workspace-cachyoslinux.git
cd start-workspace-cachyoslinux
chmod +x setup-workspace setup-workspace-gui start-workspace stop-workspace
./setup-workspace gui
```

To install the CLI commands into `~/.local/bin` **and** add **Workspace Setup** to your KDE Plasma Application Launcher:

```bash
./setup-workspace install
```

## Usage

### GUI Setup (`setup-workspace-gui`)

Launch the graphical manager with `./setup-workspace gui` (or `./setup-workspace-gui`, or search **Workspace Setup** in your application launcher after running `install`):

- **Add App → Pick Installed App...**: pick any installed app from your system menu to auto-fill Name, Command, Process Pattern, and KWin Window Classes.
- **Add App → Pick Open Window...**: click an already-open window to grab its exact Wayland `resourceClass` / `resourceName` and Virtual Desktop.
- **Load Preset**: switch between `auto` (system-detected apps), `minimal`, or `personal`.
- **Start workspace automatically on login**: one-click KDE autostart toggle.

### Terminal Setup (`setup-workspace`)

Run `./setup-workspace` with no arguments to open the interactive terminal menu, or use CLI subcommands:

| Command | Description |
| :--- | :--- |
| `setup-workspace gui` | Launch the PyQt6 graphical setup window |
| `setup-workspace` | Open interactive terminal menu |
| `setup-workspace init [--preset auto\|minimal\|personal] [--force]` | Create `workspace.conf` (default preset: `auto`) |
| `setup-workspace list` | List all configured apps per desktop |
| `setup-workspace add [OPTIONS]` | Add an app (interactive or via flags) |
| `setup-workspace edit [INDEX] [OPTIONS]` | Edit an existing app entry |
| `setup-workspace remove [INDEX]` | Remove an app entry by number |
| `setup-workspace windows [--pick]` | Inspect open KWin windows (`resourceClass` / `resourceName`) |
| `setup-workspace autostart [status\|enable\|disable]` | Enable or disable KDE login autostart |
| `setup-workspace install` | Symlink scripts into `~/.local/bin` & add App Launcher entry |
| `setup-workspace uninstall` | Remove symlinks & App Launcher entry |
| `setup-workspace doctor` | Verify dependencies, KWin D-Bus, and paths |
| `setup-workspace ensure-desktops` | Create KDE Virtual Desktops to match config |
| `setup-workspace reset [--preset ...] [--yes]` | Reset `workspace.conf` using a preset |

Example: discover a window's KWin `resourceClass` and add it via CLI:

```bash
setup-workspace windows
setup-workspace add --desktop 2 --name "Firefox" --pattern firefox --classes firefox,org.mozilla.firefox --cmd firefox
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
| `-a`, `--all` | Also close `keep_open` apps (such as your terminal) |
| `-f`, `--force` | Force-kill unresponsive processes (`pkill -9 -f`) |
| `-h`, `--help` | Show help message |

Examples:

```bash
# Close workspace apps while keeping your terminal open
stop-workspace

# Close all workspace apps including your terminal
stop-workspace --all

# Force-kill all workspace processes including your terminal
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

If `~/.config/start-workspace/workspace.conf` does not exist, `start-workspace` and `stop-workspace` fall back to built-in defaults (only launching tools present on your system).

## License

This project is licensed under the [MIT License](LICENSE).
