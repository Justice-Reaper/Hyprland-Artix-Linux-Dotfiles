#!/bin/bash

dir="/home/justice-reaper/.config/rofi/manager"

chosen=$(echo -e "󵀚 Power\n󵀙 Launcher\n󵀠 Tray\n󵀖 WiFi\n󵀘 Audio\n󵀗 Bluetooth" | rofi -dmenu -x11 -normal-window -theme "${dir}/style.rasi")

case "${chosen}" in
    "󵀙 Launcher")
        /home/justice-reaper/.config/rofi/launcher/launcher.sh
        ;;
    "󵀠 Tray")
        /home/justice-reaper/.config/rofi/tray/tray.sh
        ;;
    "󵀖 WiFi")
        nm-connection-editor &
        ;;
    "󵀘 Audio")
        pavucontrol &
        ;;
    "󵀗 Bluetooth")
        blueman-manager &
        ;;
    "󵀚 Power")
        /home/justice-reaper/.config/rofi/power-menu/power-menu.sh
        ;;
esac
