#!/bin/bash

icon_on="<span color='#70A5EB'>󵀐</span>"
icon_off="<span color='#70A5EB'>󵀏</span>"

nightlight="/home/justice-reaper/.config/bin/nightlight"
nightlight_status="/home/justice-reaper/.config/bin/nightlight-status"
neutral=6500
step=275

get_temp() {
    if [ -f "$nightlight" ]; then
        cat "$nightlight"
    else
        echo 3750
    fi
}

get_status() {
    if [ -f "$nightlight_status" ]; then
        cat "$nightlight_status"
    else
        echo Off
    fi
}

set_kelvin() {
    busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q "$1"
}

get_kelvin() {
    busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature 2>/dev/null | awk '{print $2}'
}

to_percent() {
    echo $(( (neutral - $1) * 100 / (neutral - 1000) ))
}

case $1 in
    toggle|increase|decrease)
        exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-nightlight.lock"
        if ! flock -n 9; then
            exit 0
        fi
        ;;
esac

case $1 in
    toggle)
        if [ "$(get_status)" = "On" ]; then
            echo Off > "$nightlight_status"
            pkill -SIGRTMIN+1 waybar
            set_kelvin "$neutral"
        else
            echo On > "$nightlight_status"
            pkill -SIGRTMIN+1 waybar
            set_kelvin "$(get_temp)"
        fi
        ;;
    increase|decrease)
        if [ "$(get_status)" != "On" ]; then
            exit 0
        fi
        if [ "$1" = "increase" ]; then
            delta="-$step"
        else
            delta="$step"
        fi
        busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n "$delta"
        kelvin=$(get_kelvin)
        if [ -n "$kelvin" ]; then
            if [ "$kelvin" -gt "$neutral" ]; then
                kelvin=$neutral
                set_kelvin "$neutral"
            elif [ "$kelvin" -lt 1000 ]; then
                kelvin=1000
                set_kelvin 1000
            fi
            echo "$kelvin" > "$nightlight"
        fi
        pkill -SIGRTMIN+1 waybar
        ;;
    temperature)
        if [ "$(get_status)" = "On" ]; then
            kelvin=$(get_temp)
            echo "{\"text\": \"$icon_on $(to_percent "$kelvin")%\", \"class\": \"on\"}"
        else
            echo "{\"text\": \"$icon_off Off\", \"class\": \"off\"}"
        fi
        ;;
    restore)
        for _ in $(seq 1 50); do
            if busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature >/dev/null 2>&1; then
                break
            fi
            sleep 0.1
        done
        if [ "$(get_status)" = "On" ]; then
            set_kelvin "$(get_temp)"
        else
            set_kelvin "$neutral"
        fi
        ;;
esac
