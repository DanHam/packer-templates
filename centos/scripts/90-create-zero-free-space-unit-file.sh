#!/usr/bin/env bash
#
# Create a systemd unit file to zero out free space in all filesystems
# in preparation for disk defrag and shrink utilities provided by some
# virtualisation platforms

# Packer logging
echo "Creating systemd unit file to run zero free space service..."

UNIT_FILE_LOCATION="/etc/systemd/system/zero-free-space.service"
UNIT="${UNIT_FILE_LOCATION##*/}"

# The location of the script is specified in the Packer configuration
# template and exported as an environment variable
ZERO_SCRIPT_LOCATION="${ZERO_SCRIPT_UPLOAD_PATH}"

# Write the unit file
printf "%s" "\
[Unit]
Description=Zero out all free space in filesystems
Before=shutdown.target reboot.target halt.target
# Before and After work in reverse at shutdown so here we are specifying
# that zero-free-space must run AFTER the listed services
Before=packer-virt-sysprep.service remove-packer-user.service
Requires=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
# Increase the timeout limit as zeroing out large filesystems takes time
TimeoutStopSec=10m
ExecStart=/bin/true
# Run the script to zero out all free space on filesystems
ExecStop=${ZERO_SCRIPT_LOCATION}
# Remove the script after running
ExecStop=/bin/rm -f ${ZERO_SCRIPT_LOCATION}
# Remove and disable this unit on first run
ExecStop=/usr/bin/find /etc/systemd/system/ -name ${UNIT} \
    -exec /bin/rm -f '{}' \;

[Install]
WantedBy=multi-user.target
" >${UNIT_FILE_LOCATION}

# Make systemd aware of the newly created unit
systemctl daemon-reload
# Start the service
systemctl start ${UNIT} >/dev/null 2>&1

# The script to zero out free space should have been uploaded by Packer
# in a previous step. We need to ensure that it is executable.
if [ -e ${ZERO_SCRIPT_LOCATION} ]; then
    chmod u+x ${ZERO_SCRIPT_LOCATION}
else
    echo "ERROR Zero free space script missing: ${ZERO_SCRIPT_LOCATION}"
    exit -1
fi

exit 0
