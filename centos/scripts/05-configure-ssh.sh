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


# Set to allow root ssh login with key based auth only (disables password
# based login for root)
sed -i -e "/^#*PermitRootLogin/ s/ .*/ without-password/" \
       -e "s/^#\(PermitRootLogin*\)/\1/" $SSHD_CONF


# Set to disable password based authentication
#
# Annoyingly the sshd_config file has lines with both commented and
# uncommented PasswordAuthentication settings... so delete one.
if grep ^PasswordAuthentication $SSHD_CONF >/dev/null && \
   grep ^#PasswordAuthentication $SSHD_CONF >/dev/null
then
    sed -i '/^#PasswordAuthentication/ d' $SSHD_CONF
fi
# Now process as usual
sed -i -e "/^#*PasswordAuthentication/ s/ .*/ no/" \
    -e "s/^#\(PasswordAuthentication*\)/\1/" $SSHD_CONF

exit 0
