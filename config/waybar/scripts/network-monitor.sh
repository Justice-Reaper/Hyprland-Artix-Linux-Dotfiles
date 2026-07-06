#!/bin/bash

ip monitor address | while read -r _; do
    pkill -SIGRTMIN+2 waybar
    pkill -SIGRTMIN+3 waybar
done
