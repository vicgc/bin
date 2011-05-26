#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] filename

This script prints a cleaned up version of a filename. See notes.

OPTIONS:

    -d  Scrub all subdirectory names as well.
    -h  Print this help message.

EXAMPLES:

    $0 "/My Videos/Pulp Fiction [@xvid] - 2008.txt"

    # Prints:
    /my_videos/pulp_fiction_xvid_2008.txt

NOTES:

    This script does not rename a file. It simply takes a filename and prints a
    cleaned up version of the filename. Use file_rename.sh to rename files.

    The script performs the following formats.
    * Remove any non-word characters, ie anything not an alpha, digit or
      underscore.
    * Replace hyphens with underscores.
    * Replace whitespace with underscores.
    * Replace multiple underscores with a single underscore.
    * Change all characters to lowercase.

    The filename can include a path. By default only the filename will be
    scrubbed. If the -d options is provided, the path is scrubbed as well.

    If a filename has whitespace, surround it with quotes.
EOF
}

do_dirs=
while getopts "dh" options; do
  case $options in

    d ) do_dirs=1;;
    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))


if [[ "$#" -lt "1" ]]; then
    usage
    exit 1
fi

filename="$1"

dir=
base="$filename"
if [[ -z $do_dirs ]]; then
    dir=$(dirname "$filename")
    base=$(basename "$filename")
fi
scrubbed=$(echo "$base" |    sed -e 's/\s/_/g' \
                    -e 's/-/_/g' \
                    -e 's/[_]\+/_/g' \
                    -e 's/[^0-9A-Za-z_./]//g'  | \
                    tr "[[:upper:]]" "[[:lower:]]")

if [[ -z $do_dirs ]]; then
    echo "$dir/$scrubbed"
else
    echo "$scrubbed"
fi
