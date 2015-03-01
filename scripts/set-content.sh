#!/bin/bash

SLAPDENV=`dirname $0`/../config/slapdenv.config
D=`dirname $0`/..
DATALDIFS="${D}/ldif/*.ldif"

source ${SLAPDENV}

for DATALDIF in ${DATALDIFS};
do
  echo "Importing: ${DATALDIF}"
  python ${D}/scripts/ldif-convertor.py --src=${DATALDIF} --dst=${DATALDIF}.tmp
  ldapadd -D "cn=Manager,${ROOTDN}" -y ${D}/passwdfile.conf -f ${DATALDIF}.tmp
  rm -f ${DATALDIF}.tmp
done

