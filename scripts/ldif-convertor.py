#/usr/bin/env python

import argparse
import sys
from ldif import LDIFParser, LDIFWriter


class ActiveDirectoryToOpenLdapLDIFConvertor(LDIFParser):
    objectclassMappings = { 'top' : 'mstop', 'user' : 'customActiveDirectoryUser' }
    objectclassAddsBasedOnDN = { 'CN=ExchangeActiveSyncDevices' : 'exchangeActiveSyncDevices' }

    def __init__(self, input, output):
        LDIFParser.__init__(self, input)
        self.writer = LDIFWriter(output)

    def changeObjectclasses(self, dn, entry):
        if 'objectClass' in entry.keys():        
            index = 0
            for objectclass in entry['objectClass']:
                for objMap in self.objectclassMappings:
                    if objMap == objectclass:
                        entry['objectClass'][index] = self.objectclassMappings[objMap]
                index += 1

    def addObjectclassesBasedOnDN(self, dn, entry):
        for objAdd in self.objectclassAddsBasedOnDN:
            if objAdd.lower() in dn.lower(): # case insensitive match
                if 'objectClass' not in entry.keys():        
                    entry['objectClass'] = [ ]
                entry['objectClass'].append(self.objectclassAddsBasedOnDN[objAdd]);


    def handle(self, dn, entry):
        self.changeObjectclasses(dn, entry)
        self.addObjectclassesBasedOnDN(dn, entry)
        self.writer.unparse(dn, entry)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='',
    )
    parser.add_argument('--src', metavar='SOURCE', help='Source ldif')
    parser.add_argument('--dst', metavar='DESTINATION', help='Destination ldif')
    args = parser.parse_args()

    parser = ActiveDirectoryToOpenLdapLDIFConvertor(open(args.src, 'rb'), open(args.dst, 'wb'))
    parser.parse()

