#!/bin/bash

wifi_interface=$(ip -o link show | awk -F': ' '{print $2}' | grep -m1 "^wl" | cut -d'@' -f1)
ethernet_interface=$(ip -o link show | awk -F': ' '{print $2}' | grep -m1 "^en\|^eth" | cut -d'@' -f1)

ip_address_wifi=$(ip addr show dev "$wifi_interface" 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d'/' -f1)
if [ -n "$ip_address_wifi" ]; then
    ip_address=$ip_address_wifi
fi

ip_address_ethernet=$(ip addr show dev "$ethernet_interface" 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d'/' -f1)
if [ -n "$ip_address_ethernet" ]; then
    ip_address=$ip_address_ethernet
fi

echo -n "$ip_address" | wl-copy
