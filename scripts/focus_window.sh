#!/usr/bin/env bash
# ==============================================================================
# SoftShell Window Focus Helper
# ==============================================================================
# Focuses the Hyprland client window associated with an incoming notification.
# Usage: focus_window.sh "<appName>" "<summary>"
# ==============================================================================

APP_NAME="${1:-}"
SUMMARY="${2:-}"

# Filter out generic notification daemon names
if [[ "${APP_NAME,,}" =~ ^(notify-send|notification|system|dunst|mako)$ ]]; then
    APP_NAME=""
fi

# Construct Lua matching script for Hyprland
LUA_SCRIPT=$(cat <<EOF
local app = string.lower([==[${APP_NAME}]==])
local sum = string.lower([==[${SUMMARY}]==])
local wins = hl.get_windows()

local function matches(query, w)
    if not query or #query < 2 then return false end
    local c = string.lower(w.class or "")
    local ic = string.lower(w.initialClass or "")
    local t = string.lower(w.title or "")
    local it = string.lower(w.initialTitle or "")
    return string.find(c, query, 1, true)
        or string.find(ic, query, 1, true)
        or string.find(t, query, 1, true)
        or string.find(it, query, 1, true)
end

-- 1. Try matching appName against class, initialClass, or title
if #app > 0 then
    for _, w in ipairs(wins) do
        if matches(app, w) then
            hl.dispatch(hl.dsp.focus({ window = w }))
            return "focused"
        end
    end
end

-- 2. Try matching summary
if #sum > 0 then
    for _, w in ipairs(wins) do
        if matches(sum, w) then
            hl.dispatch(hl.dsp.focus({ window = w }))
            return "focused"
        end
    end

    -- Try first word of summary if multi-word
    local first_word = sum:match("(%w+)")
    if first_word and #first_word >= 3 and first_word ~= app then
        for _, w in ipairs(wins) do
            if matches(first_word, w) then
                hl.dispatch(hl.dsp.focus({ window = w }))
                return "focused"
            end
        end
    end
end

-- 3. Fallback for Web Apps (e.g. WhatsApp, Slack, Mail running inside a browser)
local web_apps = {
    whatsapp = true,
    telegram = true,
    discord = true,
    slack = true,
    mail = true,
    gmail = true,
    youtube = true,
    music = true
}

if web_apps[app] or web_apps[sum] then
    for _, w in ipairs(wins) do
        local c = string.lower(w.class or "")
        if string.find(c, "brave", 1, true) or string.find(c, "chrome", 1, true) or string.find(c, "firefox", 1, true) or string.find(c, "chromium", 1, true) then
            hl.dispatch(hl.dsp.focus({ window = w }))
            return "focused_browser_fallback"
        end
    end
end

return "not found"
EOF
)

hyprctl eval "$LUA_SCRIPT" >/dev/null 2>&1 || true
