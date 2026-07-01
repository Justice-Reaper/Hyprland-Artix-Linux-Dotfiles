#!/bin/bash

dir="/home/justice-reaper/.config/rofi/power-menu"
lock='󵀒'
logout='󵀓'
suspend='󵀟'
reboot='󵀛'
shutdown='󵀚'

rofi_cmd() {
    rofi -dmenu \
        -x11 \
        -normal-window \
        -theme "${dir}/style.rasi"
}

run_rofi() {
    echo -e "$shutdown\n$logout\n$lock\n$suspend\n$reboot" | rofi_cmd
}

chosen="$(run_rofi)"

case "${chosen}" in
    "$lock")
        swaylock
        ;;
    "$logout")
        hyprctl dispatch 'hl.dsp.exit()'
        ;;
    "$suspend")
        loginctl suspend
        ;;
    "$reboot")
        loginctl reboot
        ;;
    "$shutdown")
        loginctl poweroff
        ;;
esac
