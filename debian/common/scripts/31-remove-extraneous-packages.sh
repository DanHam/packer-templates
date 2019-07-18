#!/usr/bin/env bash
#
# Remove extraneous packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Removing extraneous packages..."

packages="avahi-autoipd busybox cpp cpp-6 gcc iamerican installation-report \
          laptop-detect make task-laptop"
apt-get --purge autoremove -y ${packages} > ${redirect}

exit 0
