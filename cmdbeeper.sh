#!/bin/bash
#
# cmdbeeper — beep repeatedly until Enter is pressed or a timer elapses
# Copyright (C) 2026  Diego Fernández
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

VERSION=1.0.0

# Child and child cleanup routines
loop_sound () {
    local ret=0

    trap 'pkill -P $BASHPID 2>/dev/null; wait; exit $ret' SIGTERM
    
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
    wait $loop_pid 2>/dev/null
    exit
}

# --version command
if [[ "$1" == "--version" ]]; then
    echo "cmdbeeper $VERSION"
    echo "Copyright (C) 2026 Diego Fernández"
    echo "License GPLv3+: GNU GPL version 3 or later <https://www.gnu.org/licenses/gpl-3.0.html>"
    echo
    echo "This is free software: you are free to change and redistribute it."
    echo "There is NO WARRANTY, to the extent permitted by law."
    exit 0
fi

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
            ;;
        i) 
            CMDBEEPER_INTERVAL=$OPTARG ;;
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

# Default interval + check format
if [[ ! -v CMDBEEPER_INTERVAL ]]; then
    CMDBEEPER_INTERVAL=0
elif [[ -v CMDBEEPER_INTERVAL && ! $CMDBEEPER_INTERVAL =~ ^[0-9]+$ ]]; then
    echo "${0}: interval must be a positive integer"
    exit 1
fi

# Suppress or output text depending on whether silent mode is on
if [[ -v CMDBEEPER_QUIET ]]; then
    output_text=$'\n'
else
    output_text=$'Press Enter to stop...\n'
fi

# Check timer format correctness
if [[ -v CMDBEEPER_TIMER && ! $CMDBEEPER_TIMER =~ ^[0-9]+$ ]]; then
    echo "${0}: timeout must be a positive integer"
    exit 1
fi

# Exit gracefully on CTRL-C
trap 'cleanup' SIGINT SIGTERM

loop_sound "$CMDBEEPER_TUNE" "$CMDBEEPER_INTERVAL" &
loop_pid=$!

# No timer by default
if [[ -v CMDBEEPER_TIMER ]]; then
    read -r -s -t "$CMDBEEPER_TIMER" -p "${output_text?}"
else
    read -r -s -p "${output_text?}"
fi
cleanup

