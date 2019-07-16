#!/usr/bin/env bash
#
# Enable the EPEL yum repository
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Ensuring the EPEL yum repository is enabled..."

if ! rpm -qa | grep epel-release &>/dev/null; then
    yum install -y epel-release > ${REDIRECT}
fi

exit 0
