#!/usr/bin/python

"""
Format and print a web2py error file to stdout.
"""

from optparse import OptionParser
import cPickle

def main():

    usage = "%prog [options] /path/to/error/file"

    parser = OptionParser(usage=usage)

    parser.add_option("-v", "--verbose",
                     action="store_true", dest="verbose", default=False,
                     help="print messages to stdout")

    (options, args) = parser.parse_args()

    if not len(args) > 0:
        parser.print_usage()
        quit(code=1)

    for file in args:
        fh = open(file)
        data = cPickle.load(fh)
        fh.close

        for k in data.keys():
            print "%s: %s" % ( k, data[k])

    quit(code=0)

if __name__ == "__main__":
    main()
