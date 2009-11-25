#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] filename

Permanently delete a file from git repo.

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

filename=$1

if [[ -z $filename ]]; then
    usage
    exit 1
fi

[[ -n "$verbose" ]] && echo "Deleting file: $filename"

# Code from here down was adapted from script on this page.
# http://dound.com/wp/wp-content/uploads/2009/04/git-remove-history
# Author: David Underhill

# remove all paths passed as arguments from the history of the repo
git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch $filename" HEAD

# remove the temporary history git-filter-branch otherwise leaves behind for a long time
rm -rf .git/refs/original/ && git reflog expire --all &&  git gc --aggressive --prune

