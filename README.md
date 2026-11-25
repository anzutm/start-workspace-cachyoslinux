# Start Workspace — CachyOS / KDE Plasma

GUI and Bash scripts to launch (`start-workspace`), stop (`stop-workspace`), and configure (`setup-workspace-gui` / `setup-workspace`) your apps across **KDE Plasma 6 (Wayland)** Virtual Desktops.

## Quick Start

```bash
git clone https://github.com/anzutm/start-workspace-cachyoslinux.git
cd start-workspace-cachyoslinux
chmod +x setup-workspace setup-workspace-gui start-workspace stop-workspace
./setup-workspace gui
```

*(Optional)* Add **Workspace Setup** to your KDE Application Launcher and link CLI commands into `~/.local/bin`:

```bash
./setup-workspace install
```

## How to Use

### 1. Configure via GUI (`./setup-workspace gui`)
- **Add App** → **Choose Installed App...** (or **Choose Custom File / Script...**), pick a Desktop (`Desktop 1`, `Desktop 2`, `Desktop 3`, …), and click **Save App**.
- Click **Save** (changes also auto-save to `~/.config/start-workspace/workspace.conf`).
- Use **Create Missing Desktops** if KDE needs more Virtual Desktops, or enable **Start workspace automatically when I log in**.

### 2. Start & Stop
```bash
start-workspace          # Launch apps and move them to their Virtual Desktops
stop-workspace           # Close workspace apps (keeps keep_open apps like terminal)
stop-workspace --all     # Close everything, including terminal
stop-workspace -a -f     # Force-kill unresponsive apps
```

*(Prefer the terminal? Run `./setup-workspace` for an interactive CLI menu or `./setup-workspace --help` for subcommands.)*

## Requirements

- **KDE Plasma 6 (Wayland)** with `bash`, `pgrep`/`pkill`, and `qdbus6` (`qt6-tools`)
- `python-pyqt6` (for GUI setup)
- Optional: `python-gobject` (window detection), `notify-send`, `flatpak`

## License

[MIT](LICENSE)
