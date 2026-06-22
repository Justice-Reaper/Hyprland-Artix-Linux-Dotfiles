#!/bin/bash

dir="/home/justice-reaper/.config/rofi/manager"

chosen=$(echo -e "WiFi\nAudio\nBluetooth\nTray" | rofi -dmenu -x11 -normal-window -theme "${dir}/style.rasi")

case ${chosen} in
    WiFi)
        nm-connection-editor &
        ;;
    Audio)
        pavucontrol &
        ;;
    Bluetooth)
        blueman-manager &
        ;;
    Tray)
        /home/justice-reaper/.config/rofi/tray/tray.sh
        ;;
esac
