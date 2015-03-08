#!/usr/bin/python

import argparse
import sys
from ldif import LDIFParser, LDIFWriter


class ActiveDirectoryToOpenLdapLDIFConvertor(LDIFParser):
    objectclassAddsBasedOnDN = { 'CN=ExchangeActiveSyncDevices' : 'exchangeActiveSyncDevices'
                               }

    objectclassChangesBasedOnDN = { 'CN=_Template ': { 'user': 'customActiveDirectoryUserTemplate' },
                                    'CN=_Template_': { 'user': 'customActiveDirectoryUserTemplate' },
                                    'CN=_Template\, ': { 'user': 'customActiveDirectoryUserTemplate' }
                                  }

    objectclassMappings = { 'top' : 'mstop', 'user' : 'customActiveDirectoryUser', 'group' : 'customActiveDirectoryGroup',
                            'contact' : 'customActiveDirectoryContact' }

    attributetypesValuesDuplicates = [ 'dSCorePropagationData' ]

    def __init__(self, input, output):
        LDIFParser.__init__(self, input)
        self.writer = LDIFWriter(output)

    def addObjectclassesBasedOnDN(self, dn, entry):
        for objAdd in self.objectclassAddsBasedOnDN:
            if objAdd.lower() in dn.lower(): # case insensitive match
                if 'objectClass' not in entry.keys():        
                    entry['objectClass'] = [ ]
                entry['objectClass'].append(self.objectclassAddsBasedOnDN[objAdd]);

    def changeObjectclassesBasedOnDN(self, dn, entry):
        if 'objectClass' not in entry.keys():
            return
        for objChange in self.objectclassChangesBasedOnDN:
            if objChange.lower() in dn.lower(): # case insensitive match
                for objSource in self.objectclassChangesBasedOnDN[objChange]:
                    index = 0
                    for objTarget in entry['objectClass']:
                        if objSource == objTarget:
                            entry['objectClass'][index] = self.objectclassChangesBasedOnDN[objChange][objSource]
                        index += 1

    def changeObjectclasses(self, dn, entry):
        if 'objectClass' in entry.keys():        
            index = 0
            for objectclass in entry['objectClass']:
                for objMap in self.objectclassMappings:
                    if objMap == objectclass:
                        entry['objectClass'][index] = self.objectclassMappings[objMap]
                index += 1

    def removeDuplicateAttributeValues(self, dn, entry):
        for attributetype in self.attributetypesValuesDuplicates:
            if attributetype in entry.keys():
                entry[attributetype] = list(set(entry[attributetype]))


    def handle(self, dn, entry):
        self.addObjectclassesBasedOnDN(dn, entry)
        self.changeObjectclassesBasedOnDN(dn, entry)
        self.changeObjectclasses(dn, entry)
        self.removeDuplicateAttributeValues(dn, entry)
        self.writer.unparse(dn, entry)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='',
    )
    parser.add_argument('--src', metavar='SOURCE', help='Source ldif')
    parser.add_argument('--dst', metavar='DESTINATION', help='Destination ldif')
    args = parser.parse_args()

    adparser = ActiveDirectoryToOpenLdapLDIFConvertor(open(args.src, 'rb'), open(args.dst, 'wb'))
    adparser.parse()

