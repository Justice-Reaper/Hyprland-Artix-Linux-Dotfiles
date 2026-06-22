#!/bin/bash

bat=/sys/class/power_supply/BAT0
frame_file=/tmp/battery-charge-frame
cfg=/home/justice-reaper/.config
state_file=$cfg/bin/battery-state
icons=$cfg/dunst/icons

charging_icons=($(printf '\U000F500B') $(printf '\U000F5000') $(printf '\U000F5001') $(printf '\U000F5002') $(printf '\U000F5003') $(printf '\U000F5004') $(printf '\U000F5005') $(printf '\U000F5006') $(printf '\U000F5007') $(printf '\U000F5008') $(printf '\U000F500C'))
discharge_icons=($(printf '\U000F500B') $(printf '\U000F5000') $(printf '\U000F5001') $(printf '\U000F5002') $(printf '\U000F5003') $(printf '\U000F5004') $(printf '\U000F5005') $(printf '\U000F5006') $(printf '\U000F5007') $(printf '\U000F5008') $(printf '\U000F500C'))

get_index() {
    local cap=$1
    if [ "$cap" -lt 10 ]; then echo 0
    elif [ "$cap" -lt 20 ]; then echo 1
    elif [ "$cap" -lt 30 ]; then echo 2
    elif [ "$cap" -lt 40 ]; then echo 3
    elif [ "$cap" -lt 50 ]; then echo 4
    elif [ "$cap" -lt 60 ]; then echo 5
    elif [ "$cap" -lt 70 ]; then echo 6
    elif [ "$cap" -lt 80 ]; then echo 7
    elif [ "$cap" -lt 90 ]; then echo 8
    elif [ "$cap" -lt 100 ]; then echo 9
    else echo 10
    fi
}

status=$(cat "$bat/status" 2>/dev/null)
capacity=$(cat "$bat/capacity" 2>/dev/null || echo 0)

state=$(cat "$state_file" 2>/dev/null)

if [ "$status" = "Discharging" ] && [ "$capacity" -le 10 ] && [ "$state" != "warning" ]; then
    echo 'warning' > "$state_file"
    notify-send "Low Battery" "${capacity}% of battery remaining" -u critical -c battery-critical -i "$icons/battery-warning.png" -r 9991
elif [ "$status" = "Discharging" ] && [ "$capacity" -gt 10 ] && [ "$capacity" -lt 100 ] && [ "$state" != "discharging" ]; then
    echo 'discharging' > "$state_file"
elif [ "$status" = "Charging" ] && [ "$capacity" -le 99 ] && [ "$state" != "charging" ]; then
    echo 'charging' > "$state_file"
    notify-send "Charging" "${capacity}% of battery charged" -u normal -c battery-normal -i "$icons/battery-charging.png" -r 9991
elif [ "$capacity" -eq 100 ] && [ "$state" != "fully_charged" ]; then
    echo 'fully_charged' > "$state_file"
    notify-send "Battery Charged" "Battery is fully charged" -u normal -c battery-normal -i "$icons/battery-fully-charged.png" -r 9991
fi

if [ "$status" = "Charging" ]; then
    frame=$(cat "$frame_file" 2>/dev/null || echo 0)
    idx=$((frame % 11))
    class="charging"
    printf '{"text": "%s %d%%", "class": "%s", "tooltip": "Charging: %d%%"}\n' "${charging_icons[$idx]}" "$capacity" "$class" "$capacity"
elif [ "$status" = "Full" ]; then
    printf '{"text": "%s 100%%", "class": "full", "tooltip": "Battery Full"}\n' "$(printf '\U000F500C')"
else
    idx=$(get_index "$capacity")
    if [ "$capacity" -le 10 ]; then
        class="critical"
    elif [ "$capacity" -le 20 ]; then
        class="warning"
    else
        class="discharging"
    fi
    printf '{"text": "%s %d%%", "class": "%s", "tooltip": "Discharging: %d%%"}\n' "${discharge_icons[$idx]}" "$capacity" "$class" "$capacity"
fi
