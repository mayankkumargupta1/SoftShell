#!/usr/bin/env bash
# ==============================================================================
# network.sh — NetworkManager / nmcli backend for SoftShell Network Popover
# ==============================================================================

set -eo pipefail

get_status() {
    python3 -c "
import subprocess, json

def get_status():
    wifi_radio = subprocess.getoutput('nmcli radio wifi').strip()
    wifi_enabled = (wifi_radio == 'enabled')
    
    active_wifi = None
    if wifi_enabled:
        out = subprocess.getoutput('nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY,BSSID dev wifi list')
        for line in out.splitlines():
            parts = line.split(':')
            if len(parts) >= 4 and parts[0] == '*':
                ssid = parts[1].strip()
                signal = int(parts[2]) if parts[2].isdigit() else 0
                sec = parts[3].strip()
                active_wifi = {
                    'ssid': ssid,
                    'signal': signal,
                    'security': sec,
                    'isSecured': len(sec) > 0 and sec != '--',
                    'isKnown': True,
                    'inUse': True
                }
                break

    # If active_wifi was not found via list (sometimes takes a moment), check active connection
    if not active_wifi and wifi_enabled:
        active_con = subprocess.getoutput(\"nmcli -t -f NAME,TYPE connection show --active | grep ':802-11-wireless' | head -1\").strip()
        if active_con:
            ssid = active_con.split(':')[0]
            active_wifi = {
                'ssid': ssid,
                'signal': 70,
                'security': 'WPA2',
                'isSecured': True,
                'isKnown': True,
                'inUse': True
            }

    # Known connections
    known = []
    con_out = subprocess.getoutput('nmcli -t -f NAME,TYPE connection show')
    for line in con_out.splitlines():
        parts = line.split(':')
        if len(parts) >= 2 and parts[1] == '802-11-wireless':
            known.append(parts[0])

    # Ethernet
    eth_device = 'eth0'
    eth_state = 'unavailable'
    dev_out = subprocess.getoutput('nmcli -t -f DEVICE,TYPE,STATE dev')
    for line in dev_out.splitlines():
        parts = line.split(':')
        if len(parts) >= 3 and parts[1] == 'ethernet':
            eth_device = parts[0]
            eth_state = parts[2]
            break

    print(json.dumps({
        'wifiEnabled': wifi_enabled,
        'activeWifi': active_wifi,
        'knownNetworks': known,
        'ethernet': {
            'device': eth_device,
            'state': eth_state
        }
    }))

get_status()
" 2>/dev/null || echo '{"wifiEnabled":false,"activeWifi":null,"knownNetworks":[],"ethernet":{"device":"eth0","state":"unavailable"}}'
}

scan_networks() {
    python3 -c "
import subprocess, json

def scan_networks():
    wifi_radio = subprocess.getoutput('nmcli radio wifi').strip()
    if wifi_radio != 'enabled':
        print('[]')
        return

    # Trigger rescan in background if possible, don't block
    subprocess.run(['nmcli', 'dev', 'wifi', 'rescan'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    con_out = subprocess.getoutput('nmcli -t -f NAME,TYPE connection show')
    known = set()
    for line in con_out.splitlines():
        parts = line.split(':')
        if len(parts) >= 2 and parts[1] == '802-11-wireless':
            known.add(parts[0])

    out = subprocess.getoutput('nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list')
    networks_map = {}
    for line in out.splitlines():
        parts = line.split(':')
        if len(parts) < 4:
            continue
        in_use = (parts[0].strip() == '*')
        ssid = parts[1].strip()
        if not ssid or ssid == '--':
            continue
        signal = int(parts[2]) if parts[2].isdigit() else 0
        sec = parts[3].strip()
        is_secured = len(sec) > 0 and sec != '--'
        is_known = ssid in known

        if ssid not in networks_map or signal > networks_map[ssid]['signal']:
            networks_map[ssid] = {
                'ssid': ssid,
                'signal': signal,
                'security': sec,
                'isSecured': is_secured,
                'isKnown': is_known,
                'inUse': in_use
            }

    sorted_nets = sorted(networks_map.values(), key=lambda x: (x['inUse'], x['isKnown'], x['signal']), reverse=True)
    print(json.dumps(sorted_nets))

scan_networks()
" 2>/dev/null || echo '[]'
}

toggle_wifi() {
    local target="$1"
    if [ "$target" = "off" ] || [ "$target" = "false" ]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
    get_status
}

connect_wifi() {
    local ssid="$1"
    local password="$2"
    local res=""

    if [ -n "$password" ]; then
        res=$(nmcli dev wifi connect "$ssid" password "$password" 2>&1) || {
            echo "{\"success\": false, \"error\": $(python3 -c "import json, sys; print(json.dumps(sys.argv[1]))" "$res")}"
            return 0
        }
    else
        res=$(nmcli dev wifi connect "$ssid" 2>&1) || {
            echo "{\"success\": false, \"error\": $(python3 -c "import json, sys; print(json.dumps(sys.argv[1]))" "$res")}"
            return 0
        }
    fi

    echo "{\"success\": true, \"message\": $(python3 -c "import json, sys; print(json.dumps(sys.argv[1]))" "$res")}"
}

forget_network() {
    local ssid="$1"
    nmcli connection delete id "$ssid" >/dev/null 2>&1 || true
    echo "{\"success\": true, \"ssid\": $(python3 -c "import json, sys; print(json.dumps(sys.argv[1]))" "$ssid")}"
}

disconnect_wifi() {
    local dev
    dev=$(nmcli -t -f DEVICE,TYPE dev | grep ':wifi$' | head -1 | cut -d: -f1)
    if [ -n "$dev" ]; then
        nmcli dev disconnect "$dev" >/dev/null 2>&1 || true
    fi
    get_status
}

case "$1" in
    status)
        get_status
        ;;
    scan)
        scan_networks
        ;;
    toggle-wifi)
        toggle_wifi "$2"
        ;;
    connect)
        connect_wifi "$2" "$3"
        ;;
    forget)
        forget_network "$2"
        ;;
    disconnect)
        disconnect_wifi
        ;;
    *)
        get_status
        ;;
esac
