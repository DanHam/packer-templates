#!/usr/bin/env bash
#
# Configure required ssh server options
set -o errexit

# Packer logging
echo "Configuring ssh..."

# Location of sshd configuration file
SSHD_CONF="/etc/ssh/sshd_config"


# Disallow ssh based logins for root
sed -i -e "/^#*PermitRootLogin/ s/ .*/ no/" \
       -e "s/^#\(PermitRootLogin*\)/\1/" $SSHD_CONF


# Set to disable password based authentication
sed -i -e "/^#*PasswordAuthentication/ s/ .*/ no/" \
       -e "s/^#\(PasswordAuthentication*\)/\1/" $SSHD_CONF


# Set not to perform reverse hostname lookups for connecting hosts
cat << EOF >> ${SSHD_CONF}

# Do not perform reverse hostname lookups for connecting guests
UseDNS no
EOF


exit 0
