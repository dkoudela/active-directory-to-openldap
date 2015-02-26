#!/bin/bash

SLAPDCONF=`dirname $0`/../slapd.conf
SCHEMADIRREL=`dirname $0`/../schema
SCHEMADIR=`readlink -f $SCHEMADIRREL`
SLAPDENV=`dirname $0`/../slapdenv.config
PASSWDFILE=`dirname $0`/../passwdfile.conf

# Generate config files from templates
source ${SLAPDENV}
sed "s/dc=example,dc=com/$ROOTDN/g;s|__SCHEMADIR__|$SCHEMADIR|g;s/^rootpw.*$/rootpw	$ROOTPW/g" ${SLAPDCONF}.template >$SLAPDCONF
printf "${ROOTPW}" > ${PASSWDFILE}

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

