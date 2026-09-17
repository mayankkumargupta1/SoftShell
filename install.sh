#!/usr/bin/env bash
# ==============================================================================
# SoftShell Installer & Hyprland Integration Script
# ==============================================================================
# Deploys SoftShell (Apple Dynamic Island & Launcher) to ~/.config/quickshell
# and integrates it seamlessly with Hyprland on Arch Linux.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
HYPR_CONFIG_DIR="$HOME/.config/hypr"
QS_CONFIG_DIR="$HOME/.config/quickshell"
BACKUP_ROOT="$HOME/.config/softshell_backups"
CURRENT_BACKUP_DIR="$BACKUP_ROOT/backup_$BACKUP_TIMESTAMP"

# Color formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ___         __  _     ____  _          _  _ "
    echo " / __| ___  / _|| |_  / ___|| |__   ___ | || |"
    echo " \__ \/ _ \| |_ | __| \___ \| '_ \ / _ \| || |"
    echo " |___/\___/|_|   \__| |____/|_| |_|\___/|_||_|"
    echo -e "       Apple Dynamic Island & Launcher for Wayland${NC}\n"
}

# ------------------------------------------------------------------------------
# 1. Dependency Checking and Installation
# ------------------------------------------------------------------------------
check_and_install_dependencies() {
    info "Verifying system requirements and dependencies..."

    # Check Arch Linux
    if [ ! -f /etc/arch-release ]; then
        warn "This installer is optimized for Arch Linux. Detected other distribution."
    fi

    local PACMAN_PKGS=(
        "quickshell"
        "hyprland"
        "kitty"
        "playerctl"
        "brightnessctl"
        "wireplumber"
        "pipewire"
        "wl-clipboard"
        "cliphist"
        "grim"
        "slurp"
        "mpvpaper"
        "ttf-jetbrains-mono-nerd"
    )

    local MISSING_PKGS=()
    for pkg in "${PACMAN_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null && ! pacman -Qg "$pkg" &>/dev/null; then
            MISSING_PKGS+=("$pkg")
        fi
    done

    if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
        info "The following recommended packages were not detected: ${MISSING_PKGS[*]}"
        if command -v yay &>/dev/null; then
            info "Installing missing dependencies via yay..."
            yay -S --needed --noconfirm "${MISSING_PKGS[@]}" || {
                warn "Some packages failed to install automatically. Please review manually."
            }
        elif command -v sudo &>/dev/null && command -v pacman &>/dev/null; then
            info "Installing missing dependencies via pacman..."
            sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}" || {
                warn "Some packages failed to install automatically. Please install via your AUR helper."
            }
        else
            warn "Neither yay nor pacman with sudo available. Continuing with existing packages..."
        fi
    else
        success "All core dependencies are satisfied."
    fi
}

# ------------------------------------------------------------------------------
# 2. Backup Existing Configurations
# ------------------------------------------------------------------------------
create_backup() {
    info "Creating safe configuration backup in: $CURRENT_BACKUP_DIR"
    mkdir -p "$CURRENT_BACKUP_DIR"

    # Backup Hyprland config
    if [ -d "$HYPR_CONFIG_DIR" ]; then
        cp -r "$HYPR_CONFIG_DIR" "$CURRENT_BACKUP_DIR/hypr"
        success "Backed up $HYPR_CONFIG_DIR"
    fi

    # Backup Quickshell config
    if [ -d "$QS_CONFIG_DIR" ]; then
        cp -r "$QS_CONFIG_DIR" "$CURRENT_BACKUP_DIR/quickshell"
        success "Backed up $QS_CONFIG_DIR"
    fi

    # Generate dedicated rollback script
    cat << 'EOF' > "$CURRENT_BACKUP_DIR/rollback.sh"
#!/usr/bin/env bash
set -e
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Restoring configurations from $BACKUP_DIR..."

if [ -d "$BACKUP_DIR/hypr" ]; then
    rm -rf "$HOME/.config/hypr"
    cp -r "$BACKUP_DIR/hypr" "$HOME/.config/hypr"
    echo "Restored ~/.config/hypr"
fi

if [ -d "$BACKUP_DIR/quickshell" ]; then
    rm -rf "$HOME/.config/quickshell"
    cp -r "$BACKUP_DIR/quickshell" "$HOME/.config/quickshell"
    echo "Restored ~/.config/quickshell"
else
    rm -rf "$HOME/.config/quickshell"
fi

echo "Restarting desktop shell..."
systemctl --user stop softshell-wallpaper.service 2>/dev/null || true
killall mpvpaper 2>/dev/null || true
killall quickshell 2>/dev/null || true
if command -v serpantinumd &>/dev/null; then
    serpantinumd start &>/dev/null &
fi
hyprctl reload &>/dev/null || true
echo "Rollback complete!"
EOF
    chmod +x "$CURRENT_BACKUP_DIR/rollback.sh"
    success "Generated rollback script at $CURRENT_BACKUP_DIR/rollback.sh"
}

