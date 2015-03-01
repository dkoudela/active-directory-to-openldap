#!/bin/bash

SLAPDENV=`dirname $0`/../config/slapdenv.config
D=`dirname $0`/..
DATALDIFS="${D}/ldif/*.ldif"

source ${SLAPDENV}

for DATALDIF in ${DATALDIFS};
do
  DATALDIFABS=`readlink -f ${DATALDIF} `
  echo "Processing begin: ${DATALDIFABS}"
  echo "Converting: ${DATALDIFABS}"
  python ${D}/scripts/ldif-convertor.py --src=${DATALDIF} --dst=${DATALDIF}.tmp
  echo "Importing: ${DATALDIFABS}"
  ldapadd -D "cn=Manager,${ROOTDN}" -y ${D}/passwdfile.conf -f ${DATALDIF}.tmp
  rm -f ${DATALDIF}.tmp
  echo "Processing done: ${DATALDIFABS}"
done

