#!/usr/bin/python

import argparse
import sys
from ldif import LDIFParser, LDIFWriter


class ActiveDirectoryDefaultUserSetup(LDIFParser):
    password = ""

    def __init__(self, input, output, password):
        LDIFParser.__init__(self, input)
        self.writer = LDIFWriter(output)
        self.password = password

    def setUserDefaultPassword(self, dn, entry):
        if 'objectClass' not in entry.keys():
            return
        if 'user' in entry['objectClass']:
            entry['userPassword'] = [ self.password ]


    def handle(self, dn, entry):
        self.setUserDefaultPassword(dn, entry)
        self.writer.unparse(dn, entry)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='',
    )
    parser.add_argument('--src', metavar='SOURCE', help='Source ldif')
    parser.add_argument('--dst', metavar='DESTINATION', help='Destination ldif')
    parser.add_argument('--password', metavar='PASSWORD', help='Default User Password')
    args = parser.parse_args()

    adparser = ActiveDirectoryDefaultUserSetup(open(args.src, 'rb'), open(args.dst, 'wb'), args.password)
    adparser.parse()

