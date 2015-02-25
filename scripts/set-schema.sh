#!/bin/bash

ldapmodify -D "cn=config" -y `dirname $0`/../passwdfile.conf -f `dirname $0`/../ldif/inetperson.schema.ldif
ldapmodify -D "cn=config" -y `dirname $0`/../passwdfile.conf -f `dirname $0`/../ldif/core.schema.ldif

