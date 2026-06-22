#!/bin/bash
exec 2>/dev/null

ICON_ON=$(printf '\U000F5021')
ICON_OFF=$(printf '\U000F5022')

if ip link show tun0 &>/dev/null; then
    ip_address=$(ip -4 -o addr show tun0 | awk '{print $4}' | cut -d'/' -f1)
    printf '{"text": "%s %s", "class": "connected", "tooltip": "VPN: %s"}\n' "$ICON_ON" "$ip_address" "$ip_address"
else
    printf '{"text": "%s Disconnected", "class": "disconnected", "tooltip": "VPN: Disconnected"}\n' "$ICON_OFF"
fi
