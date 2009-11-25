#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] username

This script will print teksavvy usage stats.

OPTIONS:

-h      Print this help message.

EXAMPLES:

    $0 your_username@teksavvy.com           # Print usage stats.
EOF
}


#
# parse
#
# Sent: usage parameters
# Return: nothing
# Purpose:
#
#   Parse the usage parameters.
#
function parse {

    user=$1
    up=$2
    down=$3
    hours=$4
    total=$5

    return
}


#
# print_usage
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Print the usage stats.
#
function print_usage {

    for param in user total up down hours; do

        value=$(eval echo \$$param)

        if [[ -n $(echo $value | grep '[^0-9.]') ]] ; then
            # string
            printf "%5s: %s\n" $param $value
        else
            # float
            printf "%5s: %6s\n" $param $(printf "%3.2f" $value)
        fi

    done

    return
}


while getopts "h" options; do
  case $options in

    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ "$#" -lt "1" ]]; then
    usage
    exit 1
fi

username=$1

user=
up=
down=
hours=
total=

table=$(w3m -dump "http://www.teksavvy.com/en/gigcheck.asp?ID=7&mID=3&UserName=$username" | grep "^$username")

parse $table

print_usage
