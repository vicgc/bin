#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] path

This script will rename files as per options.

OPTIONS:

    -d  Dry run. Show results but do not rename files.
    -i  Rename files interactively.
    -r  Remove matching text from file names.
    -s  Scrub file name.

    -h  Print this help message.

NOTES:

    If no options are given, a list of files is printed. No changes are made.

    If the -r and -s options are both given, the remove is done first.

    The -s option requires scrub_filesname.sh
EOF
}

dry_run=
interactive=
remove_text=
scrub=

while getopts "dhir:s" options; do
  case $options in

    d ) dry_run=1;;
    i ) interactive=1;;
    r ) remove_text=$OPTARG;;
    s ) scrub=1;;
    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

path=$1

if [[ -z $path ]]; then
    usage
    exit 1
fi


for file in $path/*; do
    new_file="$file"

    if [[ -n "$remove_text" ]]; then
        new_file=${file/$remove_text/}
    fi

    if [[ -n $scrub ]];then
        new_file=$(~/bin/scrub_filename.sh "$new_file")
    fi

    cmd="mv \"$file\" \"$new_file\""
    echo $cmd

    if [[ -z $dry_run ]]; then
        reply='y'

        if [[ -n $interactive ]]; then
            read -p 'Do it? Y(es) n(o) a(ll) q(uit): ' reply
            [[ -z $reply ]]       && reply='y'
            reply=$( echo "$reply" | tr "[:upper:]" "[:lower:]")
            [[ "$reply" == 'Y' ]] && reply='y'
            [[ "$reply" == 'a' ]] && interactive=
            [[ "$reply" == 'q' ]] && exit 0
        fi

        if [[ "$reply" == 'y' ]]; then
            if [[ "$file" != "$new_file" ]]; then
                mv "$file" "$new_file"
            fi
        fi
    fi;

done

