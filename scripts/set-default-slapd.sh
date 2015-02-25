#!/bin/bash

service slapd stop
mkdir -p /etc/openldap/slapd.d.new
slaptest -f `dirname $0`/../slapd.conf -F /etc/openldap/slapd.d.new
chown ldap:ldap /etc/openldap/slapd.d.new -R
chmod 700 /etc/openldap/slapd.d.new
rm -Rf /etc/openldap/slapd.d
mv /etc/openldap/slapd.d.new /etc/openldap/slapd.d
service slapd start

