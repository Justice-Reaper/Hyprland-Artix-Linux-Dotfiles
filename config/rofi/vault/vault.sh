#!/bin/bash

dir="/home/justice-reaper/.config/rofi/vault"
common=(-dmenu -i -no-custom -format i -x11 -normal-window)
list_theme="${dir}/style-1.rasi"
menu_theme="${dir}/style-2.rasi"

run_menu() {
    local bus="$1" path="$2" pid="$3"
    local stack=(0)
    local parent lines entry label id kind idx
    local ids kinds disps

    while true; do
        parent="${stack[-1]}"
        mapfile -t lines < <(hyprland-minimizer tray-menu "$bus" "$path" "$parent")

        ids=("")
        kinds=("back")
        disps=("Go Back")
        for entry in "${lines[@]}"; do
            IFS=$'\x1f' read -r label id kind <<< "$entry"
            ids+=("$id")
            kinds+=("$kind")
            if [ "$kind" = "submenu" ]; then
                disps+=("$label ▸")
            else
                disps+=("$label")
            fi
        done

        local min_width=300 max_width=850 min_lines=1 max_lines=9
        local n="${#disps[@]}" maxlen=0 d
        for d in "${disps[@]}"; do
            if [ "${#d}" -gt "$maxlen" ]; then
                maxlen="${#d}"
            fi
        done
        local width=$(( maxlen * 14 ))
        if [ "$width" -lt "$min_width" ]; then
            width="$min_width"
        fi
        if [ "$width" -gt "$max_width" ]; then
            width="$max_width"
        fi
        if [ "$n" -lt "$min_lines" ]; then
            n="$min_lines"
        fi
        if [ "$n" -gt "$max_lines" ]; then
            n="$max_lines"
        fi
        local adapt="listview { lines: ${n}; } window { width: ${width}px; }"

        idx=$(printf '%s\n' "${disps[@]}" | rofi "${common[@]}" -theme "$menu_theme" -p Menu -theme-str "$adapt")
        if [ -z "$idx" ]; then
            return 1
        fi

        case "${kinds[$idx]}" in
            back)
                if [ "${#stack[@]}" -gt 1 ]; then
                    unset 'stack[-1]'
                else
                    return 0
                fi
                ;;
            submenu)
                stack+=("${ids[$idx]}")
                ;;
            *)
                hyprland-minimizer tray-menu-click "$bus" "$path" "${ids[$idx]}"
                return 1
                ;;
        esac
    done
}

while true; do
    mapfile -t rows < <(hyprland-minimizer list-tray mine)
    if [ "${#rows[@]}" -eq 0 ]; then
        exit 0
    fi

    idx=$(
        for r in "${rows[@]}"; do
            IFS=$'\x1f' read -r name icon bus path pid <<< "$r"
            printf '%s\0icon\x1f%s\n' "$name" "$icon"
        done | rofi "${common[@]}" -theme "$list_theme" -p Tray
    )
    if [ -z "$idx" ]; then
        exit 0
    fi

    IFS=$'\x1f' read -r name icon bus path pid <<< "${rows[$idx]}"
    if run_menu "$bus" "$path" "$pid"; then
        continue
    else
        exit 0
    fi
done
