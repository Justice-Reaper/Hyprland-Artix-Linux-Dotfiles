#!/bin/bash
# Pure reader for the system tray in rofi. All the D-Bus work (enumerating items,
# resolving names/icons, activating) lives in hyprland-minimizer; this script only
# reads its output and renders the rofi menu.

dir="/home/justice-reaper/.config/rofi/tray"

if [ ! "${ROFI_RETV+set}" = "set" ]; then
    rofi -show tray -modi "tray:$0" -x11 -normal-window -theme "${dir}/style.rasi"
    exit 0
fi

state="${ROFI_DATA:-list}"

show_list() {
    echo -en "\0data\x1flist\n"
    echo -en "\0prompt\x1fTray\n"
    echo -en "\0no-custom\x1ftrue\n"

    hyprland-minimizer list-tray | while IFS='|' read -r name icon bus path pid; do
        echo -en "${name}\0icon\x1f${icon}\x1finfo\x1f${bus}|${path}|${pid}\n"
    done
}

show_actions() {
    echo -en "\0data\x1f${ROFI_INFO}\n"
    echo -en "\0prompt\x1fAction\n"
    echo -en "\0no-custom\x1ftrue\n"
    echo -en "Open\0icon\x1fgo-next\x1finfo\x1fopen\n"
    echo -en "Close\0icon\x1fwindow-close\x1finfo\x1fclose\n"
}

case "$state" in
    list)
        case "${ROFI_RETV}" in
            0) show_list ;;
            1) show_actions ;;
        esac
        ;;
    *)
        IFS='|' read -r bus path pid <<< "$state"
        case "$ROFI_INFO" in
            open)
                hyprland-minimizer tray-activate "$bus" "$path"
                show_list
                ;;
            close)
                hyprland-minimizer tray-close "$bus" "$path" "$pid"
                show_list
                ;;
        esac
        ;;
esac
