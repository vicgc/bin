#!/bin/bash

script=${0##*/}

usage() {

    cat << EOF

    usage: $script

    Suspend laptop when battery remaining is >= 5%

    On a laptop run this script as a cron job
    */5 * * * * $HOME/bin/suspend.sh

EOF
}

if [[ "$#" -ne "0" ]]; then
    usage
    exit 1
fi


battery='-'
bat_dir="/proc/acpi/battery/BAT0"

if [ -d "$bat_dir" ]; then
    remaining="$(awk '/remaining capacity/ {print $3}' <${bat_dir}/state)"
    total="$(awk '/last full capacity/ {print $4}' <${bat_dir}/info)"
    battery_level="$((remaining *100 /total))"
    battery="${battery_level}"
fi

## If battery life is less than 5 percent than suspend
if (( "${battery}" <= 5 )); then
    /usr/sbin/pm-suspend
fi

echo "${battery}"
