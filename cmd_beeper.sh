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

while getopts ":s:t:h" opt; do
    case $opt in
        s) sound=$OPTARG ;;
        t) 
            timer=$OPTARG
            if [[ ! $timer =~ ^[0-9]+$ ]]; then
                echo "${0}: timeout must be a positive integer"
                exit 1
            fi
            ;;
        h)
            echo -e "usage: ${0} [-s sound_file] [-t timeout]\n\n See the man page for more information"
            exit 0
            ;;
        \?) 
            echo "${0}: unknown option -$OPTARG"
            exit 1
            ;;
        :) echo "${0}: -$OPTARG requires an argument"
            exit 1
            ;;
    esac
done

trap 'cleanup' SIGINT SIGTERM

loop_sound "$sound" &

if [[ -v timer ]]; then
    read -r -s -p -t "${timer?}" $'Press Enter to stop...\n'
else
    read -r -s -p $'Press Enter to stop...\n'
fi
cleanup

