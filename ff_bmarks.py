#!/usr/bin/python

"""

Convert Firefox bookmarks to vimperator bmark commands.

Usage: ff_bmarks.py path/to/bookmarks.html

This script will read a firefox bookmarks.html file and print commands suitable
for running at the vimperator command line. This permits bookmarks to be easily
shared and imported by other instances of firefox running vimperator.

Example:

    ## Export bookmarks
    $ ff_bmarks.py ~/.mozilla/firefox/XXXXXXXXX/bookmarks.html > /tmp/bmarks.txt

    ## Import bookmarks from within firefox at vimperator command line
    :delbmarks!      # Optional, warning this will remove all existing bookmarks
    :source /tmp/bmarks.txt

"""

import logging
import re
import sys
import time


class File():

    def __init__(self, name=''):
        self.name = name

    def parse(self):
        kw_re = re.compile(r'.*SHORTCUTURL="(.*?)".*')
        title_re = re.compile(r'.*>(.*?)</A>.*')
        href_re = re.compile(r'.*HREF="(.*?)".*')


        logging.debug("Opening file: %s" % self.name)
        fh = open(self.name, 'r')
        line = fh.readline()
        while line:
            out = ''
            kw_match = kw_re.match(line)
            if kw_match:
                out = "%s -keyword=%s" % (out, kw_match.group(1))
            title_match = title_re.match(line)
            if title_match:
                out = "%s -title='%s'" % (out, title_match.group(1))
            href_match = href_re.match(line)
            if href_match:
                out = "%s %s" % (out, href_match.group(1))
            if out:
                out = "bmark %s" % out
                print re.sub(r'\s{2,}', ' ', out)

            line = fh.readline()

        fh.close()


def logging_init(level=None):

    level = level or logging.INFO

    logging.basicConfig(level=level,
                        format='%(asctime)s %(levelname)-8s %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S',
                        stream=sys.stdout,
                        # filename='/root/tmp/proline.log',
                        filemode='w')

def usage():
    print """Usage: ff_bmarks.py [--debug] path/to/bookmarks.html
          """

def main():
    import getopt, sys

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hdv", ["help", "debug", "verbose" ])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err)      # will print something like "option -a not recognized"
        usage()
        sys.exit(2)

    output = None
    verbose = False
    debug = False
    for o, a in opts:
        if o in ("-v", "--verbose"):
            verbose = True
        elif o in ("-d", "--debug"):
            debug = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"

    if not args:
        usage()
        sys.exit(1)

    level = debug and logging.DEBUG or logging.INFO
    logging_init(level)

    logging.debug("Logging at DEBUG level.")
    logging.debug("Args" + str(args))

    file = File(name=args[0])
    file.parse()

if __name__ == '__main__':
    main()

