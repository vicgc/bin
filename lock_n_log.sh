#!/bin/bash

usage() {

cat << EOF
usage: $0 [options]

This script will lock the screen after a period of inactivity, and permit
the logging of wake and lock times.

OPTIONS:
-f      Fork process (detach).
-d      Delay lock.
-v      Verbose.

-h      Print this help message.

NOTES:

The script runs as a daemon with the -f option.

Generally, only one version of this script should be run at any given time. The
forked process will kill any existing processes running the script.

This script calls access_log.sh to handle logging wake and lock times.

The default delay time is determined by the SCREEN_LOCK_WAIT_TIME environmental
variable. If the variable is not set 300 seconds is used.

The -d delay option can be used to delay operation of the screen lock. This handy
for example when watching a video. The script will sleep for the delay time and
then begin normal operation.

# Delay lock for 1 hour.
Eg. $0 -d 3600 -f
EOF
}


#
# fork
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Fork (detach) the script.
#
# Notes:
#
#   A fork simply retarts this script in the background
#   using setsid with all arguments except the fork option
#   and then exits.
#
function fork {

    cmd=$( echo "$0 $args" | sed -e "s/ -f//" | sed -e "s/ -v//")          # Remove fork and verbose options.

    [[ -n $verbose ]] && echo "Forking... $cmd"

    /usr/bin/setsid $cmd <&- >&- &                      # Close stdin/stdout and run in background.

    exit 0
}


fork=0
delay=0
verbose=
wait=${SCREEN_LOCK_WAIT_TIME:-"300"}
slock_status_file="${HOME}/.weechat/slock_status"

args="$*"

while getopts "hd:fv" options; do
  case $options in
    d ) delay=$OPTARG;;
    f ) fork=1;;
    v ) verbose="1";;
    h ) usage
        exit 0;;
    \? ) usage
         exit 1;;
    * ) usage
          exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ "$fork" -eq "1" ]]; then
    fork
fi

for pid in $(pgrep lock_n_log.sh);
do

    # $$ is the current process id. Don't kill it!

    if [ "$pid" -eq "$$" ];
    then
        continue;
    fi

    kill -9 $pid
done

[[ -n $verbose ]] && echo "Delay time: $delay seconds";
[[ -n $verbose ]] && echo "Wait time: $wait seconds";

sleep ${delay}s

while true; do
    sinac -w $wait
    access_log.sh -o
    res=$(echo 'locked' > $slock_status_file)
    slock
    res=$(echo 'unlocked' > $slock_status_file)
    urxvt -e bash -c "access_log.sh -i -l 2; echo; access_log.sh -R 2";
done
