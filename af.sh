#!/bin/bash

script=${0##*/}
af=$HOME/doc/af
aflist=$HOME/doc/aflist
aftmp=$HOME/tmp/af.tmp
afexclude=$HOME/doc/afexclude

usage() {

    cat << EOF

    usage: $script

    This script is used to download the most recent archlinux.org forum posts.
    Forum posts being the posts' title along with its URL. It has the ability
    to track which posts the user has viewed and store the unread forum posts
    in a file.

EOF
}

if [[ "$#" -ne "0" ]]; then
    usage
    exit 1
fi

## Check to see if $af is open.  If so exit.
ps a | \
    grep -q "[0-9] vim -c sort /^http/ + /root/doc/af" && exit 0

## Appened to the master list ($aflist) of new posts.
wget -q -O - http://bbs.archlinux.org/search.php?action=show_24h | \
    grep -v stickytext | \
    grep "viewtopic.php?id=" | \
    awk -F'"' '{print $2 $3}' | \
    sed -e 's@</a> <span class=@@' | \
    sed -e 's@viewtopic.php?id=@@' | \
    awk -F'>' '{printf("%06d>%s", $1, $2 "\n")}' >> "$aflist"

sort -r "$aflist" | \
    uniq -w 6 > "$aftmp"

mv "$aftmp" "$aflist"

## Create list of posts which have not been viewed ($af).
grep -v '^[0-9]*#' "$aflist" | \
    sed 's/0*//' | \
    awk -F'>' '{print "http://bbs.archlinux.org/viewtopic.php?id=" $1 " " $2}' >> "$af"

## Add mail headers to $af so it's viewable in mutt.
cat "$af" | \
    sed 1d | \
    awk -v var="$(echo "Date: $(date -R)")" 'BEGIN {print var}{print}' > "$aftmp"

## Run $af through an exclude list ($afexclude) to remove any posts
## which are not of interest.
grep -ivf "$afexclude" "$aftmp" > "$af"

## Mark all posts in $aflist as read
sed -i -e 's/^\([0-999999]*\)>/\1#/g' "$aflist"

## The key binding in mutt
## macro generic,index,pager   E "<shell-escape>vim '-c sort /\^http/' + /root/doc/af<enter>" "unread archlinux forum post titles"
