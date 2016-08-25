#!/usr/bin/env bash
#
# Minor fixes for complaints issued by systemd with regard to unit files

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Performing minor fixes to systemd unit file permissions..."

echo "Removing +x permission bit from ebtables.service..." > ${REDIRECT}
chmod -x /usr/lib/systemd/system/ebtables.service

echo "Setting world read on auditd.service since APIs provide info..." > \
     ${REDIRECT}
chmod 0644 /usr/lib/systemd/system/auditd.service

exit 0
