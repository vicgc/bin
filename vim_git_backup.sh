#!/bin/bash

usage() {

    cat << EOF
usage: $0 FILE GIT_DIRECTORY

This script copies a file to a git repository and commits the current version
of the file.

OPTIONS:

   -h      Print this help message.

EXAMPLES:

    $0 /path/to/file /var/git/vim
    $0 file.txt /var/git/vim

    ## To use as a vim backup, add this line to ~/.vimrc
    autocmd BufWritePre * silent ! /root/bin/vim_git_backup.sh "%:p" /var/git/vim

NOTES:

    If the file path is relative it is assumed relative to the current directory.

    This works for regular files only.

    If using as a backup for vim, at times you may experience noticable pauses
    when saving files as the git repo is updated.

    Requires rsync.
EOF
}


verbose=
while getopts "hv" options; do
  case $options in

    v )  verbose=1;;

    h )  usage
         exit 0;;


    \? ) usage
         exit 1;;

    * )  usage
         exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ "$#" -ne "2" ]]; then
    usage
    exit 1
fi


filename=$(readlink -f $1)          # Convert relative to absolute

[[ -n $verbose ]] && echo "Filename: $filename"

if [[ ! -f $filename ]]; then
    echo "Not a regular file: $filename" >&2
    exit 1
fi

git_dir=$2

if [[ ! -d $git_dir ]]; then
    echo "Directory not found or not a valid directory: $git_dir" >&2
    exit 1
fi

if [[ ! -d $git_dir/.git ]]; then
    echo "Not a git repository: $git_dir" >&2
    exit 1
fi

rsync -aR $filename $git_dir/

cd $git_dir
res=$(git add -u && git add .)

[[ -n $verbose ]] && echo "$res"

res=$(git status -q && git commit -a -m "Vim backup")

[[ -n $verbose ]] && echo "$res"

exit 0
