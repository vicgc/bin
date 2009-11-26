#!/bin/bash

script=${0##*/}

usage() {

    cat << EOF

    usage: $script

    This script is to handle ssh'ing into different hosts running
    GNU screen.

EOF
}

if [[ "$#" -eq "0" ]]; then
    usage
    exit 1
fi


if [[ -e $HOME/.screen/screenrc.$@ ]] ; then
    ssh -t $@ "LANG=en_CA.utf8 screen -c $HOME/.screen/screenrc.$@ -xRR $@"
else
    ssh -t $@ "LANG=en_CA.utf8 screen -xRR $@"
fi