# ------------------------------------------------------------------------------
# 3. Deploy SoftShell to ~/.config/quickshell
# ------------------------------------------------------------------------------
deploy_softshell() {
    info "Deploying SoftShell to $QS_CONFIG_DIR..."
    mkdir -p "$QS_CONFIG_DIR"

    # Copy files cleanly excluding git and temporary files
    local TARGET_ITEMS=(
        "shell.qml"
        "theme"
        "components"
        "widgets"
        "windows"
        "services"
        "scripts"
        "assets"
        "AGENTS.md"
        "README.md"
    )

    for item in "${TARGET_ITEMS[@]}"; do
        if [ -e "$SCRIPT_DIR/$item" ]; then
            cp -r "$SCRIPT_DIR/$item" "$QS_CONFIG_DIR/"
        fi
    done

    chmod +x "$QS_CONFIG_DIR/scripts/"*.sh 2>/dev/null || true

    success "SoftShell deployed successfully to $QS_CONFIG_DIR."
}

# ------------------------------------------------------------------------------
# 4. Integrate with Hyprland (~/.config/hypr)
# ------------------------------------------------------------------------------
configure_hyprland() {
    info "Configuring Hyprland settings for SoftShell integration..."

    mkdir -p "$HYPR_CONFIG_DIR/config"

    # 4.1 Update autostart.lua
    local AUTOSTART_FILE="$HYPR_CONFIG_DIR/config/autostart.lua"
    info "Updating $AUTOSTART_FILE..."
    cat << 'EOF' > "$AUTOSTART_FILE"
-- Hyprland Autostart Configuration
hl.on("hyprland.start", function()
	-- Clipboard history manager
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	
	-- Audio effects daemon
	hl.exec_cmd("systemctl --user enable --now easyeffects")
	
	-- SoftShell Quickshell Desktop Environment
	hl.exec_cmd("quickshell")
	
	-- SoftShell Wallpaper Manager (mpvpaper daemon)
	hl.exec_cmd("bash " .. os.getenv("HOME") .. "/.config/quickshell/scripts/wallpaper.sh init")
	
	-- Secrets and Authentication
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)
EOF
    success "Updated autostart.lua"

    # 4.2 Update keybinds.lua
    local KEYBINDS_FILE="$HYPR_CONFIG_DIR/config/keybinds.lua"
    info "Updating $KEYBINDS_FILE with native dispatchers and SoftShell bindings..."
    cat << 'EOF' > "$KEYBINDS_FILE"
-- Hyprland Keybindings Configuration with SoftShell Integration
local mainMod = _G.mainMod or "SUPER"
local terminal = _G.terminal or "kitty"

-- Gestures and Mouse Controls
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Window Resizing
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

-- Window Movement
hl.bind(mainMod .. " + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.window.move({ direction = "d" }))

-- Focus Navigation
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }))

-- Window State
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Hardware: Brightness Controls (brightnessctl)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true })

-- Hardware: Media & Audio Controls (PipeWire / WirePlumber & playerctl)
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })

-- Screenshots (grim & slurp)
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), { locked = true })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"), { locked = true })
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"), { locked = true })

-- Applications & Terminal
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("brave-origin"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))

-- SoftShell Launchers & Controls
-- Super + A and Super + D trigger SoftShell Dynamic Island launcher
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("quickshell ipc call launcher toggle"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("quickshell ipc call launcher toggle"))
-- Super + W cycles desktop wallpaper from ~/Pictures/Wallpapers
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("bash ~/.config/quickshell/scripts/wallpaper.sh next"))
-- Super + R reloads the shell configuration
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill -USR1 quickshell || quickshell"))

