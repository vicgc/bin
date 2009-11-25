#!/usr/bin/python

"""
This script prints the current value of the X screensave api idle time in
seconds.
"""

from xscreensaver_api import XScreenSaverApi

if __name__ == '__main__':

    xit = XScreenSaverApi()
    idle_time_ms = xit.current('idle')
    print idle_time_ms / 1000
