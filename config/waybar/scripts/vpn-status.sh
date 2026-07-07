#!/bin/bash

icon_on="<span color='#70A5EB'>󵀤</span>"
icon_off="<span color='#70A5EB'>󵀣</span>"

if ip link show tun0 &>/dev/null; then
    ip_address=$(ip -4 -o addr show tun0 | awk '{print $4}' | cut -d'/' -f1)
    echo "{\"text\": \"$icon_on $ip_address\", \"class\": \"connected\", \"tooltip\": \"VPN: $ip_address\"}"
else
    echo "{\"text\": \"$icon_off Disconnected\", \"class\": \"disconnected\", \"tooltip\": \"VPN: Disconnected\"}"
fi
