#!/bin/bash

usage() {

    cat << EOF

usage: $0 [options] DIRECTORIES

This script removes files and empty directories from selected directories.
Suitable for cleaning up tmp directories.

OPTIONS:

    -d  Run in debug mode.
    -v  Verbose.

    -h  Print this help message.

EXAMPLES:

    $0 /path/to/directory    # Clean /path/to/directory
    $0 /tmp /root/tmp        # Clean several tmp directories

NOTES:

    Directories and files not accessed in last 30 days are removed.
EOF
}


function remove {

    $verbose && echo "Removing file $1"

    $debug && echo "Debug mode, files not removed"
    $debug && return

    [[ -f $1 ]] && rm "$1" && return
    [[ -d $1 ]] && rmdir "$1" && return

    echo "Unable to remove file $1" >&2
    return
}

debug=false
verbose=false

while getopts "dhv" options; do
  case $options in
    d ) debug=true;;
    v ) verbose=true;;
    h ) usage
        exit 0;;
    \? ) usage
         exit 1;;
    * ) usage
          exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ "$#" -lt 1 ]]; then
    usage
    exit 1
fi

file_opts="-ignore_readdir_race -type f -atime +30"
path_opts="-ignore_readdir_race -mindepth 1 -type d -atime +30 -empty"

while [[ "$1" != "" ]]; do

    dir=$1
    $verbose && echo "Cleaning $dir"
    $verbose && echo "Find: find $dir $file_opts"

    # Note: find results are piped into while to prevent foo caused by
    # filenames with spaces in them

    find $dir $file_opts | while read file; do
        $verbose && echo "File: $file"
        remove "$file"
    done

    $verbose && echo "Find: find $dir $path_opts"

    find $dir $path_opts | while read path; do
        $verbose && echo "Path: $path"
        remove "$path"
    done
    shift
done

