#!/usr/bin/env bash
#
# Configure required ssh server options

# Packer logging
echo "Configuring ssh..."

# Location of sshd configuration file
SSHD_CONF="/etc/ssh/sshd_config"

# Set not to perform reverse hostname lookups for connecting hosts
sed -i -e "/^#*UseDNS/ s/ .*/ no/" \
       -e "s/^#\(UseDNS*\)/\1/" $SSHD_CONF

exit 0
