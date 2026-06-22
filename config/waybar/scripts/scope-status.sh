#!/bin/bash
exec 2>/dev/null

ICON_ACTIVE=$(printf '\U000F501D')
ICON_EMPTY=$(printf '\U000F501C')

scope="/home/justice-reaper/.config/bin/scope"
assets=0
[ -f "$scope" ] && assets=$(grep -c '[^[:space:]]' "$scope")

if [ "$assets" -eq 0 ]; then
    printf '{"text": "%s No Scope", "class": "empty", "tooltip": "No targets in scope"}\n' "$ICON_EMPTY"
else
    printf '{"text": "%s Scope (%d)", "class": "active", "tooltip": "Scope: %d assets"}\n' "$ICON_ACTIVE" "$assets" "$assets"
fi
