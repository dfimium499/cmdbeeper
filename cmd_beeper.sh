#!/bin/bash

# Child and child cleanup routines
loop_sound () {
    trap 'pkill -P $BASHPID 2>/dev/null; wait; exit 0' SIGTERM
    
    while true; do
        paplay "$1">/dev/null &
        wait $!
        ret=$?

        if [ $ret -ne 0 ]; then
            kill $$
            exit $ret
        fi

        sleep "$2" &
        wait $!
    done
}

cleanup () {
    pkill -P $$ 2>/dev/null
    wait
    exit
}

# Argument parsing: env vars are overridden by explicit flag args
v_flag=false
q_flag=false

t_flag=false
e_flag=false

while getopts ":s:t:i:evqh" opt; do
    case $opt in
        s) CMDBEEPER_TUNE=$OPTARG ;;
        t)
            if $e_flag; then
                echo "${0}: -e and -t flags are incompatible"
                exit 1
            fi
            t_flag=true

            CMDBEEPER_TIMER=$OPTARG
            if [[ ! $CMDBEEPER_TIMER =~ ^[0-9]+$ ]]; then
                echo "${0}: timeout must be a positive integer"
                exit 1
            fi
            ;;
        
        i) 
            CMDBEEPER_INTERVAL=$OPTARG
            if [[ ! $CMDBEEPER_INTERVAL =~ ^[0-9]+$ ]]; then
                echo "${0}: interval must be a positive integer"
                exit 1
            fi
            ;;
        e)
            if $t_flag; then
                echo "${0}: -e and -t flags are incompatible"
                exit 1
            fi
            e_flag=true

            unset CMDBEEPER_TIMER
            ;;
        v) 
            if $q_flag; then
                echo "${0}: -v and -q flags are incompatible"
                exit 1
            fi
            v_flag=true
            unset CMDBEEPER_QUIET
            ;;
        q) 
            if $v_flag; then
                echo "${0}: -v and -q flags are incompatible"
                exit 1
            fi
            q_flag=true
            CMDBEEPER_QUIET=
            ;;
        h)
            echo -e "usage: ${0} [-s sound_file] [-t timeout] [-i interval]\n\n See the man page for more options"
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

# Default tune
if [[ ! -v CMDBEEPER_TUNE ]]; then
    CMDBEEPER_TUNE=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
fi

# Default interval
if [[ ! -v CMDBEEPER_INTERVAL ]]; then
    CMDBEEPER_INTERVAL=0
fi

# Suppress or output text depending on whether silent mode is on
if [[ -v CMDBEEPER_QUIET ]]; then
    output_text=$'\n'
else
    output_text=$'Press Enter to stop...\n'
fi

# Exit gracefully on CTRL-C
trap 'cleanup' SIGINT SIGTERM

loop_sound "$CMDBEEPER_TUNE" "$CMDBEEPER_INTERVAL" &

# No timer by default
if [[ -v CMDBEEPER_TIMER ]]; then
    read -r -s -t "$CMDBEEPER_TIMER" -p "${output_text?}"
else
    read -r -s -p "${output_text?}"
fi
cleanup

