# Active Directory to OpenLdap
A successful attempt to provide tools and schemas for conversion of Active Directory content to OpenLdap.

## Motivation
User services like Jenkins, Confluence or Upsource are usually integrated with an LDAP service in corporate environments.


Imagine the following situation:
* You have an Active Directory instance with the production data
* You would like to have a second LDAP instance with full data access
* You cannot use an additional Active Directory instance for some reason, like:
  * License costs
  * Not having full admin access to the Active Directory
* You need just:
  * Authenticate the users against the LDAP service
  * Synchronize the user profiles with your user services

In this case, this project is suitable for you.

## Prerequisites
* Installed:
  * openldap-2.4.40
  * openldap-servers-sql-2.4.40
  * openldap-clients-2.4.40
  * openldap-devel-2.4.40
  * python-ldap-2.3.10
  * openldap-servers-2.4.40

## Content
### config directory
It contains the OpenLdap configuration files.

First, you will need to modify ``config/slapdenv.config``
Modify ``ROOTDN`` and ``ROOTPW``; if you need a user LDAP authentication, set ``ADDADUSERPW=true`` and ``DEFAULTADUSERPW``.

If you would like to alter the OpenLdap settings, you should modify ``config/slapd.conf.template``.

### ldif directory
It contains your ldif import files containing your LDAP data.
If you have more than one LDIF file, please ensure the right order (e.g. ``01.ldif``, ``02.ldif``, etc.).

### schema directory
It contains modified OpenLdap schemas merged with Active Directory specifics.

### scripts directory
It contains scripts for OpenLdap setup, LDIF import and Active Directory schema conversion to OpenLdap schemas.

#### set-default-slapd.sh
This is the first script you should execute. It sets the OpenLdap server according to the configuration.

#### set-content.sh
This is the second script you should execute. It imports the data from the LDIFs.

#### ad-schema-to-open-ldap.py
This script converts Active Directory schema LDIF to the OpenLdap schema file. It is just for the reference.
