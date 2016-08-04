#!/usr/bin/env bash
#
# Install and configure SELinux utilities
#
# Note that the policycoreutils-restorecond is only available from network
# based repositories.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Logging for packer
echo "Installing and configuring SELinux utilities..."


# Install useful SELinux packages
yum install -y policycoreutils-restorecond \
               policycoreutils-python > ${REDIRECT}

# Ensure the restorecond daemon is set to start at boot
systemctl enable restorecond.service


exit 0
