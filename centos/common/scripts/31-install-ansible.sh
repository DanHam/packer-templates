#!/usr/bin/env bash
#
# Install Ansible from the EPEL yum repository
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Installing required packages for Ansible..."

if [ "x$(rpm -qa | grep ansible)" = "x" ]; then
    yum install -y ansible > ${REDIRECT}
fi

exit 0
