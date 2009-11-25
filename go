#!/bin/bash

if [[ -e $HOME/.screen/screenrc.$@ ]] ; then
    ssh -t $@ "LANG=en_CA.utf8 screen -c $HOME/.screen/screenrc.$@ -xRR $@"
else
    ssh -t $@ "LANG=en_CA.utf8 screen -xRR $@"
fi
