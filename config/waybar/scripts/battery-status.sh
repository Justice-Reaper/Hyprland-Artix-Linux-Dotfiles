#!/bin/bash

bat=/sys/class/power_supply/BAT0
ac=/sys/class/power_supply/ACAD
cfg=/home/justice-reaper/.config
frame_file=$cfg/bin/battery-charge-frame
state_file=$cfg/bin/battery-state
icons=$cfg/waybar/icons

# charging animation frames: empty -> full (cycled while charging)
charging_icons=("󵀋" "󵀀" "󵀁" "󵀂" "󵀃" "󵀄" "󵀅" "󵀆" "󵀇" "󵀈" "󵀌")
# discharging level icons, indexed by get_index (0 = <10% ... 10 = 100%)
discharge_icons=("󵀉" "󵀀" "󵀁" "󵀂" "󵀃" "󵀄" "󵀅" "󵀆" "󵀇" "󵀈" "󵀌")

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
ac_online=$(cat "$ac/online" 2>/dev/null || echo 0)

state=$(cat "$state_file" 2>/dev/null)

if [ "$ac_online" = "0" ]; then
    # Sin corriente: solo avisamos de batería baja
    if [ "$capacity" -le 10 ] && [ "$state" != "warning" ]; then
        echo 'warning' > "$state_file"
        notify-send "Low Battery" "${capacity}% of battery remaining" -u critical -c battery-critical -i "$icons/battery-warning.png" -r 9991
    elif [ "$capacity" -gt 10 ]; then
        echo 'discharging' > "$state_file"
    fi
else
    # Con corriente conectada
    if [ "$state" = "discharging" ] || [ "$state" = "warning" ]; then
        # Acabamos de enchufar el cargador: avisamos siempre, entra corriente
        # aunque estemos al 100% y no se cargue nada
        notify-send "Charging" "${capacity}% of battery charged" -u normal -c battery-normal -i "$icons/battery-charging.png" -r 9991
        if [ "$capacity" -eq 100 ]; then
            echo 'fully_charged' > "$state_file"
        else
            echo 'charging' > "$state_file"
        fi
    elif [ "$state" = "charging" ] && [ "$capacity" -eq 100 ]; then
        # Estaba cargando y ha llegado al 100%
        echo 'fully_charged' > "$state_file"
        notify-send "Battery Charged" "Battery is fully charged" -u normal -c battery-normal -i "$icons/battery-fully-charged.png" -r 9991
    fi
fi

if [ "$status" = "Charging" ]; then
    frame=$(cat "$frame_file" 2>/dev/null || echo 0)
    idx=$((frame % 11))
    echo "{\"text\": \"${charging_icons[$idx]} $capacity%\", \"class\": \"charging\"}"
elif [ "$status" = "Full" ]; then
    echo "{\"text\": \"󵀊 100%\", \"class\": \"full\"}"
else
    idx=$(get_index "$capacity")
    if [ "$capacity" -le 10 ]; then
        class="critical"
    elif [ "$capacity" -le 20 ]; then
        class="warning"
    else
        class="discharging"
    fi
    echo "{\"text\": \"${discharge_icons[$idx]} $capacity%\", \"class\": \"$class\"}"
fi
