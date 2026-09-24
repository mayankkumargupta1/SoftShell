#!/usr/bin/env bash
# ==============================================================================
# SoftShell Theme Generator
# ==============================================================================
# Single responsibility: derive a flat accent palette from the current wallpaper
# using matugen and publish it atomically to ~/.config/softshell/colors.json.
#
# Usage: theme_from_wallpaper.sh [wallpaper_path]
#   With no argument the current wallpaper is read from wallpaper.conf.
# ==============================================================================

set -eo pipefail

CONFIG_DIR="$HOME/.config/softshell"
STATE_FILE="$CONFIG_DIR/wallpaper.conf"
OUT_FILE="$CONFIG_DIR/colors.json"

die() {
    echo "Error: $1" >&2
    exit 1
}

command -v matugen >/dev/null 2>&1 || die "matugen is not installed."
command -v jq >/dev/null 2>&1 || die "jq is not installed."

# ------------------------------------------------------------------------------
# Resolve the source wallpaper
# ------------------------------------------------------------------------------
WP="${1:-}"
if [ -z "$WP" ]; then
    [ -f "$STATE_FILE" ] || die "no wallpaper state file at $STATE_FILE."
    WP="$(head -n 1 "$STATE_FILE" | tr -d '\r')"
fi
[ -n "$WP" ] || die "no wallpaper path could be resolved."
[ -f "$WP" ] || die "wallpaper '$WP' does not exist."

mkdir -p "$CONFIG_DIR"

# ------------------------------------------------------------------------------
# Video wallpapers: matugen cannot decode them, so extract a single frame
# ------------------------------------------------------------------------------
SRC="$WP"
FRAME=""
cleanup() {
    if [ -n "$FRAME" ]; then
        rm -f "$FRAME"
    fi
    return 0
}
trap cleanup EXIT

case "${WP,,}" in
    *.mp4 | *.webm | *.mkv | *.mov)
        command -v ffmpeg >/dev/null 2>&1 ||
            die "'$WP' is a video wallpaper; ffmpeg is required to extract a frame."
        FRAME="$(mktemp "${TMPDIR:-/tmp}/softshell-frame.XXXXXX.png")"
        # Prefer a frame 1s in (skips fade-ins); fall back to the very first frame
        # for clips shorter than a second, where seeking lands past the end.
        ffmpeg -y -loglevel error -ss 1 -i "$WP" -frames:v 1 "$FRAME" </dev/null || true
        if [ ! -s "$FRAME" ]; then
            ffmpeg -y -loglevel error -i "$WP" -frames:v 1 "$FRAME" </dev/null || true
        fi
        [ -s "$FRAME" ] || die "could not extract a frame from '$WP'."
        SRC="$FRAME"
        ;;
esac

# ------------------------------------------------------------------------------
# Generate the palette (dark scheme, no templates written, no apps reloaded)
# ------------------------------------------------------------------------------
if ! RAW="$(matugen image "$SRC" --json hex --dry-run --quiet --mode dark --prefer saturation)"; then
    die "matugen failed to generate a palette for '$SRC'."
fi

TMP="$(mktemp "$OUT_FILE.XXXXXX")"
if ! printf '%s' "$RAW" | jq --arg wp "$WP" '
    .colors as $c | {
        wallpaper:  $wp,
        source:     $c.source_color.dark.color,
        primary:    $c.primary.dark.color,
        secondary:  $c.secondary.dark.color,
        tertiary:   $c.tertiary.dark.color,
        surface:    $c.surface.dark.color,
        onSurface:  $c.on_surface.dark.color,
        accent:     $c.primary.dark.color,
        accentAlt:  $c.tertiary.dark.color
    } | with_entries(select(.value != null))
' >"$TMP"; then
    rm -f "$TMP"
    die "failed to reduce the matugen output to a flat palette."
fi

jq -e '.accent' "$TMP" >/dev/null 2>&1 || {
    rm -f "$TMP"
    die "generated palette is missing an accent color."
}

chmod 644 "$TMP"
mv -f "$TMP" "$OUT_FILE"
cat "$OUT_FILE"
