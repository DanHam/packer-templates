#!/usr/bin/env bash
#
# Clean up and reconfigure Packer specific settings

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Cleaning up and reconfiguring Packer specific build settings..."

echo "Removing authorised ssh keys from roots dir..." > ${REDIRECT}
[[ -d /root/.ssh ]] && rm -rf /root/.ssh
echo "Removing build artifacts..." > ${REDIRECT}
[[ -e /root/.vbox_version ]] && rm -f /root/.vbox_version

exit 0
