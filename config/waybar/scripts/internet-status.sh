#!/bin/bash

icon_wifi="<span color='#70A5EB'>󵀨</span>"
icon_eth="<span color='#70A5EB'>󵀧</span>"
icon_off="<span color='#70A5EB'>󵀦</span>"

default_interface=$(ip route show default | awk 'NR==1{print $5}')

if [ -n "$default_interface" ]; then
    ip_address=$(ip -4 -o addr show "$default_interface" | awk '{print $4}' | cut -d'/' -f1)
    case "$default_interface" in
        wl*) icon="$icon_wifi"; class="wifi" ;;
        *)   icon="$icon_eth"; class="ethernet" ;;
    esac
fi

if [ -z "$ip_address" ]; then
    ip_address="Disconnected"
    icon="$icon_off"
    class="disconnected"
fi

echo "{\"text\": \"$icon $ip_address\", \"class\": \"$class\", \"tooltip\": \"${default_interface:-none}: $ip_address\"}"
