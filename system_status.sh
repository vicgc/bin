#!/bin/bash
#
# system_status.sh
#
# This script prints system status values to stdout, suitable for dwm status bar.
#
# Prints:
#   * Number of unread emails
#   * Number of unread jabber messages
#   * Battery level
#   * CPU temperature
#   * Date and time
#
# Usage:
#
#    ## In ~/.xinitrc
#
#        while : ; do
#            xsetroot -name "$($HOME/bin/system_status.sh 2>/dev/null)"
#            sleep 5
#        done &
#        exec dwm
#

mail='-';
jabber='-';
battery='-';
temperature='-';
bat_dir="/proc/acpi/battery/BAT0";
temp_dir="/proc/acpi/thermal_zone/THRC/temperature";

if [[ $HOSTNAME == "donkey" ]]; then
    mail_dir="/root/.mail/inbox/new/";
    jabber_file="/root/.weechat/logs/events";

    ls ${mail_dir} | wc -l > /srv/http/nginx/E.html &
    cat ${jabber_file} | wc -l > /srv/http/nginx/I.html &

    exit 0
fi

if [[ $HOSTNAME == "ltsteve" ]]; then
    temperature=$(cat ${temp_dir} | sed 's/temperature:             //' | sed 's/ //')
fi

if [[ -d "$bat_dir" ]]; then
    remaining="$(awk '/remaining capacity/ {print $3}' <${bat_dir}/state)"
    total="$(awk '/last full capacity/ {print $4}' <${bat_dir}/info)"
    battery_level="$((remaining *100 /total))"
    battery="${battery_level}%"
fi

mail=$(w3m -dump http://donkey/E.html)
jabber=$(w3m -dump http://donkey/I.html)
date=$(date '+%a %d %b %R');

if [[ $HOSTNAME == "ltsteve" ]]; then
    echo "E:${mail} I:${jabber} B:${battery} T:${temperature} [${date}]"
else
    echo "E:${mail} I:${jabber} [${date}]"
fi
