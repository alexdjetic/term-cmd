#!/bin/bash
# Author: Djetic Alexandre
# Date: 31/03/2024
# Description: this script enables LDAP client on Red Hat machine

if [ $EUID -ne 0 ]; then
    echo "require sudo/root access"
    exit 1
fi

# env
LDAP="193.48.127.155"
BASE_DN="ou=uds,dc=agalan,dc=org"
LDAP_USER="djetica"

# Install dependencies
dnf -y install openldap-clients sssd sssd-ldap oddjob-mkhomedir >> /dev/null

if [ $? -eq 0 ]; then
    echo "Dependency installation: OK"
else
    echo "Dependency installation: NOK"
    exit 1
fi

# Select authentication method
authselect select sssd with-mkhomedir --force > /dev/null

if [ $? -eq 0 ]; then
    echo "Authentication mode setup: OK"
else
    echo "Authentication mode setup: NOK"
    exit 1
fi

# Configure sssd.conf
cat << EOF | tee /etc/sssd/sssd.conf >/dev/null
[domain/default]
id_provider = ldap
autofs_provider = ldap
auth_provider = ldap
chpass_provider = ldap
ldap_uri = ldap://$LDAP/
ldap_search_base = $BASE_DN
ldap_id_use_start_tls = True
ldap_tls_cacertdir = /etc/openldap/certs
cache_credentials = True
ldap_tls_reqcert = allow

[sssd]
services = nss, pam, autofs
domains = default

[nss]
homedir_substring = /home
EOF

# Restart sssd (ldap client)
chmod 600 /etc/sssd/sssd.conf 
systemctl restart sssd oddjobd > /dev/null

if [ $? -eq 0 ]; then
    echo "launch ldap client(sssd) success"
else
    echo "aunch ldap client(sssd) failed"
    exit 1
fi

# Check that it works
user_info=$(id "${LDAP_USER}")

if [ $? -eq 0 ]; then
		 echo "Information about ${LDAP_USER}:"
    echo "$user_info"
		 echo "LDAP client setup complete"
			exit 0
else
    echo "No information found for ${LDAP_USER}"
    exit 1
fi

# Enable at startup
systemctl enable sssd oddjobd
echo "sssd added to startup!"
