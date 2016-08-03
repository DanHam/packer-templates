#!/usr/bin/env bash
#
# Install the open-vm-tools package for better management and interaction
# with VMware based guest VM's

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

echo "Installing open-vm-tools..."
yum -y install open-vm-tools > $REDIRECT

exit 0
