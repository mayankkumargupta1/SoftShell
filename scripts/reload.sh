#!/usr/bin/env bash
# reload.sh — SoftShell shell reload (bound to SUPER + R)
#
# Why this isn't "pkill -USR1 quickshell": in this Quickshell build SIGUSR1
# terminates the process rather than reloading it, and since pkill still exits 0
# any `|| quickshell` fallback never fires — the shell just dies and stays dead.
# A reload is therefore a clean stop + detached restart.
#
# Usage: reload.sh

set -u

# Stop the running instance (exact name match: ignores "quickshell ipc ..." helpers)
pkill -x quickshell 2>/dev/null || true

# Wait for the old instance to release its layer-shell surfaces and IPC socket.
# Restarting immediately can race the dying process for the same namespace.
for _ in $(seq 1 30); do
    pgrep -x quickshell >/dev/null 2>&1 || break
    sleep 0.1
done

# Detach so the new shell outlives this script (and Hyprland's exec_cmd parent)
setsid -f quickshell >/dev/null 2>&1