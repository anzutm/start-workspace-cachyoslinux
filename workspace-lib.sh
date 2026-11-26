#!/usr/bin/env bash
# Shared helper functions for start-workspace, stop-workspace, and setup-workspace.

# Return PIDs matching proc_pattern for the current user, excluding helper/self scripts
# and unrelated commands whose arguments merely mention the pattern.
find_matching_pids() {
    local pattern="$1"
    [ -z "$pattern" ] && return 0

    local uid
    uid="$(id -u)"

    local is_regex=false
    case "$pattern" in
        *[[:space:]]*|*'|'*|*'^'*|*'$'*|*'\\'*|*'*'*|*'+'*|*'?'*|*'('*|*')'*|*'['*|*']'*|*'{'*|*'}'*)
            is_regex=true
            ;;
    esac

    local pat_short="${pattern:0:15}"
    local pid
    while IFS= read -r pid; do
        [ -z "$pid" ] && continue
        [ "$pid" = "$$" ] || [ "$pid" = "${BASHPID:-$$}" ] && continue
        [ -r "/proc/$pid/comm" ] || continue

        local comm exe_path exe_base
        IFS= read -r comm < "/proc/$pid/comm" || continue
        exe_path="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
        exe_base="${exe_path##*/}"

        case "$comm" in
            fuse-overlayfs|fusermount|fusermount3|profile-sync-da|systemd|pgrep|pkill|start-workspace|stop-workspace|setup-workspace|setup-workspace-gui)
                continue
                ;;
        esac
        case "$exe_base" in
            fuse-overlayfs|fusermount|fusermount3|profile-sync-daemon|systemd|pgrep|pkill|start-workspace|stop-workspace|setup-workspace|setup-workspace-gui)
                continue
                ;;
        esac

        local argv=()
        mapfile -d '' -t argv < "/proc/$pid/cmdline" 2>/dev/null || true
        local arg0="${argv[0]:-}"
        local arg0_base="${arg0##*/}"
        arg0_base="${arg0_base##*\\}"
        local arg1_base="${argv[1]:-}"
        arg1_base="${arg1_base##*/}"

        case "$arg0_base" in
            start-workspace|stop-workspace|setup-workspace|setup-workspace-gui)
                continue
                ;;
        esac
        case "$arg1_base" in
            start-workspace|stop-workspace|setup-workspace|setup-workspace-gui)
                continue
                ;;
        esac

        if [ "$is_regex" = true ]; then
            # Avoid matching shells/editors merely inspecting or running helper commands
            case "$exe_base" in
                grep|rg|awk|sed)
                    continue
                    ;;
            esac
            echo "$pid"
            continue
        fi

        if [ "$comm" = "$pat_short" ] || [ "$exe_base" = "$pattern" ] || [ "$exe_path" = "$pattern" ] || [ "$arg0_base" = "$pattern" ] || [ "$arg0" = "$pattern" ]; then
            echo "$pid"
            continue
        fi

        case "$exe_base" in
            sh|bash|dash|zsh|python|python3*|node|nodejs|electron*|flatpak|bwrap|wine*|proton*|env)
                local i
                for ((i = 1; i < ${#argv[@]}; i++)); do
                    local a="${argv[i]}"
                    local a_base="${a##*/}"
                    a_base="${a_base##*\\}"
                    if [ "$a" = "$pattern" ] || [ "$a_base" = "$pattern" ]; then
                        echo "$pid"
                        break
                    fi
                done
                ;;
        esac
    done < <(
        {
            pgrep -u "$uid" -f "$pattern" 2>/dev/null || true
            if [ "$is_regex" = false ]; then
                pgrep -u "$uid" -x "$pat_short" 2>/dev/null || true
            fi
        } | awk '!seen[$0]++'
    )
}

# Split a shell-quoted command string into SPLIT_CMD_ARGS.
# Prepends 'env' if leading tokens are VAR=VALUE assignments so "${SPLIT_CMD_ARGS[@]}" executes properly.
# Returns non-zero if quoting is invalid.
split_command_args() {
    local cmd_str="$1"
    SPLIT_CMD_ARGS=()
    [ -z "$cmd_str" ] && return 1

    local raw_out
    if ! raw_out="$(printf '%s\n' "$cmd_str" | xargs -n1 printf '%s\n' 2>/dev/null)"; then
        return 1
    fi
    local parsed=()
    mapfile -t parsed <<< "$raw_out"
    [ "${#parsed[@]}" -eq 0 ] && return 1

    if [[ "${parsed[0]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
        SPLIT_CMD_ARGS=("env" "${parsed[@]}")
    else
        SPLIT_CMD_ARGS=("${parsed[@]}")
    fi
    return 0
}

# Execute a temporary KWin JavaScript file via qdbus6 and remove it safely afterwards.
run_kwin_js() {
    local js_code="$1"
    local label_prefix="${2:-ws_kwin}"
    if ! command -v qdbus6 >/dev/null 2>&1; then
        return 0
    fi

    local tmp_script
    tmp_script="$(mktemp "/tmp/${label_prefix}_XXXXXX.js")" || return 1
    local script_name="${label_prefix}_$$"

    printf '%s\n' "$js_code" > "$tmp_script"
    qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$tmp_script" "$script_name" >/dev/null 2>&1 || true
    qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null 2>&1 || true
    sleep 0.3
    qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$script_name" >/dev/null 2>&1 || true
    rm -f "$tmp_script"
}

# Emit default auto-detected workspace entries (used when workspace.conf does not exist yet).
get_default_entries() {
    # --- Desktop 1 (Coding & Notes) ---
    if command -v antigravity-ide >/dev/null 2>&1; then
        echo "1|Antigravity IDE|antigravity-ide|antigravity-ide||antigravity-ide"
    elif command -v code >/dev/null 2>&1; then
        echo "1|VS Code|code|code,Code||code"
    elif command -v codium >/dev/null 2>&1; then
        echo "1|VSCodium|codium|codium,VSCodium||codium"
    elif command -v zeditor >/dev/null 2>&1; then
        echo "1|Zed|zeditor|dev.zed.Zed,zeditor||zeditor"
    fi

    if command -v ptyxis >/dev/null 2>&1; then
        echo "1|Ptyxis Terminal|ptyxis|org.gnome.Ptyxis,ptyxis|keep_open|ptyxis"
    elif command -v konsole >/dev/null 2>&1; then
        echo "1|Konsole|konsole|org.kde.konsole,konsole|keep_open|konsole"
    elif command -v kitty >/dev/null 2>&1; then
        echo "1|Kitty Terminal|kitty|kitty|keep_open|kitty"
    elif command -v alacritty >/dev/null 2>&1; then
        echo "1|Alacritty|alacritty|Alacritty,alacritty|keep_open|alacritty"
    elif command -v ghostty >/dev/null 2>&1; then
        echo "1|Ghostty|ghostty|com.mitchellh.ghostty,ghostty|keep_open|ghostty"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        echo "1|GNOME Terminal|gnome-terminal|org.gnome.Terminal,gnome-terminal-server|keep_open|gnome-terminal"
    fi

    if command -v gnome-text-editor >/dev/null 2>&1; then
        echo "1|GNOME Text Editor|gnome-text-editor|org.gnome.TextEditor||gnome-text-editor"
    elif command -v kate >/dev/null 2>&1; then
        echo "1|Kate|kate|org.kde.kate,kate||kate"
    fi

    if command -v nautilus >/dev/null 2>&1; then
        echo "1|Files (Nautilus)|nautilus|org.gnome.Nautilus,nautilus||nautilus"
    elif command -v dolphin >/dev/null 2>&1; then
        echo "1|Files (Dolphin)|dolphin|org.kde.dolphin,dolphin||dolphin"
    elif command -v thunar >/dev/null 2>&1; then
        echo "1|Files (Thunar)|thunar|Thunar,thunar||thunar"
    fi

    # --- Desktop 2 (Web) ---
    if command -v chromium >/dev/null 2>&1; then
        echo "2|Chromium Browser|chromium|chromium,Chromium,chromium-browser||chromium"
    elif command -v firefox >/dev/null 2>&1; then
        echo "2|Firefox|firefox|firefox,org.mozilla.firefox||firefox"
    elif command -v brave >/dev/null 2>&1; then
        echo "2|Brave Browser|brave|brave-browser||brave"
    elif command -v google-chrome >/dev/null 2>&1; then
        echo "2|Google Chrome|chrome|google-chrome||google-chrome"
    elif command -v zen-browser >/dev/null 2>&1; then
        echo "2|Zen Browser|zen-browser|zen,zen-alpha||zen-browser"
    fi

    # --- Desktop 3 (System, Utilities & Gaming) ---
    if command -v flatpak >/dev/null 2>&1 && flatpak info app.twintaillauncher.ttl >/dev/null 2>&1; then
        echo "3|Twintail Launcher|twintaillauncher|Twintaillauncher,twintaillauncher,app.twintaillauncher.ttl|flatpak|flatpak run app.twintaillauncher.ttl"
        echo "0|Wuthering Waves|client-win64-shipping.exe|client-win64-shipping.exe|close_only|"
    elif command -v steam >/dev/null 2>&1; then
        echo "3|Steam|steam|steam||steam"
    elif command -v lutris >/dev/null 2>&1; then
        echo "3|Lutris|lutris|net.lutris.Lutris,lutris||lutris"
    fi

    if command -v omen-gui >/dev/null 2>&1; then
        echo "3|Omen Space|omen-gui|org.hp.OmenSpace,omen-gui||omen-gui"
    fi

    if command -v resources >/dev/null 2>&1; then
        echo "3|Resources Monitor|resources|net.nokyan.Resources,org.gnome.Resources,resources||resources"
    elif command -v plasma-systemmonitor >/dev/null 2>&1; then
        echo "3|System Monitor|plasma-systemmonitor|org.kde.plasma-systemmonitor||plasma-systemmonitor"
    fi
}
