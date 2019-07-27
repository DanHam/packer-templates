#!/usr/bin/env bash
#
# Dynamically create the packer-virt-sysprep systemd unit file using
# settings in the packer configuration template
set -o errexit

# Packer logging
echo "Creating packer-virt-sysprep systemd unit file..."

# Unit file
unit_file_location="/etc/systemd/system/packer-virt-sysprep.service"
unit="${unit_file_location##*/}"

# The directory that is to be used to hold all packer-virt-sysprep files
# and operations scripts is specified in the Packer configuration template
# and exported as an environment variable
prefix="${PACKER_VIRT_SYSPREP_DIR}"

# Write the unit file
printf "%s" "\
[Unit]
Description=Virt-sysprep style operations for Packer builds
Before=shutdown.target reboot.target halt.target
Requires=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/true
# Run all required packer-virt-sysprep operations
ExecStop=${prefix}/packer-virt-sysprep-run-ops.sh
# Remove all packer-virt-sysprep scripts; Disable and remove associated
# systemd services upon first use
ExecStop=/bin/rm -rf ${PACKER_VIRT_SYSPREP_DIR}
# Use find/rm to disable and remove the unit file as systemd seems to run
# into problems when systemctl commands are used within a unit file
ExecStop=/usr/bin/find /etc/systemd/system/ -name ${unit} \\
    -exec /bin/rm -f '{}' \;

[Install]
WantedBy=multi-user.target
" >${unit_file_location}

# Start the packer-virt-sysprep service
#
echo "Starting the packer-virt-sysprep service..."

# Make systemd aware of the newly created unit and then start the service
systemctl daemon-reload
systemctl start ${unit} >/dev/null 2>&1

exit 0
