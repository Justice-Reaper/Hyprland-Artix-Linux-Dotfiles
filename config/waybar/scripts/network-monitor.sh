#!/bin/bash

ip monitor address | while read -r _; do
    pkill -SIGRTMIN+14 waybar
    pkill -SIGRTMIN+15 waybar
done
