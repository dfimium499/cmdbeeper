#!/bin/bash
sound=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga

loop_sound () {
    trap 'kill "$paplay_pid"; exit' SIGTERM
    
    while true; do
        paplay "$1">/dev/null &
        paplay_pid=$!
        wait $paplay_pid
    done
}

cleanup () {
    pkill -P $$ 2>/dev/null
    exit
}

trap 'cleanup' SIGINT SIGTERM SIGALRM

loop_sound $sound &

read -r -s -p $'Press Enter to stop...\n'
cleanup

