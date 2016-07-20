#!/usr/bin/env bash
#
# Configure required ssh server options

# Packer logging
echo "Configuring ssh..."

# Location of sshd configuration file
SSHD_CONF="/etc/ssh/sshd_config"

# Set not to perform reverse hostname lookups for connecting hosts
cat << EOF >> ${SSHD_CONF}

# Do not perform reverse hostname lookups for connecting guests
UseDNS no
EOF


exit 0
