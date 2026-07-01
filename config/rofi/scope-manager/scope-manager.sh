#!/bin/bash

file="/home/justice-reaper/.config/bin/scope"
dir="/home/justice-reaper/.config/rofi/scope-manager"

mapfile -t domains < <(grep '[^[:space:]]' "$file" 2>/dev/null | sort -u)
assets="${#domains[@]}"

if [[ "$assets" -eq 0 ]]; then
    exit 0
fi

selection=$(printf '%s\n' "${domains[@]}" | rofi \
  -dmenu \
  -x11 \
  -normal-window \
  -p " " \
  -theme "${dir}/style.rasi"
)

if [[ -n "$selection" ]]; then
    echo -n "$selection" | wl-copy
fi
