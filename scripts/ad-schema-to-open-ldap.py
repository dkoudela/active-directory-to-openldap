#!/usr/bin/python

import argparse
import sys
from ldif import LDIFParser, LDIFWriter

class OpenLdapSchemaWriter:
    # Resources: 
    #  https://technet.microsoft.com/en-us/library/cc961740.aspx
    #  https://github.com/jelmer/samba/blob/master/source4/setup/schema-map-openldap-2.3
    mapMSSyntaxToOpenLdap = {
        '2.5.5.1'  : '1.3.6.1.4.1.1466.115.121.1.12', # DN
        '2.5.5.2'  : '1.3.6.1.4.1.1466.115.121.1.44', # OID -> Printable String
        '2.5.5.3'  : '1.3.6.1.4.1.1466.115.121.1.44', # Case-sensitive string (a.k.a. case-exact string) -> Printable String
        '2.5.5.4'  : '1.3.6.1.4.1.1466.115.121.1.44', # Case-ignore string (teletex) -> Printable String
        '2.5.5.5'  : '1.3.6.1.4.1.1466.115.121.1.15', # Printable String -> Directory String
        '2.5.5.6'  : '1.3.6.1.4.1.1466.115.121.1.36', # Numeric String
        '2.5.5.7'  : '1.3.6.1.4.1.1466.115.121.1.15', # OR Name -> Directory String
        '2.5.5.8'  : '1.3.6.1.4.1.1466.115.121.1.7',  # Boolean
        '2.5.5.9'  : '1.3.6.1.4.1.1466.115.121.1.27', # INTEGER
        '2.5.5.10' : '1.3.6.1.4.1.1466.115.121.1.40', # Octet String
        '2.5.5.11' : '1.3.6.1.4.1.1466.115.121.1.24', # UTC TIME -> General Time
        '2.5.5.12' : '1.3.6.1.4.1.1466.115.121.1.15', # Directory String
        '2.5.5.13' : '1.3.6.1.4.1.1466.115.121.1.43', # Presentation Address
        '2.5.5.14' : '1.3.6.1.4.1.1466.115.121.1.40', # DN with Unicode string -> Octet String
        '2.5.5.15' : '1.3.6.1.4.1.1466.115.121.1.40', # Windows NT security descriptor -> Octet String
        '2.5.5.16' : '1.3.6.1.4.1.1466.115.121.1.27', # Large integer (a.k.a. INTEGER8) -> INTEGER
        '2.5.5.17' : '1.3.6.1.4.1.1466.115.121.1.40'  # Octet String (again)
    }

    # Resources: 
    #  https://msdn.microsoft.com/en-us/library/ms679014%28v=vs.85%29.aspx
    mapMSObjectClassCategoryToOpenLdapKind = {
        '0' : 'STRUCTURAL', # Class 88 -> STRUCTURAL
        '1' : 'STRUCTURAL', # Structural
        '2' : 'ABSTRACT',   # Abstract
        '3' : 'AUXILIARY'   # Auxiliary
    }

    def __init__(self, output):
        self.output = output

    def __mapSyntax(self, syntax):
        return self.mapMSSyntaxToOpenLdap[syntax]

    def __mapClassCategory(self, category):
        return self.mapMSObjectClassCategoryToOpenLdapKind[category]

    def __writeAttributeType(self, dn, entry):
        singlevalue = 'SINGLE-VALUE' if str(entry['isSingleValued'][0]).lower() == 'true' else ''
        syntax = self.__mapSyntax(entry['attributeSyntax'][0])
        atributetype = 'attributetype ( %s\n NAME \'%s\'\n DESC \'%s\'\n SYNTAX %s\n %s )\n\n' % (
            entry['attributeID'][0], entry['lDAPDisplayName'][0], entry['lDAPDisplayName'][0], syntax, singlevalue)
        self.output.write(atributetype)
        return

    def __writeObjectclassType(self, dn, entry):
        must = ''
        may = ''
        if 'systemMustContain' in entry.keys():
            for index, mustAttribute in enumerate(entry['systemMustContain']):
                if index < 1:
                    must = 'MUST ( ' + mustAttribute
                elif (index % 4) == 0:
                    must = must + " $\n    " + mustAttribute
                else:
                    must = must + " $ " + mustAttribute
            must = must + ' )\n'
        if 'systemMayContain' in entry.keys():
            for index, mayAttribute in enumerate(entry['systemMayContain']):
                if index < 1:
                    may = 'MAY ( ' + mayAttribute
                elif (index % 4) == 0:
                    may = may + " $\n    " + mayAttribute
                else:
                    may = may + " $ " + mayAttribute
            may = may + ' )\n'
        category = self.__mapClassCategory(entry['objectClassCategory'][0])
        objectclass = 'objectclass ( %s\n NAME \'%s\'\n SUP \'%s\'\n %s\n %s %s )\n\n' % (
            entry['governsID'][0], entry['lDAPDisplayName'][0], entry['subClassOf'][0], category, must, may )
        self.output.write(objectclass)
        return

    def construct(self, dn, entry):
        if 'objectClass' not in entry.keys():
            print 'DN without objectClass: ' + dn
            return
        if 'attributeSchema' in entry['objectClass']:
            self.__writeAttributeType(dn, entry)
        elif 'classSchema' in entry['objectClass']:
            self.__writeObjectclassType(dn, entry)

class ActiveDirectorySchemaLdifExportToOpenLdapSchema(LDIFParser):

    def __init__(self, input, output):
        LDIFParser.__init__(self, input)
        self.writer = OpenLdapSchemaWriter(output)

    def handle(self, dn, entry):
       self.writer.construct(dn, entry)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='',
    )
    parser.add_argument('--src', metavar='SOURCE', help='Source ldif')
    parser.add_argument('--dst', metavar='DESTINATION', help='Destination ldif')
    args = parser.parse_args()

    adparser = ActiveDirectorySchemaLdifExportToOpenLdapSchema(open(args.src, 'rb'), open(args.dst, 'wb'))
    adparser.parse()

