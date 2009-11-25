#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] filename

Print a summary list of files deleted from a git repo.

OPTIONS:

    -v  Verbose.

    -h  Print this help message.

NOTES:

The script assumes the git repo is accessible from the pwd. Change to the git
repo root directory if not.

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

## Get all commits that include a delete.
commit_ids=$(git log --diff-filter=D --summary | grep '^commit ' | awk '{ print $2}')

for commit_id in $commit_ids; do
    deleted_files=$(git log -n 1 --name-status $commit_id | grep '^D[[:space:]]' | awk '{print $2}')
    for deleted_file in $deleted_files; do
        blob_id=$(git log -p -n 1 --full-index ${commit_id} | grep -A3 "diff --git a/$deleted_file " | awk '/^index / { print $2}' | awk -F'.' '{print $1}')
        if [[ -n $blob_id ]]; then
            object_size=$(git cat-file -s $blob_id)
        else
            echo "unable to find blob id for"
            echo "commit: $commit_id"
            echo "file: $deleted_file"
            continue
        fi
        date=$(git log -n 1 --date=iso | grep '^Date:' | awk '{ print $2, $3}')
        printf "%10s %s %s %s %s\n" \
        "$object_size" "$date" "$deleted_file" "$blob_id" "$commit_id"
    done
done
