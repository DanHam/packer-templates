#!/usr/bin/env bash
#
# Install Ansible from the Ubuntu PPA
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Logging for packer
echo "Installing required packages for Ansible..."

DEBIAN_FRONTEND="noninteractive" apt-get -y install ansible > ${REDIRECT}

exit 0
