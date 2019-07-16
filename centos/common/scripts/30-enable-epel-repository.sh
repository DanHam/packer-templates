#!/usr/bin/env bash
#
# Enable the EPEL yum repository
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Enabling the EPEL yum repository..."

if [ "x$(rpm -qa | grep epel-release)" = "x" ]; then
    yum install -y epel-release > ${REDIRECT}
fi

exit 0
