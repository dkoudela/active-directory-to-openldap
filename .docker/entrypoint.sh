#!/bin/bash

VARNAMES=( ROOTDN ROOTPW ADDADUSERPW DEFAULTADUSERPW )

for VARNAME in "${VARNAMES[@]}"
do
	if [[ ! -z ${!VARNAME} ]]; then
        sed -i "s/^$VARNAME=\".*\"/$VARNAME=\"${!VARNAME}\"/g" /app/config/slapdenv.config
    fi;
done

cat << EOF > /etc/sasl2/slapd.conf
pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: gssapi
EOF

cat << EOF > /etc/krb5.conf
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = EXAMPLE.COM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 ignore_acceptor_hostname = true

[realms]
EXAMPLE.COM = {
  kdc = localhost
  admin_server = localhost
 }

[domain_realm]
.example.com = EXAMPLE.COM
example.com = EXAMPLE.COM

[dbdefaults]
    ldap_kerberos_container_dn = cn=krbContainer,dc=example,dc=com

[dbmodules]
    openldap_ldapconf = {
        db_library = kldap
        ldap_kdc_dn = "cn=Manager,dc=example,dc=com"

        ldap_kadmind_dn = "cn=Manager,dc=example,dc=com"

        ldap_service_password_file = /etc/krb5kdc/service.keyfile
        ldap_servers = ldaps://example.com
        ldap_conns_per_server = 5
    }
EOF

cat << EOF >> /etc/sysconfig/slapd
KRB5_KTNAME="FILE:/etc/krb5.keytab"
export KRB5_KTNAME
EOF

printf 'secrets\nsecrets\n' | kdb5_util create -r EXAMPLE.COM -s
kadmin.local -q "addprinc -pw secrets root"
kadmin.local -q "addprinc -pw secrets ldap/localhost"
kadmin.local -q "addprinc -pw secrets ldap/$(hostname)"

service krb5kdc restart
service kadmin restart

printf 'secrets\n' | kinit

# test with:
# ldapsearch -H ldap://127.0.0.1 -A -wsecrets -D "cn=Manager,dc=example,dc=com" -Y GSSAPI

kadmin.local -q "ktadd -k /etc/krb5.keytab ldap/localhost@EXAMPLE.COM"
kadmin.local -q "ktadd -k /etc/krb5.keytab ldap/$(hostname)@EXAMPLE.COM"
chown ldap /etc/krb5.keytab

cd scripts;

./set-default-slapd.sh
./set-content.sh

# kdb5_ldap_util -D "cn=Manager,dc=example,dc=com" -w secrets create -subtrees dc=example,dc=com -r EXAMPLE.COM -s -H ldap://127.0.0.1

service slapd stop

LOGLEVEL=${LOGLEVEL:-32768}
SLAPD_ENDPOINTS="${SLAPD_ENDPOINTS:-ldap://*:389 ldaps://*:636}"

/usr/sbin/slapd -h "$SLAPD_ENDPOINTS" -F /etc/openldap/slapd.d -u ldap -g ldap -d $LOGLEVEL