#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] path

This script will rename files as per options.

OPTIONS:

    -d  Dry run. Show results but do not rename files.
    -i  Rename files interactively.
    -r  Recursive.
    -x  Remove matching text from file names.
    -s  Scrub file name.

    -h  Print this help message.

NOTES:

    If no options are given, a list of files is printed. No changes are made.

    If the -x and -s options are both given, the remove is done first.

    The -s option requires scrub_filesname.sh

    A file will not be renamed if an existing file with the new name already
    exists.
EOF
}

dry_run=
interactive=
recursive=
remove_text=
scrub=

while getopts "dhirsx:" options; do
  case $options in

    d ) dry_run=1;;
    i ) interactive=1;;
    r ) recursive=1;;
    x ) remove_text=$OPTARG;;
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

if [[ -z "$path" ]]; then
    usage
    exit 1
fi

# Remove spaces from Internal Field Separator
saveIFS=$IFS
IFS=$'\n'
maxdepth=1
[[ -n $recursive ]] && maxdepth=99999
find $1 -depth -maxdepth $maxdepth | while read file; do
    new_file="$file"

    if [[ -n "$remove_text" ]]; then
        new_file=${new_file/$remove_text/}
    fi

    if [[ -n $scrub ]];then
        new_file=$(~/bin/scrub_filename.sh "$new_file")
    fi

    cmd="mv -n \"$file\" \"$new_file\""
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
                if [[ -e "$new_file" ]]; then
                    echo "Refusing to clobber $new_file" >&2
                else
                    mv -n "$file" "$new_file"
                fi
            fi
        fi
    fi;

done
IFS=$saveIFS
