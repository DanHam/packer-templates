#!/usr/bin/env bash
#
# Install the open-vm-tools package for better management and interaction
# with VMware based guest VM's

echo "Installing open-vm-tools..."
yum -y install open-vm-tools > /dev/null

exit 0
