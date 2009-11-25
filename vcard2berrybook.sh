#!/bin/bash

usage() {

cat << EOF

usage: $0 [options] file.vcard  path/to/berry/contacts


This script will convert a file containing vcard formatted contacts to
individual contact files suitable for import into the Blackberry.


OPTIONS:

    -r      Reverse. Convert Blackberry contact files into one vcard file.

    -h      Print this help message.

NOTES:

    If the -r option is used the script will convert multiple Blackberry contact
    files into a single file containing vcard formatted contacts. The
    order of the parameters does not change.

    The path to the Blackberry contact files can be absolute or
    relative, but must exist or the script will die.

    Without -r option, any existing Blackberry contact files will be
    deleted.

    With -r option, an existing vcard file will be overwritten.
EOF
}


#
# vcard2berry
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Convert vcard file to Blackberry contact files.
#
function vcard2berry {

    rm ${berry_dir}/*

    count=0
    file=
    saveIFS=$IFS

    IFS=$'\n'
    cat $vcard_file | while read line; do

        [[ -z $line ]] && continue

        start=${line:0:6}

        if [[ $start == 'BEGIN:' ]]; then
            count=$(($count + 1))
            file=$(printf "%05d.txt" $count)
        fi

        [[ -z $file ]] && continue

        echo $line >> ${berry_dir}/${file}

        if [[ $start == 'BEGIN:' ]]; then
            echo 'VERSION:2.1' >> ${berry_dir}/${file}
            echo 'PRODID:-//OpenSync//NONSGML Barry Contact Record//EN' >> ${berry_dir}/${file}
        fi

    done

    # Remove blank/whitespace lines from all files.
    sed -i -e '/^\s*\t*$/d' ${berry_dir}/*

    IFS=$saveIFS

    return
}


#
# berry2vcard
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Convert Blackberry contact files to a vcard file.
#
function berry2vcard {

    cp /dev/null $vcard_file

    for file in ${berry_dir}/*; do
        cat $file | grep -v '^VERSION:' | grep -v '^PRODID:'  >> $vcard_file
        echo '' >> $vcard_file
    done

    return
}


reverse=

while getopts "hr" options; do
  case $options in

    r ) reverse=1;;
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

vcard_file=$1
berry_dir=$2

if [[ ! -d $berry_dir ]]; then
    echo "Invalid directory $berry_dir" >&2
    exit 1
fi

if [[ -z $reverse ]]; then

    if [[ ! -r $vcard_file ]]; then
        echo "Unable to read vcard file $vcard_file" >&2
        exit 1
    fi

    vcard2berry
else
    berry2vcard
fi
