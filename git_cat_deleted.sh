#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] filename

This script will print a deleted file from a git repo.

OPTIONS:

    -v  Verbose.

    -h  Print this help message.

NOTES:

    The script assumes the git repo is accessible from the pwd. Change to the
    git repo root directory if not.

    The script has a very basic search algorithm. The script prints the first
    file it finds that matches and was deleted. It searches in order last
    deleted first, ie the order git log prints.

    It prints the version of the file as it was at the time it was deleted.

    All or partial paths to files can be included in the filename to be more
    precise if for example there exists several files of the same name in
    different paths.
EOF
}

verbose=

while getopts "hv" options; do
  case $options in

    v ) verbose="1";;
    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ ! -f ".git/config" ]]; then
    echo "Error: Run this script from the root of a git repo."
    exit 1
fi

filename=$1

if [[ -z $filename ]]; then
    usage
    exit 1
fi

[[ -n "$verbose" ]] && echo "Searching for deleted file: $filename"

#
# In order to preserve variable values, dynamic regexs are used
# See GNU Awks user guide, 7.2 Using Shell Variables in Programs
#

commit_id=$(git log --diff-filter=D --summary | awk -v regex="commit|$filename" '$0 ~ regex ' | grep -B 1 $filename | awk '/^commit/ {print $2}')


if [[ -z $commit_id ]]; then
    echo "Unable to find commit responsible for deleting filename $filename" >&2
    exit 1
fi

[[ -n "$verbose" ]] && echo "File deleted in commit id: $commit_id"


blob_id=$(git log -p -n 1 --full-index ${commit_id} | grep -A3 "diff --git a/$deleted_file " | awk '/^index / { print $2}' | awk -F'.' '{print $1}')

if [[ -z $blob_id ]]; then
    echo "Unable to find blob id representing filename $filename in commit $commit_id" >&2
    exit 1
fi

[[ -n "$verbose" ]] && echo "File stored in blob id: $blob_id"


git cat-file -p $blob_id
