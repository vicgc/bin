#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] filename

This script will permit cleaning up pacman conf files, eg *.conf.pacnew
and *.conf.pacsave.

OPTIONS:

    -l  List existing *.pacnew and *.pacsave files and exit.

    -h  Print this help message.

NOTES:
EOF
}


#
# clean_file
#
# Sent: file
# Return: nothing
# Purpose:
#
#   Execute file cleaning.
#
function clean_file {

    file=$1

    [[ -z $file ]] && return

    # Determine extension of filename

    ext=
    base=${file##*/}
    path=${file%/*}
    case $base in
        *.*) ext=${base##*.} ;;
        *  ) ext= ;;
    esac

    base_conf=${base%.*}

    conf="${path}/${base_conf}"
    conf_new="${path}/${base_conf}.${ext}"

    if [[ ! -e "$conf_new" ]]; then
        echo "Unable to find file $cond_new" >&2
        return
    fi

    while : ; do

        echo ""
        ls -l $conf $conf_new

        diff=$(diff -b -q $conf $conf_new 2>&1)

        case $? in
            0 ) echo -e "${GREEN}Files are identical.${COLOUROFF}";;
            1 ) echo -e "${BROWN}Files differ.${COLOUROFF}";;
            * ) echo -e "${RED}${diff}${COLOUROFF}";;
        esac

        echo ""

        cat <<EOT
Code   Command
d: diff -b ${base_conf} ${base_conf}.${ext}
m:   mv -i ${base_conf}.${ext} ${base_conf}
r:   rm -i ${base_conf}.${ext}
c:      vi ${base_conf}
p:      vi ${base_conf}.${ext}
v: vimdiff ${base_conf} ${base_conf}.${ext}

n: (next file)
x: (exit)
EOT

        read -p "Enter a code: " code

        cmd=
        [[ $code == 'd' ]] && cmd="diff -b $conf $conf_new"
        [[ $code == 'm' ]] && cmd="mv -i $conf_new $conf"
        [[ $code == 'r' ]] && cmd="rm -i $conf_new"
        [[ $code == 'c' ]] && cmd="vim $conf"
        [[ $code == 'p' ]] && cmd="vim $conf_new"
        [[ $code == 'v' ]] && cmd="vimdiff $conf $conf_new"
        [[ $code == 'n' ]] && break
        [[ $code == 'x' ]] && exit 0

        echo ""
        [[ -z $cmd ]] && echo "Invalid code $code" && continue

        echo -e $BLUE $cmd $COLOUROFF
        echo ""
        echo -e -n $GREEN
        eval $cmd
        echo -e -n $COLOUROFF
        echo ""
    done

    return
}


list=
while getopts "hl" options; do
  case $options in

    l ) list='1';;
    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

find_cmd='find -L /boot /etc -name '*.pacnew' -o -name '*.pacsave' | sort'

if [[ -n "$list" ]]; then
    eval $find_cmd
    exit 0
fi

for file in $(eval $find_cmd); do
    clean_file $file
done
