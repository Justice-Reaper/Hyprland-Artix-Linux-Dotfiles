#!/bin/bash
exec 2>/dev/null

ICON_ON="󵀤"
ICON_OFF="󵀣"

if ip link show tun0 &>/dev/null; then
    ip_address=$(ip -4 -o addr show tun0 | awk '{print $4}' | cut -d'/' -f1)
    echo "{\"text\": \"$ICON_ON $ip_address\", \"class\": \"connected\", \"tooltip\": \"VPN: $ip_address\"}"
else
    echo "{\"text\": \"$ICON_OFF Disconnected\", \"class\": \"disconnected\", \"tooltip\": \"VPN: Disconnected\"}"
fi
