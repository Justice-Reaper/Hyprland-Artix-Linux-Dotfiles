#!/bin/bash
exec 2>/dev/null

ICON_ACTIVE="󵀝"
ICON_EMPTY="󵀜"

scope="/home/justice-reaper/.config/bin/scope"
assets=0
[ -f "$scope" ] && assets=$(grep -c '[^[:space:]]' "$scope")

if [ "$assets" -eq 0 ]; then
    echo "{\"text\": \"$ICON_EMPTY No Scope\", \"class\": \"empty\", \"tooltip\": \"No targets in scope\"}"
else
    echo "{\"text\": \"$ICON_ACTIVE Scope ($assets)\", \"class\": \"active\", \"tooltip\": \"Scope: $assets assets\"}"
fi
