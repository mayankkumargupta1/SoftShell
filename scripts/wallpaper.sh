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

    # Stop any previous wallpaper instance
    systemctl --user stop softshell-wallpaper.service 2>/dev/null || true
    killall -q mpvpaper 2>/dev/null || true
    sleep 0.1

    # Detect all active monitors from Hyprland
    local MONITORS=""
    if command -v hyprctl &>/dev/null; then
        MONITORS=$(hyprctl monitors 2>/dev/null | grep -E "^Monitor " | awk '{print $2}' || true)
    fi
    if [ -z "$MONITORS" ]; then
        MONITORS="*"
    fi

    # Launch with systemd-run --user for robust daemon management, fallback to setsid
    # panscan=1.0 scales and crops image/video to fill the entire monitor (object-fit: cover)
    if command -v systemd-run &>/dev/null; then
        for mon in $MONITORS; do
            systemd-run --user --unit=softshell-wallpaper mpvpaper -o "no-audio loop panscan=1.0" "$mon" "$target" >/dev/null 2>&1
        done
    else
        for mon in $MONITORS; do
            nohup setsid mpvpaper -p -f -o "no-audio loop panscan=1.0" "$mon" "$target" >/dev/null 2>&1 &
        done
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
        if [ -n "$CURRENT" ] && [ -f "$CURRENT" ]; then
            apply_wallpaper "$CURRENT"
        else
            FIRST=$(get_wallpapers | head -n 1)
            if [ -n "$FIRST" ]; then
                apply_wallpaper "$FIRST"
            else
                echo "No wallpapers available in $WALLPAPER_DIR." >&2
            fi
        fi
        ;;
esac
