#!/bin/bash

LIMIT_EXCEEDED=3            # Exit status code for when limit exceeded.

usage() {

cat << EOF
usage: $0 [options] username email_address [ email_address ... ]

This script will send a teksavvy usage alert.

OPTIONS:

    -l      Send alert only if total usage exceeds this limit (GB).

    -h      Print this help message.

EXAMPLES:

    $0 your_username@teksavvy.com username@gmail.com             # Email teksavvy usage stats to username@gmail.com
    $0 -l 200 your_username@teksavvy.com pageruser@rogers.com    # Send a page if total usage exceeds 200 GB
    $0 -l 200 your_username@teksavvy.com pageruser@rogers.com username@gmail.com     # Send alert to pager and email

EOF
}

limit=
while getopts "hl:" options; do
  case $options in
    l ) limit=$OPTARG;;
    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ "$#" -lt "2" ]]; then
    usage
    exit 1
fi

username=$1
shift

stats=$(teksavvy_usage.sh $username)

# Remove spaces and decimals from total
total=$(echo "$stats" | awk -F':' '/^total:/ {print $2}' | tr -d " " | sed -e 's/\..*//')

subject='teksavvy usage'
if [[ -n "$limit" ]]; then

    if [[ "$(($total * 100))" -lt "$(($limit * 100))" ]]; then
        # alls good
        exit 0
    fi

    subject="teksavvy usage over ${limit}!"
fi

body="$stats"

while [[ "$1" != "" ]]; do

    to=$1
    res=$(echo -e "To: $to\nSubject: $subject\n\n$stats" | sendmail -v -- $to)
    shift

done

exit $LIMIT_EXCEEDED
