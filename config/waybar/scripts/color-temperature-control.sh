#!/bin/bash

ICON_ON=$(printf '\U000F5010')
ICON_OFF=$(printf '\U000F500F')

nightlight_percentage_file=/home/justice-reaper/.config/bin/nightlight-percentage
nightlight_status_file=/home/justice-reaper/.config/bin/nightlight-status

nightlight_percentage=$(cat "$nightlight_percentage_file" 2>/dev/null || echo 0)
nightlight_status=$(cat "$nightlight_status_file" 2>/dev/null || echo Off)

apply() {
    local kelvin=$((6500 - (5500 * $1) / 100))
    if [ "$kelvin" -ge 1000 ] && [ "$kelvin" -le 6500 ]; then
        echo "$kelvin" > /home/justice-reaper/.config/bin/nightlight-kelvin
        echo "$1" > "$nightlight_percentage_file"
        busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q "$kelvin"
    fi
}

case $1 in
    toggle)
        if [ "$nightlight_status" = "On" ]; then
            echo 'Off' > "$nightlight_status_file"
            busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500
        else
            echo 'On' > "$nightlight_status_file"
            apply "$nightlight_percentage"
        fi
        pkill -SIGRTMIN+12 waybar
        ;;
    increase)
        [ "$nightlight_status" = "On" ] && apply $((nightlight_percentage + 5))
        pkill -SIGRTMIN+12 waybar
        ;;
    decrease)
        [ "$nightlight_status" = "On" ] && apply $((nightlight_percentage - 5))
        pkill -SIGRTMIN+12 waybar
        ;;
    temperature)
        if [ "$nightlight_status" = "On" ]; then
            printf '{"text": "%s %d%%", "class": "on", "tooltip": "Night Light: %d%%"}\n' "$ICON_ON" "$nightlight_percentage" "$nightlight_percentage"
        else
            printf '{"text": "%s Off", "class": "off", "tooltip": "Night Light: Off"}\n' "$ICON_OFF"
        fi
        ;;
esac
