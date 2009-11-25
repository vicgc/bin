#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] filename

This script prints a cleaned up version of a filename. See notes.

OPTIONS:

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
    * Replace " - " with single underscore.
    * Replace whitespace with underscores.
    * Change all characters to lowercase.

    The filename can include a path. Both the path and filename will be
    scrubbed.

    If a filename has whitespace, surround it with quotes.
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


if [[ "$#" -lt "1" ]]; then
    usage
    exit 1
fi

name=$1

echo $name |    sed -e 's/\s/_/g' \
                    -e 's/_-_/_/g' \
                    -e 's/[^0-9A-Za-z_./]//g'  | \
                    tr "[[:upper:]]" "[[:lower:]]"
