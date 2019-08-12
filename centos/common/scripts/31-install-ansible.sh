#!/usr/bin/env bash
#
# Install Ansible from the EPEL yum repository
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Packer logging
echo "Installing required packages for Ansible..."

if ! rpm -qa | grep ansible &>/dev/null; then
    yum install -y ansible > ${redirect}
fi

exit 0
