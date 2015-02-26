#!/bin/bash

SLAPDCONF=`dirname $0`/../slapd.conf
DATABASEDIR=`sed -n 's/^directory[ \t]*\(.*\)/\1/p' ${SLAPDCONF} `

# Stop the LDAP service
service slapd stop

# Clean the LDAP database
rm -f ${DATABASEDIR}/*
cp `dirname $0`/../DB_CONFIG ${DATABASEDIR}
slapd
killall `which slapd`
sudo chown -R ldap:ldap ${DATABASEDIR}

# Setup the LDAP schema
mkdir -p /etc/openldap/slapd.d.new
slaptest -f ${SLAPDCONF} -F /etc/openldap/slapd.d.new
chown ldap:ldap /etc/openldap/slapd.d.new -R
chmod 700 /etc/openldap/slapd.d.new
rm -Rf /etc/openldap/slapd.d
mv /etc/openldap/slapd.d.new /etc/openldap/slapd.d

# Start the LDAP service
service slapd start

