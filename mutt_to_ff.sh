#!/bin/bash
#
# mutt_to_ff.sh
#
# This script is used by mutt to display text/html in firefox.
#
# Setup
# =====
#
# Add this line to ~/.mailcap.
#
#   text/html; /root/bin/mutt_to_ff.sh %s; needsterminal;
#
# Notes:
#
# Mutt handles attachments by creating a tmp file, eg
# /tmp/mutt/muttcyDE60 The name of the file is passed to the mailcap
# line as %s. That name gets passed to this script as the first
# parameter, $1. As soon as this script is complete, mutt deletes the
# tmp file. Thus, make a copy of it first so firefox can open it.

filename=${1##*/}
tmp_dir=/tmp/tools/mutt
mkdir -p $tmp_dir
cp $1 $tmp_dir
firefox -new-window ${tmp_dir}/${filename} > /dev/null &
