#!/bin/bash

SLAPDENV=`dirname $0`/../slapdenv.config
D=`dirname $0`/..
DATALDIFS="*.ldif"

source ${SLAPDENV}

for DATALDIF in ${DATALDIFS};
do
  ldapadd -D "cn=Manager,${ROOTDN}" -y ${D}/passwdfile.conf -f ${D}/ldif/${DATALDIF}
done

