#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] [/path/to/error/file]


This script will print a web2py error file to stdout.

OPTIONS:

    -a  Application
    -p  Purge error file after display.
    -v  Verbose.

    -h  Print this help message.

NOTES:

    The error file argument is optional. If not provided the script will
    attempt to find one relative to the current working directory. If it finds
    more than one, it will select the one with the later timestamp.

    If the error file does not exist, the script will attempt to interpret it as
    the error file application.

    # Full path
    $0 /srv/http/web2py/applications/imdb/errors

    # As application
    $0 imdb

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
path=
if [[ -n "$1" ]]; then
    if [[ -e $1 ]] && [[ ! -d $1 ]]; then
        filename=$1
    else
        app_path="/srv/http/igeejo/web2py/applications/${1}/errors"
        if [[ -d $app_path ]]; then
            path=$app_path
        fi
    fi
fi
if [[ -z $filename ]]; then
    if [[ -z $path ]]; then
        path=$(find . -type d -name errors)
    fi
    filename=$(ls -t1 $path | head -1)
fi

if [[ -z $filename ]]; then
    echo "Unable to determine web2py error file."
    exit 1
fi

web2py_error.py "$path/$filename"

if [[ -n "$purge" ]]; then
    if [[ -n $path ]] && [[ -n $filename ]]; then
        rm -i "$path"/*
    fi
fi
