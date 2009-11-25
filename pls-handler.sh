#!/bin/bash

usage() {

cat << EOF
usage: $0 filename

This script starts up shoutcasts stream casts in mpd.

NOTES:

    The file is assumed to be shoutcast pls formatted.
EOF
}

while getopts "h" options; do
  case $options in

    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

grep '^File[0-9]*' $1 | sed -e 's/^File[0-9]*=//' | mpc add
mpc play
