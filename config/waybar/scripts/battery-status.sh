#!/bin/bash

battery=/sys/class/power_supply/BAT0
ac_adapter=/sys/class/power_supply/ACAD
icons=/home/justice-reaper/.config/waybar/icons

charging_icons=("󵀋" "󵀀" "󵀁" "󵀂" "󵀃" "󵀄" "󵀅" "󵀆" "󵀇" "󵀈" "󵀌")
discharge_icons=("󵀉" "󵀀" "󵀁" "󵀂" "󵀃" "󵀄" "󵀅" "󵀆" "󵀇" "󵀈" "󵀌")

frame=0
state=""

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

notify() {
    local status=$1 capacity=$2 ac_online=$3
    if [ "$ac_online" = "0" ]; then
        if [ "$capacity" -le 10 ] && [ "$state" != "warning" ]; then
            state="warning"
            notify-send "Low Battery" "${capacity}% of battery remaining" -u critical -c battery-critical -i "$icons/battery-warning.svg" -r 9991
        elif [ "$capacity" -gt 10 ]; then
            state="discharging"
        fi
    else
        if [ "$state" = "discharging" ] || [ "$state" = "warning" ]; then
            notify-send "Charging" "${capacity}% of battery charged" -u normal -c battery-normal -i "$icons/battery-charging.svg" -r 9991
            if [ "$capacity" -eq 100 ]; then
                state="fully_charged"
            else
                state="charging"
            fi
        elif [ "$state" = "charging" ] && [ "$capacity" -eq 100 ]; then
            state="fully_charged"
            notify-send "Battery Charged" "Battery is fully charged" -u normal -c battery-normal -i "$icons/battery-fully-charged.svg" -r 9991
        fi
    fi
}

render() {
    status=$(cat "$battery/status" 2>/dev/null)
    capacity=$(cat "$battery/capacity" 2>/dev/null || echo 0)
    local idx
    ac_online=$(cat "$ac_adapter/online" 2>/dev/null || echo 0)

    notify "$status" "$capacity" "$ac_online"

    if [ "$ac_online" = "1" ] && [ "$capacity" -lt 100 ]; then
        idx=$((frame % 11))
        echo "{\"text\": \"<span color='#70A5EB'>${charging_icons[$idx]}</span> $capacity%\"}"
    elif [ "$status" = "Full" ]; then
        echo "{\"text\": \"<span color='#70A5EB'>󵀊</span> 100%\"}"
    else
        idx=$(get_index "$capacity")
        echo "{\"text\": \"<span color='#70A5EB'>${discharge_icons[$idx]}</span> $capacity%\"}"
    fi
}

trap : USR1
main=$$
( upower --monitor 2>/dev/null | while read -r _; do kill -USR1 "$main" 2>/dev/null; done ) &

cleanup() {
    kill $(jobs -p) 2>/dev/null
    exit 0
}
trap cleanup EXIT INT TERM

while true; do
    render
    if [ "$ac_online" = "1" ] && [ "$capacity" -lt 100 ]; then
        frame=$(( (frame + 1) % 11 ))
        sleep 0.5
    else
        frame=0
        wait
    fi
done