-- Workspaces Navigation (Native Hyprland Lua dispatchers)
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
EOF
    success "Updated keybinds.lua with SoftShell bindings and native dispatchers."

    # 4.3 Ensure window gaps and layer blur rules exist in settings.lua
    local SETTINGS_FILE="$HYPR_CONFIG_DIR/config/settings.lua"
    if [ -f "$SETTINGS_FILE" ]; then
        info "Configuring window gaps (gaps_in=5, gaps_out=10 for uniform 10px gaps) and layer blur rules in $SETTINGS_FILE..."
        sed -i 's/gaps_in = [0-9]*/gaps_in = 5/' "$SETTINGS_FILE" 2>/dev/null || true
        sed -i 's/gaps_out = [0-9]*/gaps_out = 10/' "$SETTINGS_FILE" 2>/dev/null || true
        sed -i 's/float_gaps = [0-9]*/float_gaps = 10/' "$SETTINGS_FILE" 2>/dev/null || true
        if ! grep -q "quickshell:bar" "$SETTINGS_FILE"; then
            cat << 'EOF' >> "$SETTINGS_FILE"

-- SoftShell Menu Bar blur rules (macOS frosted glass vibrancy)
hl.layer_rule({ "blur", "quickshell:bar" })
hl.layer_rule({ "ignorealpha 0.1", "quickshell:bar" })
EOF
            success "Added layer rules to settings.lua."
        fi
    fi
}

# ------------------------------------------------------------------------------
# 5. Switchover Processes & Reload Hyprland
# ------------------------------------------------------------------------------
apply_live_switchover() {
    info "Stopping old shell instances..."
    killall -9 quickshell 2>/dev/null || true
    if command -v serpantinumd &>/dev/null; then
        serpantinumd stop 2>/dev/null || true
    fi

    sleep 1

    info "Starting newly installed SoftShell in Hyprland session..."
    if command -v hyprctl &>/dev/null; then
        hyprctl dispatch "hl.dsp.exec_cmd('quickshell')" &>/dev/null || nohup quickshell >/dev/null 2>&1 &
    else
        nohup quickshell >/dev/null 2>&1 &
    fi

    sleep 1

    info "Reloading Hyprland configuration..."
    hyprctl reload &>/dev/null || true

    success "Live switchover complete!"
}

# ------------------------------------------------------------------------------
# Main Entry Point
# ------------------------------------------------------------------------------
main() {
    banner

    case "$1" in
        --check-deps)
            check_and_install_dependencies
            exit 0
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTION]"
            echo ""
            echo "Options:"
            echo "  (none)        Full install: verify deps, backup configs, deploy SoftShell & switchover."
            echo "  --check-deps  Only check and install dependencies."
            echo "  --no-switch   Deploy configs and backup without stopping or starting live processes."
            echo "  --help, -h    Display this help message."
            exit 0
            ;;
        --no-switch)
            check_and_install_dependencies
            create_backup
            deploy_softshell
            configure_hyprland
            success "SoftShell installed without live process restart."
            exit 0
            ;;
        *)
            check_and_install_dependencies
            create_backup
            deploy_softshell
            configure_hyprland
            apply_live_switchover
            ;;
    esac

    echo -e "\n${GREEN}${BOLD}======================================================${NC}"
    echo -e "${GREEN}${BOLD} SoftShell Installation Finished Successfully!        ${NC}"
    echo -e "${GREEN}${BOLD}======================================================${NC}"
    echo -e "• Dynamic Island Notch: Active at top of monitor"
    echo -e "• macOS Menu Bar: Thin translucent frosted glass with Apple controls"
    echo -e "• Launcher: Press ${CYAN}Super + A${NC} or ${CYAN}Super + D${NC} to toggle"
    echo -e "• Shell Config Directory: ${CYAN}~/.config/quickshell${NC}"
    echo -e "• Rollback Available: ${CYAN}$CURRENT_BACKUP_DIR/rollback.sh${NC}\n"
}

main "$@"
