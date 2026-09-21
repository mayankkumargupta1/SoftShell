#!/usr/bin/env bash
# screenshot.sh — SoftShell screenshot capture + annotation + Dynamic Island indicator
#
# Usage:
#   screenshot.sh region   — select an area with slurp, capture with grim,
#                            open swappy for annotation, save, notify island
#   screenshot.sh screen   — capture the focused monitor, then annotate, save, notify
#
# Saves to ~/Pictures/Screenshots/screenshot-YYYY-MM-DD_HH-MM-SS.png
# If swappy is not installed, falls back to saving the raw capture (no annotation).
# Cancelling the region selection (Esc) aborts silently — no error notification.

set -u

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR" 2>/dev/null || exit 1

TS="$(date +%Y-%m-%d_%H-%M-%S)"
OUT="$SAVE_DIR/screenshot-$TS.png"
TMP="/tmp/softshell-screenshot-$TS.png"

mode="${1:-region}"

case "$mode" in
    region)
        # Interactive area selection; cancelled (Esc) -> silent abort
        GEOM="$(slurp)" || exit 1
        grim -g "$GEOM" "$TMP" || exit 1
        ;;
    screen)
        # Focused monitor via Hyprland (no jq needed); falls back to full composite
        MON="$(hyprctl activeworkspace -j 2>/dev/null | grep -oP '"monitor":\s*"\K[^"]+' | head -1)"
        if [ -n "$MON" ]; then
            grim -o "$MON" "$TMP" || exit 1
        else
            grim "$TMP" || exit 1
        fi
        ;;
    *)
        echo "usage: $0 {region|screen}" >&2
        exit 2
        ;;
esac

# Annotation pass (skip gracefully when swappy is missing)
if command -v swappy >/dev/null 2>&1; then
    swappy -f "$TMP" -o "$OUT" || { rm -f "$TMP"; exit 1; }
else
    cp "$TMP" "$OUT"
fi
rm -f "$TMP"

# Only indicate after a file was actually saved
if [ -f "$OUT" ]; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "Screenshot" "Screenshot saved" "$OUT" || true
    fi
fi