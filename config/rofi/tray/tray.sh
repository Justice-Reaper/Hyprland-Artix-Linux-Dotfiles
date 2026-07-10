#!/bin/bash
# Tray menu in rofi. The D-Bus work (listing items, reading their menus and
# triggering entries) lives in hyprland-minimizer; this script just renders each
# level with its own "rofi -dmenu" call. Because every level is a separate rofi
# invocation, the tray list can show app icons while the menus stay icon-free
# (the icon column is dropped only for the menu levels).

dir="/home/justice-reaper/.config/rofi/tray"
common=(-dmenu -i -no-custom -format i -x11 -normal-window)
list_theme="${dir}/style-1.rasi"   # tray list: scope style with app icons
menu_theme="${dir}/style-2.rasi"   # menus: scope style, no icons, size injected below

# run_menu <bus> <path> <pid>
# Walks an item's menu, one level at a time. Returns 0 to go back to the tray
# list, 1 when an action was triggered or the user cancelled (close rofi).
run_menu() {
    local bus="$1" path="$2" pid="$3"
    local stack=(0)
    local parent lines entry label id kind idx
    local ids kinds disps

    while true; do
        parent="${stack[-1]}"
        mapfile -t lines < <(hyprland-minimizer tray-menu "$bus" "$path" "$parent")

        # entry 0 is always the "Go Back" navigation row
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

        # width = longest label * 14px, clamped to [min_width, max_width]. px is
        # computed in bash because this rofi build does NOT render a clamped
        # ch-based calc (calc(((Xch+60)max..)min..) stays stuck at the floor).
        # height = number of entries, clamped to [min_lines, max_lines]; over the
        # cap the scrollbar handles the overflow.
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
    mapfile -t rows < <(hyprland-minimizer list-tray)
    if [ "${#rows[@]}" -eq 0 ]; then
        exit 0
    fi

    # the tray list keeps icons (name + per-row icon)
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
        continue   # "Go Back" at the root -> show the tray list again
    else
        exit 0     # action triggered or cancelled -> done
    fi
done
