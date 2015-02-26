#!/bin/bash

D=`dirname $0`/..
SLAPDCONFTEMPLATE=${D}/config/slapd.conf.template
DBCONFIG=${D}/config/DB_CONFIG
SLAPDCONF=${D}/slapd.conf
SCHEMADIRREL=${D}/schema
SCHEMADIR=`readlink -f $SCHEMADIRREL`
SLAPDENV=${D}/config/slapdenv.config
PASSWDFILE=${D}/passwdfile.conf

# Generate config files from templates
source ${SLAPDENV}
sed "s/dc=example,dc=com/$ROOTDN/g;s|__SCHEMADIR__|$SCHEMADIR|g;s/^rootpw.*$/rootpw	$ROOTPW/g" ${SLAPDCONFTEMPLATE} >${SLAPDCONF}
printf "${ROOTPW}" > ${PASSWDFILE}

DATABASEDIR=`sed -n 's/^directory[ \t]*\(.*\)/\1/p' ${SLAPDCONF} `

# Stop the LDAP service
service slapd stop

# Clean the LDAP database
rm -f ${DATABASEDIR}/*
cp ${DBCONFIG} ${DATABASEDIR}
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

