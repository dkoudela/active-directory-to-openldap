#!/bin/bash

VARNAMES=( ROOTDN ROOTPW ADDADUSERPW DEFAULTADUSERPW )

for VARNAME in "${VARNAMES[@]}"
do
	if [[ ! -z ${!VARNAME} ]]; then
        sed -i "s/^$VARNAME=\".*\"/$VARNAME=\"${!VARNAME}\"/g" /app/config/slapdenv.config
    fi;
done

cd scripts;

./set-default-slapd.sh
./set-content.sh

service slapd stop

LOGLEVEL=${LOGLEVEL:-32768}
SLAPD_ENDPOINTS="${SLAPD_ENDPOINTS:-ldap://*:389 ldaps://*:636}"

/usr/sbin/slapd -h "$SLAPD_ENDPOINTS" -F /etc/openldap/slapd.d -u ldap -g ldap -d $LOGLEVEL