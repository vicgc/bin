#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] [/path/to/error/file]


This script will print a web2py error file to stdout.

OPTIONS:

    -p  Purge error file after display.
    -v  Verbose.

    -h  Print this help message.

NOTES:

    The error file argument is optional. If not provided the script will
    attempt to find one relative to the current working directory. If it finds
    more than one, it will select the one with the later timestamp.
EOF
}

purge=
verbose=

while getopts "hpv" options; do
  case $options in

    p ) purge=1;;
    v ) verbose=1;;
    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

filename=
if [[ -n "$1" ]]; then
    filename=$1
else
    path=$(find . -type d | grep errors)
    filename=$(ls -t1 $path | head -1)
fi

if [[ -z $filename ]]; then
    echo "Unable to determine web2py error file."
    exit 1
fi

web2py_error.py "$path/$filename"

if [[ -n "$purge" ]]; then
    rm -i "$path/$filename"
fi
