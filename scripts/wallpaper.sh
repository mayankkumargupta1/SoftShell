#!/usr/bin/env bash
# ==============================================================================
# SoftShell Wallpaper Manager
# ==============================================================================
# Manages desktop wallpapers from ~/Pictures/Wallpapers (or ~/Pictures/wallpaper)
# Supports static images (.jpg, .png, .webp) and animated videos (.mp4, .webm)
# ==============================================================================

set -eo pipefail

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALLPAPER_DIR" ] && [ -d "$HOME/Pictures/wallpaper" ]; then
    WALLPAPER_DIR="$HOME/Pictures/wallpaper"
fi

CONFIG_DIR="$HOME/.config/softshell"
STATE_FILE="$CONFIG_DIR/wallpaper.conf"
LOCK_FILE="$CONFIG_DIR/.wallpaper.lock"

mkdir -p "$CONFIG_DIR"

# Collect valid wallpaper files (images + videos)
get_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "Error: Directory $WALLPAPER_DIR does not exist." >&2
        return 1
    fi
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.mp4" -o -iname "*.webm" \
    \) | sort -f
}

get_current() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        get_wallpapers | head -n 1
    fi
}

apply_wallpaper() {
    local target="$1"
    if [ ! -f "$target" ]; then
        echo "Error: Wallpaper file '$target' does not exist." >&2
        return 1
    fi

    # Acquire exclusive lock to prevent startup race conditions
    exec 200>"$LOCK_FILE"
    flock -x 200

    # Stop and clean up any previous wallpaper instance
    systemctl --user stop --no-block softshell-wallpaper.service 2>/dev/null || true
    systemctl --user reset-failed softshell-wallpaper.service 2>/dev/null || true
    pkill -x mpvpaper 2>/dev/null || true
    for _ in {1..10}; do
        pgrep -x mpvpaper >/dev/null 2>&1 || break
        sleep 0.05
    done
    pkill -9 -x mpvpaper 2>/dev/null || true

    # Launch with systemd-run --user for robust daemon management, fallback to setsid
    # TimeoutStopSec=2s prevents systemd from hanging for 90s on stop
    # panscan=1.0 scales and crops image/video to fill the entire monitor (object-fit: cover)
    local started=0
    if command -v systemd-run &>/dev/null; then
        systemctl --user reset-failed softshell-wallpaper.service 2>/dev/null || true
        if systemd-run --user --unit=softshell-wallpaper -p TimeoutStopSec=2s mpvpaper -p -o "no-audio loop panscan=1.0" ALL "$target" >/dev/null 2>&1; then
            started=1
        fi
    fi

    # Fallback to setsid / nohup if systemd-run is unavailable or fails
    if [ "$started" -eq 0 ]; then
        nohup setsid mpvpaper -p -o "no-audio loop panscan=1.0" ALL "$target" >/dev/null 2>&1 &
    fi
    
    echo "$target" > "$STATE_FILE"
    echo "Wallpaper set: $(basename "$target")"
}

case "$1" in
    list)
        get_wallpapers
        ;;
    current)
        get_current
        ;;
    set)
        if [ -z "$2" ]; then
            echo "Usage: $0 set <path_or_filename>" >&2
            exit 1
        fi
        if [ -f "$2" ]; then
            apply_wallpaper "$2"
        elif [ -f "$WALLPAPER_DIR/$2" ]; then
            apply_wallpaper "$WALLPAPER_DIR/$2"
        else
            echo "Error: Cannot find wallpaper '$2'" >&2
            exit 1
        fi
        ;;
    next)
        mapfile -t LIST < <(get_wallpapers)
        COUNT=${#LIST[@]}
        if [ "$COUNT" -eq 0 ]; then
            echo "No wallpapers found in $WALLPAPER_DIR" >&2
            exit 1
        fi

        CURRENT=$(get_current)
        NEXT_IDX=0
        for i in "${!LIST[@]}"; do
            if [ "${LIST[$i]}" = "$CURRENT" ]; then
                NEXT_IDX=$(( (i + 1) % COUNT ))
                break
            fi
        done
        apply_wallpaper "${LIST[$NEXT_IDX]}"
        ;;
    prev)
        mapfile -t LIST < <(get_wallpapers)
        COUNT=${#LIST[@]}
        if [ "$COUNT" -eq 0 ]; then
            echo "No wallpapers found in $WALLPAPER_DIR" >&2
            exit 1
        fi

        CURRENT=$(get_current)
        PREV_IDX=$(( COUNT - 1 ))
        for i in "${!LIST[@]}"; do
            if [ "${LIST[$i]}" = "$CURRENT" ]; then
                PREV_IDX=$(( (i - 1 + COUNT) % COUNT ))
                break
            fi
        done
        apply_wallpaper "${LIST[$PREV_IDX]}"
        ;;
    init|*)
        CURRENT=$(get_current)
        TARGET="$CURRENT"
        if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
            TARGET=$(get_wallpapers | head -n 1)
        fi

        if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
            echo "No wallpapers available in $WALLPAPER_DIR." >&2
            exit 1
        fi

        # If mpvpaper is already running and state file matches target, do nothing
        if pgrep -x mpvpaper >/dev/null 2>&1 && [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "$TARGET" ]; then
            echo "Wallpaper set: $(basename "$TARGET")"
            exit 0
        fi

        apply_wallpaper "$TARGET"
        ;;
esac
