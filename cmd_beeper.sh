#!/bin/bash
sound=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga

loop_sound () {
    trap 'kill "$paplay_pid"2>/dev/null; wait; exit 0' SIGTERM
    
    while true; do
        paplay "$1">/dev/null &
        paplay_pid=$!
        wait $paplay_pid
        sleep "$2"
    done
}

cleanup () {
    pkill -P $$ 2>/dev/null
    wait
    exit
}

output_text=$'Press Enter to stop...\n'
interval=0

while getopts ":s:t:i:qh" opt; do
    case $opt in
        s) sound=$OPTARG ;;
        t) 
            timer=$OPTARG
            if [[ ! $timer =~ ^[0-9]+$ ]]; then
                echo "${0}: timeout must be a positive integer"
                exit 1
            fi
            ;;
        
        i) 
            interval=$OPTARG
            if [[ ! $interval =~ ^[0-9]+$ ]]; then
                echo "${0}: interval must be a positive integer"
                exit 1
            fi
            ;;
        q) output_text=$'\n' ;;
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

shift $((OPTIND - 1))
if [[ $# -gt 0 ]]; then
    echo "${0}: unknown option $*" >&2
    exit 1
fi

trap 'cleanup' SIGINT SIGTERM

loop_sound "$sound" "$interval" &

if [[ -v timer ]]; then
    read -r -s -t "$timer" -p "${output_text?}"
else
    read -r -s -p "${output_text?}"
fi
cleanup

