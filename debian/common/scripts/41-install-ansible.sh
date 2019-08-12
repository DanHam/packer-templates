#!/usr/bin/env bash
#
# Install Ansible from the Ubuntu PPA
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Installing required packages for Ansible..."

DEBIAN_FRONTEND="noninteractive" apt-get -y install ansible > ${redirect}

exit 0
