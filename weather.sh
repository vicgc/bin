#!/bin/sh
#--------
# Command line short term and extended weather report for Southern Ontario
# Usage: weather

file=`mkdir -p /tmp/tools && echo /tmp/tools/weather.txt`

res=$(w3m -dump "http://www.weatheroffice.gc.ca/forecast/textforecast_e.html?Bulletin=fpcn11.cwto")
echo "$res" > $file

res=$(w3m -dump "http://www.weatheroffice.gc.ca/forecast/textforecast_e.html?Bulletin=fpcn51.cwto")
echo "$res" >> $file

if [[ -n "$1" ]]; then
    less -i -p"$*" $file
else
    less $file
fi

