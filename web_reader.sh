#!/bin/bash
#
# web_reader.sh
#
# Usage: web_reader.sh url
#
# This script downloads a text version of a web page and opens it
# with vim for reading. Vim can format the page nicely, eg set tw=72
# and has a highlighter suitable for reading.
#
# Eg: web_reader.sh http://www.gladwell.com/2006/2006_10_16_a_formula.html
#
# Requires elinks.
#

BROWSER=elinks
# BROWSER=w3m             # w3m was producing redirection errors on some sites

if [[ -z "$1" ]]; then
    echo "Usage: $0 url"
    exit 1
fi

file=`mkdir -p /tmp/tools && echo /tmp/tools/web_reader.txt`

$BROWSER -dump "$1" > $file

vim -R -c "set tw=72" -c "set scrolloff=999" -u ~/.vimrc $file
