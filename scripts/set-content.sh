#!/bin/bash

SLAPDENV=`dirname $0`/../config/slapdenv.config
D=`dirname $0`/..
DATALDIFS="${D}/ldif/*.ldif"

source ${SLAPDENV}

for DATALDIF in ${DATALDIFS};
do
  ldapadd -D "cn=Manager,${ROOTDN}" -y ${D}/passwdfile.conf -f ${DATALDIF}
done

