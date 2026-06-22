#!/bin/bash

bat=/sys/class/power_supply/BAT0
frame_file=/tmp/battery-charge-frame

cleanup() {
    kill $(jobs -p) 2>/dev/null
    exit 0
}
trap cleanup EXIT INT TERM
trap : USR1

echo 0 > "$frame_file"

pkill -SIGRTMIN+11 waybar

monitor_pid=$$
(upower --monitor 2>/dev/null | while read -r _; do
    pkill -SIGRTMIN+11 waybar
    kill -USR1 $monitor_pid 2>/dev/null
done) &

while true; do
    status=$(cat "$bat/status" 2>/dev/null)
    if [ "$status" = "Charging" ]; then
        frame=$(cat "$frame_file" 2>/dev/null || echo 0)
        echo $(( (frame + 1) % 6 )) > "$frame_file"
        pkill -SIGRTMIN+11 waybar
        sleep 0.75
    else
        echo 0 > "$frame_file"
        wait
    fi
done
