#!/bin/bash
exec 2>/dev/null

ICON_WIFI="󵀧"
ICON_ETH="󵀦"
ICON_OFF="󵀥"

default_interface=$(ip route show default | awk 'NR==1{print $5}')

if [ -n "$default_interface" ]; then
    ip_address=$(ip -4 -o addr show "$default_interface" | awk '{print $4}' | cut -d'/' -f1)
    case "$default_interface" in
        wl*) icon="$ICON_WIFI"; class="wifi" ;;
        *)   icon="$ICON_ETH"; class="ethernet" ;;
    esac
fi

if [ -z "$ip_address" ]; then
    ip_address="Disconnected"
    icon="$ICON_OFF"
    class="disconnected"
fi

echo "{\"text\": \"$icon $ip_address\", \"class\": \"$class\", \"tooltip\": \"${default_interface:-none}: $ip_address\"}"
