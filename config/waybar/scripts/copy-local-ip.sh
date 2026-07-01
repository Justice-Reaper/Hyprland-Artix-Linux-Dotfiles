#!/bin/bash

wifi_interface=$(ip -o link show | awk -F': ' '{print $2}' | grep "wl")
ethernet_interface=$(ip -o link show | awk -F': ' '{print $2}' | grep "en\|eth")

ip_address_wifi=$(ip addr show $wifi_interface 2>/dev/null | awk '/inet / {print $2}' | cut -d'/' -f1)
if [ -n "$ip_address_wifi" ]; then
    ip_address=$ip_address_wifi
fi

ip_address_ethernet=$(ip addr show $ethernet_interface 2>/dev/null | awk '/inet / {print $2}' | cut -d'/' -f1)
if [ -n "$ip_address_ethernet" ]; then
    ip_address=$ip_address_ethernet
fi

echo -n "$ip_address" | wl-copy
