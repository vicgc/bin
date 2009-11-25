#!/bin/bash

GOOGLE='g'

usage() {

cat << EOF
usage: $0 [options] keyword [ searchwords ]

This script converts a keyword to a url. Optionally it will convert searchwords
into a google search url.

OPTIONS:

    -h  Print this help message.

EXAMPLES:

    ## To start firefox from the command line, and be able to open pages using
    ## bookmark keywords, set up the following.

    ## Create a function, for example in ~/.bashrc
    ff_cli () {
        firefox $(ff_keyword_url.sh $*)  > /dev/null 2>&1
    }

    ## Create a google search bookmark in Firefox
    url: http://www.google.ca/search?q=%s
    keyword: g

    ## Open firefox with a google search from the command line
    $ ff_cli g what is the capital of tasmania

NOTES:

    The first argument is assumed to be a firefox bookmark keyword. If the
    argument not found in firefox bookmarks, it is then assumed to be a
    searchword. The google keyword is then assumed (defined by the variable
    GOOGLE).

    Any arguments after the keyword are assumed to be searchwords and will be
    used in place of the "%s" in the firefox bookmark url.

    The GOOGLE global variable should be set to the keyword for the firefox
    google search bookmark.
EOF
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

keyword=$1

shift

tmpdir='/tmp/tools/sqlite'
mkdir -p $tmpdir

profile=$(cat ~/.mozilla/firefox/profiles.ini | grep Path= | awk -F'=' '{print $2}')
cp /root/.mozilla/firefox/$profile/places.sqlite $tmpdir/
cp /root/.mozilla/firefox/$profile/places.sqlite-journal $tmpdir/

# If keyword has a "://" or a period "." then print the cli parameters
# as is.
for pattern in '://' '\.'; do

    found=$(echo $keyword | grep "$pattern")
    if [[ -n "$found" ]]; then
        echo $keyword $*
        exit 0
    fi
done

bm_url=$(sqlite3 -list $tmpdir/places.sqlite "select mp.url from moz_bookmarks as mb, moz_keywords as mk, moz_places as mp WHERE mk.id=mb.keyword_id AND mp.id=mb.fk and mk.keyword='$keyword'";)

if [[ -z "$bm_url" ]]; then
    # If no keyword was found, then print the equivalent of a google search
    # on the cli parameters.

    bm_url=$(sqlite3 -list $tmpdir/places.sqlite "select mp.url from moz_bookmarks as mb, moz_keywords as mk, moz_places as mp WHERE mk.id=mb.keyword_id AND mp.id=mb.fk and mk.keyword='$GOOGLE'";)
    url=$(echo ${bm_url/\%s/$keyword $*} | sed -e 's/ /%20/g')
else
    url=$(echo ${bm_url/\%s/$*} | sed -e 's/ /%20/g')
fi

echo $url
