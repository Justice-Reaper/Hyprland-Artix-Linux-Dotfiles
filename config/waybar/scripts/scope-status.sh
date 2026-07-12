#!/bin/bash

icon_active="<span color='#70A5EB'>󵀝</span>"
icon_empty="<span color='#70A5EB'>󵀜</span>"

scope="/home/justice-reaper/.config/bin/scope"

assets=0

[ -f "$scope" ] && assets=$(grep -c '[^[:space:]]' "$scope")

if [ "$assets" -eq 0 ]; then
    echo "{\"text\": \"$icon_empty No Scope\", \"class\": \"empty\", \"tooltip\": \"No targets in scope\"}"
else
    echo "{\"text\": \"$icon_active Scope ($assets)\", \"class\": \"active\", \"tooltip\": \"Scope: $assets assets\"}"
fi
