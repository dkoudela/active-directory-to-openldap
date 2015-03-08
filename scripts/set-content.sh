#!/bin/bash

SLAPDENV=`dirname $0`/../config/slapdenv.config
D=`dirname $0`/..
DATALDIFS="${D}/ldif/*.ldif"

source ${SLAPDENV}

for DATALDIF in ${DATALDIFS};
do
  DATALDIFABS=`readlink -f ${DATALDIF} `
  echo "Processing begin: ${DATALDIFABS}"
  if [ ${ADDADUSERPW} == true ]; then
    echo "Adding user passwords: ${DATALDIFABS}"
    python ${D}/scripts/add-default-user-password.py --src=${DATALDIF} --dst=${DATALDIF}.tmp --password=${DEFAULTADUSERPW}
  else
    cp ${DATALDIF} ${DATALDIF}.tmp
  fi
  echo "Converting: ${DATALDIFABS}"
  python ${D}/scripts/ldif-convertor.py --src=${DATALDIF}.tmp --dst=${DATALDIF}.tmp.tmp
  echo "Importing: ${DATALDIFABS}"
  time ldapadd -D "cn=Manager,${ROOTDN}" -y ${D}/passwdfile.conf -f ${DATALDIF}.tmp.tmp
  rm -f ${DATALDIF}.tmp*
  echo "Processing done: ${DATALDIFABS}"
done

