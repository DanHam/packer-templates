#!/usr/bin/env bash
#
# Create a systemd unit file to remove the Packer build user and clean up
# associated files on system shutdown.

# Packer logging
echo "Creating systemd unit file to remove Packer build user..."

UNIT_FILE_LOCATION="/etc/systemd/system/remove-packer-user.service"
UNIT="${UNIT_FILE_LOCATION##*/}"

# Write the unit file
printf "%s" "\
[Unit]
Description=Remove the Packer build user and associated files
Before=shutdown.target reboot.target halt.target
Requires=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/true
ExecStop=/sbin/userdel --force --remove --selinux-user packer
# Delete the passwd, shadow, and group backup files as they will include
# the packer build user, password and group
ExecStop=/usr/bin/rm -f /etc/passwd- /etc/shadow- /etc/group-
ExecStop=/usr/bin/rm -f /etc/sudoers.d/packer
# Remove and disable this unit on first run
ExecStop=/usr/bin/find /etc/systemd/system/ -name ${UNIT} \
    -exec /usr/bin/rm -f '{}' \;

[Install]
WantedBy=multi-user.target
" >${UNIT_FILE_LOCATION}

# Make systemd aware of the newly created unit
systemctl daemon-reload
# Start the service
systemctl start ${UNIT} >/dev/null 2>&1

exit 0
