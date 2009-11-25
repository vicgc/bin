#!/bin/bash

# Change these variables as required.

# url = the url of the central script that has database access
url="http://www.example.com/access_log__mp.cgi"

# delay = delay time in seconds (normally set to the screensaver's wait time)
delay=${SCREEN_LOCK_WAIT_TIME:-"300"}


# These variables will be set by the script.

username=                   # User identity
post_data=                  # wget --post-data value, eg &username=my_username&in=12345678
reply=y                     # Confirmation reply

now=$(date +%s);            # Current timestamp, unix format
let now_delay=$now-$delay


#
# confirm
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#     Confirm recording scans.
#
#     The reply variable is set according to the response.
#
function confirm {

    reply=

    while [[ "$reply" != "y" &&
            "$reply" != "n"     ]]; do

        echo -n "Record logs (y/n)? "
        read -e reply

        # Convert response to lowercase
        reply=$(echo $reply | tr '[:upper:]' '[:lower:]')

    done
}


#
# usage
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#     Print usage information.
#
function usage {

    cat << EOF
Usage: access_log.sh [options]

Options

-c      Confirm before proceeding.
-h      Print full help.
-i      Log in time (screen wake)
-l      Print most recent screen logs.
-o      Log out time (screen lock)
-r      Convert most recent screen logs to scans.
-R      Like -r but confirm first.
-s      Print most recent recorded scans.

EOF
}


#
# usage_long
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#     Print extended usage information.
#
function usage_extended {

    cat << EOF
EXAMPLES

# Log a screen saver wake.
# The log time is the current time.

access_log.sh -i


# Log a screen saver lock.
# The log time is the current time less the delay.

access_log.sh -o


# Print the last 5 recorded scans

access_log.sh -s 5


# Log a screen saver wake, then convert
# the two most recent logs into scans.

access_log.sh -i -r 2

# Log a screen saver wake, display the last two logs
# then prompt the user to record them.

access_log.sh -i -l 2 && access_log.sh -R 2

ENVIRONMENT

The \$USER environment variable is used to identify the user.
If \$USER is not set, or is set to "root", the \$USERNAME environment variable is used.
If \$USERNAME is not set, or is set to "root", the user cannot be identified.
EOF
}


#
# username
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#     Deteremine the username to identify the user with.
#
#     Logic, $USER is used unless not set or set to "root".
#            $USERNAME is used otherwise unless not set or set to "root".
#            Otherwise, die with error.
#
function username {

    username=${USER}

    if [ -n "$username" ]; then

        if [ "$username" != "root" ]; then
            return
        fi
    fi

    username=${USERNAME}

    if [ -n "$username" ]; then
        if [ "$username" != "root" ]; then
            return
        fi
    fi

    echo "ERROR: Unable to identify user." >&2
    usage
    usage_extended
    exit 1;
}

username
post_data="${post_data}&username=${username}"

while getopts hciol:s:R:r: option; do
    case $option in

    h )
        usage
        usage_extended
        exit 1
        ;;
    c )
        confirm
        ;;
    i )
        post_data="${post_data}&in=${now}"
        ;;
    o )
        post_data="${post_data}&out=${now_delay}"
        ;;
    l )
        post_data="${post_data}&logs=${OPTARG}"
        ;;
    s )
        post_data="${post_data}&scans=${OPTARG}"
        ;;
    R )
        confirm
        post_data="${post_data}&record=${OPTARG}"
        ;;
    r )
        post_data="${post_data}&record=${OPTARG}"
        ;;
    \? )
         usage
         exit 1
         ;;
    * )
         usage
         exit 1
         ;;

    esac
done

if [ "$reply" == "y" ]; then
    wget -q -O - --post-data="$post_data" $url
fi
